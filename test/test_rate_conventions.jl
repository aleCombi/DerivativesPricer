using Test
include("../src/rate_conventions.jl"); using .RateConventions  # Import the module you're testing

# Test for Linear Interest
@testset "Linear Interest Tests" begin
    principal = 1000.0
    rate = 0.05  # 5% annual interest
    time_fraction = 1.0  # 1 year
    
    # Expected: 1000 * 0.05 * 1 = 50
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 50.0

    # Test with different time fractions (6 months)
    time_fraction = 0.5
    # Expected: 1000 * 0.05 * 0.5 = 25
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 25.0

    # Edge case: Zero principal
    principal = 0.0
    # Expected: 0 * 0.05 * 0.5 = 0
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 0.0

    # Edge case: Negative time fraction (possible scenario)
    principal = 1000.0
    time_fraction = -0.5
    # Expected: 1000 * 0.05 * -0.5 = -25
    @test calculate_interest(principal, rate, time_fraction, Linear()) == -25.0
end

# Test for Compounded Interest
@testset "Compounded Interest Tests" begin
    principal = 1000.0
    rate = 0.05  # 5% annual interest
    time_fraction = 1.0  # 1 year
    frequency = 12  # Monthly compounding

    # Expected: 1000 * (1 + 0.05 / 12)^(12 * 1) - 1000
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, frequency, Compounded()) ≈ expected_interest

    # Test with different compounding frequency (quarterly)
    frequency = 4  # Quarterly compounding
    # Expected: 1000 * (1 + 0.05 / 4)^(4 * 1) - 1000
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, frequency, Compounded()) ≈ expected_interest

    # Edge case: Zero principal
    principal = 0.0
    # Expected: 0 compound interest
    @test calculate_interest(principal, rate, time_fraction, frequency, Compounded()) == 0.0

    # Edge case: Time fraction of zero (no time has passed)
    principal = 1000.0
    time_fraction = 0.0
    # Expected: 1000 * (1 + 0.05 / 4)^(4 * 0) - 1000 = 0
    @test calculate_interest(principal, rate, time_fraction, frequency, Compounded()) == 0.0
end
