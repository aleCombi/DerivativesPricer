using BusinessDays

"""
    AbstractScheduleConfig

Abstract type representing the configuration for generating an accrual schedule in a stream of cash flows.
"""
abstract type AbstractScheduleConfig end

"""
    ScheduleConfig

Represents the configuration for generating a payment schedule in a stream of cash flows.

# Fields
- `start_date::Date`: The start date of the schedule.
- `end_date::Date`: The end date of the schedule.
- `schedule_rule::ScheduleRule`: The rule for generating the schedule (e.g., monthly, quarterly).
- `day_count_convention::DayCountConvention`: The convention for calculating time fractions between accrual periods (e.g., ACT/360, ACT/365).
"""
struct ScheduleConfig{P <:Period, R<:RollConvention, B<:BusinessDayConvention, C<:HolidayCalendar} <: AbstractScheduleConfig
    period::P
    roll_convention::R
    business_days_convention::B
    calendar::C
    stub_period::StubPeriod
end 

"""
    date_corrector(schedule_config::S)

Returns a function that adjusts a date according to the given schedule configuration, applying first adjustment conventions like EOM and then business day adjustment.

# Arguments
- `schedule_config::S`: The schedule configuration.

# Returns
- A function that adjusts a date according to the given schedule configuration.
"""
function date_corrector(schedule_config::ScheduleConfig)
    return date -> adjust_date(roll_date(date, schedule_config.roll_convention), schedule_config.calendar, schedule_config.business_days_convention)
end

"""
    generate_unadjusted_dates(start_date, end_date, stub_period::StubPeriod, period::P) where P <: Period

Generates a stream of unadjusted dates according to the given period and stub period.

# Arguments
- `start_date`: The start date of the schedule.
- `end_date`: The end date of the schedule.
- `stub_period::StubPeriod`: The stub period configuration.
- `period::P`: The period.

# Returns
- A stream of unadjusted dates.
"""
function generate_unadjusted_dates(start_date, end_date, stub_period::StubPeriod, period::P) where P <: Period
    if isa(stub_period.position, BackStub)
        return Iterators.flatten((start_date:period:end_date, end_date))
    elseif isa(stub_period.position, FrontStub)
        return Iterators.flatten((end_date:-period:start_date, start_date))
    else
        throw(ArgumentError("Invalid stub period position."))
    end
end

"""
    generate_schedule(unadjusted_dates, schedule_config::S) where S <: AbstractScheduleConfig

Generates a schedule of adjusted dates according to the given schedule configuration.

# Arguments
- `unadjusted_dates`: A stream of unadjusted dates.
- `schedule_config::S`: The schedule configuration.

# Returns
- A schedule of adjusted dates.
"""
function generate_schedule(unadjusted_dates, schedule_config::S) where S <: AbstractScheduleConfig
    date_corrector = date_corrector(schedule_config)
    adjusted_dates = Iterators.map(date_corrector, unadjusted_dates)
    return adjusted_dates
end