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
    # Calculate forward rates
    fwd_rates = calculate_forward_rate(rate_curve, dates, dates, LinearRate(), ACT360())

    # Expected forward rates
    expected_fwd_rates = [(0.90 / 0.95 - 1) / 181 * 360, (0.85 / 0.90 - 1) / 184 * 360]

    @test fwd_rates == expected_fwd_rates
end

@testitem "float_rate_pricing" begin
    include("discount_pricing_setup.jl")
    # Create a mock FloatRateStream
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)
    rate_index = DummyRateIndex()
    rate_convention = DummyRateType()
    schedule_config = DummyScheduleConfig() # this daycount convention makes every period count as 0.25
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)
    rate_config = SimpleRateConfig(DummyDayCountConvention(), LinearRate(), NoShift(), AdditiveMargin(0))
    instrument_rate = FloatRate(rate_index, rate_config)
    stream_config = FlowStreamConfig(principal, instrument_rate, instrument_schedule)
    stream = FloatingRateStream(stream_config)
    print(stream.pay_dates)
    # Calculate the price
    price = price_float_rate_stream(stream, rate_curve)

    # Expected price
    expected_price = 1000.0 * (0.9 * (0.90 / 0.95 - 1) / 0.25 + 0.85 * (0.85 / 0.90 - 1) / 0.25)

    @test price == expected_price
end