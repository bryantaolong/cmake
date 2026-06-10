add_executable(TestMathFunctions)

target_sources(TestMathFunctions
  PRIVATE
    TestMathFunctions.cxx
)

# TODO1: Find the SimpleTest package. This should be a required dependency when
#        building tests.
find_package(SimpleTest REQUIRED)

# TODO2: Add the SimpleTest::SimpleTest target to Test MathFunctions
target_link_libraries(TestMathFunctions
  PRIVATE
    MathFunctions
    SimpleTest::SimpleTest
)

# TODO3: Replace MathFunctionTest and all the calls to it with
#        simpletest_discover_tests called on TestMathFunctions
simpletest_discover_tests(TestMathFunctions)