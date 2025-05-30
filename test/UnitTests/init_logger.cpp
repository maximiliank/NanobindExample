#include <spdlog/spdlog.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include "init_logger.h"

void TestUtils::InitSpdlog()
{
    auto console_sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
    auto logger = std::make_shared<spdlog::logger>("console", console_sink);
    spdlog::set_default_logger(logger);
    spdlog::set_level(spdlog::level::debug); // Set log level to debug
    spdlog::flush_on(spdlog::level::debug);  // Flush on debug level
}