struct CompoundedRateStreamSchedules{D, A, B, N}
    pay_dates::Vector{D}
    compounding_schedules::Vector{SimpleRateStreamSchedules{A,B}}
    accrual_day_counts::Vector{N}
    #this schedules also define pay dates which dont have a meaning in this context
end

function CompoundedRateStreamSchedules(pay_dates::Vector{D}, compounding_schedules::Vector{SimpleRateStreamSchedules{A,B}}) where {D,A,B}
    accrual_day_counts = [sum(schedule.accrual_day_counts) for schedule in compounding_schedules]
    return CompoundedRateStreamSchedules(pay_dates, compounding_schedules, accrual_day_counts)
end

function CompoundedRateStreamSchedules(stream_config::FloatStreamConfig{P,CompoundInstrumentRate}) where P
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = shifted_trimmed_schedule(accrual_dates, stream_config.schedule.pay_shift)
    compounded_instrument_schedules = [InstrumentSchedule(accrual_dates[i], accrual_dates[i+1], stream_config.rate.rate_config.compound_schedule, stream_config.schedule.pay_shift) for i in 1:length(accrual_dates)-1]
    compounding_schedules = [SimpleRateStreamSchedules(compounded_instrument_schedules[i], stream_config.rate.rate_config) for i in 1:length(accrual_dates)-1]
    return CompoundedRateStreamSchedules(pay_dates, compounding_schedules)
end

struct CompoundFloatRateStream{P,S} <: FlowStream where P
    config::FloatStreamConfig{P,CompoundInstrumentRate}
    schedules::CompoundedRateStreamSchedules
end

function CompoundFloatRateStream(stream_config::FloatStreamConfig{P,CompoundInstrumentRate}) where P
    return CompoundFloatRateStream(stream_config, CompoundedRateStreamSchedules(stream_config))
end