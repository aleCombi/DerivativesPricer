module RateStream

using Dates
include("../src/day_count_conventions.jl"); using .DayCount
include("../src/schedule_generation.jl"); using .ScheduleGeneration
include("../src/rate_conventions.jl"); using .RateConventions

abstract type FlowStream end

struct FixedRateStream <: FlowStream
    rate 
    pay_dates::Vector{Date}
    accrual_dates::Vector{Date}
end

function generate_flow_stream(principal::Float64, start_date::Date, end_date::Date, rate, schedule_rule::ScheduleRule, day_count_convention::DayCountConvention, rate_convention::Linear)
    time_fractions = day_count_fraction(start_date, end_date, schedule_rule, day_count_convention)
    return calculate_interest([principal], [rate], time_fractions, rate_convention)
end

function generate_flow_stream(principal::Float64, start_date::Date, end_date::Date, rate, schedule_rule::ScheduleRule, day_count_convention::DayCountConvention, rate_convention::Compounded, frequency::Int)
    time_fractions = day_count_fraction(start_date, end_date, schedule_rule, day_count_convention)
    return calculate_interest([principal], [rate], time_fractions, [frequency], rate_convention)
end

end