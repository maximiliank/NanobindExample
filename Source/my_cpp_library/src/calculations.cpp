#include <my_cpp_library/calculations.h>
#include <numeric>

double Calculations::sum(const std::vector<double>& numbers)
{
    return std::accumulate(numbers.begin(), numbers.end(), 0.0);
}