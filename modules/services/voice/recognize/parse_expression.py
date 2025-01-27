import re
from dataclasses import dataclass
from itertools import permutations
from typing import List, Optional

from .expression import (
    Expression,
    ListReference,
    RuleReference,
    Sentence,
    Sequence,
    SequenceType,
    TextChunk,
)
from .parser import (
    GROUP_END,
    GROUP_START,
    LIST_END,
    LIST_START,
    OPT_END,
    OPT_START,
    RULE_END,
    RULE_START,
    ParseChunk,
    ParseError,
    ParseType,
    next_chunk,
)
from .util import normalize_text


@dataclass
class ParseMetadata:
    """Debug metadata for more helpful parsing errors."""

    file_name: str
    line_number: int
    intent_name: Optional[str] = None


class ParseExpressionError(ParseError):
    def __init__(self, chunk: ParseChunk, metadata: Optional[ParseMetadata] = None):
        super().__init__()
        self.chunk = chunk
        self.metadata = metadata

    def __str__(self) -> str:
        return f"Error in chunk {self.chunk} at {self.metadata}"


def _ensure_alternative(seq: Sequence):
    if seq.type != SequenceType.ALTERNATIVE:
        seq.type = SequenceType.ALTERNATIVE

        # Collapse items into a single group
        seq.items = [
            Sequence(
                type=SequenceType.GROUP,
                items=seq.items,
            )
        ]


def _ensure_permutation(seq: Sequence):
    if seq.type != SequenceType.PERMUTATION:
        seq.type = SequenceType.PERMUTATION

        # Collapse items into a single group
        seq.items = [
            Sequence(
                type=SequenceType.GROUP,
                items=seq.items,
            )
        ]


def parse_group_or_alt_or_perm(
    seq_chunk: ParseChunk, metadata: Optional[ParseMetadata] = None
) -> Sequence:
    seq = Sequence(type=SequenceType.GROUP)
    if seq_chunk.parse_type == ParseType.GROUP:
        seq_text = _remove_delimiters(seq_chunk.text, GROUP_START, GROUP_END)
    elif seq_chunk.parse_type == ParseType.OPT:
        seq_text = _remove_delimiters(seq_chunk.text, OPT_START, OPT_END)
    else:
        raise ParseExpressionError(seq_chunk, metadata=metadata)

    item_chunk = next_chunk(seq_text)
    last_seq_text = seq_text

    while item_chunk is not None:
        if item_chunk.parse_type in (
            ParseType.WORD,
            ParseType.GROUP,
            ParseType.OPT,
            ParseType.LIST,
            ParseType.RULE,
        ):
            item = parse_expression(item_chunk, metadata=metadata)

            if seq.type in (SequenceType.ALTERNATIVE, SequenceType.PERMUTATION):
                # Add to most recent group
                if not seq.items:
                    seq.items.append(Sequence(type=SequenceType.GROUP))

                # Must be group or alternative
                last_item = seq.items[-1]
                if not isinstance(last_item, Sequence):
                    raise ParseExpressionError(seq_chunk, metadata=metadata)

                last_item.items.append(item)
            else:
                # Add to parent group
                seq.items.append(item)

                if isinstance(item, TextChunk):
                    item_tc: TextChunk = item
                    item_tc.parent = seq
        elif item_chunk.parse_type == ParseType.ALT:
            _ensure_alternative(seq)

            # Begin new group
            seq.items.append(Sequence(type=SequenceType.GROUP))
        elif item_chunk.parse_type == ParseType.PERM:
            _ensure_permutation(seq)

            # Begin new group
            seq.items.append(Sequence(type=SequenceType.GROUP))
        else:
            raise ParseExpressionError(seq_chunk, metadata=metadata)

        # Next chunk
        seq_text = seq_text[item_chunk.end_index :]

        if seq_text == last_seq_text:
            # No change, unable to proceed
            raise ParseExpressionError(seq_chunk, metadata=metadata)

        item_chunk = next_chunk(seq_text)
        last_seq_text = seq_text

    if seq.type == SequenceType.PERMUTATION:
        permuted_items: List[Expression] = []

        for permutation in permutations(seq.items):
            permutation_with_spaces = _add_spaces_between_items(list(permutation))
            permuted_items.append(
                Sequence(type=SequenceType.GROUP, items=permutation_with_spaces)
            )

        seq = Sequence(type=SequenceType.ALTERNATIVE, items=permuted_items)

    return seq


def parse_expression(
    chunk: ParseChunk, metadata: Optional[ParseMetadata] = None
) -> Expression:
    if chunk.parse_type == ParseType.WORD:
        original_text = _remove_escapes(chunk.text)
        text = normalize_text(original_text)
        return TextChunk(text=text, original_text=original_text)

    if chunk.parse_type == ParseType.GROUP:
        return parse_group_or_alt_or_perm(chunk, metadata=metadata)

    if chunk.parse_type == ParseType.OPT:
        seq = parse_group_or_alt_or_perm(chunk, metadata=metadata)
        _ensure_alternative(seq)
        seq.items.append(TextChunk(text="", parent=seq))
        seq.is_optional = True
        return seq

    if chunk.parse_type == ParseType.LIST:
        text = _remove_escapes(chunk.text)
        list_name = _remove_delimiters(text, LIST_START, LIST_END)
        return ListReference(list_name=list_name)

    if chunk.parse_type == ParseType.RULE:
        text = _remove_escapes(chunk.text)
        rule_name = _remove_delimiters(text, RULE_START, RULE_END)
        return RuleReference(rule_name=rule_name)

    raise ParseExpressionError(chunk, metadata=metadata)


def parse_sentence(
    text: str, keep_text=False, metadata: Optional[ParseMetadata] = None
) -> Sentence:
    """Parse a single sentence."""
    original_text = text
    text = text.strip()
    # text = fix_pattern_whitespace(text.strip())

    # Wrap in a group because sentences need to always be sequences.
    text = f"({text})"

    chunk = next_chunk(text)
    if chunk is None:
        raise ParseError(f"Unexpected empty chunk in: {text}")

    if chunk.parse_type != ParseType.GROUP:
        raise ParseError(f"Expected (group) in: {text}")

    if chunk.start_index != 0:
        raise ParseError(f"Expected (group) to start at index 0 in: {text}")

    if chunk.end_index != len(text):
        raise ParseError(f"Expected chunk to end at index {chunk.end_index} in: {text}")

    seq = parse_expression(chunk, metadata=metadata)
    if not isinstance(seq, Sequence):
        raise ParseError(f"Expected Sequence, got: {seq}")

    # Unpack redundant sequence
    if len(seq.items) == 1:
        first_item = seq.items[0]
        if isinstance(first_item, Sequence):
            seq = first_item

    return Sentence(
        type=seq.type,
        items=seq.items,
        text=original_text if keep_text else None,
        is_optional=seq.is_optional,
    )


# def fix_pattern_whitespace(text: str) -> str:
#     if PERM_SEP in text:
#         # Fix within permutations
#         text = PERM_SEP.join(
#             GROUP_START + fix_pattern_whitespace(perm_chunk) + GROUP_END
#             for perm_chunk in text.split(PERM_SEP)
#         )

#     # Recursively process (group)
#     group_start_index = text.find(GROUP_START)
#     while group_start_index > 0:
#         # TODO: Can't cross OPT boundary
#         group_end_index = find_end_delimiter(
#             text, group_start_index + 1, GROUP_START, GROUP_END
#         )
#         if group_end_index is None:
#             return text  # will fail parsing

#         before_group, text_without_group, after_group = (
#             text[:group_start_index],
#             text[group_start_index + 1 : group_end_index - 1],
#             text[group_end_index:],
#         )

#         text = (
#             fix_pattern_whitespace(before_group)
#             + GROUP_START
#             + fix_pattern_whitespace(text_without_group)
#             + GROUP_END
#             + fix_pattern_whitespace(after_group)
#         )
#         group_start_index = text.find(GROUP_START, group_end_index)

#     # Fix whitespace after optional (beginning of sentence)
#     left_text, right_text = "", text
#     while right_text.startswith(OPT_START):
#         opt_end_index = find_end_delimiter(right_text, 1, OPT_START, OPT_END)
#         if (opt_end_index is None) or (opt_end_index >= len(right_text)):
#             break

#         if not right_text[opt_end_index].isspace():
#             # No adjustment needed
#             break

#         # Move whitespace into optional and group
#         left_text += (
#             OPT_START
#             + GROUP_START
#             + right_text[1 : opt_end_index - 1]
#             + GROUP_END
#             + " "
#             + OPT_END
#         )
#         right_text = right_text[opt_end_index:].lstrip()

#     text = left_text + right_text

#     # Fix whitespace before optional (end of sentence)
#     left_text, right_text = text, ""
#     while left_text.endswith(OPT_END):
#         opt_end_index = len(left_text)
#         opt_start_index = left_text.rfind(OPT_START)
#         maybe_opt_end_index: Optional[int] = None

#         # Keep looking back for the "[" that starts this optional
#         while opt_start_index > 0:
#             maybe_opt_end_index = find_end_delimiter(
#                 left_text, opt_start_index + 1, OPT_START, OPT_END
#             )
#             if maybe_opt_end_index == opt_end_index:
#                 break  # found the matching "["

#             # Look farther back
#             opt_start_index = left_text.rfind(OPT_START, 0, opt_start_index)

#         if (maybe_opt_end_index != opt_end_index) or (opt_start_index <= 0):
#             break

#         if not left_text[opt_start_index - 1].isspace():
#             # No adjustment needed
#             break

#         # Move whitespace into optional and group
#         right_text = (
#             (OPT_START + " " + GROUP_START + left_text[opt_start_index + 1 : -1])
#             + GROUP_END
#             + OPT_END
#             + right_text
#         )

#         left_text = left_text[:opt_start_index].rstrip()

#     text = left_text + right_text

#     # Fix whitespace around optional (middle of a sentence)
#     left_text, right_text = "", text
#     match = re.search(rf"\s({re.escape(OPT_START)})", right_text)
#     while match is not None:
#         opt_start_index = match.start(1)
#         opt_end_index = find_end_delimiter(
#             right_text, opt_start_index + 1, OPT_START, OPT_END
#         )
#         if (opt_end_index is None) or (opt_end_index >= len(text)):
#             break

#         if right_text[opt_end_index].isspace():
#             # Move whitespace inside optional, add group
#             left_text += (
#                 right_text[: opt_start_index - 1]
#                 + OPT_START
#                 + " "
#                 + GROUP_START
#                 + right_text[opt_start_index + 1 : opt_end_index - 1].lstrip()
#                 + GROUP_END
#                 + OPT_END
#             )
#         else:
#             left_text += right_text[:opt_end_index]

#         right_text = right_text[opt_end_index:]
#         if not right_text:
#             break

#         match = re.search(rf"\s({re.escape(OPT_START)})", right_text)

#     text = left_text + right_text

#     return text


def _remove_delimiters(
    text: str, start_char: str, end_char: Optional[str] = None
) -> str:
    """Removes the surrounding delimiters in text."""
    if end_char is None:
        assert len(text) > 1, "Text is too short"
        assert text[0] == start_char, "Wrong start char"
        return text[1:]

    assert len(text) > 2, "Text is too short"
    assert text[0] == start_char, "Wrong start char"
    assert text[-1] == end_char, "Wrong end char"
    return text[1:-1]


def _remove_escapes(text: str) -> str:
    """Remove backslash escape sequences"""
    return re.sub(r"\\(.)", r"\1", text)


def _escape_text(text: str) -> str:
    """Escape parentheses, etc."""
    return re.sub(r"([()\[\]{}<>])", r"\\\1", text)


def _add_spaces_between_items(items: List[Expression]) -> List[Expression]:
    """Add spaces between each 2 items of a sequence, used for permutations"""
    spaced_items: List[Expression] = []

    # Unpack single item sequences to make pattern matching easier below
    unpacked_items: List[Expression] = []
    for item in items:
        while (
            isinstance(item, Sequence)
            and (item.type == SequenceType.GROUP)
            and (len(item.items) == 1)
        ):
            item = item.items[0]

        unpacked_items.append(item)

    previous_item: Optional[Expression] = None
    for item_idx, item in enumerate(unpacked_items):
        if item_idx > 0:
            # Only add whitespace after the first item
            if isinstance(previous_item, Sequence) and previous_item.is_optional:
                # Modify the previous optional to include a space at the end of
                # each item.
                opt: Sequence = previous_item
                fixed_items: List[Expression] = []
                for opt_item in opt.items:
                    fix_item = True
                    if isinstance(opt_item, TextChunk):
                        opt_tc: TextChunk = opt_item
                        if not opt_tc.text:
                            # Don't fix empty text chunks
                            fix_item = False
                        else:
                            # Remove ending whitespace since we'll be adding a
                            # whitespace text chunk after.
                            opt_tc.text = opt_tc.text.rstrip()

                    if fix_item:
                        fixed_items.append(
                            Sequence(
                                type=SequenceType.GROUP,
                                items=[opt_item, TextChunk(" ")],
                            )
                        )
                    else:
                        fixed_items.append(opt_item)

                spaced_items[-1] = Sequence(
                    type=SequenceType.ALTERNATIVE, is_optional=True, items=fixed_items
                )
            else:
                # Add a space in front
                spaced_items.append(TextChunk(text=" "))

        spaced_items.append(item)
        previous_item = item

    return spaced_items
