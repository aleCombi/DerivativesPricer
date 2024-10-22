using Test
using Dates
using DerivativesPricer
include("dummy_struct_functions.jl")
# Create mock dates and day count convention
dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
discount_factors = [0.95, 0.90, 0.85]
pricing_date = Date(2022, 1, 1)

# Create a mock RateCurve
rate_curve_inputs = RateCurveInputs(dates, discount_factors, pricing_date)
rate_curve = create_rate_curve(rate_curve_inputs)
