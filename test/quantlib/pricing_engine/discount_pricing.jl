# act365, cmp rate, modified preceding, 3 months, 2 days pay delay
@testitem "Quantlib:  act365, cmp rate, modified preceding, 3 months, 2 days pay delay" setup=[QuantlibSetup] begin
## Getting Hedgehog Results
# schedule configuration
start_date = Date(2019, 6, 27)
end_date = Date(2029, 6, 27)
schedule_config = ScheduleConfig(Month(3); business_days_convention=ModifiedPreceding(), calendar=BusinessDays.TARGET())
instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

# rate configuration
rate = 0.0047
rate_config = FixedRateConfig(ACT360(), LinearRate())
instrument_rate = FixedRate(rate, rate_config)

# fixed rate stream configuration
principal = 1.0
stream_config = FixedStreamConfig(principal, instrument_rate, instrument_schedule)

# fixed rate stream calculations
fixed_rate_stream = FixedRateStream(stream_config)

## Getting Quanatlib Results

ql_start_date = to_ql_date(start_date)
ql_end_date = to_ql_date(end_date)

# Define schedule with NullCalendar (treat all days as business)
schedule = ql.Schedule(ql_start_date, ql_end_date, ql.Period(ql.Quarterly),
                        ql.TARGET(), ql.ModifiedPreceding, ql.ModifiedPreceding,
                       ql.DateGeneration.Forward, false)

ql_fixed_rate_leg = ql.FixedRateLeg(schedule, ql.Actual360(), [principal], [rate])
ql_fixed_flows = [cash_flow.amount() for cash_flow in ql_fixed_rate_leg]

# Define the discount rate for the flat curve
flat_rate = 0.02  # Example: 2% flat rate

# Set the reference date (valuation date) for the curve, matching the start of the instrument
valuation_date = ql_start_date  # Could be any date, but often the start date is used
ql.Settings.instance().evaluationDate = valuation_date

# Create a flat forward curve
day_count = ql.Actual360()  # Use the same day count convention as the instrument
calendar = ql.NullCalendar()  # NullCalendar for simplicity, no holidays considered
flat_forward_curve = ql.FlatForward(valuation_date, ql.QuoteHandle(ql.SimpleQuote(flat_rate)), day_count)

# Turn the curve into a YieldTermStructureHandle for pricing
discount_curve_handle = ql.YieldTermStructureHandle(flat_forward_curve)

# Define the fixed rate leg based on the previously defined schedule and principal
fixed_rate_leg = ql.FixedRateLeg(schedule, day_count, [principal], [rate])

# Discount each cash flow and calculate the present value
present_value = sum([
    cash_flow.amount() * discount_curve_handle.discount(cash_flow.date())
    for cash_flow in fixed_rate_leg
])

print("Present Value of Fixed Rate Stream:", present_value)

rate_curve = FlatRateCurve("Curve", start_date, 0.02, ACT360(), Exponential())
price_hh = price_flow_stream(fixed_rate_stream, rate_curve)

@test isapprox(present_value, price_hh; atol=1e-15)
end