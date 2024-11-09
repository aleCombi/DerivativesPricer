using Interpolations: InterpolationType, BoundaryCondition

"""
    AbstractRateCurve

An abstract type representing the base structure for all rate curves. Specific rate curves should inherit from this type to ensure compatibility within rate curve calculations and interpolations.
"""
abstract type AbstractRateCurve end

"""
    RateCurve{I, C, D, R} <: AbstractRateCurve

A structure representing an interpolated rate curve that leverages an interpolation method to compute rates over a continuous range. The interpolated rate curve uses a specified day count convention, rate type, and supports boundary conditions for extrapolation.

Fields
- `name::String`: Name identifier for the rate curve.
- `day_count_convention::C`: The day count convention used for calculating date-based fractions (e.g., ACT360, 30E360).
- `rate_type::R`: Type of rate (e.g., simple, compounded) used in discounting and rate calculations.
- `date::D`: The anchor date for the rate curve.
- `interpolation::I`: Interpolation object that supports interpolation and optional extrapolation of rate data points.

Type Parameters
- `I<:AbstractInterpolation`: Specifies the interpolation and extrapolation method (e.g., linear, spline).
- `C<:DayCount`: Day count convention used for time fraction calculations.
- `D<:TimeType`: Type representing the date or time basis.
- `R<:RateType`: Type representing the rate calculation basis (e.g., LinearRate).
"""
struct RateCurve{I<:AbstractInterpolation, C<:DayCount, D<:TimeType, R<:RateType} <: AbstractRateCurve
    name::String
    day_count_convention::C
    rate_type::R
    date::D
    interpolation::I
end

"""
    RateCurve(date::D, spine_rates::Vector{N}; interp_method::I=Gridded(Linear()), 
              extrap_method::E=Flat(), day_count_convention::C=ACT360(), rate_type::R=LinearRate(), 
              spine_day_counts::Vector{N}=Vector{N}(), spine_dates::Vector{D}=Vector{D}())

Creates an instance of `RateCurve` based on given spine rates and interpolation settings.

Positional Arguments
- `date::D`: The base date for the rate curve.
- `spine_rates::Vector{N}`: Vector containing the interest rates for interpolation.

Keyword Arguments
- `interp_method::I=Gridded(Linear())`: Specifies the interpolation method to be used for the curve.
- `extrap_method::E=Flat()`: Boundary condition to be applied for extrapolation outside the defined range.
- `day_count_convention::C=ACT360()`: The day count convention used to calculate fractions of time between dates.
- `rate_type::R=LinearRate()`: Type of rate for discounting.
- `spine_day_counts::Vector{N}=Vector{N}()`: Pre-computed day count fractions for the spine dates; calculated automatically if empty.
- `spine_dates::Vector{D}=Vector{D}()`: Vector of dates corresponding to each spine rate.

Returns
- `RateCurve`: An instance of the interpolated rate curve.
"""
function RateCurve(date::D, spine_rates::Vector{N}; interp_method::I=Gridded(Linear()),
                   extrap_method::E=Flat(),
                   day_count_convention::C=ACT360(),
                   rate_type::R=LinearRate(),
                   spine_day_counts::Vector{N}=Vector{N}(),
                   spine_dates::Vector{D}=Vector{D}()) where {D<:TimeType, N<:Number, I<:InterpolationType, E<:BoundaryCondition, C<:DayCount, R<:RateType}
    if length(spine_rates) == length(spine_dates) && length(spine_day_counts) == 0
        spine_day_counts = day_count_fraction(date, spine_dates, day_count_convention)
    end
    if length(spine_rates) != length(spine_day_counts)
        return error("Wrong inputs for curve creation.")
    end
    interpolation = interpolate((spine_day_counts,), spine_rates, interp_method) 
    extrap_interp = extrapolate(interpolation, extrap_method)
    return RateCurve("Curve", day_count_convention, rate_type, date, extrap_interp)
end

"""
    discount_factor(rate_curve::RateCurve, date)

Calculates the discount factor at a specified date using an interpolated rate curve.

Arguments
- `rate_curve::RateCurve`: The interpolated rate curve to evaluate.
- `date`: Target date for which the discount factor is calculated.

Returns
- `Float64`: Discount factor for the specified date.
"""
function discount_factor(rate_curve::RateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return discount_interest(rate_curve.interpolation(delta), delta, rate_curve.rate_type)
end

"""
    FlatRateCurve{D, T, C, R} <: AbstractRateCurve

Represents a flat rate curve with a constant rate applied throughout. This type of curve is typically used when the interest rate is fixed and does not vary over time.

Fields
- `name::String`: Name identifier for the flat rate curve.
- `date::D`: Base date for the flat rate curve.
- `rate::T`: The fixed interest rate applied across all time periods.
- `day_count_convention::C`: Day count convention used for time-based calculations.
- `rate_type::R`: Rate calculation type (e.g., LinearRate).

Type Parameters
- `D<:TimeType`: The date or time basis type.
- `T`: Type of the fixed rate.
- `C<:DayCount`: The day count convention used.
- `R<:RateType`: The rate calculation type.
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

Calculates the discount factor at a specified date using a flat rate curve.

Arguments
- `rate_curve::FlatRateCurve`: The flat rate curve to evaluate.
- `date`: Target date for which the discount factor is calculated.

Returns
- `Float64`: Discount factor for the specified date.
"""
function discount_factor(rate_curve::FlatRateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return discount_interest(rate_curve.rate, delta, rate_curve.rate_type)
end
