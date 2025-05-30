cmake_minimum_required(VERSION 3.30)

include(FetchContent)
FetchContent_Declare(
  CMakeExtraUtils
  URL https://github.com/LecrisUT/CMakeExtraUtils/archive/refs/tags/v0.4.1.zip
  DOWNLOAD_NO_PROGRESS TRUE)
FetchContent_MakeAvailable(CMakeExtraUtils)

include(DynamicVersion)
dynamic_version(
  PROJECT_PREFIX
  NanobindExample_
  VERSION_FULL_MODE
  POST
  ALLOW_FAILS
  FALLBACK_VERSION
  0.0.1
  FALLBACK_HASH
  "00000000")
if(DEFINED GIT_DISTANCE
   AND NOT
       GIT_DISTANCE
       STREQUAL
       "0"
   AND NOT
       GIT_DISTANCE
       STREQUAL
       "distance-NOTFOUND")
  set(PROJECT_VERSION "${PROJECT_VERSION}.${GIT_DISTANCE}")
endif()
message("version: ${PROJECT_VERSION}")
message("version-full: ${PROJECT_VERSION_FULL}")
message("commit: ${GIT_COMMIT}")
message("short-hash: ${GIT_SHORT_HASH}")
message("describe: ${GIT_DESCRIBE}")
message("distance: ${GIT_DISTANCE}")

message(STATUS "Using cmake ${CMAKE_VERSION}")
# Only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 26)
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

# Set the project name and language
project(
  NanobindExample
  VERSION ${PROJECT_VERSION}
  DESCRIPTION "Nanobind Example Project"
  HOMEPAGE_URL "https://github.com/maximiliank/nanobind-example"
  LANGUAGES CXX C)

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)

nanobind_example_setup_options()

nanobind_example_global_options()

if(NanobindExample_ENABLE_PYTHON_PACKAGE)
  if(NOT TARGET Python::Module)
    # Try to import all Python components potentially needed by nanobind
    find_package(
      Python
      3.12
      BYPASS_PROVIDER
      REQUIRED
      COMPONENTS Interpreter Development.Module
      OPTIONAL_COMPONENTS Development.SABIModule Development.Embed)
  endif()
endif()

include(Dependencies.cmake)
nanobind_example_setup_dependencies()

nanobind_example_local_options()

# don't know if this should be set globally from here or not...
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

target_compile_features(NanobindExample_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})
set_target_properties(NanobindExample_options PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(NanobindExample::NanobindExample_options ALIAS NanobindExample_options)
add_library(NanobindExample::NanobindExample_warnings ALIAS NanobindExample_warnings)

#add_library(NanobindExample::NanobindExample_options INTERFACE IMPORTED)
#add_library(NanobindExample::NanobindExample_warnings INTERFACE IMPORTED)

# configure files based on CMake configuration options
add_subdirectory(configured_files)

# Adding the src:
add_subdirectory(Source)

if(NanobindExample_ENABLE_PYTHON_PACKAGE)
  message(STATUS "Building Python package")
  add_subdirectory(python)
else()
  message(STATUS "Not building Python package")
endif()
# Don't even look at tests if we're not top level
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

# Adding the tests:
option(BUILD_TESTING "Enabling tests" ON)

if(BUILD_TESTING)
  enable_testing()
  add_subdirectory(test)
endif()

include(cmake/lint-targets.cmake)
include(cmake/spell-targets.cmake)

# If MSVC is being used, and ASAN is enabled, we need to set the debugger environment
# so that it behaves well with MSVC's debugger, and we can run the target from visual studio
if(MSVC)
  get_all_installable_targets(all_targets)
  message("all_targets=${all_targets}")
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()

# set the startup project for the "play" button in MSVC
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT intro)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

include(cmake/PackageProject.cmake)

# Add other targets that you want installed here, by default we just package the one executable
# we know we want to ship
set(PACKAGE_TARGETS NanobindExample_options NanobindExample_warnings)

if(NanobindExample_ENABLE_PYTHON_PACKAGE)
  list(APPEND PACKAGE_TARGETS my_cpp_library)
endif()

nanobind_example_package_project(
  TARGETS ${PACKAGE_TARGETS}
  # FIXME: this does not work! CK
  # PRIVATE_DEPENDENCIES_CONFIGURED project_options project_warnings
)

# Experience shows that explicit package naming can help make it easier to sort
# out potential ABI related issues before they start, while helping you
# track a build to a specific GIT SHA
set(CPACK_PACKAGE_FILE_NAME
    "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${GIT_SHORT_SHA}-${CMAKE_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}"
)

include(CPack)
