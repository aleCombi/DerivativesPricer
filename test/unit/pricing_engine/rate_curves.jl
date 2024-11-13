@testitem "Discount Factor Calculation on a spine date" begin
    using Dates
    spine_dates = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] 
    spine_rates = [1.5, 2.0, 2.5]
    date = Date(2023, 1, 1)
    curve = InterpolatedRateCurve(Date(2023, 1, 1); input_values=spine_rates, input_type=Hedgehog.Rate(), spine_dates=spine_dates)

    # Calculate discount factor with the real interpolation
    test_date = Date(2023, 6, 1)
    discount = discount_factor(curve, test_date)

    # Expected discount factor (based on the real interpolation)
    expected_discount = 1 / (1 + 151.0/360 * 2)  # Example day count for June 1, 2023
    @test discount ≈ expected_discount
end

@testitem "Discount Factor Calculation on a non-spine date inputting day-counts" begin
    using Dates
    spine_day_counts = [0.1, 0.3, 1] 
    spine_rates = [1.5, 2.0, 2.5]
    date = Date(2023, 1, 1)
    curve = InterpolatedRateCurve(Date(2023, 1, 1); input_values=spine_rates, input_type=Hedgehog.Rate(), spine_day_counts=spine_day_counts)

    # Calculate discount factor with the real interpolation
    test_day_count = 1.6 # Example day count for June 1, 2023
    discount = discount_interest(curve.interpolation(test_day_count), test_day_count, curve.rate_type)

    # Expected discount factor (based on the real interpolation)
    expected_discount = 1 / (1 + test_day_count * curve.interpolation(test_day_count)) 
    @test discount ≈ expected_discount
end

@testitem "Discount Factor Calculation on a spine date, exponential rates" begin
    using Dates
    spine_dates = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] 
    spine_rates = [1.5, 2.0, 2.5]
    date = Date(2023, 1, 1)
    curve = InterpolatedRateCurve(Date(2023, 1, 1); input_values=spine_rates, input_type=Hedgehog.Rate(), spine_dates=spine_dates, rate_type=Exponential())

    # Calculate discount factor with the real interpolation
    test_date = Date(2023, 6, 1)
    discount = discount_factor(curve, test_date)

    # Expected discount factor (based on the real interpolation)
    expected_discount = exp(- 151.0/360 * 2)  # Example day count for June 1, 2023
    @test discount ≈ expected_discount
end

@testitem "Discount Factor Calculation on a spine date, exponential rates, ACT365" begin
    using Dates
    spine_dates = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] 
    spine_rates = [1.5, 2.0, 2.5]
    date = Date(2023, 1, 1)
    curve = InterpolatedRateCurve(Date(2023, 1, 1); input_values=spine_rates, interpolated_value=Hedgehog.Rate(), input_type=Hedgehog.Rate(), spine_dates=spine_dates, 
        rate_type=Exponential(), 
        day_count_convention=ACT365())

    # Calculate discount factor with the real interpolation
    test_date = Date(2023, 6, 5)
    test_day_count = 155.0/365 # Example day count for June 5, 2023
    discount = discount_factor(curve, test_date)

    # Expected discount factor (based on the real interpolation)
    expected_discount = exp(- test_day_count * curve.interpolation(test_day_count))  
    @test discount ≈ expected_discount
end

@testitem "Flat Rate Curve Discount Factor Calculation on a spine date, exponential rates, ACT365" begin
    using Dates
    spine_dates = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] 
    rate = 1
    date = Date(2023, 1, 1)
    curve = FlatRateCurve("Curve", Date(2023, 1, 1), rate, ACT365(), Exponential())

    test_date = Date(2023, 6, 5)
    test_day_count = 155.0/365
    discount = discount_factor(curve, test_date)

    expected_discount = exp(- test_day_count * rate) 
    @test discount ≈ expected_discount
end