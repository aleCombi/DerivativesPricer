using TestItemRunner
using DerivativesPricer

include("day_count_conventions.jl")
include("rate_conventions.jl")
include("schedule_generation.jl")
include("fixed_rate_stream.jl")
include("rate_curves.jl")
include("float_rate_stream.jl")
include("discount_pricing.jl")
    
@run_package_tests