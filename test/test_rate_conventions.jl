using Test
using DerivativesPricer

# Linear Interest Tests
# This test set validates the `calculate_interest` function for the `Linear` (simple) interest method.
# The tests cover:
# - Standard interest calculation with a 5% annual rate.
# - Different time fractions (e.g., 6 months).
# - Edge cases such as zero principal and negative time fractions.
# - Vectorized calculations for multiple principals, rates, and time fractions.
@testset "Linear Interest Tests" begin
    principal = 1000.0
    rate = 0.05  # 5% annual interest
    time_fraction = 1.0  # 1 year

    # Test 1: Standard calculation for 1 year at 5% interest
    # Expected: 1000 * 0.05 * 1 = 50
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 50.0

    # Test 2: Calculation for 6 months (0.5 years)
    time_fraction = 0.5
    # Expected: 1000 * 0.05 * 0.5 = 25
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 25.0

    # Test 3: Edge case with zero principal
    principal = 0.0
    # Expected: 0 * 0.05 * 0.5 = 0
    @test calculate_interest(principal, rate, time_fraction, Linear()) == 0.0

    # Test 4: Edge case with a negative time fraction (e.g., early withdrawal)
    principal = 1000.0
    time_fraction = -0.5
    # Expected: 1000 * 0.05 * -0.5 = -25
    @test calculate_interest(principal, rate, time_fraction, Linear()) == -25.0

    # Test 5: Vectorized calculation for multiple principals, rates, and time fractions
    principals = [1000.0, 500.0]
    rates = [0.05, 0.04]
    time_fractions = [1.0, 0.5]
    # Expected: [1000 * 0.05 * 1, 500 * 0.04 * 0.5] = [50.0, 10.0]
    expected = [50.0, 10.0]
    @test calculate_interest(principals, rates, time_fractions, Linear()) == expected
end

# Compounded Interest Tests
# This test set validates the `calculate_interest` function for the `Compounded` interest method.
# The tests cover:
# - Standard interest calculation with monthly compounding at a 5% annual rate.
# - Different compounding frequencies (e.g., quarterly).
# - Edge cases such as zero principal, zero time fraction, and negative time fractions.
# - Vectorized calculations for multiple principals, rates, and time fractions.
@testset "Compounded Interest Tests" begin
    principal = 1000.0
    rate = 0.05  # 5% annual interest
    time_fraction = 1.0  # 1 year
    frequency = 12  # Monthly compounding

    # Test 1: Standard calculation for 1 year at 5% interest with monthly compounding
    # Expected: 1000 * (1 + 0.05 / 12)^(12 * 1) - 1000
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 2: Calculation with quarterly compounding
    frequency = 4  # Quarterly compounding
    # Expected: 1000 * (1 + 0.05 / 4)^(4 * 1) - 1000
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 3: Edge case with zero principal
    principal = 0.0
    # Expected: 0 compound interest
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) == 0.0

    # Test 4: Edge case with a time fraction of zero (no time has passed)
    principal = 1000.0
    time_fraction = 0.0
    # Expected: 1000 * (1 + 0.05 / 4)^(4 * 0) - 1000 = 0
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) == 0.0

    # Test 5: Edge case with a negative time fraction (e.g., interest for past periods)
    time_fraction = -1.0
    # Expected: Compound interest can also be negative when time goes backward
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 6: Vectorized calculation for multiple principals, rates, and time fractions
    principals = [1000.0, 500.0]
    rates = [0.05, 0.04]
    time_fractions = [1.0, 0.5]
    frequency = 12  # Monthly compounding
    # Expected for each:
    # 1000 * (1 + 0.05 / 12)^(12 * 1) - 1000
    # 500 * (1 + 0.04 / 12)^(12 * 0.5) - 500
    expected = [
        1000.0 * (1 + 0.05 / 12)^(12 * 1.0) - 1000.0,
        500.0 * (1 + 0.04 / 12)^(12 * 0.5) - 500.0
    ]
    @test calculate_interest(principals, rates, time_fractions, Compounded(frequency)) ≈ expected
end
