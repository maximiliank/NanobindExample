if(Python_EXECUTABLE)
  get_filename_component(Python_BIN_PATH ${Python_EXECUTABLE} PATH)
  set(SPELL_COMMAND
      "${Python_BIN_PATH}/codespell"
      CACHE STRING "Spell checker to use")
else()
  set(SPELL_COMMAND
      "codespell"
      CACHE STRING "Spell checker to use")
endif()

add_custom_target(
  spell-check
  COMMAND "${CMAKE_COMMAND}" "-DSPELL_COMMAND=${SPELL_COMMAND}" -P "${PROJECT_SOURCE_DIR}/cmake/spell.cmake"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Checking spelling"
  VERBATIM)

add_custom_target(
  spell-fix
  COMMAND "${CMAKE_COMMAND}" "-DSPELL_COMMAND=${SPELL_COMMAND}" "-DFIX=YES" -P "${PROJECT_SOURCE_DIR}/cmake/spell.cmake"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Fixing spelling errors"
  VERBATIM)
