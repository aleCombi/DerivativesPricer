using Dates
using DerivativesPricer
import DerivativesPricer.day_count_fraction, DerivativesPricer.generate_schedule

# Dummy implementations of RateIndex, ScheduleConfig, and RateType for testing purposes.
struct DummyRateIndex <: AbstractRateIndex end
struct DummyRateType <: RateType end
struct DummyScheduleRule <: ScheduleRule end
struct DummyDayCountConvention <: DayCountConvention end
struct DummyScheduleConfig <: AbstractScheduleConfig
    start_date::Date
    end_date::Date
    schedule_rule::DummyScheduleRule
    day_count_convention::DummyDayCountConvention
end

# Dummy generate_schedule and day_count_fraction functions for testing purposes
function generate_schedule(schedule_config::DummyScheduleConfig)
    return Date(schedule_config.start_date):Month(3):Date(schedule_config.end_date)  # Quarterly schedule
end

function day_count_fraction(dates::Vector{Date}, day_count_convention::DummyDayCountConvention)
    return [0.25 for _ in 1:length(dates) - 1]  # Assume quarterly periods with a day count of 0.25
end
