# test_rate_stream.jl

using Test
using Dates
include("../src/day_count_conventions.jl")
include("../src/schedule_generation.jl")
include("../src/rate_conventions.jl")
include("../src/fixed_rate_stream.jl")

using .DayCount
using .ScheduleGeneration
using .RateConventions
using .RateStream

@testset "FixedRateStream Tests" begin
    pay_dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
    accrual_dates = [Date(2023, 1, 1), Date(2023, 7, 1), Date(2024, 1, 1)]
    stream = FixedRateStream(0.05, pay_dates, accrual_dates)
    
    # Test the basic structure
    @test stream.rate == 0.05
    @test stream.pay_dates == pay_dates
    @test stream.accrual_dates == accrual_dates
end

@testset "FlowStream Generation Tests - Linear" begin
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    rate = 0.05
    schedule_rule = AnnualSchedule()
    day_count_convention = ACT360()
    rate_convention = Linear()

    # Generate the flow stream using linear rate convention
    interest = generate_flow_stream(principal, start_date, end_date, rate, schedule_rule, day_count_convention, rate_convention)

    # Expected interest: Using simple interest calculation
    time_fraction = 1.0  # Full year
    expected_interest = principal * rate * time_fraction
    @test interest == [expected_interest]
end

@testset "FlowStream Generation Tests - Compounded" begin
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    rate = 0.05
    schedule_rule = AnnualSchedule()
    day_count_convention = ACT360()
    rate_convention = Compounded()
    frequency = 12  # Monthly compounding

    # Generate the flow stream using compounded rate convention
    interest = generate_flow_stream(principal, start_date, end_date, rate, schedule_rule, day_count_convention, rate_convention, frequency)

    # Expected interest: Using compounded interest calculation
    time_fraction = 1.0  # Full year
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test interest == [expected_interest]
end

@testset "Edge Cases" begin
    principal = 0.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    rate = 0.05
    schedule_rule = AnnualSchedule()
    day_count_convention = ACT360()
    rate_convention = Linear()

    # Test for zero principal
    interest = generate_flow_stream(principal, start_date, end_date, rate, schedule_rule, day_count_convention, rate_convention)
    @test interest == [0.0]

    # Test for zero time fraction (start_date == end_date)
    principal = 1000.0
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 1, 1)
    interest = generate_flow_stream(principal, start_date, end_date, rate, schedule_rule, day_count_convention, rate_convention)
    @test interest == [0.0]
end
