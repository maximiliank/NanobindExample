#include <gtest/gtest.h>
#include <gmock/gmock-matchers.h>
#include <my_cpp_library/calculations.h>


namespace {
    TEST(Test, Sum)
    {
        // NOLINTNEXTLINE(cppcoreguidelines-avoid-magic-numbers,readability-magic-numbers)
        std::vector<double> numbers = {1.0, 2.0, 3.0, 4.0, 5.0};
        double result = Calculations::sum(numbers);
        EXPECT_DOUBLE_EQ(result, 15.0);
    }
}