using TestItemRunner
using DerivativesPricer #TODO:explore the use of @testable to avoid exporting everything from the package.

# fake include test files: necessary to have code completion
if false
    # unit tests
    include("unit/day_count_conventions.jl")
    include("unit/date_generation/business_day_conventions.jl")
    include("unit/date_generation/calendar.jl")
    include("unit/date_generation/date_shift.jl")
    include("unit/date_generation/roll_conventions.jl")
    include("unit/date_generation/schedule_generation.jl")
    include("unit/date_generation/instrument_schedule.jl")
    include("unit/rate_definition/rate_conventions.jl")
    include("unit/rate_definition/margin.jl")

    include("fixed_rate_stream.jl")
    include("rate_curves.jl")
    include("float_rate_stream.jl")
    include("discount_pricing.jl")

    # quantlib tests
    include("quantlib/day_count_conventions.jl")
    include("quantlib/date_generation/business_day_conventions.jl")
    include("quantlib/date_generation/calendar.jl")
    include("quantlib/date_generation/schedule_generation.jl")

    # integration_tests
    include("integration_tests/include_integration_tests.jl")
end

@run_package_tests filter=ti->!occursin("quantlib", ti.filename)