module DerivativesPricer

# Include all the required files
include("day_count_conventions.jl")
include("rate_conventions.jl")
include("schedule_generation.jl")
include("fixed_rate_stream.jl")

# Export relevant functions and types for external use
export  DayCountConvention, ACT360, ACT365, day_count_fraction,
        # day_count_conventions.jl
        Linear, Compounded, Exponential, calculate_interest,
        # rate_conventions.jl
        ScheduleRule, Daily, Monthly, Quarterly, Annual, generate_schedule,
        # schedule_generation.jl
        ScheduleConfig, FixedRateStreamConfig, FixedRateStream
        # fixed_rate_stream.jl
end
