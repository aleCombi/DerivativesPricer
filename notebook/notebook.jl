using DerivativesPricer
using Dates
using DerivativesPricer
using BenchmarkTools

function simple_fixed_loan_pricer()
    # Market rates
    interest_rate = 0.03  # 3% flat rate

    # Day count convention
    day_count = ACT360()

    settlement_date = Date(2024, 10, 10)

    rate_curve = DerivativesPricer.FlatRateCurve("myRateCurve", settlement_date, interest_rate, day_count, Exponential())

    loan_interest_rate = 0.05
    start_date = Date(2024, 10, 10)
    maturity_date = Date(2025, 10, 10)

    schedule_config = ScheduleConfig(start_date, maturity_date, Annual(), day_count)
    fixed_rate_config = FixedRateStreamConfig(1, loan_interest_rate, schedule_config, Linear())
    fixed_rate_stream = FixedRateStream(fixed_rate_config)

    price = price_fixed_flows_stream(fixed_rate_stream.pay_dates, fixed_rate_stream.cash_flows, rate_curve)
    return price
end

x = @benchmark simple_fixed_loan_pricer()
display(x)