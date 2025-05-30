set(TARGET_NAME tests)
file(
  GLOB_RECURSE
  sources
  *.cpp
  *.h
  *.hpp)

add_executable(${TARGET_NAME} ${sources})

target_link_libraries(${TARGET_NAME} PRIVATE NanobindExample::NanobindExample_warnings
                                             NanobindExample::NanobindExample_options)

target_link_system_libraries(
  ${TARGET_NAME}
  PRIVATE
  GTest::GTest
  GTest::gmock_main
  my_cpp_library
  spdlog::spdlog)

# add Source directory to enable testing of internal implementations
target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/Source ${CMAKE_SOURCE_DIR}/test/UnitTests)

if(WIN32 AND BUILD_SHARED_LIBS)
  add_custom_command(
    TARGET ${TARGET_NAME}
    PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:${TARGET_NAME}> $<TARGET_FILE_DIR:${TARGET_NAME}>
    COMMAND_EXPAND_LISTS)
endif()

add_dependencies(${TARGET_NAME} compiletime_checks)

# include(GoogleTest)
# gtest_discover_tests(${TARGET_NAME})
