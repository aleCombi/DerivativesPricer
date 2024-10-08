import QuantLib as ql

def simple_fixed_pricer():
    # Market rates
    interest_rate = 0.03  # 3% flat rate

    # Day count convention
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
    frequency = ql.Annual
    loan_interest_rate = [0.05]  # 5% fixed rate

    # Use NullCalendar where every day is a business day
    calendar = ql.NullCalendar()

    # Loan start and maturity dates
    start_date = ql.Date(10, 10, 2024)
    maturity_date = ql.Date(10, 10, 2025)  # A 3-year loan

    # Define schedule with NullCalendar (treat all days as business)
    schedule = ql.Schedule(start_date, maturity_date, ql.Period(frequency),
                        calendar, ql.Following, ql.Following,
                        ql.DateGeneration.Forward, False)

    fixed_rate_leg = ql.FixedRateLeg(schedule, day_count, [loan_notional], loan_interest_rate)

    # Pricing engine using the flat rate curve
    swap = ql.Swap(fixed_rate_leg, ql.Leg())  # Only a fixed-rate leg, no floating leg

    swap_engine = ql.DiscountingSwapEngine(rate_curve_handle)
    swap.setPricingEngine(swap_engine)

    # Calculate the NPV of the loan
    npv = swap.NPV()
    return npv

import timeit

# Wrap the function call in timeit
execution_time = timeit.timeit("simple_fixed_pricer()", 
                               setup="from __main__ import simple_fixed_pricer", 
                               number=10000)

# Average execution time for 1000 runs
print(f"Average execution time over 1000 runs: {execution_time / 10000:.6f} seconds")
