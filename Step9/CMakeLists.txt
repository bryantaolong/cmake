cmake_minimum_required(VERSION 3.23)

# TODO9: Add a VERSION parameter to the project() command for version 1.0.0
project(Tutorial
  VERSION 1.0.0
)

option(TUTORIAL_BUILD_UTILITIES "Build the Tutorial executable" ON)
option(TUTORIAL_USE_STD_SQRT "Use std::sqrt" OFF)
option(TUTORIAL_ENABLE_IPO "Check for and use IPO support" ON)
option(BUILD_TESTING "Enable testing and build tests" ON)

if(TUTORIAL_ENABLE_IPO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    message("IPO is supported, enabling IPO")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    message(WARNING "IPO is not supported: ${output}")
  endif()
endif()

if(TUTORIAL_BUILD_UTILITIES)
  add_subdirectory(Tutorial)
  # TODO1: Install the Tutorial target
  # install(TARGETS Tutorial)

  # TODO3: Add the Tutorial target to the TutorialTargets export
   install(
    TARGETS Tutorial
    EXPORT TutorialTargets
  )
endif()

if(BUILD_TESTING)
  enable_testing()
  add_subdirectory(Tests)
endif()

add_subdirectory(MathFunctions)

# TODO4: Include the GNUInstallDirs module
include(GNUInstallDirs)

# TODO2: Install the MathFunctions, OpAdd, OpMul, OpSub, SqrtTable, and
#        MathLogger targets. Ensure you name their header file set so the
#        headers will be installed.
# install(
#   TARGETS MathFunctions OpAdd OpMul OpSub SqrtTable MathLogger
#   FILE_SET HEADERS)

# TODO5: Add the targets from TODO2 to the TutorialTargets export
install(
  TARGETS MathFunctions OpAdd OpMul OpSub MathLogger SqrtTable
  EXPORT TutorialTargets
  FILE_SET HEADERS
)

# TODO6: Install the TutorialTargets export to:
#          ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
#        And give them a namespace of "Tutorial::"
install(
  EXPORT TutorialTargets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
  NAMESPACE Tutorial::
)

# TODO10: Include CMakePackageConfigHelpers
include(CMakePackageConfigHelpers)

# TODO11: Use write_basic_package_version_file to write a
#         TutorialConfigVersion.cmake file to the CMAKE_CURRENT_BINARY_DIR.
#         The version compatibility should be ExactVersion.
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  COMPATIBILITY ExactVersion
)

# TODO12: Add the generated TutorialConfigVersion.cmake file to the file list
#         of the TODO7 install() command.
install(
  FILES
    cmake/TutorialConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/TutorialConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
)

# TODO7: Install the config file at cmake/TutorialConfig.cmake to the same
#        destination as the TutorialTargets export.
# install(
#   FILES
#     cmake/TutorialConfig.cmake
#   DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Tutorial
# )