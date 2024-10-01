using Base.Iterators
"""
    ScheduleRule

Abstract type for schedule generation rules. This is the base type for all specific schedule generation rules such as `DailySchedule`, `Monthly`, `Quarterly`, etc.
"""
abstract type ScheduleRule end

"""
    AbstractScheduleConfig

Abstract type representing the configuration for generating a payment schedule in a stream of cash flows.
"""
abstract type AbstractScheduleConfig end

"""
    AbstractShift

Abstract type representing a shift in time by a specified period.
"""
abstract type AbstractShift end

"""
    TimeShift

Represents a shift in time by a specified period.
"""
struct TimeShift{T<:Period} <: AbstractShift
    shift::T
    from_end::Bool
end

struct NoShift <: AbstractShift
    from_end::Bool
end

shift(time::T, shift::TimeShift) where T <: TimeType = time + shift.shift

"""
    ScheduleConfig

Represents the configuration for generating a payment schedule in a stream of cash flows.

# Fields
- `start_date::Date`: The start date of the schedule.
- `end_date::Date`: The end date of the schedule.
- `schedule_rule::ScheduleRule`: The rule for generating the schedule (e.g., monthly, quarterly).
- `day_count_convention::DayCountConvention`: The convention for calculating time fractions between accrual periods (e.g., ACT/360, ACT/365).
"""
struct ScheduleConfig{T<:TimeType, S<:ScheduleRule, D<:DayCountConvention, R<:AbstractShift} <: AbstractScheduleConfig
    start_date::T
    end_date::T
    schedule_rule::S
    day_count_convention::D
    payment_shift_rule::R
end 

function ScheduleConfig(start_date::T, end_date::T, schedule_rule::S, day_count_convention::D) where {T<:TimeType, S<:ScheduleRule, D<:DayCountConvention}
    return ScheduleConfig(start_date, end_date, schedule_rule, day_count_convention, NoShift(true))
end

function ScheduleConfig(start_date::T, end_date::T, schedule_rule::S) where {T<:TimeType, S<:ScheduleRule}
    return ScheduleConfig(start_date, end_date, schedule_rule, ACT365(), NoShift(true))
end

function ScheduleConfig(start_date::T, end_date::T, schedule_rule::S, payment_shift_rule::R) where {T<:TimeType, S<:ScheduleRule, R<:AbstractShift}
    return ScheduleConfig(start_date, end_date, schedule_rule, ACT365(), payment_shift_rule)
end

struct FloatScheduleConfig{T<:AbstractShift} <: AbstractScheduleConfig
    schedule_config::ScheduleConfig
    fixing_shift_rule::T
end


"""
    Daily <: ScheduleRule

A concrete type representing a rule that generates schedules daily.
"""
struct Daily <: ScheduleRule end

"""
    Monthly <: ScheduleRule

A concrete type representing a rule that generates schedules monthly.
"""
struct Monthly <: ScheduleRule end

"""
    Quarterly <: ScheduleRule

A concrete type representing a rule that generates schedules quarterly.
"""
struct Quarterly <: ScheduleRule end

"""
    Annual <: ScheduleRule

A concrete type representing a rule that generates schedules annually.
"""
struct Annual <: ScheduleRule end

period(::Daily) = Day(1)
period(::Monthly) = Month(1)
period(::Quarterly) = Month(3)
period(::Annual) = Year(1)

"""
    generate_schedule(start_date::Date, end_date::Date, rule::ScheduleRule) -> Vector{Date}

Generates a sequence of dates between `start_date` and `end_date` based on the specified schedule generation rule.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::ScheduleRule`: The rule for schedule generation (e.g., `DailySchedule`, `Monthly`, `Quarterly`, etc.).

# Returns
- `Vector{Date}`: A vector of generated dates.
"""
function generate_schedule(start_date, end_date, rule::S) where S <: ScheduleRule
    return start_date:period(rule):end_date
end

"""
    generate_schedule(schedule_config::ScheduleConfig)

Generate a schedule based on the provided `schedule_config`.

# Arguments
- `schedule_config::ScheduleConfig`: A configuration object containing the start date, end date, and schedule rule.

# Returns
- A schedule generated according to the specified configuration.

# Example
"""
function generate_schedule(schedule_config::ScheduleConfig)
    accrual_schedule = generate_schedule(schedule_config.start_date, schedule_config.end_date, schedule_config.schedule_rule)
    pay_schedule = relative_schedule(accrual_schedule, schedule_config.payment_shift_rule)
    return pay_schedule, accrual_schedule
end

function generate_schedule(float_schedule_config::FloatScheduleConfig)
    schedule_config = float_schedule_config.schedule_config
    accrual_schedule = generate_schedule(schedule_config.start_date, schedule_config.end_date, schedule_config.schedule_rule)
    pay_schedule = relative_schedule(accrual_schedule, schedule_config.payment_shift_rule)
    fixing_schedule = relative_schedule(accrual_schedule, float_schedule_config.fixing_shift_rule)
    return pay_schedule, accrual_schedule, fixing_schedule
end

function relative_schedule(schedule, shift_rule::TimeShift)
    origin_schedule = shift_rule.from_end ? schedule[1:end-1] : schedule[2:end]
    return map(d -> shift(d, shift_rule), origin_schedule)
end

relative_schedule(schedule, shift::NoShift) = shift.from_end ? schedule[2:end] : schedule[1:end-1]