"""
    ScheduleRule

Abstract type for schedule generation rules. This is the base type for all specific schedule generation rules such as `DailySchedule`, `Monthly`, `Quarterly`, etc.
"""
abstract type ScheduleRule end

"""
    ScheduleConfig

Represents the configuration for generating a payment schedule in a stream of cash flows.

# Fields
- `start_date::Date`: The start date of the schedule.
- `end_date::Date`: The end date of the schedule.
- `schedule_rule::ScheduleRule`: The rule for generating the schedule (e.g., monthly, quarterly).
- `day_count_convention::DayCountConvention`: The convention for calculating time fractions between accrual periods (e.g., ACT/360, ACT/365).
"""
struct ScheduleConfig{T<:TimeType, S<:ScheduleRule, D<:DayCountConvention}
    start_date::T
    end_date::T
    schedule_rule::S
    day_count_convention::D
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
function generate_schedule(start_date, end_date, ::Daily)
    return start_date:Day(1):end_date
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::Monthly) -> Vector{Date}

Generates a sequence of monthly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::Monthly`: The rule for generating monthly schedules.

# Returns
- `Vector{Date}`: A vector of generated monthly dates.
"""
function generate_schedule(start_date, end_date, ::Monthly)
    return start_date:Month(1):end_date
end


"""
    generate_schedule(start_date::Date, end_date::Date, rule::Quarterly) -> Vector{Date}

Generates a sequence of quarterly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::Quarterly`: The rule for generating quarterly dates.
"""
function generate_schedule(start_date, end_date, ::Quarterly)
    return start_date:Month(3):end_date
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::Annual) -> Vector{Date}

Generates a sequence of yearly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::Annual`: The rule for generating yearly dates.
"""
function generate_schedule(start_date, end_date, ::Annual)
    return start_date:Year(1):end_date
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
    return generate_schedule(schedule_config.start_date, schedule_config.end_date, schedule_config.schedule_rule)
end