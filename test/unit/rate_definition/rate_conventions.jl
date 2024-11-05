# Linear Interest Tests
@testitem "Linear Interest Tests" begin
    principal = 1000.0
    rate = 0.05  # 5% annual interest
    time_fraction = 1.0  # 1 year

    # Test 1: Standard calculation for 1 year at 5% interest
    @test calculate_interest(principal, rate, time_fraction, LinearRate()) == 50.0

    # Test 2: Calculation for 6 months (0.5 years)
    time_fraction = 0.5
    @test calculate_interest(principal, rate, time_fraction, LinearRate()) == 25.0

    # Test 3: Edge case with zero principal
    principal = 0.0
    @test calculate_interest(principal, rate, time_fraction, LinearRate()) == 0.0

    # Test 4: Edge case with a negative time fraction (e.g., early withdrawal)
    principal = 1000.0
    time_fraction = -0.5
    @test calculate_interest(principal, rate, time_fraction, LinearRate()) == -25.0

    # Test 5: Vectorized calculation for multiple principals, rates, and time fractions
    principals = [1000.0, 500.0]
    rates = [0.05, 0.04]
    time_fractions = [1.0, 0.5]
    expected = [50.0, 10.0]
    @test calculate_interest(principals, rates, time_fractions, LinearRate()) == expected
end

# Compounded Interest Tests
@testitem "Compounded Interest Tests" begin
    principal = 1000.0
    rate = 0.05
    time_fraction = 1.0
    frequency = 12

    # Test 1: Standard calculation for 1 year at 5% interest with monthly compounding
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 2: Calculation with quarterly compounding
    frequency = 4
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 3: Edge case with zero principal
    principal = 0.0
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) == 0.0

    # Test 4: Edge case with a time fraction of zero (no time has passed)
    principal = 1000.0
    time_fraction = 0.0
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) == 0.0

    # Test 5: Edge case with a negative time fraction
    time_fraction = -1.0
    expected_interest = principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Compounded(frequency)) ≈ expected_interest

    # Test 6: Vectorized calculation
    principals = [1000.0, 500.0]
    rates = [0.05, 0.04]
    time_fractions = [1.0, 0.5]
    frequency = 12
    expected = [
        1000.0 * (1 + 0.05 / 12)^(12 * 1.0) - 1000.0,
        500.0 * (1 + 0.04 / 12)^(12 * 0.5) - 500.0
    ]
    @test calculate_interest(principals, rates, time_fractions, Compounded(frequency)) ≈ expected
end

# Exponential Interest Tests
@testitem "Exponential Interest Tests" begin
    principal = 1000.0
    rate = 0.05
    time_fraction = 1.0

    # Test 1: Standard calculation for 1 year at 5% interest
    expected_interest = principal * exp(rate * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Exponential()) ≈ expected_interest

    # Test 2: Calculation for 6 months (0.5 years)
    time_fraction = 0.5
    expected_interest = principal * exp(rate * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Exponential()) ≈ expected_interest

    # Test 3: Edge case with zero principal
    principal = 0.0
    @test calculate_interest(principal, rate, time_fraction, Exponential()) == 0.0

    # Test 4: Edge case with a negative time fraction
    principal = 1000.0
    time_fraction = -1.0
    expected_interest = principal * exp(rate * time_fraction) - principal
    @test calculate_interest(principal, rate, time_fraction, Exponential()) ≈ expected_interest

    # Test 5: Vectorized calculation
    principals = [1000.0, 500.0]
    rates = [0.05, 0.04]
    time_fractions = [1.0, 0.5]
    expected = [
        1000.0 * exp(0.05 * 1.0) - 1000.0,
        500.0 * exp(0.04 * 0.5) - 500.0
    ]
    @test calculate_interest(principals, rates, time_fractions, Exponential()) ≈ expected
end

# Linear Rate - Discount and Compounding Factor Tests
@testitem "Linear Rate - Discount and Compounding Factor Tests" begin
    principal = 1000.0
    rate = 0.05
    time_fraction = 1.0

    # Compounding Factor Test
    @test compounding_factor(rate, time_fraction, LinearRate()) == 1.05

    # Discount Factor Test
    @test discount_interest(rate, time_fraction, LinearRate()) ≈ 1/1.05

    # Edge Case - Zero Interest Rate
    rate = 0.0
    @test compounding_factor(rate, time_fraction, LinearRate()) == 1.0
    @test discount_interest(rate, time_fraction, LinearRate()) == 1.0
end

# Compounded Rate - Discount and Compounding Factor Tests
@testitem "Compounded Rate - Discount and Compounding Factor Tests" begin
    principal = 1000.0
    rate = 0.05
    time_fraction = 1.0
    frequency = 12

    # Compounding Factor Test
    expected_compounding_factor = (1 + rate / frequency)^(frequency * time_fraction)
    @test compounding_factor(rate, time_fraction, Compounded(frequency)) ≈ expected_compounding_factor

    # Discount Factor Test
    expected_discount_factor = 1 / expected_compounding_factor
    @test discount_interest(rate, time_fraction, Compounded(frequency)) ≈ expected_discount_factor

    # Edge Case - High Compounding Frequency (daily compounding)
    frequency = 365
    expected_compounding_factor = (1 + rate / frequency)^(frequency * time_fraction)
    @test compounding_factor(rate, time_fraction, Compounded(frequency)) ≈ expected_compounding_factor
    @test discount_interest(rate, time_fraction, Compounded(frequency)) ≈ (1 / expected_compounding_factor)
end

# Exponential Rate - Discount and Compounding Factor Tests
@testitem "Exponential Rate - Discount and Compounding Factor Tests" begin
    principal = 1000.0
    rate = 0.05
    time_fraction = 1.0

    # Compounding Factor Test
    expected_compounding_factor = exp(rate * time_fraction)
    @test compounding_factor(rate, time_fraction, Exponential()) ≈ expected_compounding_factor

    # Discount Factor Test
    expected_discount_factor = 1 / expected_compounding_factor
    @test discount_interest(rate, time_fraction, Exponential()) ≈ expected_discount_factor

    # Edge Case - Negative Interest Rate (exponential decay)
    rate = -0.05
    expected_compounding_factor = exp(rate * time_fraction)
    @test compounding_factor(rate, time_fraction, Exponential()) ≈ expected_compounding_factor
    @test discount_interest(rate, time_fraction, Exponential()) ≈ (1 / expected_compounding_factor)
end

# Implied Rate Tests
@testitem "Implied Rate Tests" begin
    accrual_ratio = 1.05  # The ratio implies a 5% growth over the time period
    time_fraction = 1.0  # 1 year

    # Linear Rate Type Tests
    # Test 1: Implied rate for a 1-year accrual with a 5% growth in a linear context
    @test implied_rate(accrual_ratio, time_fraction, LinearRate()) ≈ 0.05 atol=1e-10

    # Test 2: Implied rate for a half-year accrual with a 2.5% growth in a linear context
    accrual_ratio = 1.025
    time_fraction = 0.5
    @test implied_rate(accrual_ratio, time_fraction, LinearRate()) ≈ 0.05 atol=1e-10

    # Test 3: Edge case with a zero time fraction (undefined behavior)
    accrual_ratio = 1.05
    time_fraction = 0.0
    @test implied_rate(accrual_ratio, time_fraction, LinearRate()) == Inf

    # Compounded Rate Type Tests
    accrual_ratio = 1.05
    time_fraction = 1.0
    frequency = 12  # monthly compounding

    # Test 4: Implied rate for a 1-year accrual with a 5% growth in a compounded context (monthly)
    imp_rate = implied_rate(accrual_ratio, time_fraction, Compounded(frequency)) 
    comp_factor = compounding_factor(imp_rate, time_fraction, Compounded(frequency))
    @test comp_factor ≈ accrual_ratio atol=1e-10

    # Test 5: Implied rate with quarterly compounding for a 1.0125 accrual over 0.25 years
    accrual_ratio = 1.0125
    time_fraction = 0.25
    frequency = 4
    imp_rate = implied_rate(accrual_ratio, time_fraction, Compounded(frequency)) 
    comp_factor = compounding_factor(imp_rate, time_fraction, Compounded(frequency))
    @test comp_factor ≈ accrual_ratio atol=1e-10

    # Test 6: Edge case with zero accrual ratio
    accrual_ratio = 1.0
    time_fraction = 1.0
    @test implied_rate(accrual_ratio, time_fraction, Compounded(frequency)) == 0.0

    # Exponential Rate Type Tests
    accrual_ratio = 1.05
    time_fraction = 1.0

    # Test 7: Implied rate for a 1-year accrual with a 5% growth in an exponential context
    expected_rate = log(accrual_ratio)
    @test implied_rate(accrual_ratio, time_fraction, Exponential()) ≈ expected_rate atol=1e-10

    # Test 8: Implied rate for a half-year accrual with a 2.5% growth in an exponential context
    accrual_ratio = 1.025
    time_fraction = 0.5
    expected_rate = log(accrual_ratio) / time_fraction
    @test implied_rate(accrual_ratio, time_fraction, Exponential()) ≈ expected_rate atol=1e-10

    # Edge case: Implied rate with an accrual ratio of 1 (no growth)
    accrual_ratio = 1.0
    time_fraction = 1.0
    @test implied_rate(accrual_ratio, time_fraction, Exponential()) == 0.0
end
