using DerivativesPricer
using Dates
using BusinessDays

start_date = Date(2022,1,1)
end_date = Date(2025,1,1)
rate_index = RateIndex("dummy rate index")
principal = 1
day_count_convention = ACT360()
rate_type = LinearRate()
fixing_shift = NoShift()
compound_schedule = ScheduleConfig(Month(1), NoRollConvention(), NoneBusinessDayConvention(), BusinessDays.TARGET(), StubPeriod())
compound_margin = DerivativesPricer.MarginOnUnderlying(AdditiveMargin(0))
rate_config = CompoundRateConfig(day_count_convention, rate_type, fixing_shift, compound_schedule, compound_margin)
instrument_rate = DerivativesPricer.CompoundInstrumentRate(rate_index, rate_config)
main_schedule = ScheduleConfig(Year(1), NoRollConvention(), NoneBusinessDayConvention(), BusinessDays.TARGET(), StubPeriod())
instrument_schedule = InstrumentSchedule(start_date, end_date, main_schedule)

stream_config = FlowStreamConfig(principal, instrument_rate, instrument_schedule)

accrual_dates = generate_schedule(stream_config.schedule)
pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
compounded_instrument_schedules = [InstrumentSchedule(accrual_dates[i], accrual_dates[i+1], stream_config.rate.rate_config.compound_schedule, stream_config.schedule.pay_shift) for i in 1:length(accrual_dates)-1]
compounding_schedules = [SimpleRateStreamSchedules(compounded_instrument_schedules[i], stream_config.rate.rate_config) for i in 1:length(accrual_dates)-1]

cmp_stream_schedule = CompoundedRateStreamSchedules(stream_config)