using Test
using Dates
using DerivativesPricer

# Test for DailySchedule
@testset "DailySchedule Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 1, 10)
    
    # Expected daily dates from January 1 to January 10
    expected = Date(2023, 1, 1):Day(1):Date(2023, 1, 10) |> collect
    @test generate_schedule(start_date, end_date, DailySchedule()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, DailySchedule()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, DailySchedule()) == []
end

# Test for MonthlySchedule
@testset "MonthlySchedule Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 6, 1)
    
    # Expected monthly dates from January 1 to June 1
    expected = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 4, 1), Date(2023, 5, 1), Date(2023, 6, 1)]
    @test generate_schedule(start_date, end_date, MonthlySchedule()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, MonthlySchedule()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, MonthlySchedule()) == []
end

# Test for QuarterlySchedule
@testset "QuarterlySchedule Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 1)
    
    # Expected quarterly dates from January 1 to December 1
    expected = [Date(2023, 1, 1), Date(2023, 4, 1), Date(2023, 7, 1), Date(2023, 10, 1)]
    @test generate_schedule(start_date, end_date, QuarterlySchedule()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, QuarterlySchedule()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, QuarterlySchedule()) == []
end

# Test for AnnualSchedule
@testset "AnnualSchedule Tests" begin
    start_date = Date(2020, 1, 1)
    end_date = Date(2023, 1, 1)
    
    # Expected yearly dates from January 1, 2020 to January 1, 2023
    expected = [Date(2020, 1, 1), Date(2021, 1, 1), Date(2022, 1, 1), Date(2023, 1, 1)]
    @test generate_schedule(start_date, end_date, AnnualSchedule()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, AnnualSchedule()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, AnnualSchedule()) == []
end
