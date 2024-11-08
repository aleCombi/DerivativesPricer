const InterpType = Interpolations.InterpolationType
const AbstractInterp = Interpolations.AbstractInterpolation

abstract type AbstractRateCurve end

"""
    struct RateCurve{T<:AbstractInterp,C<:DayCount,D<:TimeType}

A structure representing a rate curve with interpolation.

# Fields
- `name::String`: The name of the rate curve.
- `date::D`: The reference date for the rate curve.
- `interpolation::T`: The interpolation method used for the rate curve.
- `day_count_convention::C`: The day count convention used for the rate curve.
"""
struct RateCurve{T<:AbstractInterp,C<:DayCount,D<:TimeType,R<:RateType} <: AbstractRateCurve
    name::String
    date::D
    interpolation::T
    day_count_convention::C
    rate_type::R
end

"""
    struct RateCurveInputs{T<:Number, R, I<:InterpType, C<:DayCount, D<:TimeType}

A structure representing the necessary inputs to create a `RateCurve`.

# Fields
- `times_day_counts::Vector{T}`: Time points stored as day counts.
- `rates::Vector{R}`: Corresponding rates for each time point.
- `interp_method::I`: Interpolation method to be used for the rate curve.
- `date::D`: Reference date for the rate curve.
- `day_count_convention::C`: Day count convention to apply for the rate curve.
- `rate_type::R`: Type of rate (e.g., continuous or simple).
"""
struct RateCurveInputs{T<:Number, R, I<:InterpType, C<:DayCount, D<:TimeType, rate <: RateType}
    times_day_counts::Vector{T}
    rates::Vector{R}
    interp_method::I
    date::D
    day_count_convention::C
    rate_type::rate
    times::Vector{D}
end

"""
    RateCurveInputs(times::Vector{D}, rates::Vector{R}, interp_method::I, date::D, day_count_convention::C) where {D<:TimeType, R, I<:InterpType, C<:DayCount}

Constructor for `RateCurveInputs` that converts time points from Dates to day counts.

# Arguments
- `times::Vector{D}`: Time points as Dates.
- `rates::Vector{R}`: Corresponding rates for each time point.
- `interp_method::I`: Interpolation method to be applied.
- `date::D`: Reference date for the rate curve.
- `day_count_convention::C`: Day count convention for calculating day counts.

# Returns
- `RateCurveInputs`: An instance of `RateCurveInputs` with day counts as time points.
"""
RateCurveInputs(times::Vector{D}, rates::Vector{R}, date::D, interp_method::I=Gridded(Interpolations.Linear()), day_count_convention::C = ACT365()) where {D<:TimeType, R, I<:InterpType, C<:DayCount} =
    RateCurveInputs(vcat(0,day_count_fraction.(date, times, Ref(day_count_convention))), vcat(rates[1],rates), interp_method, date, day_count_convention, LinearRate(), times)

"""
    discount_factor(rate_curve::RateCurve, date)

Calculates the discount factor for a given date on the rate curve.

# Arguments
- `rate_curve::RateCurve`: The rate curve used for discount factor computation.
- `date`: The target date for calculating the discount factor.

# Returns
- `Float64`: The discount factor for the specified date.
"""
function discount_factor(rate_curve::RateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return discount_interest(rate_curve.interpolation(delta), delta, rate_curve.rate_type)
end

"""
    RateCurve(inputs::RateCurveInputs)

Creates a `RateCurve` instance from given `RateCurveInputs`.

# Arguments
- `inputs::RateCurveInputs`: The inputs necessary to define a rate curve.

# Returns
- `RateCurve`: A fully constructed `RateCurve`.
"""
function RateCurve(inputs::RateCurveInputs)
    interpolation = interpolate((inputs.times_day_counts,), inputs.rates, inputs.interp_method) 
    RateCurve("Curve", inputs.date, interpolation, inputs.day_count_convention, inputs.rate_type)
end

"""
    struct FlatRateCurve{D<:TimeType, T, C<:DayCount, R<:RateType}

A structure representing a flat rate curve where the rate is constant.

# Fields
- `name::String`: The name of the flat rate curve.
- `date::D`: The reference date for the flat rate curve.
- `rate::T`: The constant rate applied across the curve.
- `day_count_convention::C`: The day count convention applied to the curve.
- `rate_type::R`: Type of rate (e.g., continuous or simple).
"""
struct FlatRateCurve{D<:TimeType, T, C<:DayCount, R<:RateType} <: AbstractRateCurve
    name::String
    date::D
    rate::T
    day_count_convention::C
    rate_type::R
end

"""
    discount_factor(rate_curve::FlatRateCurve, date)

Calculates the discount factor for a given date using a flat rate curve.

# Arguments
- `rate_curve::FlatRateCurve`: The flat rate curve for discount factor computation.
- `date`: The date for which the discount factor is calculated.

# Returns
- `Float64`: The discount factor for the specified date.
"""
function discount_factor(rate_curve::FlatRateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return discount_interest(rate_curve.rate, delta, rate_curve.rate_type)
end