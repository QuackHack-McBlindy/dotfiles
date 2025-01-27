"""Errors for hassil."""


class HassilError(Exception):
    """Base class for hassil errors"""


class MissingListError(HassilError):
    """Error when a {slot_list} is missing."""


class MissingRuleError(HassilError):
    """Error when an <expansion_rule> is missing."""
