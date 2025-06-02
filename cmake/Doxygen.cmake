# Enable doxygen doc builds of source
function(nanobind_example_enable_doxygen DOXYGEN_THEME)
  # If not specified, use the top readme file as the first page
  if((NOT DOXYGEN_USE_MDFILE_AS_MAINPAGE) AND EXISTS "${PROJECT_SOURCE_DIR}/README.md")
    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/README.md")
  endif()

  # set better defaults for doxygen
  is_verbose(_is_verbose)
  if(NOT ${_is_verbose})
    set(DOXYGEN_QUIET YES)
  endif()
  set(DOXYGEN_CALLER_GRAPH YES)
  set(DOXYGEN_CALL_GRAPH YES)
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_GENERATE_TREEVIEW YES)
  # svg files are much smaller than jpeg and png, and yet they have higher quality
  set(DOXYGEN_DOT_IMAGE_FORMAT svg)
  set(DOXYGEN_DOT_TRANSPARENT YES)
  set(DOXYGEN_PREDEFINED DOXYGEN_SHOULD_SKIP_THIS)

  # If not specified, exclude the vcpkg files and the files CMake downloads under _deps (like project_options)
  if(NOT DOXYGEN_EXCLUDE_PATTERNS)
    set(DOXYGEN_EXCLUDE_PATTERNS
        "${CMAKE_CURRENT_BINARY_DIR}/vcpkg_installed/*"
        "${CMAKE_CURRENT_BINARY_DIR}/_deps/*"
        "${CMAKE_SOURCE_DIR}/out/*"
        "${CMAKE_SOURCE_DIR}/dev/*"
        "${CMAKE_SOURCE_DIR}/conan2/*"
        "${CMAKE_SOURCE_DIR}/python/*"
        "${CMAKE_SOURCE_DIR}/.vscode/*"
        "${CMAKE_SOURCE_DIR}/.devcontainer/*"
        "${CMAKE_SOURCE_DIR}/.github/*"
        "${CMAKE_SOURCE_DIR}/.venv/*")
  endif()

  if("${DOXYGEN_THEME}" STREQUAL "")
    set(DOXYGEN_THEME "awesome-sidebar")
  endif()

  if("${DOXYGEN_THEME}" STREQUAL "awesome" OR "${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
    include(FetchContent)
    # use a modern doxygen theme
    # https://github.com/jothepro/doxygen-awesome-css v2.3.4
    FetchContent_Declare(
      _doxygen_theme
      URL https://github.com/jothepro/doxygen-awesome-css/archive/refs/tags/v2.3.4.zip
      DOWNLOAD_NO_PROGRESS TRUE)
    FetchContent_MakeAvailable(_doxygen_theme)
    if("${DOXYGEN_THEME}" STREQUAL "awesome" OR "${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
      set(DOXYGEN_HTML_EXTRA_STYLESHEET "${_doxygen_theme_SOURCE_DIR}/doxygen-awesome.css")
    endif()
    if("${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
      set(DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_HTML_EXTRA_STYLESHEET}
                                        "${_doxygen_theme_SOURCE_DIR}/doxygen-awesome-sidebar-only.css")
    endif()
  else()
    # use the original doxygen theme
  endif()

  # find doxygen and dot if available
  find_package(Doxygen BYPASS_PROVIDER REQUIRED OPTIONAL_COMPONENTS dot)

  # add doxygen-docs target
  message(STATUS "Adding `doxygen-docs` target that builds the documentation.")
  doxygen_add_docs(doxygen-docs ALL ${PROJECT_SOURCE_DIR}
                   COMMENT "Generating documentation - entry file: ${CMAKE_CURRENT_BINARY_DIR}/html/index.html")
endfunction()
