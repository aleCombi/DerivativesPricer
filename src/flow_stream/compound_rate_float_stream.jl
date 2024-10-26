struct CompoundedRateStreamSchedules{D, A, B}
    pay_dates::Vector{D}
    compounding_schedules::Vector{SimpleRateStreamSchedules{A,B}}
    #this schedules also define pay dates which dont have a meaning in this context
end

function CompoundedRateStreamSchedules(stream_config::FlowStreamConfig{P,CompoundInstrumentRate,S}) where {P,S}
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
    compounded_instrument_schedules = [InstrumentSchedule(accrual_dates[i], accrual_dates[i+1], stream_config.rate.rate_config.compound_schedule, stream_config.schedule.pay_shift) for i in 1:length(accrual_dates)-1]
    compounding_schedules = [SimpleRateStreamSchedules(compounded_instrument_schedules[i], stream_config.rate.rate_config) for i in 1:length(accrual_dates)-1]
    return CompoundedRateStreamSchedules(pay_dates, compounding_schedules)
end

struct CompoundFloatRateStream{P,S} <: FlowStream where {P,S}
    config::FlowStreamConfig{P,CompoundInstrumentRate,S}
    schedules::CompoundedRateStreamSchedules
end

function CompoundFloatRateStream(stream_config::FlowStreamConfig{P,CompoundInstrumentRate,S}) where {P,S}
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
    fixing_dates = relative_schedule(accrual_dates, stream_config.rate.rate_config.fixing_shift)
    discount_start_dates = fixing_dates
    discount_end_dates = generate_end_date(fixing_dates, stream_config.schedule.schedule_config)
    return SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, stream_config.rate.rate_config.day_count_convention)
end
