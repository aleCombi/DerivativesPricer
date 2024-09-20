using BenchmarkTools
using Interpolations

# Define the parameterized RateCurve
struct RateCurveParam{T <: Interpolations.AbstractInterpolation}
    times::Vector{Float64}
    rates::Vector{Float64}
    interpolation::T
end

# # Define the non-parameterized RateCurve
struct RateCurveAbstract
    times::Vector{Float64}
    rates::Vector{Float64}
    interpolation::Interpolations.AbstractInterpolation
end

# Helper method to create the interpolation for the parametric type
function RateCurveParam(times::Vector{Float64}, rates::Vector{Float64}, interp_method)
    interpolation = interpolate(rates, interp_method)
    return RateCurveParam{typeof(interpolation)}(times, rates, interpolation)
end

# Helper method for the abstract version
function Rate_CurveAbstract(times::Vector{Float64}, rates::Vector{Float64}, interp_method)
    interpolation = interpolate(rates, interp_method)
    return RateCurveAbstract(times, rates, interpolation)
end

# Querying function for parametric type
function get_rate_param(curve::RateCurveParam, time::Float64)
    return curve.interpolation(time)
end

# # Querying function for abstract type
function get_rate_abstract(curve::RateCurveAbstract, time::Float64)
    return curve.interpolation(time)
end

# Create sample data
times = [1.0, 2.0, 3.0, 4.0, 5.0]
rates = [0.02, 0.025, 0.027, 0.03, 0.035]

# Create both rate curves
linear_curve_param = RateCurveParam(times, rates, BSpline(Linear()))
linear_curve_abstract = Rate_CurveAbstract(times, rates, BSpline(Linear()))

# Benchmark the querying for both the parameterized and abstract versions
println("Benchmark for Parametric Type:")
(@benchmark get_rate_param($linear_curve_param, 2.5)) |> display

println("Benchmark for Abstract Type:")
(@benchmark get_rate_abstract($linear_curve_abstract, 2.5))|> display


