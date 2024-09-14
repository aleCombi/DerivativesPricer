using Test
using DayCount

@testset "DayCount Tests" begin

    # Test ACT/360 convention
    @testset "ACT/360 Day Count Tests" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)  # 365 days
        expected = 365 / 360
        @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected

        start_date = Date(2023, 1, 1)
        end_date = Date(2023, 12, 31)  # 364 days
        expected = 364 / 360
        @test day_count_fraction(start_date, end_date, ACT360()) ≈ expected
    end

    # Test ACT/365 convention
    @testset "ACT/365 Day Count Tests" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)  # 365 days
        expected = 365 / 365
        @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected

        start_date = Date(2023, 1, 1)
        end_date = Date(2023, 12, 31)  # 364 days
        expected = 364 / 365
        @test day_count_fraction(start_date, end_date, ACT365()) ≈ expected
    end

    # Test ISDA 30/360 convention
    @testset "ISDA 30/360 Day Count Tests" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)  # 1 year
        expected = 360 / 360
        @test day_count_fraction(start_date, end_date, ISDA_30_360()) ≈ expected

        # Test end-of-month adjustment
        start_date = Date(2023, 1, 31)
        end_date = Date(2023, 2, 28)  # End of Feb adjusted
        expected = 30 / 360
        @test day_count_fraction(start_date, end_date, ISDA_30_360()) ≈ expected

        start_date = Date(2023, 7, 31)
        end_date = Date(2023, 8, 31)  # Adjust to 30/30
        expected = 30 / 360
        @test day_count_fraction(start_date, end_date, ISDA_30_360()) ≈ expected
    end

end
