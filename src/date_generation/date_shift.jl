using BusinessDays
"""
    AbstractShift

Abstract type representing a shift in time by a specified period from an accrual period.
"""
abstract type AbstractShift end

"""
    TimeShift

Represents a shift in time by a specified period from an accrual period start or end.
"""
struct TimeShift{T<:Period} <: AbstractShift
    shift::T
    from_end::Bool
end

"""
    NoShift

A shift that doesn't shift, just decides to use the start date or end date of each period.
"""
struct NoShift <: AbstractShift
    from_end::Bool
end

struct BusinessDayShift{C <: HolidayCalendar} <: AbstractShift
    shift::Int
    calendar::C
    from_end::Bool
end

"""
    relative_schedule(accrual_schedule, shift_rule::TimeShift)

    NoShift()

By default schedules are generated from the end date of each accrual period.
"""
function NoShift()
    return NoShift(true)
end

"""
    relative_schedule(accrual_schedule, shift_rule::NoShift)

Creates a payment or fixing schedule relative to an accrual schedule without shifting.

# Arguments
- `accrual_schedule`: The dates to be adjusted.
- `shift_rule`: Rule defining how to shift from the accrual schedule.

# Returns
- The shifted dates.
"""
function relative_schedule(accrual_schedule, shift_rule::NoShift)
    return shift_rule.from_end ? accrual_schedule[2:end] : accrual_schedule[1:end-1]
end

"""
    relative_schedule(accrual_schedule, shift_rule::TimeShift)

Shifts the accrual schedule by the specified period to create a payment or fixing schedule.

# Arguments
- `accrual_schedule`: The dates to be adjusted.
- `shift_rule`: Rule defining how to shift from the accrual schedule.

# Returns
- The shifted dates.
"""
function relative_schedule(accrual_schedule, shift_rule::TimeShift)
    unshifted_schedule = shift_rule.from_end ? accrual_schedule[2:end] : accrual_schedule[1:end-1]
    return unshifted_schedule .+ shift_rule.shift
end

"""
    relative_schedule(accrual_schedule, shift_rule::BusinessDayShift)

Shifts the accrual schedule by the specified number of business days to create a payment or fixing schedule.

# Arguments
- `accrual_schedule`: The dates to be adjusted.
- `shift_rule`: Rule defining how to shift from the accrual schedule.

# Returns
- The shifted dates.
"""
function relative_schedule(accrual_schedule, shift_rule::BusinessDayShift)
    unshifted_schedule = shift_rule.from_end ? accrual_schedule[2:end] : accrual_schedule[1:end-1]
    return advancebdays.(shift_rule.calendar, unshifted_schedule, shift_rule.shift)
end