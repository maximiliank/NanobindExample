#pragma once

#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h>
#include <spdlog/details/null_mutex.h>
#include <spdlog/details/synchronous_factory.h>
#include <spdlog/sinks/base_sink.h>
#include <spdlog/spdlog.h>

#include <mutex>
#include <iostream>

namespace Bindings::Logging {
    namespace detail {

        enum LevelFilter : std::uint8_t {
            Off = 0,
            Trace = 5,
            Debug = 10,
            Info = 20,
            Warn = 30,
            Error = 40,
            Critical = 50,
        };


        template<typename Mutex>
        class nanobind_sink : public spdlog::sinks::base_sink<Mutex> {
          public:
            void sink_it_(const spdlog::details::log_msg& msg) override
            {
                // Acquire GIL to interact with Python interpreter
                nanobind::gil_scoped_acquire acquire;
                if (py_logger_.is_none())
                {
                    auto py_logging = nanobind::module_::import_("logging");
                    py_logger_ = py_logging.attr("getLogger")(name_);
                }
                std::string filename = msg.source.filename ? msg.source.filename : "";
                std::string msg_payload = std::string(msg.payload.begin(), msg.payload.end());

                int level = static_cast<int>(map_level(msg.level));

                if (is_enabled(level))
                {
                    auto record = py_logger_.attr("makeRecord")(
                            name_, level, filename, msg.source.line, msg_payload, nanobind::none(), nanobind::none());
                    py_logger_.attr("handle")(record);
                }
            }

            void flush_() override {}

            void set_name(const std::string& logger_name)
            {
                name_ = logger_name;
            }

          private:
            nanobind::object py_logger_ = nanobind::none();
            std::string name_;

            bool is_enabled(int level)
            {
                return nanobind::cast<bool>(py_logger_.attr("isEnabledFor")(level));
            }

            /// Map from spdlog logging level to Python logging level
            static LevelFilter map_level(spdlog::level::level_enum level)
            {
                switch (level)
                {
                    case spdlog::level::trace:
                        return LevelFilter::Trace;
                    case spdlog::level::debug:
                        return LevelFilter::Debug;
                    case spdlog::level::info:
                        return LevelFilter::Info;
                    case spdlog::level::warn:
                        return LevelFilter::Warn;
                    case spdlog::level::err:
                        return LevelFilter::Error;
                    case spdlog::level::critical:
                        return LevelFilter::Critical;
                    case spdlog::level::off:
                    default:
                        return LevelFilter::Off;
                }
            }
        };


    }


    template<bool UseMultiThreadedLogger = true>
    class SetupSpdlogSink {
      public:
        explicit SetupSpdlogSink(const std::string& loggerName)
        {
            std::cout << "Setting up spdlog sink with logger name: " << loggerName << std::endl;
            using Sink = std::conditional_t<UseMultiThreadedLogger, detail::nanobind_sink<std::mutex>,
                    detail::nanobind_sink<spdlog::details::null_mutex>>;
            using Factory = spdlog::synchronous_factory;

            auto ptr = Factory::template create<Sink>(loggerName);
            auto sink_ptr = std::dynamic_pointer_cast<Sink>(ptr->sinks().back());
            sink_ptr->set_name(loggerName);
            spdlog::set_default_logger(ptr);
        }
    };
}