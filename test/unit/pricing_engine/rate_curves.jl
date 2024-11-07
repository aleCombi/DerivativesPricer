# Import the necessary dependencies and modules
using Test
using DerivativesPricer

@testsnippet RateCurves begin
    using Interpolations
    using Dates
    const InterpType = Interpolations.InterpolationType
end
    
# Test 1: Basic creation of a RateCurveInputs struct using day counts
@testitem "Basic RateCurveInputs Construction (Day Counts)" setup=[RateCurves] begin
    times_day_counts = [0.1, 0.2, 0.3]
    times = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] # since we are inputing day_counts, this is not used
    rates = [1.5, 2.0, 2.5]
    interp_method = Gridded(Interpolations.Linear())
    date = Date(2023, 1, 1)
    day_count_convention = ACT365()

    # Create RateCurveInputs instance
    inputs = RateCurveInputs(times_day_counts, rates, interp_method, date, day_count_convention, LinearRate(), times)

    # Test if fields are correctly set
    @test inputs.times_day_counts == [0.1, 0.2, 0.3]
    @test inputs.rates == [1.5, 2.0, 2.5]
    @test inputs.date == Date(2023, 1, 1)
    @test inputs.day_count_convention isa ACT365
end

# Test 2: Creation of RateCurveInputs from Date-based time points (automatic day count conversion)
@testitem "RateCurveInputs Construction from Dates" setup=[RateCurves] begin
    times = [Date(2023, 6, 1), Date(2023, 12, 1)]
    rates = [1.5, 2.0]
    interp_method = Gridded(Interpolations.Linear())
    date = Date(2023, 1, 1)
    day_count_convention = ACT365()

    # Create RateCurveInputs instance (automatic day count conversion)
    inputs = RateCurveInputs(times, rates, date, interp_method, day_count_convention)

    # Test if fields are set correctly and day counts were computed
    @test inputs.times_day_counts == [0.0, 151.0/365, 334.0/365]  # Example conversion based on ACT365
    @test inputs.rates == [1.0, 1.5, 2.0]
end

# Test 3: RateCurve construction from RateCurveInputs
@testitem "RateCurve Construction" setup=[RateCurves] begin
    times_day_counts = [0.1, 0.2, 0.3]
    times = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] # since we are inputing day_counts, this is not used
    rates = [1.5, 2.0, 2.5]
    interp_method = Gridded(Interpolations.Linear())
    date = Date(2023, 1, 1)
    day_count_convention = ACT365()

    # Create RateCurveInputs instance
    inputs = RateCurveInputs(times_day_counts, rates, interp_method, date, day_count_convention, LinearRate(), times)

    # Create the RateCurve
    curve = create_rate_curve(inputs)

    # Test that the RateCurve fields are set correctly
    @test curve.name != ""  # Check that name is not empty
    @test curve.interpolation isa Interpolations.GriddedInterpolation
    @test curve.date == Date(2023, 1, 1)
    @test curve.day_count_convention isa ACT365
end

# Test 4: Discount Factor Calculation
@testitem "Discount Factor Calculation" setup=[RateCurves] begin
    times_day_counts = [0.1, 0.2, 3]
    times = [Date(2023, 1, 1), Date(2023, 6, 1), Date(2023, 12, 1)] # since we are inputing day_counts, this is not used
    rates = [1.5, 2.0, 2.5]
    interp_method = Gridded(Interpolations.Linear())
    date = Date(2023, 1, 1)
    day_count_convention = ACT365()

    # Create RateCurveInputs instance
    inputs = RateCurveInputs(times_day_counts, rates, interp_method, date, day_count_convention, LinearRate(), times)

    # Create the RateCurve
    curve = create_rate_curve(inputs)

    # Calculate discount factor with the real interpolation
    test_date = Date(2023, 6, 1)
    discount = discount_factor(curve, test_date)

    # Expected discount factor (based on the real interpolation)
    expected_discount = 1 / (1 + 151.0/365 * curve.interpolation(151.0/365))  # Example day count for June 1, 2023
    @test discount ≈ expected_discount
end