# TODO8: Include the CMakeFindDependencyMacro and use find_dependency to find
#        the TransitiveDep package.
include(CMakeFindDependencyMacro)
find_dependency(TransitiveDep)

include(${CMAKE_CURRENT_LIST_DIR}/SimpleTestTargets.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/simpletest_discover_tests.cmake)
