# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(nanobind_example_setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project

  if(NanobindExample_ENABLE_PYTHON_PACKAGE)
    if(NOT TARGET nanobind::nanobind)
      # Import nanobind through CMake's find_package mechanism set(nanobind_ROOT
      # Detect the installed nanobind package and import it into CMake
      execute_process(
        COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE NB_DIR)
      list(APPEND CMAKE_PREFIX_PATH "${NB_DIR}")

      find_package(
        nanobind
        BYPASS_PROVIDER
        CONFIG
        REQUIRED)
    endif()

    if(NOT TARGET nanobind_pyarrow::pyarrow)
      include(FetchContent)
      FetchContent_Declare(
        nanobind_pyarrow
        GIT_REPOSITORY https://github.com/maximiliank/nanobind_pyarrow.git
        GIT_TAG origin/main
        UPDATE_DISCONNECTED ON)

      FetchContent_MakeAvailable(nanobind_pyarrow)
      set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
      find_package(PyArrow REQUIRED BYPASS_PROVIDER)
    endif()
  endif()

  if(NOT TARGET spdlog::spdlog)
    find_package(spdlog REQUIRED)
  endif()

  if(NOT TARGET GTest::GTest)
    find_package(GTest REQUIRED)
  endif()

endfunction()
