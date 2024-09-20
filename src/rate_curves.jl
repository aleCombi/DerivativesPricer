using Dates
using Interpolations
using Random
using DerivativesPricer

# Type aliases to avoid fully qualifying types
const InterpType = Interpolations.InterpolationType
const AbstractInterp = Interpolations.AbstractInterpolation

struct RateCurve{T<:AbstractInterp,D<:DayCountConvention}
    name::String
    date::Date
    interpolation::T
    day_count_convention::D
end

# Discount factor calculation based on date difference and interpolation
function discount_factor(rate_curve::RateCurve, date::Date)
    delta = day_count_fraction(rate_curve.date, date, rate_curve.day_count_convention)
    return rate_curve.interpolation(delta)
end

function create_rate_curve(times::Vector{Float64}, rates::Vector{Float64}, interp_method::T, date::Date, day_count_convention::D) where {T<:InterpType,D<:DayCountConvention}
    interpolation = interpolate((times,), rates, interp_method)
    return RateCurve("Curve_$(randstring(5))", date, interpolation, day_count_convention)
end

# Parametric constructor with existing interpolation
function RateCurve(interpolation::T, date::Date, day_count_convention::D) where {T<:AbstractInterp,D<:DayCountConvention}
    return RateCurve("Curve_$(randstring(5))", date, interpolation, day_count_convention)
end

# Data points
x = 0:10 |> float |> collect
y = [1.0, 2.1, 3.5, 4.7, 5.2, 6.5, 7.0, 8.3, 9.1, 10.0, 11.0]

# Example usage
curve = create_rate_curve(x, y, Gridded(Interpolations.Linear()), Date(2017, 6, 29), ACT365())
println(discount_factor(curve, Date(2017, 7, 1)))
