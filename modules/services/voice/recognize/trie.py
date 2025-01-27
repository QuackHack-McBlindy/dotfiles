"""Specialized implementation of a trie.

See: https://en.wikipedia.org/wiki/Trie
"""

from collections import deque
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional, Tuple


@dataclass
class TrieNode:
    """Node in trie."""

    id: int
    text: Optional[str] = None
    values: Optional[List[Any]] = None
    children: "Optional[Dict[str, TrieNode]]" = None


class Trie:
    """A specialized trie data structure that finds all known words in a string."""

    def __init__(self) -> None:
        self.roots: Dict[str, TrieNode] = {}
        self._next_id = 0

    def insert(self, text: str, value: Any) -> None:
        """Insert a word and value into the trie."""
        current_node: Optional[TrieNode] = None
        current_children: Optional[Dict[str, TrieNode]] = self.roots

        last_idx = len(text) - 1
        for i, c in enumerate(text):
            if current_children is None:
                assert current_node is not None
                current_node.children = current_children = {}

            current_node = current_children.get(c)
            if current_node is None:
                current_node = TrieNode(id=self.next_id())
                current_children[c] = current_node

            if i == last_idx:
                current_node.text = text
                if current_node.values is None:
                    current_node.values = [value]
                else:
                    current_node.values.append(value)

            current_children = current_node.children

    def find(self, text: str, unique: bool = True) -> Iterable[Tuple[int, str, Any]]:
        """Yield (end_pos, text, value) pairs of all words found in the string."""
        q = deque([(self.roots, i) for i in range(len(text))])
        visited = set()

        while q:
            item = q.popleft()
            current_children, current_position = item
            if current_position >= len(text):
                continue

            current_char = text[current_position]

            node = current_children.get(current_char)
            if (node is not None) and (node.id not in visited):

                if node.text is not None:
                    # End is one past the current position
                    if unique:
                        visited.add(node.id)

                    if node.values:
                        for value in node.values:
                            yield (current_position + 1, node.text, value)
                    else:
                        # null value
                        yield (current_position + 1, node.text, None)

                if node.children and (current_position < len(text)):
                    q.append((node.children, current_position + 1))

    def next_id(self) -> int:
        current_id = self._next_id
        self._next_id += 1
        return current_id
