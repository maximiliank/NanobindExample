import logging

# See https://stackoverflow.com/a/27017068/9759769
__logger_name = "NanobindExample"
logger = logging.getLogger(__logger_name)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.NullHandler())
