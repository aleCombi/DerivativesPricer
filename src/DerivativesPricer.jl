module DerivativesPricer

# Include all the required files
include("day_count_conventions.jl")
include("rate_conventions.jl")
include("date_generation/include_date_generation.jl")
include("fixed_rate_stream.jl")
include("float_rate.jl")
include("rate_curves.jl")
include("float_rate_stream.jl")
include("discount_pricing.jl")

# fake include statements necessary to have LSP working on VS Code
if false
    include("../test/runtests.jl")
    include("../notebooks/includer.jl")
end

# Export relevant functions and types for external use
export  # day_count_conventions.jl
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
