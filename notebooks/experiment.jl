using DerivativesPricer
using Dates
using BusinessDays
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

