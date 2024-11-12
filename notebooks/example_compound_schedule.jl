using Hedgehog
using Dates
using BusinessDays

# example of the full pricing of a compounded rate stream.
# some calculations are redundant for the sake of showing the intermediate results here
# configuration
start_date = Date(2022, 1, 1)
end_date = Date(2025, 1, 1)
rate_index = RateIndex("dummy rate index")
principal = 1
day_count_convention = ACT360()
rate_type = LinearRate()
fixing_shift = NoShift()
compound_schedule = ScheduleConfig(Month(1))
compound_margin = Hedgehog.MarginOnCompoundedRate(AdditiveMargin(0))
rate_config = CompoundRateConfig(day_count_convention, rate_type, fixing_shift, compound_schedule, compound_margin)
instrument_rate = Hedgehog.CompoundInstrumentRate(rate_index, rate_config)
instrument_schedule = InstrumentSchedule(start_date, end_date, Year(1))
stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

# schedule generation
schedules = CompoundedRateStreamSchedules(stream_config)

# rate curve setup
interest_rate = 0.03  # 3% flat rate
day_count = ACT360()
settlement_date = Date(2022, 1, 1)
rate_curve = FlatRateCurve("myRateCurve", settlement_date, interest_rate, day_count, Exponential())

# forward rates calculation
forward_rates = forward_rate(rate_curve, schedules, rate_config)

# stream definition
stream = Hedgehog.CompoundFloatRateStream(stream_config)

# pricing the stream
forward_rates = forward_rate(rate_curve, schedules, rate_config)
expected_flows = Hedgehog.calculate_expected_flows(stream, forward_rates)
npv = price_flow_stream(stream, rate_curve)