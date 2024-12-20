using Dates
using Hedgehog
# Dummy implementations of RateIndex, ScheduleConfig, and RateType for testing purposes.
struct DummyRateIndex <: AbstractRateIndex end
struct DummyRateType <: RateType end
struct DummyDayCountConvention <: DayCount end
struct DummyScheduleConfig <: AbstractScheduleConfig end
struct DummyInstrumentSchedule <: AbstractInstrumentSchedule
    start_date::Date
    end_date::Date
    schedule_config::DummyScheduleConfig
end

function Hedgehog.generate_schedule(instrument_schedule::DummyInstrumentSchedule)
    return instrument_schedule.start_date:Month(6):instrument_schedule.end_date
end

# Dummy generate_schedule and day_count_fraction functions for testing purposes
function Hedgehog.generate_unadjusted_dates(start_date, end_date, schedule_config::DummyScheduleConfig)
    return start_date:Month(6):end_date  # 6 month schedule
end

function Hedgehog.date_corrector(schedule_config::DummyScheduleConfig)
    return x -> x  # No adjustment
end

function Hedgehog.generate_end_date(start_date, schedule_config::DummyScheduleConfig)
    return start_date .+ Month(6)  # No adjustment
end

function Hedgehog.termination_date_corrector(schedule_config::DummyScheduleConfig)
    return x -> x  # No adjustment
end

function Hedgehog.day_count_fraction(dates, day_count_convention::DummyDayCountConvention)
    return [0.25 for _ in 1:length(dates) - 1]  # Assume quarterly periods with a day count of 0.25
end
