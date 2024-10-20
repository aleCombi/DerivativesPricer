module DerivativesPricer

# Include all the required files
include("day_count_conventions.jl")
include("date_generation/include_date_generation.jl")
include("rate_definition/include_rate_definition.jl")
include("flow_stream/include_flow_stream.jl")
include("rate_curves.jl")
include("discount_pricing.jl")

# fake include statements necessary to have LSP working on VS Code
if false
    include("../test/runtests.jl")
    include("../notebooks/includer.jl")
end

# Export relevant functions and types for external use

export  DayCount, ACT360, ACT365, DayCount30360, day_count_fraction,
        # day_count_conventions.jl
        RateType, Linear, Compounded, Exponential, calculate_interest,
        # rate_conventions.jl
        FlowStream, ScheduleConfig, FixedRateStreamConfig, FixedRateStream,
        # fixed_rate_stream.jl
        RateCurve, RateCurveInputs, create_rate_curve, discount_factor,
        # rate_curves.jl
        FloatRateStreamConfig, FloatingRateStream,
        # float_rate_stream.jl
        price_fixed_flows_stream, calculate_forward_rates, price_float_rate_stream,
        # discount_pricing.jl
        AbstractRateIndex, RateIndex
        # float_rate.jl
end
