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

function generate_schedule(start_date, end_date, schedule_config::S) where S <: AbstractScheduleConfig
    
end

function generate_schedule_forward(start_date, end_date, schedule_config::S) where S <: AbstractScheduleConfig
    dates = []
    current_date = start_date
    while current_date <= end_date
        current_date = adjust_date(current_date, schedule_config.calendar, schedule_config.roll_convention) # adjust date to business day
        current_date = roll_date(current_date, schedule_config.roll_convention) # roll date according to roll convention (e.g. EOM)
        push!(dates, current_date)
        current_date += schedule_config.period
    end
end

function generate_schedule_backwards(start_date, end_date, schedule_config::S) where S <: AbstractScheduleConfig
    dates = []
    current_date = end_date
    while current_date >= start_date
        current_date = adjust_date(current_date, schedule_config.calendar, schedule_config.roll_convention) # adjust date to business day
        current_date = roll_date(current_date, schedule_config.roll_convention) # roll date according to roll convention (e.g. EOM)
        push!(dates, current_date)
    end
end