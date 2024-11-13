using Interpolations: InterpolationType, BoundaryCondition

abstract type InterpolatedValue end
struct RateXTime<:InterpolatedValue end
struct Rate<:InterpolatedValue end
struct DiscountFactor<:InterpolatedValue end

function convert_interpolated_value(value, from::Rate, to::RateXTime, day_count, rate_type::R) where {R<:RateType, D<:DayCount}
    return value * day_count
end

function convert_interpolated_value(value, from::Rate, to::DiscountFactor, day_count, rate_type::R) where {R<:RateType, D<:DayCount}
    return discount_interest(value, day_count, rate_type)
end

function convert_interpolated_value(value, from::RateXTime, to::Rate, day_count, rate_type::R) where {R<:RateType}
    return value / day_count
end

function convert_interpolated_value(value, from::RateXTime, to::DiscountFactor, day_count, rate_type::R) where {R<:RateType}
    return discount_interest(value / day_count, day_count, rate_type)
end

function convert_interpolated_value(value, from::DiscountFactor, to::Rate, day_count, rate_type::R) where {R<:RateType}
    return implied_rate(1 / value, day_count, rate_type)
end

function convert_interpolated_value(value, from::DiscountFactor, to::RateXTime, day_count, rate_type::R) where {R<:RateType}
    return implied_rate(1 / value, day_count, rate_type) * delta
end

function convert_interpolated_value(value, from::D, to::D, day_count, rate_type::R) where {R<:RateType, D<:InterpolatedValue}
    return value
end

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
struct InterpolatedRateCurve{I<:AbstractInterpolation, D<:TimeType, F<:Function, C<:DayCount} <: AbstractRateCurve
    name::String
    date::D
    interpolation::I
    interpolated_to_df::F
    df_to_interpolated::F
    day_count_convention::C
end

function InterpolatedRateCurve(date::D; input_values::Vector{N}, interp_method::I=Gridded(Linear()),
            extrap_method::E=Flat(),
            day_count_convention::C=ACT360(),
            rate_type::R=LinearRate(),
            spine_day_counts=(),
            spine_dates=(),
            interpolated_value=RateXTime(),
            input_type=DiscountFactor()) where {D<:TimeType, N<:Number, I<:InterpolationType, E<:BoundaryCondition, C<:DayCount, R<:RateType}               
    spine_day_counts = rate_curve_spine_daycounts(date, spine_rates, spine_dates, spine_day_counts, day_count_convention)
    spine_values = convert_interpolated_value(input_values, input_type, interpolated_value, spine_day_counts, rate_type)
    interpolation = interpolate((spine_day_counts,), spine_values, interp_method) 
    extrap_interp = extrapolate(interpolation, extrap_method)
    interpolated_to_df = (rate,day_count) -> convert_interpolated_value(rate, interpolated_value, DiscountFactor(), day_count, rate_type)
    df_to_interpolated = (df,day_count) -> convert_interpolated_value(df, DiscountFactor(), interpolated_value, day_count, rate_type)
    return InterpolatedRateCurve("Curve", date, extrap_interp, interpolated_to_df, df_to_interpolated, day_count_convention)
end

function rate_curve_spine_daycounts(date, spine_values, spine_dates, spine_day_counts, day_count_convention::D) where D<:DayCount
    if length(spine_values) == length(spine_dates) && length(spine_day_counts) == 0
       return day_count_fraction(date, spine_dates, day_count_convention)
    end
    if length(spine_values) != length(spine_day_counts)
        return error("Wrong inputs for curve creation.")
    end
    return spine_day_counts
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
function discount_factor(rate_curve::InterpolatedRateCurve, date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    interpolated_value = rate_curve.interpolation(delta)
    return rate_curve.interpolated_to_df(interpolated_value, delta)
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
