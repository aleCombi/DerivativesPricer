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