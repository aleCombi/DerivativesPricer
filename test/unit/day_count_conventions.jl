# DayCount Tests
# This test suite covers the functionality of different day count conventions.
# It checks the calculation of day count fractions between specific dates for each convention.

# ACT/360 Day Count Tests
# This test set covers the ACT/360 day count convention. It calculates the day count fraction between two dates and verifies the results by comparing them with expected values.
@testitem "ACT/360 Day Count Tests" begin
    using Dates
    # Test for a full year (365 days)
    start_date = Dates.Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 365 days
    expected = 365 / 360
    @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected atol=1e-10

    # Test for 364 days
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # 364 days
    expected = 364 / 360
    @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
    expected = [365 / 360, 183 / 360]
    @test day_count_fraction(start_dates, end_dates, ACT360()) ≈ expected atol=1e-10
end

# ACT/365 Day Count Tests
# This test set covers the ACT/365 day count convention. It verifies the day count fraction calculation between two dates using the ACT/365 convention.
@testitem "ACT/365 Day Count Tests" begin
    using Dates
    # Test for a full year (365 days)
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 365 days
    expected = 365 / 365
    @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected atol=1e-10

    # Test for 364 days
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # 364 days
    expected = 364 / 365
    @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
    expected = [365 / 365, 183 / 365]
    @test day_count_fraction(start_dates, end_dates, ACT365()) ≈ expected atol=1e-10
end

# 30/360 Day Count Tests
# This test set covers the 30/360 day count convention. It verifies the day count fraction calculation between two dates
# using the 30/360 convention.
@testitem "30/360 Day Count Tests" begin
    using Dates
    # Test for a full year (360 days in 30/360 convention)
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 360 days according to 30/360
    expected = 360 / 360
    @test day_count_fraction(start_date, end_date, Thirty360()) ≈ expected atol=1e-10

    # Test for 359 days (adjusted to 359 days in 30/360 convention)
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # Adjusted to 359 days in 30/360 convention
    expected = 359 / 360
    @test day_count_fraction(start_date, end_date, Thirty360()) ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 6, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
    expected = [360 / 360, 209 / 360]  # Assuming 30/360 convention adjustment
    @test day_count_fraction(start_dates, end_dates, Thirty360()) ≈ expected atol=1e-10
end
