using Test
using Dates
include("../src/day_count_conventions.jl"); using .DayCount

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

end
