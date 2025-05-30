set(TARGET_NAME compiletime_checks)
file(
  GLOB_RECURSE
  sources
  *.cpp
  *.h
  *.hpp)

add_library(${TARGET_NAME} SHARED ${sources})
target_link_libraries(${TARGET_NAME} PRIVATE NanobindExample::NanobindExample_warnings
                                             NanobindExample::NanobindExample_options)
