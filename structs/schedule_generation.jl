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
function generate_schedule(start_date::Date, end_date::Date, rule::DailySchedule)::Vector{Date}
    dates = Date[]
    current_date = start_date
    while current_date <= end_date
        push!(dates, current_date)
        current_date += Day(1)
    end
    return dates
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
function generate_schedule(start_date::Date, end_date::Date, rule::MonthlySchedule)::Vector{Date}
    dates = Date[]
    current_date = start_date
    while current_date <= end_date
        push!(dates, current_date)
        current_date = add_months(current_date, 1)
    end
    return dates
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::QuarterlySchedule) -> Vector{Date}

Generates a sequence of quarterly dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::QuarterlySchedule`: The rule for generating quarterly schedules.

# Returns
- `Vector{Date}`: A vector of generated quarterly dates.
"""
function generate_schedule(start_date::Date, end_date::Date, rule::QuarterlySchedule)::Vector{Date}
    dates = Date[]
    current_date = start_date
    while current_date <= end_date
        push!(dates, current_date)
        current_date = add_months(current_date, 3)
    end
    return dates
end

"""
    generate_schedule(start_date::Date, end_date::Date, rule::AnnualSchedule) -> Vector{Date}

Generates a sequence of annual dates between `start_date` and `end_date`.

# Arguments
- `start_date::Date`: The starting date of the schedule.
- `end_date::Date`: The ending date of the schedule.
- `rule::AnnualSchedule`: The rule for generating annual schedules.

# Returns
- `Vector{Date}`: A vector of generated annual dates.
"""
function generate_schedule(start_date::Date, end_date::Date, rule::AnnualSchedule)::Vector{Date}
    dates = Date[]
    current_date = start_date
    while current_date <= end_date
        push!(dates, current_date)
        current_date = add_years(current_date, 1)
    end
    return dates
end

"""
    add_months(date::Date, n::Int) -> Date

Adds `n` months to a date, handling edge cases where the date is at the end of the month. For example, if the start date is January 31st, adding one month results in February 28th (or 29th in leap years).

# Arguments
- `date::Date`: The original date.
- `n::Int`: The number of months to add.

# Returns
- `Date`: The date after adding `n` months, adjusted for end-of-month cases.
"""
function add_months(date::Date, n::Int)::Date
    y, m = Dates.year(date), Dates.month(date)
    new_m = m + n
    new_y = y + div(new_m - 1, 12)
    new_m = mod(new_m - 1, 12) + 1
    d = min(Dates.day(date), Dates.daysinmonth(Date(new_y, new_m, 1)))
    return Date(new_y, new_m, d)
end

"""
    add_years(date::Date, n::Int) -> Date

Adds `n` years to a date, handling leap years and end-of-month cases.

# Arguments
- `date::Date`: The original date.
- `n::Int`: The number of years to add.

# Returns
- `Date`: The date after adding `n` years, adjusted for leap years and end-of-month cases.
"""
function add_years(date::Date, n::Int)::Date
    y, m, d = Dates.year(date), Dates.month(date), Dates.day(date)
    new_y = y + n
    d = min(d, Dates.daysinmonth(Date(new_y, m, 1)))
    return Date(new_y, m, d)
end

end  # End of module
