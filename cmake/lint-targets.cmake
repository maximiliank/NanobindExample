set(FORMAT_COMMAND
    clang-format
    CACHE STRING "Formatter to use")

add_custom_target(
  format-check
  COMMAND "${CMAKE_COMMAND}" -D "FORMAT_COMMAND=${FORMAT_COMMAND}" -P "${PROJECT_SOURCE_DIR}/cmake/lint.cmake"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Linting the code"
  VERBATIM)

add_custom_target(
  format-fix
  COMMAND "${CMAKE_COMMAND}" -D "FORMAT_COMMAND=${FORMAT_COMMAND}" -D FIX=YES -P
          "${PROJECT_SOURCE_DIR}/cmake/lint.cmake"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Fixing the code"
  VERBATIM)
