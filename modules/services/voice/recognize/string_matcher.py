"""Original hassil matcher."""

import logging
import re
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Tuple, Union

from unicode_rbnf import RbnfEngine

from .errors import MissingListError, MissingRuleError
from .expression import (
    Expression,
    ListReference,
    RuleReference,
    Sentence,
    Sequence,
    SequenceType,
    TextChunk,
)
from .intents import IntentData, RangeSlotList, SlotList, TextSlotList, WildcardSlotList
from .models import (
    MatchEntity,
    UnmatchedEntity,
    UnmatchedRangeEntity,
    UnmatchedTextEntity,
)
from .trie import Trie
from .util import (
    PUNCTUATION_ALL,
    WHITESPACE,
    check_excluded_context,
    check_required_context,
    match_first,
    match_start,
)

NUMBER_START = re.compile(r"^(\s*-?[0-9]+)")
NUMBER_ANYWHERE = re.compile(r"(\s*-?[0-9]+)")
BREAK_WORDS_TABLE = str.maketrans("-_", "  ")

# lang -> engine
_ENGINE_CACHE: Dict[str, RbnfEngine] = {}

# lang -> number -> words
_RANGE_TRIE_CACHE: Dict[str, Dict[Tuple[int, int, int], Trie]] = defaultdict(dict)

_LOGGER = logging.getLogger()


@dataclass
class MatchSettings:
    """Settings used in match_expression."""

    slot_lists: Dict[str, SlotList] = field(default_factory=dict)
    """Available slot lists mapped by name."""

    expansion_rules: Dict[str, Sentence] = field(default_factory=dict)
    """Available expansion rules mapped by name."""

    ignore_whitespace: bool = False
    """True if whitespace should be ignored during matching."""

    allow_unmatched_entities: bool = False
    """True if unmatched entities are kept for better error messages (slower)."""

    language: Optional[str] = None
    """Optional language to use when converting digits to words."""


@dataclass
class MatchContext:
    """Context passed to match_expression."""

    text: str
    """Input text remaining to be processed."""

    entities: List[MatchEntity] = field(default_factory=list)
    """Entities that have been found in input text."""

    intent_context: Dict[str, Any] = field(default_factory=dict)
    """Context items from outside or acquired during matching."""

    is_start_of_word: bool = True
    """True if current text is the start of a word."""

    unmatched_entities: List[UnmatchedEntity] = field(default_factory=list)
    """Entities that failed to match (requires allow_unmatched_entities=True)."""

    close_wildcards: bool = False
    """True if open wildcards should be closed during init."""

    close_unmatched: bool = False
    """True if open unmatched entities should be closed during init."""

    text_chunks_matched: int = 0
    """Number of literal text chunks that were matched."""

    intent_sentence: Optional[Sentence] = None
    """Sentence template that is being matched."""

    intent_data: Optional[IntentData] = None
    """Data from sentence template group in intents."""

    def __post_init__(self):
        if self.close_wildcards:
            for entity in self.entities:
                entity.is_wildcard_open = False

        if self.close_unmatched:
            for unmatched_entity in self.unmatched_entities:
                if isinstance(unmatched_entity, UnmatchedTextEntity):
                    unmatched_entity.is_open = False

    @property
    def is_match(self) -> bool:
        """True if no text is left that isn't just whitespace or punctuation"""
        text = PUNCTUATION_ALL.sub("", self.text).strip()
        if text:
            return False

        # Wildcards cannot be empty
        for entity in self.entities:
            if entity.is_wildcard and (not entity.text.strip()):
                return False

        # Unmatched entities cannot be empty
        for unmatched_entity in self.unmatched_entities:
            if isinstance(unmatched_entity, UnmatchedTextEntity) and (
                not unmatched_entity.text.strip()
            ):
                return False

        return True

    def get_open_wildcard(self) -> Optional[MatchEntity]:
        """Get the last open wildcard or None."""
        if not self.entities:
            return None

        last_entity = self.entities[-1]
        if last_entity.is_wildcard and last_entity.is_wildcard_open:
            return last_entity

        return None

    def get_open_entity(self) -> Optional[UnmatchedTextEntity]:
        """Get the last open unmatched text entity or None."""
        if not self.unmatched_entities:
            return None

        last_entity = self.unmatched_entities[-1]
        if isinstance(last_entity, UnmatchedTextEntity) and last_entity.is_open:
            return last_entity

        return None


def match_expression(
    settings: MatchSettings, context: MatchContext, expression: Expression
) -> Iterable[MatchContext]:
    """Yield matching contexts for an expression"""
    if isinstance(expression, TextChunk):
        chunk: TextChunk = expression

        if settings.ignore_whitespace:
            # Remove all whitespace
            chunk_text = WHITESPACE.sub("", chunk.text)
            context_text = WHITESPACE.sub("", context.text)
        else:
            # Keep whitespace
            chunk_text = chunk.text
            context_text = context.text

            if context.is_start_of_word:
                # Ignore extra whitespace at the beginning of chunk and text
                # since we know we're at the start of a word.
                chunk_text = chunk_text.lstrip()
                context_text = context_text.lstrip()

        # True if remaining text to be matched is empty or whitespace.
        #
        # If so, we can't say this is a successful match yet because the
        # sentence template may have remaining non-optional expressions.
        #
        # So we have to continue matching, skipping over empty or whitespace
        # chunks until the template is exhausted.
        is_context_text_empty = len(context_text.strip()) == 0

        if chunk.is_empty:
            # Skip empty chunk (NOT whitespace)
            yield context
        else:
            wildcard = context.get_open_wildcard()
            if (wildcard is not None) and (not wildcard.text.strip()):
                if not chunk_text.strip():
                    # Skip space
                    yield MatchContext(
                        text=context_text,
                        is_start_of_word=True,
                        # Copy over
                        entities=context.entities,
                        intent_context=context.intent_context,
                        unmatched_entities=context.unmatched_entities,
                        text_chunks_matched=context.text_chunks_matched,
                        intent_sentence=context.intent_sentence,
                        intent_data=context.intent_data,
                    )
                    return

                # Wildcard cannot be empty
                start_idx = match_first(context_text, chunk_text)
                if start_idx < 0:
                    # Cannot possibly match
                    return

                if start_idx == 0:
                    # Possible degenerate case where the next word in the
                    # template duplicates.
                    start_idx = match_first(context_text, chunk_text, 1)
                    if start_idx < 0:
                        # Cannot possibly match
                        return

                # Produce all possible matches where the wildcard consumes text
                # up to where the chunk matches in the string.
                entities_without_wildcard = context.entities[:-1]
                while start_idx > 0:
                    wildcard_text = context_text[:start_idx]
                    yield from match_expression(
                        settings,
                        MatchContext(
                            text=context_text[start_idx:],
                            is_start_of_word=True,
                            entities=entities_without_wildcard
                            + [
                                MatchEntity(
                                    name=wildcard.name,
                                    text=wildcard_text,
                                    value=wildcard_text,
                                    is_wildcard=True,
                                    is_wildcard_open=False,  # always close
                                )
                            ],
                            # Copy over
                            intent_context=context.intent_context,
                            unmatched_entities=context.unmatched_entities,
                            text_chunks_matched=context.text_chunks_matched,
                            intent_sentence=context.intent_sentence,
                            intent_data=context.intent_data,
                        ),
                        expression,
                    )
                    start_idx = match_first(context_text, chunk_text, start_idx + 1)

                # Do not continue with matching
                return

            end_pos = match_start(context_text, chunk_text)
            if end_pos is not None:
                # Successful match for chunk
                context_text = context_text[end_pos:]

                # Close wildcards/unmatched entities on non-empty chunk
                chunk_text_stripped = chunk_text.strip()
                is_chunk_non_empty = len(chunk_text_stripped) > 0

                text_chunks_matched = context.text_chunks_matched
                if is_chunk_non_empty:
                    text_chunks_matched += len(chunk_text_stripped)

                yield MatchContext(
                    text=context_text,
                    # must use chunk.text because it hasn't been stripped
                    is_start_of_word=chunk.text.endswith(" "),
                    text_chunks_matched=text_chunks_matched,
                    # Copy over
                    entities=context.entities,
                    intent_context=context.intent_context,
                    unmatched_entities=context.unmatched_entities,
                    intent_sentence=context.intent_sentence,
                    intent_data=context.intent_data,
                    #
                    close_wildcards=is_chunk_non_empty,
                    close_unmatched=is_chunk_non_empty,
                )
            elif is_context_text_empty and chunk_text.isspace():
                # No text left to match, so extra whitespace is OK to skip
                yield context
            else:
                # Try breaking words apart
                context_text = context_text.translate(BREAK_WORDS_TABLE)
                end_pos = match_start(context_text, chunk_text)

                if end_pos is not None:
                    context_text = context_text[end_pos:]

                    # Close wildcards/unmatched entities on non-empty chunk
                    is_chunk_non_empty = len(chunk_text.strip()) > 0

                    yield MatchContext(
                        text=context_text,
                        # Copy over
                        entities=context.entities,
                        intent_context=context.intent_context,
                        is_start_of_word=context.is_start_of_word,
                        unmatched_entities=context.unmatched_entities,
                        text_chunks_matched=context.text_chunks_matched,
                        intent_sentence=context.intent_sentence,
                        intent_data=context.intent_data,
                        #
                        close_wildcards=is_chunk_non_empty,
                        close_unmatched=is_chunk_non_empty,
                    )
                elif wildcard is not None:
                    # Add to wildcard by skipping ahead in the text until we find
                    # the current chunk text.
                    skip_idx = match_first(context_text, chunk_text)
                    if skip_idx >= 0:
                        wildcard_text = context_text[:skip_idx]

                        # Wildcards cannot be empty
                        if wildcard_text:
                            entities = [
                                e for e in context.entities if e.name != wildcard.name
                            ]
                            entities.append(
                                MatchEntity(
                                    name=wildcard.name,
                                    value=wildcard_text,
                                    text=wildcard_text,
                                    is_wildcard=True,
                                    is_wildcard_open=False,  # always close
                                )
                            )
                            yield MatchContext(
                                text=context.text[skip_idx + len(chunk_text) :],
                                # Copy over
                                # entities=context.entities,
                                intent_context=context.intent_context,
                                is_start_of_word=True,
                                unmatched_entities=context.unmatched_entities,
                                text_chunks_matched=context.text_chunks_matched,
                                intent_sentence=context.intent_sentence,
                                intent_data=context.intent_data,
                                #
                                entities=entities,
                            )
                elif settings.allow_unmatched_entities and (
                    unmatched_entity := context.get_open_entity()
                ):
                    # Add to the most recent unmatched entity by skipping ahead in
                    # the text until we find the current chunk text.
                    re_chunk_text = re.escape(chunk_text.strip())
                    if settings.ignore_whitespace:
                        chunk_match = re.search(re_chunk_text, context_text)
                    else:
                        # Only skip to a word boundary
                        chunk_match = re.search(
                            rf"\s{re_chunk_text}(\s|$)", context_text
                        )

                    if chunk_match:
                        unmatched_entity_text = (
                            unmatched_entity.text
                            + context_text[: chunk_match.start() + 1]
                        )

                        # Unmatched entities cannot be empty
                        if unmatched_entity_text:
                            # Make a copy of modified unmatched entity
                            unmatched_entities = [
                                e
                                for e in context.unmatched_entities
                                if e.name != unmatched_entity.name
                            ]
                            unmatched_entities.append(
                                UnmatchedTextEntity(
                                    name=unmatched_entity.name,
                                    text=unmatched_entity_text,
                                    is_open=False,  # always close
                                )
                            )

                            yield MatchContext(
                                text=context.text[chunk_match.end() :],
                                # Copy over
                                entities=context.entities,
                                intent_context=context.intent_context,
                                is_start_of_word=True,
                                text_chunks_matched=context.text_chunks_matched
                                + len(chunk.text.strip()),
                                intent_sentence=context.intent_sentence,
                                intent_data=context.intent_data,
                                #
                                unmatched_entities=unmatched_entities,
                            )
                else:
                    # Match failed
                    pass
    elif isinstance(expression, Sequence):
        seq: Sequence = expression
        if seq.type == SequenceType.ALTERNATIVE:
            # Any may match (words | in | alternative)
            # NOTE: [optional] = (optional | )
            for item in seq.items:
                yield from match_expression(settings, context, item)

        elif seq.type == SequenceType.GROUP:
            if seq.items:
                # All must match (words in group)
                group_contexts = [context]
                for item in seq.items:
                    # Next step
                    group_contexts = [
                        item_context
                        for group_context in group_contexts
                        for item_context in match_expression(
                            settings, group_context, item
                        )
                    ]
                    if not group_contexts:
                        break

                yield from group_contexts
        else:
            raise ValueError(f"Unexpected sequence type: {seq}")

    elif isinstance(expression, ListReference):
        # {list}
        list_ref: ListReference = expression
        if (not settings.slot_lists) or (list_ref.list_name not in settings.slot_lists):
            raise MissingListError(f"Missing slot list {{{list_ref.list_name}}}")

        wildcard = context.get_open_wildcard()
        slot_list = settings.slot_lists[list_ref.list_name]
        if isinstance(slot_list, TextSlotList):
            if context.text:
                text_list: TextSlotList = slot_list
                # Any value may match
                has_matches = False

                required_context: Optional[Dict[str, Any]] = None
                excluded_context: Optional[Dict[str, Any]] = None
                if context.intent_data is not None:
                    required_context = context.intent_data.requires_context
                    excluded_context = context.intent_data.excludes_context

                for slot_value in text_list.values:
                    # Filter possible values with required/excluded context
                    if required_context and (
                        not check_required_context(
                            required_context,
                            slot_value.context,
                            allow_missing_keys=True,
                        )
                    ):
                        continue

                    if excluded_context and (
                        not check_excluded_context(excluded_context, slot_value.context)
                    ):
                        continue

                    if (isinstance(slot_value.text_in, TextChunk)) and (
                        len(context.text) < len(slot_value.text_in.text)
                    ):
                        # Not enough text left to match
                        continue

                    value_contexts = match_expression(
                        settings,
                        MatchContext(
                            # Copy over
                            text=context.text,
                            entities=context.entities,
                            intent_context=context.intent_context,
                            is_start_of_word=context.is_start_of_word,
                            unmatched_entities=context.unmatched_entities,
                            text_chunks_matched=context.text_chunks_matched,
                            intent_sentence=context.intent_sentence,
                            intent_data=context.intent_data,
                        ),
                        slot_value.text_in,
                    )

                    for value_context in value_contexts:
                        has_matches = True
                        value_wildcard: Optional[MatchEntity] = None
                        if (
                            value_context.entities
                            and value_context.entities[-1].is_wildcard
                        ):
                            value_wildcard = value_context.entities[-1]

                        if value_wildcard is not None and context.text.startswith(
                            value_wildcard.text
                        ):
                            # Remove wildcard text from value
                            remaining_text = context.text[len(value_wildcard.text) :]
                        else:
                            remaining_text = context.text

                        entities = value_context.entities + [
                            MatchEntity(
                                name=list_ref.slot_name,
                                value=slot_value.value_out,
                                text=(
                                    remaining_text[: -len(value_context.text)]
                                    if value_context.text
                                    else remaining_text
                                ),
                                metadata=slot_value.metadata,
                            )
                        ]

                        if slot_value.context:
                            # Merge context from matched list value
                            yield MatchContext(
                                entities=entities,
                                intent_context={
                                    **context.intent_context,
                                    **slot_value.context,
                                },
                                # Copy over
                                text=value_context.text,
                                is_start_of_word=context.is_start_of_word,
                                unmatched_entities=context.unmatched_entities,
                                text_chunks_matched=context.text_chunks_matched,
                                intent_sentence=context.intent_sentence,
                                intent_data=context.intent_data,
                            )
                        else:
                            yield MatchContext(
                                entities=entities,
                                # Copy over
                                text=value_context.text,
                                intent_context=value_context.intent_context,
                                is_start_of_word=context.is_start_of_word,
                                unmatched_entities=context.unmatched_entities,
                                text_chunks_matched=context.text_chunks_matched,
                                intent_sentence=context.intent_sentence,
                                intent_data=context.intent_data,
                            )

                if (not has_matches) and settings.allow_unmatched_entities:
                    # Report mismatch
                    yield MatchContext(
                        # Copy over
                        text=context.text,
                        entities=context.entities,
                        intent_context=context.intent_context,
                        is_start_of_word=context.is_start_of_word,
                        text_chunks_matched=context.text_chunks_matched,
                        intent_sentence=context.intent_sentence,
                        intent_data=context.intent_data,
                        #
                        unmatched_entities=context.unmatched_entities
                        + [UnmatchedTextEntity(name=list_ref.slot_name, text="")],
                        close_wildcards=True,
                    )

        elif isinstance(slot_list, RangeSlotList):
            if context.text:
                # List that represents a number range.
                range_list: RangeSlotList = slot_list

                number_matches: List[re.Match] = []
                if wildcard is None:
                    # Look for digits at the start of the incoming text
                    number_match = NUMBER_START.match(context.text)
                    if number_match is not None:
                        number_matches.append(number_match)
                else:
                    # Look for digit(s) anywhere in the string.
                    # The wildcard will consume text up to that point.
                    number_matches.extend(NUMBER_ANYWHERE.finditer(context.text))

                digits_match = False
                if range_list.digits and number_matches:
                    for number_match in number_matches:
                        number_text = number_match[1]
                        word_number: Union[int, float] = int(number_text)

                        # Check if number is within range of our list
                        if range_list.step == 1:
                            # Unit step
                            in_range = (
                                range_list.start <= word_number <= range_list.stop
                            )
                        else:
                            # Non-unit step
                            in_range = word_number in range(
                                range_list.start, range_list.stop + 1, range_list.step
                            )

                        if in_range:
                            # Number is in range
                            digits_match = True
                            range_value = word_number
                            if range_list.multiplier is not None:
                                range_value *= range_list.multiplier

                            entities = context.entities + [
                                MatchEntity(
                                    name=list_ref.slot_name,
                                    value=range_value,
                                    text=number_match.group(1),
                                )
                            ]

                            if wildcard is None:
                                yield MatchContext(
                                    text=context.text[number_match.end() :],
                                    entities=entities,
                                    # Copy over
                                    intent_context=context.intent_context,
                                    is_start_of_word=context.is_start_of_word,
                                    unmatched_entities=context.unmatched_entities,
                                    text_chunks_matched=context.text_chunks_matched,
                                    intent_sentence=context.intent_sentence,
                                    intent_data=context.intent_data,
                                )
                            else:
                                # Wildcard consumes text before number
                                wildcard.text += context.text[: number_match.end() - 1]
                                wildcard.value = wildcard.text
                                yield MatchContext(
                                    text=context.text[number_match.end() :],
                                    entities=entities,
                                    # Copy over
                                    intent_context=context.intent_context,
                                    is_start_of_word=context.is_start_of_word,
                                    unmatched_entities=context.unmatched_entities,
                                    text_chunks_matched=context.text_chunks_matched,
                                    intent_sentence=context.intent_sentence,
                                    intent_data=context.intent_data,
                                    #
                                    close_wildcards=True,
                                )
                        elif settings.allow_unmatched_entities and (wildcard is None):
                            # Report out of range
                            yield MatchContext(
                                # Copy over
                                text=context.text[len(number_text) :],
                                entities=context.entities,
                                intent_context=context.intent_context,
                                is_start_of_word=context.is_start_of_word,
                                text_chunks_matched=context.text_chunks_matched,
                                intent_sentence=context.intent_sentence,
                                intent_data=context.intent_data,
                                #
                                unmatched_entities=context.unmatched_entities
                                + [
                                    UnmatchedRangeEntity(
                                        name=list_ref.slot_name, value=word_number
                                    )
                                ],
                            )

                # Only check number words if:
                # 1. Words are enabled for this list
                # 2. We didn't already match digits
                # 3. the incoming text doesn't start with digits
                words_match: bool = False
                if range_list.words and (not digits_match) and (not number_matches):
                    words_language = range_list.words_language or settings.language
                    if words_language:
                        range_settings = (
                            range_list.start,
                            range_list.stop,
                            range_list.step,
                        )
                        range_trie = _RANGE_TRIE_CACHE[words_language].get(
                            range_settings
                        )
                        try:
                            if range_trie is None:
                                range_trie = _build_range_trie(
                                    words_language, range_list
                                )
                                _RANGE_TRIE_CACHE[words_language][
                                    range_settings
                                ] = range_trie

                            for (
                                number_end_pos,
                                number_text,
                                range_value,
                            ) in range_trie.find(context.text):
                                number_start_pos = number_end_pos - len(number_text)
                                if (wildcard is None) and (number_start_pos > 0):
                                    # Can't possibly match because the number
                                    # string isn't at the start of the text.
                                    continue

                                entities = context.entities + [
                                    MatchEntity(
                                        name=list_ref.slot_name,
                                        value=range_value,
                                        text=number_text,
                                    )
                                ]
                                if wildcard is None:
                                    yield from match_expression(
                                        settings,
                                        MatchContext(
                                            text=context.text,
                                            entities=entities,
                                            # Copy over
                                            intent_context=context.intent_context,
                                            is_start_of_word=context.is_start_of_word,
                                            unmatched_entities=context.unmatched_entities,
                                            text_chunks_matched=context.text_chunks_matched,
                                            intent_sentence=context.intent_sentence,
                                            intent_data=context.intent_data,
                                        ),
                                        TextChunk(number_text),
                                    )
                                else:
                                    # Wildcard consumes text before number
                                    wildcard.text += context.text[:number_start_pos]
                                    wildcard.value = wildcard.text
                                    yield from match_expression(
                                        settings,
                                        MatchContext(
                                            text=context.text[number_start_pos:],
                                            entities=entities,
                                            # Copy over
                                            intent_context=context.intent_context,
                                            is_start_of_word=context.is_start_of_word,
                                            unmatched_entities=context.unmatched_entities,
                                            text_chunks_matched=context.text_chunks_matched,
                                            intent_sentence=context.intent_sentence,
                                            intent_data=context.intent_data,
                                            #
                                            close_wildcards=True,
                                        ),
                                        TextChunk(number_text),
                                    )
                        except ValueError as error:
                            _LOGGER.debug(
                                "Unexpected error converting numbers to words for language '%s': %s",
                                settings.language,
                                str(error),
                            )

                if (
                    (not digits_match)
                    and (not words_match)
                    and settings.allow_unmatched_entities
                ):
                    # Report not a number
                    yield MatchContext(
                        # Copy over
                        text=context.text,
                        entities=context.entities,
                        intent_context=context.intent_context,
                        is_start_of_word=context.is_start_of_word,
                        text_chunks_matched=context.text_chunks_matched,
                        intent_sentence=context.intent_sentence,
                        intent_data=context.intent_data,
                        #
                        unmatched_entities=context.unmatched_entities
                        + [UnmatchedTextEntity(name=list_ref.slot_name, text="")],
                        close_wildcards=True,
                    )
        elif isinstance(slot_list, WildcardSlotList):
            if context.text:
                # Start wildcard entities
                yield MatchContext(
                    # Copy over
                    text=context.text,
                    intent_context=context.intent_context,
                    is_start_of_word=context.is_start_of_word,
                    unmatched_entities=context.unmatched_entities,
                    text_chunks_matched=context.text_chunks_matched,
                    intent_sentence=context.intent_sentence,
                    intent_data=context.intent_data,
                    #
                    entities=context.entities
                    + [
                        MatchEntity(
                            name=list_ref.slot_name, value="", text="", is_wildcard=True
                        )
                    ],
                    close_unmatched=True,
                )
        else:
            raise ValueError(f"Unexpected slot list type: {slot_list}")

    elif isinstance(expression, RuleReference):
        # <rule>
        rule_ref: RuleReference = expression
        if (not settings.expansion_rules) or (
            rule_ref.rule_name not in settings.expansion_rules
        ):
            raise MissingRuleError(f"Missing expansion rule <{rule_ref.rule_name}>")

        yield from match_expression(
            settings, context, settings.expansion_rules[rule_ref.rule_name]
        )
    else:
        raise ValueError(f"Unexpected expression: {expression}")


def _build_range_trie(language: str, range_list: RangeSlotList) -> Trie:
    range_trie = Trie()

    # Load number formatting engine
    engine = _ENGINE_CACHE.get(language)
    if engine is None:
        engine = RbnfEngine.for_language(language)
        _ENGINE_CACHE[language] = engine

    for word_number in range(range_list.start, range_list.stop + 1, range_list.step):
        range_value: Union[float, int] = word_number
        if range_list.multiplier is not None:
            range_value *= range_list.multiplier

        format_result = engine.format_number(word_number)
        used_words = set()

        for words in format_result.text_by_ruleset.values():
            if words in used_words:
                continue

            range_trie.insert(words, range_value)
            used_words.add(words)

            words = words.translate(BREAK_WORDS_TABLE)
            if words in used_words:
                continue

            range_trie.insert(words, range_value)
            used_words.add(words)

    return range_trie
