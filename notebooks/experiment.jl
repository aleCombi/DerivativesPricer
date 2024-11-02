using DerivativesPricer
using Dates
using BusinessDays
using PyCall
ql = pyimport("QuantLib")

## Getting DerivativesPricer Results
# schedule configuration
start_date = Date(2019, 6, 27)
end_date = Date(2029, 6, 27)
schedule_config = ScheduleConfig(Month(1); business_days_convention=ModifiedFollowing(), calendar=BusinessDays.TARGET())
instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

# rate configuration
rate_config = SimpleRateConfig(ACT360(), LinearRate())
instrument_rate = SimpleInstrumentRate(RateIndex("rate_index"), rate_config)

# float rate stream configuration
principal = 1
stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

# float rate stream calculations
float_rate_stream = SimpleFloatRateStream(stream_config)

## Get Quantlib results
# Define the main parameters
tenor = ql.Period(6, ql.Months)  # Payment frequency (semiannual)
day_count = ql.Actual360()  # Day count convention
business_day_convention = ql.ModifiedFollowing  # Business day convention

# Define the schedule (e.g., start and end dates)
start_date = ql.Date(1, ql.January, 2024)
end_date = ql.Date(1, ql.January, 2029)

# Create a Schedule for the floating rate payments
schedule = ql.Schedule(
    start_date,
    end_date,
    tenor,
    ql.TARGET(),  # Calendar
    business_day_convention,
    business_day_convention,
    ql.DateGeneration.Forward,
    False
)

# Set up the floating rate index (e.g., USD LIBOR 6M)
# Note: You'll need to set up a yield term structure for the forward rate calculation
# Here, we'll assume a flat term structure for simplicity
flat_rate = ql.QuoteHandle(ql.SimpleQuote(0.02))  # Flat 2% rate for example
term_structure = ql.YieldTermStructureHandle(ql.FlatForward(0, ql.TARGET(), flat_rate, day_count))
index = ql.USDLibor(ql.Period(6, ql.Months), term_structure)

# Create the floating rate leg
floating_rate_leg = ql.FloatingRateLeg(schedule, index)
floating_rate_leg.withNotionals(notional)  # Set notional
floating_rate_leg.withPaymentDayCounter(day_count)  # Set day count convention
floating_rate_leg.withPaymentAdjustment(business_day_convention)  # Set adjustment convention

# Generate the coupons for the floating rate leg
floating_coupons = floating_rate_leg.makeLeg()