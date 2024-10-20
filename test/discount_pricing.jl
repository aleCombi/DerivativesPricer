using Test
using Dates
using DerivativesPricer

@testsnippet DiscountPricing begin
    using Dates
    include("dummy_struct_functions.jl")
    # Create mock dates and day count convention
    dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
    discount_factors = [0.95, 0.90, 0.85]
    pricing_date = Date(2022, 1, 1)

    # Create a mock RateCurve
    rate_curve_inputs = RateCurveInputs(dates, discount_factors, pricing_date)
    rate_curve = create_rate_curve(rate_curve_inputs)
end

# Test for price_fixed_flows_stream
@testitem "price_fixed_flows_stream" setup=[DiscountPricing] begin
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
@testitem "forward_rates" setup=[DiscountPricing] begin

    # Calculate forward rates
    fwd_rates = calculate_forward_rates(rate_curve, dates, ACT360())

    # Expected forward rates
    expected_fwd_rates = [(0.90 / 0.95 - 1) / 181 * 360, (0.85 / 0.90 - 1) / 184 * 360]

    @test fwd_rates == expected_fwd_rates
end

@testitem "float_rate_pricing" setup=[DiscountPricing] begin
    # Create a mock FloatRateStream
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)
    rate_index = DummyRateIndex()
    rate_convention = DummyRateType()
    schedule_config = DummyScheduleConfig() # this daycount convention makes every period count as 0.25
    day_count_convention = DummyDayCountConvention()
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)
    rate_config = SimpleRateConfig(day_count_convention, rate_convention, NoShift())
    instrument_rate = FloatRate(rate_index, rate_config)
    stream_config = FlowStreamConfig(principal, rate_index, instrument_schedule, day_count_convention, rate_convention, NoShift())
    stream = FloatingRateStream(stream_config)
    print(stream.pay_dates)
    # Calculate the price
    price = price_float_rate_stream(stream, rate_curve)

    # Expected price
    expected_price = 1000.0 * (0.9 * (0.90 / 0.95 - 1) / 0.25 + 0.85 * (0.85 / 0.90 - 1) / 0.25)

    @test price == expected_price
end