#project(CmakeConfigPackageTests LANGUAGES CXX)

# ---- Test as standalone project the exported config package ----

if(PROJECT_IS_TOP_LEVEL OR TEST_INSTALLED_VERSION)
  enable_testing()

  # find_package(
  #   NanobindExample
  #   BYPASS_PROVIDER
  #   CONFIG
  #   REQUIRED) # for intro, project_options, ...

  # if(NOT TARGET NanobindExample_options)
  #   message(FATAL_ERROR "Required config package not found!")
  #   return() # be strictly paranoid for Template Janitor github action! CK
  # endif()
endif()

add_subdirectory(UnitTests)
add_subdirectory(CompileTimeChecks)
