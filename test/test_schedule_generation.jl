using Test
using Dates
using DerivativesPricer

# Test for Daily
@testset "Daily Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 1, 10)
    
    # Expected daily dates from January 1 to January 10
    expected = Date(2023, 1, 1):Day(1):Date(2023, 1, 10) |> collect
    @test generate_schedule(start_date, end_date, Daily()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, Daily()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, Daily()) == []
end

# Test for Monthly
@testset "Monthly Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 6, 1)
    
    # Expected monthly dates from January 1 to June 1
    expected = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 4, 1), Date(2023, 5, 1), Date(2023, 6, 1)]
    @test generate_schedule(start_date, end_date, Monthly()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, Monthly()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, Monthly()) == []
end

# Test for Quarterly
@testset "Quarterly Tests" begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 1)
    
    # Expected quarterly dates from January 1 to December 1
    expected = [Date(2023, 1, 1), Date(2023, 4, 1), Date(2023, 7, 1), Date(2023, 10, 1)]
    @test generate_schedule(start_date, end_date, Quarterly()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, Quarterly()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, Quarterly()) == []
end

# Test for Annual
@testset "Annual Tests" begin
    start_date = Date(2020, 1, 1)
    end_date = Date(2023, 1, 1)
    
    # Expected yearly dates from January 1, 2020 to January 1, 2023
    expected = [Date(2020, 1, 1), Date(2021, 1, 1), Date(2022, 1, 1), Date(2023, 1, 1)]
    @test generate_schedule(start_date, end_date, Annual()) == expected
    
    # Edge case: start_date == end_date
    @test generate_schedule(start_date, start_date, Annual()) == [start_date]

    # Edge case: start_date > end_date (invalid range)
    @test generate_schedule(end_date, start_date, Annual()) == []
end
