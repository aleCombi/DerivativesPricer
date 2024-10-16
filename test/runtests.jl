using TestItemRunner
using DerivativesPricer

# include test files in VSCODE: necessary to have code completion
if isdefined(@__MODULE__,:LanguageServer)
    include("day_count_conventions.jl")
    include("rate_conventions.jl")
    include("date_generation/roll_conventions.jl")
    include("date_generation/date_shift.jl")
    include("date_generation/schedule_generation.jl")
    include("fixed_rate_stream.jl")
    include("rate_curves.jl")
    include("float_rate_stream.jl")
    include("discount_pricing.jl")
end

@run_package_tests