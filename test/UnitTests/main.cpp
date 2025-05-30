#include <gtest/gtest.h>
#include "init_logger.h"

int main(int argc, char** argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    TestUtils::InitSpdlog();
    return RUN_ALL_TESTS();
}