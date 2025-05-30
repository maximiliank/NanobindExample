include(cmake/SystemLink.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)

macro(nanobind_example_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(nanobind_example_setup_options)
  option(NanobindExample_ENABLE_HARDENING "Enable hardening" OFF)
  option(NanobindExample_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    NanobindExample_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    NanobindExample_ENABLE_HARDENING
    OFF)

  nanobind_example_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR NanobindExample_PACKAGING_MAINTAINER_MODE)
    option(NanobindExample_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(NanobindExample_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(NanobindExample_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(NanobindExample_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(NanobindExample_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(NanobindExample_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(NanobindExample_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(NanobindExample_ENABLE_PCH "Enable precompiled headers" OFF)
    option(NanobindExample_ENABLE_CACHE "Enable ccache" OFF)
    option(NanobindExample_ENABLE_DOXYGEN "Enable doxygen documentation" OFF)
    option(NanobindExample_ENABLE_IWYU "Enable include what you use" OFF)
    option(NanobindExample_ENABLE_PYTHON_PACKAGE "Enable building of python package" ON)
  else()
    option(NanobindExample_ENABLE_IPO "Enable IPO/LTO" ON)
    option(NanobindExample_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(NanobindExample_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(NanobindExample_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(NanobindExample_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(NanobindExample_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(NanobindExample_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(NanobindExample_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(NanobindExample_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(NanobindExample_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(NanobindExample_ENABLE_PCH "Enable precompiled headers" OFF)
    option(NanobindExample_ENABLE_CACHE "Enable ccache" OFF)
    option(NanobindExample_ENABLE_DOXYGEN "Enable doxygen documentation" ON)
    option(NanobindExample_ENABLE_IWYU "Enable include what you use" OFF)
    option(NanobindExample_ENABLE_PYTHON_PACKAGE "Enable building of python package" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      NanobindExample_ENABLE_IPO
      NanobindExample_WARNINGS_AS_ERRORS
      NanobindExample_ENABLE_USER_LINKER
      NanobindExample_ENABLE_SANITIZER_ADDRESS
      NanobindExample_ENABLE_SANITIZER_LEAK
      NanobindExample_ENABLE_SANITIZER_UNDEFINED
      NanobindExample_ENABLE_SANITIZER_THREAD
      NanobindExample_ENABLE_SANITIZER_MEMORY
      NanobindExample_ENABLE_UNITY_BUILD
      NanobindExample_ENABLE_CLANG_TIDY
      NanobindExample_ENABLE_CPPCHECK
      NanobindExample_ENABLE_COVERAGE
      NanobindExample_ENABLE_PCH
      NanobindExample_ENABLE_CACHE
      NanobindExample_ENABLE_DOXYGEN
      NanobindExample_ENABLE_IWYU
      NanobindExample_ENABLE_PYTHON_PACKAGE)
  endif()

endmacro()

macro(nanobind_example_global_options)
  if(NanobindExample_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    nanobind_example_enable_ipo()
  endif()

  nanobind_example_supports_sanitizers()
  if(NanobindExample_ENABLE_HARDENING AND NanobindExample_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR NanobindExample_ENABLE_SANITIZER_UNDEFINED
       OR NanobindExample_ENABLE_SANITIZER_ADDRESS
       OR NanobindExample_ENABLE_SANITIZER_THREAD
       OR NanobindExample_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message(STATUS "enable hardening: ${NanobindExample_ENABLE_HARDENING}")
    message(STATUS "enable ubsan minimal runtime: ${ENABLE_UBSAN_MINIMAL_RUNTIME}")
    message(STATUS "enable sinitizers undefined: ${NanobindExample_ENABLE_SANITIZER_UNDEFINED}")
    nanobind_example_enable_hardening(NanobindExample_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(nanobind_example_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(NanobindExample_warnings INTERFACE)
  add_library(NanobindExample_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  nanobind_example_set_project_warnings(
    NanobindExample_warnings
    ${NanobindExample_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(NanobindExample_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(NanobindExample_options)
  endif()

  include(cmake/Sanitizers.cmake)
  nanobind_example_enable_sanitizers(
    NanobindExample_options
    ${NanobindExample_ENABLE_SANITIZER_ADDRESS}
    ${NanobindExample_ENABLE_SANITIZER_LEAK}
    ${NanobindExample_ENABLE_SANITIZER_UNDEFINED}
    ${NanobindExample_ENABLE_SANITIZER_THREAD}
    ${NanobindExample_ENABLE_SANITIZER_MEMORY})

  configure_file(${CMAKE_SOURCE_DIR}/.env.in ${CMAKE_SOURCE_DIR}/.env @ONLY)

  set_target_properties(NanobindExample_options PROPERTIES UNITY_BUILD ${NanobindExample_ENABLE_UNITY_BUILD})

  if(NanobindExample_ENABLE_PCH)
    target_precompile_headers(
      NanobindExample_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(NanobindExample_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    nanobind_example_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(NanobindExample_ENABLE_CLANG_TIDY)
    nanobind_example_enable_clang_tidy(NanobindExample_options ${NanobindExample_WARNINGS_AS_ERRORS})
  endif()

  if(NanobindExample_ENABLE_CPPCHECK)
    nanobind_example_enable_cppcheck(${NanobindExample_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(NanobindExample_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    nanobind_example_enable_coverage(NanobindExample_options)
  endif()

  if(NanobindExample_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(NanobindExample_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(NanobindExample_ENABLE_HARDENING AND NOT NanobindExample_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR NanobindExample_ENABLE_SANITIZER_UNDEFINED
       OR NanobindExample_ENABLE_SANITIZER_ADDRESS
       OR NanobindExample_ENABLE_SANITIZER_THREAD
       OR NanobindExample_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    nanobind_example_enable_hardening(NanobindExample_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

  if(NanobindExample_ENABLE_DOXYGEN)
    include(cmake/Doxygen.cmake)
    nanobind_example_enable_doxygen("")
  endif()

  if(NanobindExample_ENABLE_IWYU)
    nanobind_example_enable_include_what_you_use()
  endif()
endmacro()
