"""
    ScheduleRule

Abstract type for schedule generation rules. This is the base type for all specific schedule generation rules such as `DailySchedule`, `Monthly`, `Quarterly`, etc.
"""
abstract type ScheduleRule end

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
function generate_schedule(start_date::Date, end_date::Date, ::Daily)::Vector{Date}
    return collect(start_date:Day(1):end_date)
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
function generate_schedule(start_date::Date, end_date::Date, ::Monthly)::Vector{Date}
    return collect(start_date:Month(1):end_date)
end


"""
    generate_schedule(start_date::Date, end_date::Date, rule::Quarterly) -> Vector{Date}

Generates a sequence of quarterly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::Quarterly`: The rule for generating quarterly dates.
"""
function generate_schedule(start_date::Date, end_date::Date, ::Quarterly)::Vector{Date}
    return collect(start_date:Month(3):end_date)
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::Annual) -> Vector{Date}

Generates a sequence of yearly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::Annual`: The rule for generating yearly dates.
"""
function generate_schedule(start_date::Date, end_date::Date, ::Annual)::Vector{Date}
    return collect(start_date:Year(1):end_date)
end