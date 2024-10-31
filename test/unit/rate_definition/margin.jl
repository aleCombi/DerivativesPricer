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
