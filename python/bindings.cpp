#include <memory>
#include <nanobind/nanobind.h>
#include <nanobind/stl/vector.h>
#include <nanobind_pyarrow/pyarrow_import.h>
#include <nanobind_pyarrow/table.h>
#include <nanobind_pyarrow/type.h>
#include <spdlog/spdlog.h>
#include "spdlog_sink.hpp"
#include <my_cpp_library/calculations.h>
#include <nanobind_pyarrow/array_primitive.h>
#include <arrow/compute/api.h> // Include Arrow compute functions

namespace nb = nanobind;

// NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables, misc-use-anonymous-namespace, readability-identifier-length)
NB_MODULE(python_ext, m)
{
    using namespace nb::literals;

    static nb::detail::pyarrow::ImportPyarrow module;
    static Bindings::Logging::SetupSpdlogSink logger("NanobindExample");

    nb::set_leak_warnings(true);

    m.doc() = "Python bindings using nanobind";

    m.def(
            "my_function",
            [](int value, double scaling) {
                spdlog::info("my_function called with value: {}, scaling: {}", value, scaling);
                return value * scaling;
            },
            "value"_a, "scaling"_a, "A simple function that multiplies value by scaling");

    m.def("sum", &Calculations::sum, "numbers"_a, "Calculate the sum of a list of numbers");

    m.def(
            "square_array",
            [](std::shared_ptr<arrow::DoubleArray> arr) {
                auto result = arrow::compute::CallFunction("multiply", {arr, arr});
                if (!result.ok())
                {
                    throw std::runtime_error(result.status().ToString());
                }
                return std::static_pointer_cast<arrow::DoubleArray>(result.ValueOrDie().make_array());
            },
            "array"_a, "Square each element in a DoubleArray using Arrow compute");

    m.def(
            "table_function",
            [](std::shared_ptr<arrow::Table> table) { spdlog::info("calculate for {}", table->num_rows()); }, "table"_a,
            "Calculate based on table");

    m.def("echo", []() { spdlog::info("Test message from bindings"); }, "Printing a message to the log");
}
