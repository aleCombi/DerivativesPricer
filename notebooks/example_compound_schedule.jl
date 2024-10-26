using DerivativesPricer
using Dates
using BusinessDays

# configuration
start_date = Date(2022,1,1)
end_date = Date(2025,1,1)
rate_index = RateIndex("dummy rate index")
principal = 1
day_count_convention = ACT360()
rate_type = LinearRate()
fixing_shift = NoShift()
compound_schedule = ScheduleConfig(Month(1), NoRollConvention(), NoneBusinessDayConvention(), BusinessDays.TARGET(), StubPeriod())
compound_margin = DerivativesPricer.MarginOnCompoundedRate(AdditiveMargin(0))
rate_config = CompoundRateConfig(day_count_convention, rate_type, fixing_shift, compound_schedule, compound_margin)
instrument_rate = DerivativesPricer.CompoundInstrumentRate(rate_index, rate_config)
main_schedule = ScheduleConfig(Year(1), NoRollConvention(), NoneBusinessDayConvention(), BusinessDays.TARGET(), StubPeriod())
instrument_schedule = InstrumentSchedule(start_date, end_date, main_schedule)
stream_config = FlowStreamConfig(principal, instrument_rate, instrument_schedule)

# schedule generation
schedules = CompoundedRateStreamSchedules(stream_config)

# rate curve setup
interest_rate = 0.03  # 3% flat rate
day_count = ACT360()
settlement_date = Date(2022, 1, 1)
rate_curve = FlatRateCurve("myRateCurve", settlement_date, interest_rate, day_count, Exponential())

# forward rates calculation
calculate_forward_rate(rate_curve, schedules, rate_config)