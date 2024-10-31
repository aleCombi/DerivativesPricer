# Test for price_fixed_flows_stream
@testitem "price_fixed_flows_stream" begin
    include("discount_pricing_setup.jl")
    # Create a mock FixedRateStream
    payment_dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
    cash_flows = [1000.0, 1000.0, 1000.0]
    
    # Calculate the price
    price = price_fixed_flows_stream(payment_dates, cash_flows, rate_curve)

    # Expected price
    expected_price = sum(cash_flows .* [0.95, 0.90, 0.85])

    @test price == expected_price
end

# Test for forward_rates
@testitem "forward_rates" begin
    include("discount_pricing_setup.jl")

    rate_config = SimpleRateConfig(ACT360(), LinearRate(), NoShift(), AdditiveMargin(0))
    day_counts = day_count_fraction(dates, rate_config.day_count_convention)
    schedules = SimpleRateStreamSchedules(dates[2:end], dates[1:end-1], dates[1:end-1], dates[2:end], dates, day_counts)
    # Calculate forward rates
    fwd_rates = calculate_forward_rate(rate_curve, schedules, rate_config)

    # Expected forward rates
    expected_fwd_rates = [(0.95 / 0.90 - 1) / 181 * 360, (0.90 / 0.85 - 1) / 184 * 360]

    @test isapprox(fwd_rates, expected_fwd_rates; rtol=1e-7)
end

@testitem "float_rate_pricing" begin
    include("discount_pricing_setup.jl")
    # Create a mock FloatRateStream
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)
    rate_index = RateIndex("dummy")
    rate_convention = DummyRateType()
    schedule_config = DummyScheduleConfig()
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)
    rate_config = SimpleRateConfig(ACT365(), LinearRate(), NoShift(false), AdditiveMargin(0))
    instrument_rate = SimpleInstrumentRate(rate_index, rate_config)
    stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)
    stream = SimpleFloatRateStream(stream_config)
    print(stream.schedules.pay_dates)
    # Calculate the price
    price = price_float_rate_stream(stream, rate_curve)

    # Expected price
    expected_price = 1000.0 * (0.9 * (0.95 / 0.90 - 1) + 0.85 * (0.90 / 0.85 - 1))

    @test price == expected_price
end