set(TARGET_NAME my_cpp_library)
file(
  GLOB_RECURSE
  headers
  include/${TARGET_NAME}/*.h
  include/${TARGET_NAME}/*.hpp)
file(
  GLOB_RECURSE
  sources
  src/*.cpp
  src/*.h
  src/*.hpp)

add_library(${TARGET_NAME} ${sources} ${headers})

add_library(NanobindExample::${TARGET_NAME} ALIAS ${TARGET_NAME})

target_link_libraries(${TARGET_NAME} PRIVATE NanobindExample_options NanobindExample_warnings)

target_link_system_libraries(${TARGET_NAME} PUBLIC spdlog::spdlog)

target_include_directories(${TARGET_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>
                                                 $<INSTALL_INTERFACE:include/>)

target_include_directories(${TARGET_NAME} SYSTEM PUBLIC $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/export/>)

set_target_properties(
  ${TARGET_NAME}
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(${TARGET_NAME} EXPORT_FILE_NAME
                       ${PROJECT_BINARY_DIR}/export/${TARGET_NAME}/${TARGET_NAME}_export.hpp)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(${TARGET_NAME} PUBLIC UTILS_LIBRARY_STATIC_DEFINE)
endif()

set_property(TARGET ${TARGET_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)
