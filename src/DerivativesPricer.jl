module DerivativesPricer

# Include all the required files
include("day_count_conventions.jl")
include("rate_conventions.jl")
include("schedule_generation.jl")
include("fixed_rate_stream.jl")
include("rate_curves.jl")
include("float_rate_stream.jl")
include("discount_pricing.jl")

# Export relevant functions and types for external use
export  DayCountConvention, ACT360, ACT365, day_count_fraction,
        # day_count_conventions.jl
        RateType, Linear, Compounded, Exponential, calculate_interest,
        # rate_conventions.jl
        ScheduleRule, Daily, Monthly, Quarterly, Annual, generate_schedule,
        # schedule_generation.jl
        FlowStream, ScheduleConfig, FixedRateStreamConfig, FixedRateStream, AbstractScheduleConfig,
        # fixed_rate_stream.jl
        RateCurve, RateCurveInputs, create_rate_curve, discount_factor,
        # rate_curves.jl
        AbstractRateIndex, FloatRateStreamConfig, FloatingRateStream, RateIndex,
        # float_rate_stream.jl
        price_fixed_flows_stream, calculate_forward_rates, price_float_rate_stream
        # discount_pricing.jl
end
