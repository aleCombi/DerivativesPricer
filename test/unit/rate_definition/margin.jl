using Test

# Tests for AdditiveMargin
@testitem "AdditiveMargin Structure" begin
    margin = AdditiveMargin(2.5)
    @test isa(margin, AdditiveMargin)
    @test margin.margin == 2.5
end

@testitem "apply_margin with AdditiveMargin" begin
    rate = 10.0
    margin = AdditiveMargin(2.5)
    result = apply_margin(rate, margin)
    
    @test result == rate + margin.margin
    @test result == 12.5
end

@testitem "apply_margin with AdditiveMargin default value 0" begin
    rate = 10.0
    margin = AdditiveMargin()
    result = apply_margin(rate, margin)
    
    @test result == rate + margin.margin
    @test result == rate
end

@testitem "apply_margin with AdditiveMargin (Int type)" begin
    rate = 5
    margin = AdditiveMargin(3)
    result = apply_margin(rate, margin)
    
    @test result == rate + margin.margin
    @test result == 8
end

# Tests for MultiplicativeMargin
@testitem "MultiplicativeMargin Structure" begin
    margin = MultiplicativeMargin(0.2)
    @test isa(margin, MultiplicativeMargin)
    @test margin.margin == 0.2
end

@testitem "apply_margin with MultiplicativeMargin" begin
    rate = 10.0
    margin = MultiplicativeMargin(0.2)
    result = apply_margin(rate, margin)
    
    @test result == rate * (1 + margin.margin)
    @test result ≈ 12.0  # Allowing for floating-point precision
end

@testitem "apply_margin with MultiplicativeMargin (Int type)" begin
    rate = 4
    margin = MultiplicativeMargin(0.5)
    result = apply_margin(rate, margin)
    
    @test result == rate * (1 + margin.margin)
    @test result == 6
end

# Tests for CompoundMargin types
@testitem "MarginOnUnderlying" begin
    add_margin = AdditiveMargin(2.5)
    comp_margin = MarginOnUnderlying(add_margin)
    
    @test isa(comp_margin, MarginOnUnderlying)
    @test isa(comp_margin.margin_config, AdditiveMargin)
    @test comp_margin.margin_config.margin == 2.5
end

@testitem "MarginOnCompoundedRate" begin
    mult_margin = MultiplicativeMargin(0.3)
    comp_margin = MarginOnCompoundedRate(mult_margin)
    
    @test isa(comp_margin, MarginOnCompoundedRate)
    @test isa(comp_margin.margin_config, MultiplicativeMargin)
    @test comp_margin.margin_config.margin == 0.3
end

@testitem "Margined rate" begin
    accrual_ratio = 1.05  # The ratio implies a 5% growth over the time period
    time_fraction = 1.0  # 1 year
    margin_config = AdditiveMargin(0.01)
    # Linear Rate Type Tests
    # Test 1: Implied rate for a 1-year accrual with a 5% growth in a linear context
    @test margined_rate(accrual_ratio, time_fraction, LinearRate(), margin_config) ≈ 0.06 atol=1e-10

    # Test 2: Implied rate for a half-year accrual with a 2.5% growth in a linear context
    accrual_ratio = 1.025
    time_fraction = 0.5
    @test margined_rate(accrual_ratio, time_fraction, LinearRate(), margin_config) ≈ 0.06 atol=1e-10

    # Test 3: Edge case with a zero time fraction (undefined behavior)
    accrual_ratio = 1.05
    time_fraction = 0.0
    @test margined_rate(accrual_ratio, time_fraction, LinearRate(), margin_config) == Inf

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

    margin_config = MultiplicativeMargin(0.01)

    # Test 6: Edge case with zero accrual ratio
    accrual_ratio = 1.0
    time_fraction = 1.0
    @test margined_rate(accrual_ratio, time_fraction, Compounded(frequency), margin_config) == 0.0

    # Exponential Rate Type Tests
    accrual_ratio = 1.05
    time_fraction = 1.0

    # Test 7: Implied rate for a 1-year accrual with a 5% growth in an exponential context
    expected_rate = log(accrual_ratio)
    @test margined_rate(accrual_ratio, time_fraction, Exponential(), margin_config) ≈ expected_rate*1.01 atol=1e-10

    # Test 8: Implied rate for a half-year accrual with a 2.5% growth in an exponential context
    accrual_ratio = 1.025
    time_fraction = 0.5
    expected_rate = log(accrual_ratio) / time_fraction
    @test margined_rate(accrual_ratio, time_fraction, Exponential(), margin_config) ≈ expected_rate*1.01 atol=1e-10

    # Edge case: Implied rate with an accrual ratio of 1 (no growth)
    accrual_ratio = 1.0
    time_fraction = 1.0
    @test margined_rate(accrual_ratio, time_fraction, Exponential(), margin_config) == 0.0
end
