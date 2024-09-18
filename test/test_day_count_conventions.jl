using Test
using Dates
using DerivativesPricer

# DayCount Tests
# This test suite covers the functionality of different day count conventions including ACT/360 and ACT/365.
# It checks the calculation of day count fractions between specific dates for each convention.
@testset "DayCount Tests" begin

    # ACT/360 Day Count Tests
    # This test set covers the ACT/360 day count convention. It calculates the day count fraction between two dates
    # and verifies the results by comparing them with expected values.
    @testset "ACT/360 Day Count Tests" begin
        # Test for a full year (365 days)
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)  # 365 days
        expected = 365 / 360
        @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected

        # Test for 364 days
        start_date = Date(2023, 1, 1)
        end_date = Date(2023, 12, 31)  # 364 days
        expected = 364 / 360
        @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected

        # Test vectorized calculation for multiple date pairs
        start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
        end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
        expected = [365 / 360, 183 / 360]
        @test day_count_fraction(start_dates, end_dates, ACT360()) ≈ expected
    end

    # ACT/365 Day Count Tests
    # This test set covers the ACT/365 day count convention. It verifies the day count fraction calculation between two dates
    # using the ACT/365 convention.
    @testset "ACT/365 Day Count Tests" begin
        # Test for a full year (365 days)
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)  # 365 days
        expected = 365 / 365
        @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected

        # Test for 364 days
        start_date = Date(2023, 1, 1)
        end_date = Date(2023, 12, 31)  # 364 days
        expected = 364 / 365
        @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected

        # Test vectorized calculation for multiple date pairs
        start_dates = [Date(2023, 1, 1), Date(2023, 7, 1)]
        end_dates = [Date(2024, 1, 1), Date(2023, 12, 31)]
        expected = [365 / 365, 183 / 365]
        @test day_count_fraction(start_dates, end_dates, ACT365()) ≈ expected
    end

end
