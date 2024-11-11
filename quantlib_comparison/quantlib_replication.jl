using Hedgehog
using Dates
using BenchmarkTools
using ProfileView
# Setup phase (construct the curve, schedule, and stream)
function setup_pricer()
    # Market rates
    interest_rate = 0.03  # 3% flat rate

    # Day count convention
    day_count = ACT360()

    settlement_date = Date(2024, 10, 10)

    # Set up the flat rate curve
    rate_curve = Hedgehog.FlatRateCurve("myRateCurve", settlement_date, interest_rate, day_count, Exponential())

    loan_interest_rate = 0.05
    start_date = Date(2024, 10, 10)
    maturity_date = Date(2025, 10, 10)

    # Create the schedule and fixed rate stream
    schedule_config = ScheduleConfig(start_date, maturity_date, Daily(), day_count)
    fixed_rate_config = FixedRateStreamConfig(1, loan_interest_rate, schedule_config, Linear())
    fixed_rate_stream = FixedRateStream(fixed_rate_config)

    return fixed_rate_stream, rate_curve
end

# Calculation phase (price the fixed-rate stream)
function calculate_npv(fixed_rate_stream::Hedgehog.FixedRateStream, rate_curve::Hedgehog.FlatRateCurve)
    return price_fixed_flows_stream(fixed_rate_stream.pay_dates, fixed_rate_stream.cash_flows, rate_curve)
end

# Run the setup only once and store the results
fixed_rate_stream, rate_curve = setup_pricer()
npv = calculate_npv(fixed_rate_stream, rate_curve)
display(npv)

# Benchmarking the setup phase separately
setup_benchmark = @benchmark setup_pricer()

# Benchmarking only the calculation phase (pricing) using the precomputed setup
calculation_benchmark = @benchmark calculate_npv($fixed_rate_stream, $rate_curve)

# Display the benchmark results
display(setup_benchmark)
display(calculation_benchmark)


# @benchmark price_fixed_flows_stream($fixed_rate_stream.pay_dates, $fixed_rate_stream.cash_flows, $rate_curve)

# @benchmark discount_factor($rate_curve, $fixed_rate_stream.pay_dates)

# @benchmark day_count_fraction($rate_curve.date, $fixed_rate_stream.pay_dates, $rate_curve.day_count_convention)

# delta =  day_count_fraction(rate_curve.date, fixed_rate_stream.pay_dates, rate_curve.day_count_convention)
# @benchmark Hedgehog.discount_interest($rate_curve.rate, $delta, $rate_curve.rate_type)

# f(delta, rate) = @. exp(-delta * rate)

# rate = rate_curve.rate
# @benchmark f($delta, $rate)
