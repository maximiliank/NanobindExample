set(TARGET_NAME python_ext)

# We are now ready to compile the actual extension module
# nanobind_add_module(
#   # Name of the extension
#   ${TARGET_NAME}
#   # Target the stable ABI for Python 3.12+, which reduces the number of binary
#   # wheels that must be built. This does nothing on older Python versions
#   STABLE_ABI
#   # Build libnanobind statically and merge it into the extension (which itself
#   # remains a shared library)
#   #
#   # If your project builds multiple extensions, you can replace this flag by
#   # NB_SHARED to conserve space by reusing a shared libnanobind across libraries
#   NB_STATIC
#   # Source code goes here
#   bindings.cpp)

add_library(${TARGET_NAME} MODULE bindings.cpp)

set(NANOBIND_TARGET nanobind-static)
# Build the core parts of nanobind once
nanobind_build_library(${NANOBIND_TARGET})

# .. enable size optimizations
nanobind_opt_size(${TARGET_NAME})

# .. enable link time optimization
nanobind_lto(${TARGET_NAME})

# .. set the default symbol visibility to 'hidden'
nanobind_set_visibility(${TARGET_NAME})

# .. strip unneeded symbols and debug info from the binary (only active in release builds)
nanobind_strip(${TARGET_NAME})

# .. disable the stack protector
nanobind_disable_stack_protector(${TARGET_NAME})

# .. set the Python extension suffix
nanobind_extension(${TARGET_NAME})

# .. set important compilation flags
nanobind_compile_options(${TARGET_NAME})

# .. set important linker flags
nanobind_link_options(${TARGET_NAME})

target_link_libraries(
  ${TARGET_NAME}
  PRIVATE nanobind_pyarrow::nanobind_pyarrow
          nanobind_pyarrow::pyarrow
          NanobindExample::NanobindExample_options
          NanobindExample::NanobindExample_warnings
          my_cpp_library
          spdlog::spdlog)

target_link_system_libraries(${TARGET_NAME} PRIVATE ${NANOBIND_TARGET})

# Install directive for scikit-build-core
set_property(
  TARGET ${TARGET_NAME}
  APPEND
  PROPERTY INSTALL_RPATH "$ORIGIN/lib")

install(
  CODE [[
  file(GET_RUNTIME_DEPENDENCIES
    LIBRARIES $<TARGET_FILE:python_ext>
    RESOLVED_DEPENDENCIES_VAR _r_deps
    UNRESOLVED_DEPENDENCIES_VAR _u_deps
  )
  foreach(_file ${_r_deps})
    if(_file MATCHES ".*lib(arrow|parquet).*\\.so")
      file(INSTALL
        DESTINATION "${CMAKE_INSTALL_PREFIX}/NanobindExample/lib"
        TYPE SHARED_LIBRARY
        FOLLOW_SYMLINK_CHAIN
        FILES "${_file}"
      )
    endif()
  endforeach()
  list(LENGTH _u_deps _u_length)
  if("${_u_length}" GREATER 0)
    message(WARNING "Unresolved dependencies detected!")
  endif()
]])

install(TARGETS ${TARGET_NAME} LIBRARY DESTINATION NanobindExample)

nanobind_add_stub(
  ${TARGET_NAME}_stub
  MODULE
  ${TARGET_NAME}
  OUTPUT
  "${CMAKE_CURRENT_SOURCE_DIR}/src/NanobindExample/${TARGET_NAME}.pyi"
  PYTHON_PATH
  $<TARGET_FILE_DIR:${TARGET_NAME}>
  DEPENDS
  ${TARGET_NAME}
  MARKER_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/NanobindExample/py.typed")

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/NanobindExample/${TARGET_NAME}.pyi"
        DESTINATION "NanobindExample/$<TARGET_PROPERTY:${TARGET_NAME},OUTPUT_NAME>.pyi")
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/NanobindExample/py.typed" DESTINATION NanobindExample)
