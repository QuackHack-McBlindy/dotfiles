from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional

GROUP_START = "("
GROUP_END = ")"
OPT_START = "["
OPT_END = "]"
LIST_START = "{"
LIST_END = "}"
RULE_START = "<"
RULE_END = ">"

DELIM = {
    GROUP_START: GROUP_END,
    OPT_START: OPT_END,
    LIST_START: LIST_END,
    RULE_START: RULE_END,
}
DELIM_START = tuple(DELIM.keys())
DELIM_END = tuple(DELIM.values())

WORD_SEP = " "
ALT_SEP = "|"
PERM_SEP = ";"
ESCAPE_CHAR = "\\"


class ParseType(Enum):
    """Parse chunk types."""

    WORD = auto()
    GROUP = auto()
    OPT = auto()
    LIST = auto()
    RULE = auto()
    ALT = auto()
    PERM = auto()
    END = auto()


@dataclass
class ParseChunk:
    """Block of text that means something to the parser."""

    text: str
    start_index: int
    end_index: int
    parse_type: ParseType


class ParseError(Exception):
    """Base class for parse errors"""


def _find_end_delimiter(
    text: str, start_index: int, start_char: str, end_char: str
) -> Optional[int]:
    """Finds the index of an ending delimiter."""
    if start_index > 0:
        text = text[start_index:]

    stack = 1
    is_escaped = False
    for i, c in enumerate(text):
        if is_escaped:
            is_escaped = False
            continue

        if c == ESCAPE_CHAR:
            is_escaped = True
            continue

        if c == end_char:
            stack -= 1
            if stack < 0:
                return None

            if stack == 0:
                return start_index + i + 1

        if c == start_char:
            stack += 1

    return None


def _find_end_word(text: str, start_index: int) -> Optional[int]:
    """Finds the end index of a word."""
    if start_index > 0:
        text = text[start_index:]

    is_escaped = False
    separator_found = False
    for i, c in enumerate(text):
        if is_escaped:
            is_escaped = False
            continue

        if c == ESCAPE_CHAR:
            is_escaped = True
            continue

        if (i > 0) and (c == WORD_SEP):
            separator_found = True
            continue

        if separator_found and (c != WORD_SEP):
            # Start of next word
            return start_index + i

        if (c == ALT_SEP) or (c == PERM_SEP) or (c in DELIM_START) or (c in DELIM_END):
            return start_index + i

    if text:
        # Entire text is a word
        return start_index + len(text)

    return None


def _peek_type(text, start_index: int) -> ParseType:
    """Gets the parse chunk type based on the next character."""
    if start_index >= len(text):
        return ParseType.END

    c = text[start_index]
    if c == GROUP_START:
        return ParseType.GROUP

    if c == OPT_START:
        return ParseType.OPT

    if c == LIST_START:
        return ParseType.LIST

    if c == RULE_START:
        return ParseType.RULE

    if c == ALT_SEP:
        return ParseType.ALT

    if c == PERM_SEP:
        return ParseType.PERM

    return ParseType.WORD


def next_chunk(text: str, start_index: int = 0) -> Optional[ParseChunk]:
    """Gets the next parsable chunk from text."""
    next_type = _peek_type(text, start_index)

    if next_type == ParseType.END:
        return None

    if next_type == ParseType.WORD:
        # Single word
        end_index = _find_end_word(text, start_index)
        if end_index is None:
            raise ParseError(
                f"Unable to find end of word from index {start_index} in: {text}"
            )

    elif next_type in (ParseType.GROUP, ParseType.OPT, ParseType.LIST, ParseType.RULE):
        if next_type == ParseType.GROUP:
            start_char = GROUP_START
            end_char = GROUP_END
            error_str = "group ')'"

        elif next_type == ParseType.OPT:
            start_char = OPT_START
            end_char = OPT_END
            error_str = "optional ']'"

        elif next_type == ParseType.LIST:
            start_char = LIST_START
            end_char = LIST_END
            error_str = "list '}'"

        else:  # next_type == ParseType.RULE
            start_char = RULE_START
            end_char = RULE_END
            error_str = "rule '>'"

        end_index = _find_end_delimiter(text, start_index + 1, start_char, end_char)
        if end_index is None:
            raise ParseError(
                f"Unable to find end of {error_str} from index {start_index} in: {text}"
            )

    else:  # next_type in (ParseType.ALT, ParseType.PERM):
        end_index = start_index + 1

    chunk_text = text[start_index:end_index]

    return ParseChunk(
        text=chunk_text,
        start_index=start_index,
        end_index=end_index,
        parse_type=next_type,
    )
