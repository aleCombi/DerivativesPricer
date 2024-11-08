# This tests the forward rates calculation when the rate fixes in advance (forward looking) before the accrual start and the accrual period is shorter than the benchmark rate accrual period (e.g. you read a benchmark rate referred to a period longer or shorter than the one you apply it to), with some margin.
@testitem "Forward rates" begin
    using Dates
    rate_config = SimpleRateConfig(ACT360(), LinearRate(), NoShift(), AdditiveMargin(0.01))
    pay_dates = [Date(2013,3,3), Date(2013,6,3), Date(2013,9,3)]
    fixing_dates = [Date(2013,3,1), Date(2013,6,2), Date(2013,8,29)]
    discount_start_dates = fixing_dates
    discount_end_dates = [Date(2013,6,1), Date(2013,9,2), Date(2013,11,29)]
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1), Date(2013,12,1)]
    time_fractions = day_count_fraction(accrual_dates, rate_config.day_count_convention)
    schedules = SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, time_fractions)

    dates = vcat(fixing_dates[2:end], Date(2099,1,1))
    rates = [0.02, 0.06, 0.06]
    pricing_date = Date(2013,3,1)
    rate_curve_inputs = RateCurveInputs(dates, rates, pricing_date)
    rate_curve = RateCurve(rate_curve_inputs)
    forward_rates = calculate_forward_rate(rate_curve, schedules, rate_config)
    println(forward_rates)
end