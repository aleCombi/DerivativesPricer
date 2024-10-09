import QuantLib as ql
import timeit

# Setup phase (construct the curve, schedule, and stream, but don't set the pricing engine yet)
def setup_pricer_without_engine():
    # Market rates
    interest_rate = 0.03  # 3% flat rate
    day_count = ql.Actual360()

    # Set up the flat yield curve
    settlement_date = ql.Date(10, 10, 2024)
    ql.Settings.instance().evaluationDate = settlement_date

    rate = ql.SimpleQuote(interest_rate)
    rate_handle = ql.QuoteHandle(rate)
    rate_curve = ql.FlatForward(settlement_date, rate_handle, day_count)
    rate_curve_handle = ql.YieldTermStructureHandle(rate_curve)

    # Loan characteristics
    loan_notional = 1000000  # 1,000,000
    frequency = ql.Daily
    loan_interest_rate = [0.05]  # 5% fixed rate

    # Use NullCalendar where every day is a business day
    calendar = ql.NullCalendar()

    # Loan start and maturity dates
    start_date = ql.Date(10, 10, 2024)
    maturity_date = ql.Date(10, 10, 2025)

    # Define schedule with NullCalendar (treat all days as business)
    schedule = ql.Schedule(start_date, maturity_date, ql.Period(frequency),
                           calendar, ql.Following, ql.Following,
                           ql.DateGeneration.Forward, False)

    fixed_rate_leg = ql.FixedRateLeg(schedule, day_count, [loan_notional], loan_interest_rate)

    # Create swap without setting the pricing engine
    swap = ql.Swap(fixed_rate_leg, ql.Leg())  # Only a fixed-rate leg, no floating leg

    rate_curve_handle = ql.YieldTermStructureHandle(rate_curve)
    return swap, rate_curve_handle

# Isolate setPricingEngine execution
def set_engine_only(swap, rate_curve_handle):
    swap_engine = ql.DiscountingSwapEngine(rate_curve_handle)
    swap.setPricingEngine(swap_engine)

# Calculation phase (NPV calculation)
def calculate_npv(swap):
    return swap.NPV()  # This is where the actual NPV is computed

# Define an overall function that does both setup and NPV calculation
def overall_npv():
    swap, rate_curve_handle = setup_pricer_without_engine()
    set_engine_only(swap, rate_curve_handle)
    return calculate_npv(swap)

# Run the setup without the engine, only once and store the result
swap, rate_curve_handle = setup_pricer_without_engine()

# Now benchmark the setPricingEngine step only
samples = 10000

# Benchmark setPricingEngine alone
engine_time = timeit.timeit("set_engine_only(swap, rate_curve_handle)", 
                            setup="from __main__ import set_engine_only, swap, rate_curve_handle", 
                            number=samples)

# Time the calculation phase separately
calculation_time = timeit.timeit("calculate_npv(swap)", 
                                 setup="from __main__ import calculate_npv, swap", 
                                 number=samples)

# Time the combined setup (without engine) + NPV calculation phase
overall_time = timeit.timeit("overall_npv()", 
                             setup="from __main__ import overall_npv", 
                             number=samples)

# Print the average execution times for setPricingEngine, NPV calculation, and overall
print(f"Average setPricingEngine time over {samples} runs: {engine_time / samples * 1000000:.12f} microseconds")
print(f"Average NPV calculation time over {samples} runs: {calculation_time / samples * 1000000:.12f} microseconds")
print(f"Average overall time (setup without engine + NPV) over {samples} runs: {overall_time / samples * 1000000:.12f} microseconds")
