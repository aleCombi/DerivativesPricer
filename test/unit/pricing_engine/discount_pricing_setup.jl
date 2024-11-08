using Test
using Dates
using DerivativesPricer
include("../dummy_struct_functions.jl")
# Create mock dates and day count convention
pricing_date = Date(2022, 1, 1)
dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
discount_factors = [0.95, 0.90, 0.85]
rate_type = LinearRate()
time_fractions = day_count_fraction(pricing_date, dates, ACT365())
# println(length(time_fractions))
rates = implied_rate(1 ./ discount_factors, time_fractions, rate_type)
# println(rates)
# println(1 ./ discount_interest(rates, time_fractions, rate_type))

# Create a mock RateCurve
rate_curve_inputs = RateCurveInputs(dates, rates, pricing_date)
rate_curve = RateCurve(rate_curve_inputs)

discount_factor(rate_curve, dates) |> println
