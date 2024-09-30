import DerivativesPricer
using Test
using TestItemRunner
@run_package_tests
include("dummy_struct_functions.jl")
include("test_day_count_conventions.jl")
include("test_rate_conventions.jl")
include("test_schedule_generation.jl")
include("test_fixed_rate_stream.jl")
include("test_float_rate_stream.jl")
include("test_rate_curves.jl")
include("test_discount_pricing.jl")