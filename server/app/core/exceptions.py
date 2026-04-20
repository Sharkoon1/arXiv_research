class ReportNotFound(Exception):
    """Raised when a report cannot be found by id."""


class AgentError(Exception):
    """Raised when an agent call fails irrecoverably."""
