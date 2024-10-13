"""
    AbstractRateIndex

An abstract type representing a rate index. This type is used to define the rate index for a floating-rate stream.
"""
abstract type AbstractRateIndex end

"""
    RateIndex

A structure representing a rate index.

# Fields
- `name::String`: The name of the rate index.
"""
struct RateIndex
    name::String
end

abstract type RateConfig end

struct LinearRateConfig{P, R<:AbstractRateIndex, D<:DayCountConvention, C<:AbstractShift, N<:AbstractMarginConfig}
    <:RateConfig
    rate_index::R
    day_count_convention::D
    rate_convention::Linear
    fixing_shift::C
    margin::N
end

struct CompoundRateConfig{P, R<:AbstractRateIndex, D<:DayCountConvention, C<:AbstractShift, S<:AbstractScheduleConfig, M<:AbstractMarginConfig, Mode<:AbstractCompoundMarginMode}
    <:RateConfig
    rate_index::R
    day_count_convention::D
    rate_convention::Compounded
    fixing_shift::C
    compound_schedule::S
    margin::M
    marginMode::Mode
end
# TODO: Think of good initializers with sensible default arguments (e.g. no margin, no fixing shift), 
# check if the compound schedule is compatible with the accrual schedule.
# TODO: Substitute the rate convention? The usefulness of it is that it also applies to fixed rates..
abstract type AbstractMarginConfig end

struct AdditiveMargin{N<:Number}
    margin::N
end

struct MultiplicativeMargin{N<:Number}
    margin::N
end

abstract type AbstractCompoundMarginMode end

struct MarginOnUnderlying end
struct MarginOnCompoundedRate end