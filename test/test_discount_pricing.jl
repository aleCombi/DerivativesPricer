using Test
using Dates
using DerivativesPricer

@testset "Discount Pricing Tests" begin
    # Create mock dates and day count convention
    dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
    discount_factors = [0.95, 0.90, 0.85]
    pricing_date = Date(2022, 1, 1)

    # Create a mock RateCurve
    rate_curve_inputs = RateCurveInputs(dates, discount_factors, pricing_date)
    rate_curve = create_rate_curve(rate_curve_inputs)

    # Test for price_fixed_flows_stream
    @testset "price_fixed_flows_stream" begin
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
    @testset "forward_rates" begin

        # Calculate forward rates
        fwd_rates = forward_rates(rate_curve, dates, ACT360())

        # Expected forward rates
        expected_fwd_rates = [(0.90 / 0.95 - 1) / 181 * 360, (0.85 / 0.90 - 1) / 184 * 360]

        @test fwd_rates == expected_fwd_rates
    end

end