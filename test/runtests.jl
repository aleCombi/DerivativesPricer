using TestItemRunner
using DerivativesPricer #TODO:explore the use of @testable to avoid exporting everything from the package.

# include test files in VSCODE: necessary to have code completion
if isdefined(@__MODULE__,:LanguageServer)
    include("day_count_conventions.jl")
    include("rate_conventions.jl")
    include("date_generation/include_date_generation.jl")
    include("integration_tests/include_integration_tests.jl")
    include("fixed_rate_stream.jl")
    include("rate_curves.jl")
    include("float_rate_stream.jl")
    include("discount_pricing.jl")
end

@run_package_tests