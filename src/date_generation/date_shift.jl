using BusinessDays

"""
    AbstractShift

An abstract type representing a time shift by a specified period from an accrual period.
"""
abstract type AbstractShift end

"""
    TimeShift

Represents a shift in time by a specified period from either the start or end of an accrual period.

# Fields
- `shift`: The period to shift by, defined as a subtype of `Period`.
- `from_end`: A boolean indicating whether the shift is applied from the end of the accrual period (`true`) or from the start (`false`).
"""
struct TimeShift{T<:Period} <: AbstractShift
    shift::T
    from_end::Bool
end

"""
    TimeShift(period::P) where {P <: Period}

Creates a `TimeShift` with the specified period, applying the shift in the forward direction by default.

# Arguments
- `period::P`: The period over which the shift is applied (e.g., `Day`, `Month`, `Year`).

# Returns
- A `TimeShift` object representing the shift with the specified period in the forward direction.
"""
function TimeShift(period::P) where {P<:Period}
    return TimeShift(period, true)
end

"""
    NoShift

A shift type that does not apply any shift, simply selects the start or end date of each period based on `from_end`.

# Fields
- `from_end`: A boolean indicating whether to use the end date (`true`) or the start date (`false`) of each period.
"""
struct NoShift <: AbstractShift
    from_end::Bool
end

"""
    NoShift()

Creates a `NoShift` object with default behavior to use the end date of each period.

# Returns
- An instance of `NoShift`.
"""
function NoShift()
    return NoShift(true)
end

"""
    BusinessDayShift

A shift in time by a specified number of business days, determined by a holiday calendar, from either the start or end of an accrual period.

# Fields
- `shift`: The number of business days to shift.
- `calendar`: The holiday calendar used to determine business days.
- `from_end`: A boolean indicating whether the shift is applied from the end (`true`) or the start (`false`) of the accrual period.
"""
struct BusinessDayShift{C <: HolidayCalendar} <: AbstractShift
    shift::Int
    calendar::C
    from_end::Bool
end

"""
    shifted_schedule(schedule, shift_rule::NoShift)

Generates a schedule identical to the input schedule, without applying any shift.
The schedule may use either the start or end date based on `shift_rule.from_end`.

# Arguments
- `schedule`: The original schedule of dates.
- `shift_rule`: A `NoShift` instance indicating whether to use start or end dates.

# Returns
- The unshifted schedule of dates.
"""
function shifted_schedule(schedule, ::NoShift)
    return schedule
end

"""
    shifted_schedule(schedule, shift_rule::TimeShift)

Shifts the input schedule by a specified period to create a payment or fixing schedule.
Applies the shift from either the start or end date of each accrual period based on `shift_rule.from_end`.

# Arguments
- `schedule`: The original schedule of dates.
- `shift_rule`: A `TimeShift` instance specifying the shift period and direction.

# Returns
- The shifted schedule of dates.
"""
function shifted_schedule(schedule, shift_rule::TimeShift)
    return schedule .+ shift_rule.shift
end

"""
    shifted_schedule(schedule, shift_rule::BusinessDayShift)

Shifts the input schedule by a specified number of business days according to a holiday calendar.

# Arguments
- `schedule`: The original schedule of dates.
- `shift_rule`: A `BusinessDayShift` instance specifying the number of business days to shift and the holiday calendar.

# Returns
- The business day-shifted schedule of dates.
"""
function shifted_schedule(schedule, shift_rule::BusinessDayShift)
    return advancebdays.(shift_rule.calendar, schedule, shift_rule.shift)
end

"""
    shifted_trimmed_schedule(accrual_schedule, shift_rule::BusinessDayShift)

Creates a shifted schedule by moving each date in the accrual schedule by a specified number of business days.
Trims either the first or last date in the schedule based on `shift_rule.from_end`.

# Arguments
- `accrual_schedule`: The original schedule of dates.
- `shift_rule`: A `BusinessDayShift` instance defining the business day shift and calendar.

# Returns
- The shifted and trimmed schedule of dates.
"""
function shifted_trimmed_schedule(accrual_schedule, shift_rule::S) where S <: AbstractShift
    unshifted_schedule = shift_rule.from_end ? accrual_schedule[2:end] : accrual_schedule[1:end-1]
    return shifted_schedule(unshifted_schedule, shift_rule)
end