using Dates
using Interpolations
using Random
using DerivativesPricer

const InterpType = Interpolations.InterpolationType
const AbstractInterp = Interpolations.AbstractInterpolation

"""
    struct RateCurve{T<:AbstractInterp,C<:DayCountConvention,D<:TimeType}

A structure representing a rate curve.

# Fields
- `name::String`: The name of the rate curve.
- `date::D`: The reference date for the rate curve.
- `interpolation::T`: The interpolation method used for the rate curve.
- `day_count_convention::C`: The day count convention used for the rate curve.
"""
struct RateCurve{T<:AbstractInterp,C<:DayCount,D<:TimeType}
    name::String
    date::D
    interpolation::T
    day_count_convention::C
end

"""
    struct RateCurveInputs{T<:Number, R, I<:InterpType, C<:DayCountConvention, D<:TimeType}

A structure representing the inputs required to create a rate curve.

# Fields
- `times_day_counts::Vector{T}`: Time points stored as day counts.
- `rates::Vector{R}`: Corresponding rates for the time points.
- `interp_method::I`: Interpolation method to be used.
- `date::D`: Reference date for the rate curve.
- `day_count_convention::C`: Day count convention to be used.
"""
struct RateCurveInputs{T<:Number, R, I<:InterpType, C<:DayCount, D<:TimeType}
    times_day_counts::Vector{T}
    rates::Vector{R}
    interp_method::I
    date::D
    day_count_convention::C
    times::Vector{D}
end

"""
    RateCurveInputs(times::Vector{D}, rates::Vector{R}, interp_method::I, date::D, day_count_convention::C) where {D<:TimeType, R, I<:InterpType, C<:DayCountConvention}

Custom constructor for `RateCurveInputs` that converts time points (Dates) to day counts.

# Arguments
- `times::Vector{D}`: Time points as Dates.
- `rates::Vector{R}`: Corresponding rates for the time points.
- `interp_method::I`: Interpolation method to be used.
- `date::D`: Reference date for the rate curve.
- `day_count_convention::C`: Day count convention to be used.

# Returns
- `RateCurveInputs`: An instance of `RateCurveInputs` with time points converted to day counts.
"""
RateCurveInputs(times::Vector{D}, rates::Vector{R}, date::D, interp_method::I=Gridded(Interpolations.Linear()), day_count_convention::C = ACT365()) where {D<:TimeType, R, I<:InterpType, C<:DayCount} =
    RateCurveInputs(day_count_fraction.(date, times, Ref(day_count_convention)), rates, interp_method, date, day_count_convention, times)

"""
    discount_factor(rate_curve::RateCurve, date)

Calculates the discount factor based on the date difference and interpolation.

# Arguments
- `rate_curve::RateCurve`: The rate curve to use for discount factor calculation.
- `date`: The date for which the discount factor is calculated.

# Returns
- `Float64`: The discount factor.
"""
function discount_factor(rate_curve::RateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return rate_curve.interpolation(delta)
end

"""
    create_rate_curve(inputs::RateCurveInputs)

Creates a `RateCurve` from the given `RateCurveInputs`.

# Arguments
- `inputs::RateCurveInputs`: The inputs required to create the rate curve.

# Returns
- `RateCurve`: An instance of `RateCurve`.
"""
function create_rate_curve(inputs::RateCurveInputs)
    interpolation = interpolate((inputs.times_day_counts,), inputs.rates, inputs.interp_method)
    return RateCurve("Curve_$(randstring(5))", inputs.date, interpolation, inputs.day_count_convention)
end

struct FlatRateCurve{D<:TimeType, T, C<:DayCount, R<:RateType}
    name::String
    date::D
    rate::T
    day_count_convention::C
    rate_type::R
end

function discount_factor(rate_curve::FlatRateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return discount_interest(rate_curve.rate, delta, rate_curve.rate_type)
end