module ScheduleGeneration

using Dates

export ScheduleRule, DailySchedule, MonthlySchedule, QuarterlySchedule, AnnualSchedule, generate_schedule

"""
    ScheduleRule

Abstract type for schedule generation rules. This is the base type for all specific schedule generation rules such as `DailySchedule`, `MonthlySchedule`, `QuarterlySchedule`, etc.
"""
abstract type ScheduleRule end

"""
    DailySchedule <: ScheduleRule

A concrete type representing a rule that generates schedules daily.
"""
struct DailySchedule <: ScheduleRule end

"""
    MonthlySchedule <: ScheduleRule

A concrete type representing a rule that generates schedules monthly.
"""
struct MonthlySchedule <: ScheduleRule end

"""
    QuarterlySchedule <: ScheduleRule

A concrete type representing a rule that generates schedules quarterly.
"""
struct QuarterlySchedule <: ScheduleRule end

"""
    AnnualSchedule <: ScheduleRule

A concrete type representing a rule that generates schedules annually.
"""
struct AnnualSchedule <: ScheduleRule end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::ScheduleRule) -> Vector{Date}

Generates a sequence of dates between `start_date` and `end_date` based on the specified schedule generation rule.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::ScheduleRule`: The rule for schedule generation (e.g., `DailySchedule`, `MonthlySchedule`, `QuarterlySchedule`, etc.).

# Returns
- `Vector{Date}`: A vector of generated dates.
"""
# Optimized for daily schedules using ranges
function generate_schedule(start_date::Date, end_date::Date, rule::DailySchedule)::Vector{Date}
    return collect(start_date:Day(1):end_date)
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::MonthlySchedule) -> Vector{Date}

Generates a sequence of monthly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::MonthlySchedule`: The rule for generating monthly schedules.

# Returns
- `Vector{Date}`: A vector of generated monthly dates.
"""
# Optimized to avoid push! and manual memory management
function generate_schedule(start_date::Date, end_date::Date, rule::MonthlySchedule)::Vector{Date}
    return collect(start_date:Month(1):end_date)
end


"""
    generate_schedule(start_date::Date, end_date::Date, rule::QuarterlySchedule) -> Vector{Date}

Generates a sequence of quarterly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::QuarterlySchedule`: The rule for generating quarterly dates.
"""
function generate_schedule(start_date::Date, end_date::Date, rule::QuarterlySchedule)::Vector{Date}
    return collect(start_date:Month(3):end_date)
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::YearlySchedule) -> Vector{Date}

Generates a sequence of quarterly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::QuarterlySchedule`: The rule for generating yearly dates.
"""
function generate_schedule(start_date::Date, end_date::Date, rule::YearlySchedule)::Vector{Date}
    return collect(start_date:Year(1):end_date)
end

end