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

"""
    NoShift()

By default schedules are generated from the end date of each accrual period.
"""
NoShift() = NoShift(true)

shift(time::T, shift::TimeShift) where T <: TimeType = time + shift.shift

relative_schedule(accrual_schedule, shift_rule::NoShift) = shift_rule.from_end ? accrual_schedule[2:end] : accrual_schedule[1:end-1]