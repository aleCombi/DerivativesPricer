# DayCount Tests
# This test suite covers the functionality of different day count conventions.
# It checks the calculation of day count fractions between specific dates for each convention.

# ACT/360 Day Count Tests
# This test set covers the ACT/360 day count convention. It calculates the day count fraction between two dates and verifies the results by comparing them with expected values.
@testitem "QuantLib ACT/360 Day Count Tests" begin
    using PyCall
    ql = pyimport("QuantLib")
    using Dates
    # Test for a full year (365 days)
    start_date = Dates.Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 365 days
    actual = day_count_fraction(start_date, end_date, ACT360())

    ql_start = ql.Date(1,1,2023)
    ql_end = ql.Date(1,1,2024)
    day_count = ql.Actual360()
    expected = day_count.yearFraction(ql_start, ql_end)
    @test actual ≈ expected atol=1e-10

    # Test for 364 days
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # 364 days
    actual = day_count_fraction(start_date, end_date, ACT360())
    
    ql_start = ql.Date(1,1,2023)
    ql_end = ql.Date(31,12,2023)
    expected = day_count.yearFraction(ql_start, ql_end)

    @test actual ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
    actual = day_count_fraction(start_dates, end_dates, ACT360())

    ql_start = [ql.Date(1,1,2023), ql.Date(1,7,2023)]
    ql_end = [ql.Date(1,1,2024), ql.Date(31,12,2023)]
    expected = [day_count.yearFraction(ql_start[i], ql_end[i]) for i in eachindex(ql_start)]

    @test actual ≈ expected atol=1e-10
end

# ACT/365 Day Count Tests
# This test set covers the ACT/365 day count convention. It verifies the day count fraction calculation between two dates using the ACT/365 convention.
@testitem "Quantlib ACT/365 Day Count Tests" begin
    using PyCall
    ql = pyimport("QuantLib")
    using Dates
    day_count = ql.Actual365Fixed()

    # Test for a full year (365 days)
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 365 days

    ql_start_date = ql.Date(1,1,2023)
    ql_end_date = ql.Date(1,1,2024)
    expected = day_count.yearFraction(ql_start_date, ql_end_date)

    @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected atol=1e-10

    # Test for 364 days
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # 364 days

    ql_start_date = ql.Date(1,1,2023)
    ql_end_date = ql.Date(31,12,2023)
    expected = day_count.yearFraction(ql_start_date, ql_end_date)

    @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
    expected = [365 / 365, 183 / 365]

    ql_start_date = [ql.Date(1,1,2023), ql.Date(1,7,2023)]
    ql_end_date = [ql.Date(1,1,2024), ql.Date(31,12,2023)]
    expected = [day_count.yearFraction(ql_start_date[i], ql_end_date[i]) for i in eachindex(ql_start_date)]

    @test day_count_fraction(start_dates, end_dates, ACT365()) ≈ expected atol=1e-10
end

# 30/360 Day Count Tests
# This test set covers the 30/360 day count convention. It verifies the day count fraction calculation between two dates
# using the 30/360 convention.
@testitem "Quantlib 30/360 Day Count Tests" begin
    using PyCall
    ql = pyimport("QuantLib")
    using Dates
    day_count = ql.Thirty360(ql.Thirty360.European)

    # Test for a full year (360 days in 30/360 convention)
    start_date = Date(2023, 1, 1)
    end_date = Date(2024, 1, 1)  # 360 days according to 30/360

    ql_start_date = ql.Date(1,1,2023)
    ql_end_date = ql.Date(1,1,2024)
    expected = day_count.yearFraction(ql_start_date, ql_end_date)
    @test day_count_fraction(start_date, end_date, Thirty360()) ≈ expected atol=1e-10

    # Test for 359 days (adjusted to 359 days in 30/360 convention)
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)  # Adjusted to 359 days in 30/360 convention

    ql_start_date = ql.Date(1,1,2023)
    ql_end_date = ql.Date(31,12,2023)
    expected = day_count.yearFraction(ql_start_date, ql_end_date)
    @test day_count_fraction(start_date, end_date, Thirty360()) ≈ expected atol=1e-10

    # Test vectorized calculation for multiple date pairs
    start_dates = [Date(2023, 1, 1), Date(2023, 6, 1)]
    end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]

    ql_start_date = [ql.Date(1,1,2023), ql.Date(1,6,2023)]
    ql_end_date = [ql.Date(1,1,2024), ql.Date(31,12,2023)]
    expected = [day_count.yearFraction(ql_start_date[i], ql_end_date[i]) for i in eachindex(ql_start_date)]
    @test day_count_fraction(start_dates, end_dates, Thirty360()) ≈ expected atol=1e-10
end
