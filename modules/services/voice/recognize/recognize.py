"""Methods for recognizing intents from text."""

import collections.abc
import itertools
import logging
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, MutableSequence, Optional, Tuple

from .expression import Sentence
from .intents import Intent, IntentData, Intents, SlotList
from .models import MatchEntity, UnmatchedEntity, UnmatchedTextEntity
from .string_matcher import MatchContext, MatchSettings, match_expression
from .util import (
    WHITESPACE,
    check_excluded_context,
    check_required_context,
    normalize_text,
    remove_punctuation,
    remove_skip_words,
)

MISSING_ENTITY = "<missing>"

_LOGGER = logging.getLogger()


@dataclass
class RecognizeResult:
    """Result of recognition."""

    intent: Intent
    """Matched intent"""

    intent_data: IntentData
    """Matched intent data"""

    entities: Dict[str, MatchEntity] = field(default_factory=dict)
    """Matched entities mapped by name."""

    entities_list: List[MatchEntity] = field(default_factory=list)
    """Matched entities as a list (duplicates allowed)."""

    response: Optional[str] = None
    """Key for intent response."""

    context: Dict[str, Any] = field(default_factory=dict)
    """Context values acquired during matching."""

    unmatched_entities: Dict[str, UnmatchedEntity] = field(default_factory=dict)
    """Unmatched entities mapped by name."""

    unmatched_entities_list: List[UnmatchedEntity] = field(default_factory=list)
    """Unmatched entities as a list (duplicates allowed)."""

    text_chunks_matched: int = 0
    """Number of literal text chunks that were successfully matched."""

    intent_sentence: Optional[Sentence] = None
    """Sentence template that was matched."""

    intent_metadata: Optional[Dict[str, Any]] = None
    """Metadata from the intent sentence that was matched."""


def recognize(
    text: str,
    intents: Intents,
    slot_lists: Optional[Dict[str, SlotList]] = None,
    expansion_rules: Optional[Dict[str, Sentence]] = None,
    skip_words: Optional[List[str]] = None,
    intent_context: Optional[Dict[str, Any]] = None,
    default_response: Optional[str] = "default",
    allow_unmatched_entities: bool = False,
    language: Optional[str] = None,
) -> Optional[RecognizeResult]:
    """Return the first match of input text/words against a collection of intents.

    text: Text to recognize
    intents: Compiled intents
    slot_lists: Pre-defined text lists, ranges, or wildcards
    expansion_rules: Named template snippets
    skip_words: Strings to ignore in text
    intent_context: Slot values to use when not found in text
    default_response: Response key to use if not set in intent
    allow_unmatched_entities: True if entity values outside slot lists are allowed (slower)
    language: Optional language to use when converting digits to words

    Returns the first result.
    If allow_unmatched_entities is True, you should check for unmatched entities.
    """
    for result in recognize_all(
        text,
        intents,
        slot_lists=slot_lists,
        expansion_rules=expansion_rules,
        skip_words=skip_words,
        intent_context=intent_context,
        default_response=default_response,
        allow_unmatched_entities=allow_unmatched_entities,
        language=language,
    ):
        return result

    return None


def recognize_all(
    text: str,
    intents: Intents,
    slot_lists: Optional[Dict[str, SlotList]] = None,
    expansion_rules: Optional[Dict[str, Sentence]] = None,
    skip_words: Optional[Iterable[str]] = None,
    intent_context: Optional[Dict[str, Any]] = None,
    default_response: Optional[str] = "default",
    allow_unmatched_entities: bool = False,
    language: Optional[str] = None,
) -> Iterable[RecognizeResult]:
    """Return all matches for input text/words against a collection of intents.

    text: Text to recognize
    intents: Compiled intents
    slot_lists: Pre-defined text lists, ranges, or wildcards
    expansion_rules: Named template snippets
    skip_words: Strings to ignore in text
    intent_context: Slot values to use when not found in text
    default_response: Response key to use if not set in intent
    allow_unmatched_entities: True if entity values outside slot lists are allowed (slower)
    language: Optional language to use when converting digits to words

    Yields results as they're matched.
    If allow_unmatched_entities is True, you should check for unmatched entities.
    """
    text = normalize_text(remove_punctuation(text)).strip()

    if skip_words is None:
        skip_words = intents.skip_words
    else:
        # Combine skip words
        skip_words = list(itertools.chain(skip_words, intents.skip_words))

    if skip_words:
        text = remove_skip_words(text, skip_words, intents.settings.ignore_whitespace)

    text_keywords = text.split()

    if slot_lists is None:
        slot_lists = intents.slot_lists
    else:
        # Combine with intents
        slot_lists = {**intents.slot_lists, **slot_lists}

    if slot_lists is None:
        slot_lists = {}

    if expansion_rules is None:
        expansion_rules = intents.expansion_rules
    else:
        # Combine rules
        expansion_rules = {**intents.expansion_rules, **expansion_rules}

    if intent_context is None:
        intent_context = {}

    # Filter intents based on context and keywords
    available_intents: MutableSequence[
        Tuple[Intent, IntentData, MatchSettings, Optional[List[Sentence]]]
    ] = []

    for intent in intents.intents.values():
        for intent_data in intent.data:
            if (
                intent_data.required_keywords
                and intent_data.required_keywords.isdisjoint(text_keywords)
            ):
                # No keyword overlap
                continue

            if intent_context:
                # Skip sentence templates that can't possibly be matched due to
                # requires/excludes context.
                #
                # Additional context can be added during matching, so we can
                # only be sure about keys that exist right now.
                if intent_data.requires_context and (
                    not check_required_context(
                        intent_data.requires_context,
                        intent_context,
                        allow_missing_keys=True,
                    )
                ):
                    continue

                if intent_data.excludes_context and (
                    not check_excluded_context(
                        intent_data.excludes_context, intent_context
                    )
                ):
                    continue

            match_settings = MatchSettings(
                slot_lists={
                    **slot_lists,
                    **intent_data.slot_lists,
                },
                expansion_rules={
                    **expansion_rules,
                    **intent_data.expansion_rules,
                },
                ignore_whitespace=intents.settings.ignore_whitespace,
                allow_unmatched_entities=allow_unmatched_entities,
                language=language or intents.language,
            )

            available_intents.append((intent, intent_data, match_settings, None))

    # Filter with regex
    if intents.settings.filter_with_regex and (not allow_unmatched_entities):
        matching_intents: MutableSequence[
            Tuple[Intent, IntentData, MatchSettings, Optional[List[Sentence]]]
        ] = []

        for intent, intent_data, match_settings, _intent_sentences in available_intents:
            if not intent_data.settings.filter_with_regex:
                # All sentences
                matching_intents.append((intent, intent_data, match_settings, None))
                continue

            matching_intent_sentences = []
            for intent_sentence in intent_data.sentences:
                # Compile to regex once
                intent_sentence.compile(match_settings.expansion_rules)
                assert intent_sentence.pattern is not None

                regex_match = intent_sentence.pattern.match(text)
                if regex_match is not None:
                    matching_intent_sentences.append(intent_sentence)

            if matching_intent_sentences:
                matching_intents.append(
                    (intent, intent_data, match_settings, matching_intent_sentences)
                )

        if matching_intents:
            available_intents = matching_intents

    # Fall back to string matcher
    if intents.settings.ignore_whitespace:
        text = WHITESPACE.sub("", text)
    else:
        # Artifical word boundary
        text += " "

    for intent, intent_data, match_settings, intent_sentences in available_intents:
        if not intent_sentences:
            intent_sentences = intent_data.sentences

        # Check each sentence template
        for intent_sentence in intent_sentences:
            # Create initial context
            match_context = MatchContext(
                text=text,
                intent_context=intent_context,
                intent_sentence=intent_sentence,
                intent_data=intent_data,
            )
            maybe_match_contexts = match_expression(
                match_settings, match_context, intent_sentence
            )
            yield from _process_match_contexts(
                maybe_match_contexts,
                intent,
                intent_data,
                default_response=default_response,
                allow_unmatched_entities=allow_unmatched_entities,
            )


def _merge_match_contexts(
    match_contexts: Iterable[MatchContext], merged_context: MatchContext
) -> MatchContext:
    for match_context in match_contexts:
        if match_context.text:
            # Needed for open wildcards
            merged_context.text = match_context.text

        merged_context.entities.extend(match_context.entities)
        merged_context.intent_context.update(match_context.intent_context)

    return merged_context


def _process_match_contexts(
    match_contexts: Iterable[MatchContext],
    intent: Intent,
    intent_data: IntentData,
    default_response: Optional[str] = None,
    allow_unmatched_entities: bool = False,
) -> Iterable[RecognizeResult]:
    for maybe_match_context in match_contexts:
        # Close any open wildcards or unmatched entities
        final_text = maybe_match_context.text.strip()
        if final_text:
            if unmatched_entity := maybe_match_context.get_open_entity():
                # Consume the rest of the text (unmatched entity)
                unmatched_entity.text += final_text
                unmatched_entity.is_open = False
                maybe_match_context.text = ""
            elif wildcard := maybe_match_context.get_open_wildcard():
                # Consume the rest of the text (wildcard)
                wildcard.text += final_text
                wildcard.value = wildcard.text
                wildcard.is_wildcard_open = False
                maybe_match_context.text = ""

        if not maybe_match_context.is_match:
            # Incomplete match with text still left at the end
            continue

        # Verify excluded context
        if intent_data.excludes_context and (
            not check_excluded_context(
                intent_data.excludes_context,
                maybe_match_context.intent_context,
            )
        ):
            continue

        # Verify required context
        slots_from_context: List[MatchEntity] = []
        if intent_data.requires_context and (
            not _copy_and_check_required_context(
                intent_data.requires_context,
                maybe_match_context,
                slots_from_context,
                allow_unmatched_entities=allow_unmatched_entities,
            )
        ):
            continue

        # Clean up wildcard entities
        for entity in maybe_match_context.entities:
            if not entity.is_wildcard:
                continue

            entity.text = entity.text.strip()
            if isinstance(entity.value, str):
                entity.value = entity.value.strip()

        # Add fixed entities
        entity_names = set(entity.name for entity in maybe_match_context.entities)
        for slot_name, slot_value in intent_data.slots.items():
            if slot_name not in entity_names:
                maybe_match_context.entities.append(
                    MatchEntity(name=slot_name, value=slot_value, text="")
                )

        # Add context slots
        for slot_entity in slots_from_context:
            if slot_entity.name not in entity_names:
                maybe_match_context.entities.append(slot_entity)

        # Return each match
        response = default_response
        if intent_data.response is not None:
            response = intent_data.response

        intent_metadata: Optional[Dict[str, Any]] = None
        if maybe_match_context.intent_data is not None:
            intent_metadata = maybe_match_context.intent_data.metadata

        yield RecognizeResult(
            intent=intent,
            intent_data=intent_data,
            entities={entity.name: entity for entity in maybe_match_context.entities},
            entities_list=maybe_match_context.entities,
            response=response,
            context=maybe_match_context.intent_context,
            unmatched_entities={
                entity.name: entity for entity in maybe_match_context.unmatched_entities
            },
            unmatched_entities_list=maybe_match_context.unmatched_entities,
            text_chunks_matched=maybe_match_context.text_chunks_matched,
            intent_sentence=maybe_match_context.intent_sentence,
            intent_metadata=intent_metadata,
        )


def is_match(
    text: str,
    sentence: Sentence,
    slot_lists: Optional[Dict[str, SlotList]] = None,
    expansion_rules: Optional[Dict[str, Sentence]] = None,
    skip_words: Optional[Iterable[str]] = None,
    entities: Optional[Dict[str, Any]] = None,
    intent_context: Optional[Dict[str, Any]] = None,
    ignore_whitespace: bool = False,
    allow_unmatched_entities: bool = False,
    language: Optional[str] = None,
) -> Optional[MatchContext]:
    """Return the first match of input text/words against a sentence expression."""
    text = normalize_text(remove_punctuation(text)).strip()

    if skip_words:
        text = remove_skip_words(text, skip_words, ignore_whitespace)

    if ignore_whitespace:
        text = WHITESPACE.sub("", text)
    else:
        # Artifical word boundary
        text += " "

    if slot_lists is None:
        slot_lists = {}

    if expansion_rules is None:
        expansion_rules = {}

    if intent_context is None:
        intent_context = {}

    settings = MatchSettings(
        slot_lists=slot_lists,
        expansion_rules=expansion_rules,
        ignore_whitespace=ignore_whitespace,
        allow_unmatched_entities=allow_unmatched_entities,
        language=language,
    )

    match_context = MatchContext(
        text=text,
        intent_context=intent_context,
        intent_sentence=sentence,
    )

    for maybe_match_context in match_expression(settings, match_context, sentence):
        if maybe_match_context.is_match:
            return maybe_match_context

    return None


def _copy_and_check_required_context(
    required_context: Dict[str, Any],
    maybe_match_context: MatchContext,
    slots_from_context: List[MatchEntity],
    allow_unmatched_entities: bool = False,
) -> bool:
    """Check required context and copy slots into new entities."""
    for (
        context_key,
        context_value,
    ) in required_context.items():
        copy_to_slot: Optional[str] = None
        if isinstance(context_value, collections.abc.Mapping):
            # Unpack dict
            # <context_key>:
            #   value: ...
            #   slot: true/false or "name"
            maybe_copy_to_slot = context_value.get("slot")
            if isinstance(maybe_copy_to_slot, str):
                # Slot name provided
                copy_to_slot = maybe_copy_to_slot
            elif maybe_copy_to_slot:
                # True
                copy_to_slot = context_key

            context_value = context_value.get("value")

        actual_value = maybe_match_context.intent_context.get(context_key)
        actual_text = ""
        actual_metadata: Optional[Dict[str, Any]] = None

        if isinstance(actual_value, collections.abc.Mapping):
            # Unpack dict
            actual_text = actual_value.get("text", "")
            actual_metadata = actual_value.get("metadata")
            actual_value = actual_value.get("value")

        if allow_unmatched_entities and (actual_value is None):
            # Look in unmatched entities
            for unmatched_context_entity in maybe_match_context.unmatched_entities:
                if (unmatched_context_entity.name == context_key) and isinstance(
                    unmatched_context_entity, UnmatchedTextEntity
                ):
                    actual_value = unmatched_context_entity.text
                    break

        if actual_value == context_value and context_value is not None:
            # Exact match to context value, except when context value is required and not provided
            if copy_to_slot:
                slots_from_context.append(
                    MatchEntity(
                        name=copy_to_slot,
                        value=actual_value,
                        text=actual_text,
                        metadata=actual_metadata,
                    )
                )
            continue

        if (context_value is None) and (actual_value is not None):
            # Any value matches, as long as it's set
            if copy_to_slot:
                slots_from_context.append(
                    MatchEntity(
                        name=copy_to_slot,
                        value=actual_value,
                        text=actual_text,
                        metadata=actual_metadata,
                    )
                )
            continue

        if (
            isinstance(context_value, collections.abc.Collection)
            and not isinstance(context_value, str)
            and (actual_value in context_value)
        ):
            # Actual value was in context value list
            if copy_to_slot:
                slots_from_context.append(
                    MatchEntity(
                        name=copy_to_slot,
                        value=actual_value,
                        text=actual_text,
                        metadata=actual_metadata,
                    )
                )
            continue

        if allow_unmatched_entities:
            # Create missing entity as unmatched
            has_unmatched_entity = False
            for unmatched_context_entity in maybe_match_context.unmatched_entities:
                if unmatched_context_entity.name == context_key:
                    has_unmatched_entity = True
                    break

            if not has_unmatched_entity:
                maybe_match_context.unmatched_entities.append(
                    UnmatchedTextEntity(
                        name=context_key,
                        text=MISSING_ENTITY,
                        is_open=False,
                    )
                )
        else:
            # Did not match required context
            return False

    return True


def recognize_best(
    text: str,
    intents: Intents,
    slot_lists: Optional[Dict[str, SlotList]] = None,
    expansion_rules: Optional[Dict[str, Sentence]] = None,
    skip_words: Optional[Iterable[str]] = None,
    intent_context: Optional[Dict[str, Any]] = None,
    default_response: Optional[str] = "default",
    allow_unmatched_entities: bool = False,
    language: Optional[str] = None,
    best_metadata_key: Optional[str] = None,
    best_slot_name: Optional[str] = None,
) -> Optional[RecognizeResult]:
    """Find the best result with the following priorities:

    1. The result that has "best_metadata_key" in its metadata
    2. The result that has an entity for "best_slot_name" and longest text
    3. The result that matches the most literal text

    See "recognize_all" for other parameters.
    """
    metadata_found = False
    slot_found = False
    best_results: List[RecognizeResult] = []
    best_slot_quality: Optional[int] = None

    for result in recognize_all(
        text,
        intents,
        slot_lists=slot_lists,
        expansion_rules=expansion_rules,
        skip_words=skip_words,
        intent_context=intent_context,
        default_response=default_response,
        allow_unmatched_entities=allow_unmatched_entities,
        language=language,
    ):
        # Prioritize intents with a specific metadata key
        if best_metadata_key is not None:
            is_metadata = (
                result.intent_metadata is not None
                and result.intent_metadata.get(best_metadata_key)
            )

            if metadata_found and not is_metadata:
                continue

            if (not metadata_found) and is_metadata:
                metadata_found = True

                # Clear builtin results
                slot_found = False
                best_results = []
                best_slot_quality = None

        # Prioritize results with a specific slot
        if best_slot_name:
            entity = result.entities.get(best_slot_name)
            is_slot = (entity is not None) and not entity.is_wildcard

            if slot_found and not is_slot:
                continue

            if (not slot_found) and is_slot:
                slot_found = True

                # Clear non-slot results
                best_results = []

            if is_slot and (entity is not None) and isinstance(entity.value, str):
                # Prioritize results with a better slot value
                slot_quality = len(entity.text)
                if (best_slot_quality is None) or (slot_quality > best_slot_quality):
                    best_slot_quality = slot_quality

                    # Clear worse slot results
                    best_results = []
                elif slot_quality < best_slot_quality:
                    continue

        # Accumulate results. We will resolve the ambiguity below.
        best_results.append(result)

    if best_results:
        # Prioritize matches with fewer wildcards and more literal text matched.
        return sorted(best_results, key=_get_result_score)[0]

    return None


def _get_result_score(result: RecognizeResult) -> Tuple[int, int]:
    """Get sort score for a result with (wildcards, -text_matched).

    text_matched is negated since we are sorting with lowest first.
    """
    num_wildcards = sum(1 for e in result.entities_list if e.is_wildcard)
    return (num_wildcards, -result.text_chunks_matched)
