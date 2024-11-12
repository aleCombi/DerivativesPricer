using TestItemRunner
using Hedgehog #TODO:explore the use of @testable to avoid exporting everything from the package.

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

    include("unit/flow_stream/compound_rate_float_stream.jl")
    include("unit/flow_stream/float_rate_stream.jl")

    include("unit/pricing_engine/rate_curves.jl")
    include("unit/pricing_engine/discount_pricing.jl")
    include("unit/pricing_engine/discount_pricing_setup.jl")
    include("unit/pricing_engine/forward_rates.jl")

    # quantlib tests
    include("quantlib/quantlib_setup.jl")
    include("quantlib/day_count_conventions.jl")

    include("quantlib/date_generation/business_day_conventions.jl")
    include("quantlib/date_generation/calendar.jl")
    include("quantlib/date_generation/schedule_generation.jl")

    include("quantlib/flow_stream/fixed_rate_stream.jl")
    include("quantlib/flow_stream/simple_rate_float_stream.jl")
    include("quantlib/flow_stream/compound_rate_float_stream.jl")
    include("quantlib/pricing_engine/discount_pricing.jl")

    # integration_tests
    include("integration_tests/include_integration_tests.jl")
end

include("Aqua.jl")
@run_package_tests filter=ti->!occursin("quantlib", ti.filename)