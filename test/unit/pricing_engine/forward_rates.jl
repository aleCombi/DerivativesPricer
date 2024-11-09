# This tests the forward rates calculation when the rate fixes in advance (forward looking) before the accrual start and the accrual period is shorter than the benchmark rate accrual period (e.g. you read a benchmark rate referred to a period longer or shorter than the one you apply it to), with some margin.
@testitem "Forward rates on a flat exponential curve" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1), Date(2013,12,1)]
    rates = [0.02, 0.02, 0.02, 0.02]
    pricing_date = Date(2013,2,1)
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=Exponential())
    forward_rates = forward_rate(rate_curve, Date(2013,6,1), Date(2013,9,1))
    @test forward_rates ≈ 0.02 atol=1e-8
end

@testitem "Forward rates on a linear curve" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1)]
    rates = [0.02, 0.03, 0.04]
    pricing_date = Date(2013,2,1)
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=LinearRate())
    forward_rates = forward_rate(rate_curve, Date(2013,6,1), Date(2013,9,1))
    day_count_0 = day_count_fraction(pricing_date, Date(2013,6,1), rate_curve.day_count_convention)
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    day_count_2 = day_count_fraction(pricing_date, Date(2013,9,1), rate_curve.day_count_convention)
    @test 1 + day_count_2 * 0.04 ≈ (1 + day_count_1 * forward_rates) * (1 + day_count_0 * 0.03)
end

@testitem "Forward rates on a linear curve with additive margin" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1)]
    rates = [0.02, 0.03, 0.04]
    pricing_date = Date(2013,2,1)
    margin=0.001
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=LinearRate())
    forward_rates = forward_rate(rate_curve, Date(2013,6,1), Date(2013,9,1); margin_config=AdditiveMargin(margin))
    day_count_0 = day_count_fraction(pricing_date, Date(2013,6,1), rate_curve.day_count_convention)
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    day_count_2 = day_count_fraction(pricing_date, Date(2013,9,1), rate_curve.day_count_convention)
    @test 1 + day_count_2 * 0.04 ≈ (1 + day_count_1 * (forward_rates - margin)) * (1 + day_count_0 * 0.03)
end

@testitem "Forward rates on a linear curve with multiplicative margin" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1)]
    rates = [0.02, 0.03, 0.04]
    pricing_date = Date(2013,2,1)
    margin=0.001
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=LinearRate())
    forward_rates = forward_rate(rate_curve, Date(2013,6,1), Date(2013,9,1); margin_config=MultiplicativeMargin(margin))
    day_count_0 = day_count_fraction(pricing_date, Date(2013,6,1), rate_curve.day_count_convention)
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    day_count_2 = day_count_fraction(pricing_date, Date(2013,9,1), rate_curve.day_count_convention)
    @test 1 + day_count_2 * 0.04 ≈ (1 + day_count_1 * (forward_rates - forward_rates * margin)) * (1 + day_count_0 * 0.03)
end

@testitem "Forward rates on a linear curve with multiplicative margin with prefilled day_count" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1)]
    rates = [0.02, 0.03, 0.04]
    pricing_date = Date(2013,2,1)
    margin=0.001
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=LinearRate())
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    forward_rates = forward_rate(rate_curve, Date(2013,6,1), Date(2013,9,1), day_count_1; margin_config=MultiplicativeMargin(margin))
    day_count_0 = day_count_fraction(pricing_date, Date(2013,6,1), rate_curve.day_count_convention)
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    day_count_2 = day_count_fraction(pricing_date, Date(2013,9,1), rate_curve.day_count_convention)
    @test 1 + day_count_2 * 0.04 ≈ (1 + day_count_1 * (forward_rates - forward_rates * margin)) * (1 + day_count_0 * 0.03)
end

@testitem "Forward rates on a linear curve with multiplicative margin with SimpleRateStreamSchedules" begin
    using Dates
    accrual_dates = [Date(2013,3,1), Date(2013,6,1), Date(2013,9,1)]
    rates = [0.02, 0.03, 0.04]
    pricing_date = Date(2013,2,1)
    margin=0.001
    rate_curve = RateCurve(pricing_date, rates; spine_dates=accrual_dates, rate_type=LinearRate())
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)

    accrual_dates = [Date(2013,6,1), Date(2013,9,1)]
    fixing_dates = [accrual_dates[1]]
    discount_start_dates = fixing_dates
    discount_end_dates = accrual_dates[2:end]
    accrual_day_counts = [day_count_1]
    pay_dates = discount_end_dates
    schedules = SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, accrual_day_counts)
    forward_rates = forward_rate(schedules, rate_curve, rate_curve.rate_type, MultiplicativeMargin(margin))[1]
    day_count_0 = day_count_fraction(pricing_date, Date(2013,6,1), rate_curve.day_count_convention)
    day_count_1 = day_count_fraction(Date(2013,6,1), Date(2013,9,1), rate_curve.day_count_convention)
    day_count_2 = day_count_fraction(pricing_date, Date(2013,9,1), rate_curve.day_count_convention)
    @test 1 + day_count_2 * 0.04 ≈ (1 + day_count_1 * (forward_rates - forward_rates * margin)) * (1 + day_count_0 * 0.03)
end

# Test for forward_rates
@testitem "forward_rates" setup=[RateCurveSetup] begin
    rate_config = SimpleRateConfig(ACT360(), LinearRate(), NoShift(), AdditiveMargin(0))
    day_counts = day_count_fraction(dates, rate_config.day_count_convention)
    schedules = SimpleRateStreamSchedules(dates[2:end], dates[1:end-1], dates[1:end-1], dates[2:end], dates, day_counts)
    # Calculate forward rates
    fwd_rates = forward_rate(schedules, rate_curve, rate_config)

    # Expected forward rates
    expected_fwd_rates = [(0.95 / 0.90 - 1) / 181 * 360, (0.90 / 0.85 - 1) / 184 * 360]

    @test fwd_rates ≈ expected_fwd_rates rtol=1e-7
end