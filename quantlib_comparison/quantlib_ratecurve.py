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
    swap_engine = ql.DiscountingSwapEngine(rate_curve_handle)

    swap.setPricingEngine(swap_engine)
    return swap, rate_curve_handle, schedule

# Isolate setPricingEngine execution
def set_engine_only(swap, rate_curve_handle):
    swap_engine = ql.DiscountingSwapEngine(rate_curve_handle)
    swap.setPricingEngine(swap_engine)

# Calculation phase (NPV calculation)
def calculate_npv(swap):
    return swap.NPV()  # This is where the actual NPV is computed

# Discount factor calculation for the payment dates in the schedule
def calculate_discount_factors(rate_curve_handle, schedule):
    return [rate_curve_handle.discount(date) for date in schedule]


# Setup the environment (done only once)
swap, rate_curve_handle, schedule = setup_pricer_without_engine()
# set_engine_only(swap, rate_curve_handle)
samples = 10000

# Benchmark setPricingEngine alone
engine_time = timeit.timeit("set_engine_only(swap, rate_curve_handle)", 
                            setup="from __main__ import set_engine_only, swap, rate_curve_handle", 
                            globals=globals(),
                            number=samples)

# Time the NPV calculation separately
calculation_time = timeit.timeit("calculate_npv(swap)", 
                                 setup="from __main__ import calculate_npv, swap", 
                                 globals=globals(),
                                 number=samples)

# Time only the discount factor calculation (no setup involved)
discount_time = timeit.timeit("calculate_discount_factors(rate_curve_handle, schedule)", 
                              setup="from __main__ import calculate_discount_factors, rate_curve_handle, schedule", 
                              globals=globals(),
                              number=samples)

# Print the average execution times for setPricingEngine, NPV calculation, and discount factor calculation
print(f"Average setPricingEngine time over {samples} runs: {engine_time / samples * 1000000:.12f} microseconds")
print(f"Average NPV calculation time over {samples} runs: {calculation_time / samples * 1000000:.12f} microseconds")
print(f"Average discount factor calculation time over {samples} runs: {discount_time / samples * 1000000:.12f} microseconds")
