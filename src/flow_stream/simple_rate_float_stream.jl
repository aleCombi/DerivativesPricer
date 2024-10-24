struct SimpleRateStreamSchedules{D, T}
    pay_dates::Vector{D}
    fixing_dates::Vector{D}
    discount_start_dates::Vector{D}
    discount_end_dates::Vector{D}
    accrual_dates::Vector{D}
    accrual_day_counts::Vector{T}
end

"""
    FloatRateStream(stream_config::FloatRateStreamConfig) -> FloatingRateStream

Creates a `FloatingRateStream` from a given `FloatRateStreamConfig`. This function generates the accrual schedule, calculates the time fractions
between accrual periods using the specified day count convention, and initializes the floating-rate stream.

# Arguments
- `stream_config::FloatRateStreamConfig`: The configuration specifying the parameters for the floating-rate stream.

# Returns
- A `FloatingRateStream` containing the payment dates, accrual dates, fixing dates, and day counts.

# Example
""" 

function SimpleRateStreamSchedules(stream_config::FlowStreamConfig{P,SimpleInstrumentRate,S}) where {P,S}
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
    fixing_dates = relative_schedule(accrual_dates, stream_config.rate.rate_config.fixing_shift)
    discount_start_dates = fixing_dates
    discount_end_dates = generate_end_date(fixing_dates, stream_config.schedule.schedule_config)
    return SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, stream_config.rate.rate_config.day_count_convention)
end

function SimpleRateStreamSchedules(pay_dates::Vector{D}, fixing_dates::Vector{D}, discount_start_dates::Vector{D}, discount_end_dates::Vector{D}, accrual_dates::Vector{D}, day_count_convention::C) where {C<:DayCount, D<:TimeType}
    accrual_day_counts = day_count_fraction(accrual_dates, day_count_convention)
    return SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, accrual_day_counts)
end


"""
    FloatingRateStream{D, T} <: FlowStream

A concrete type representing a stream of floating-rate cash flows. This includes the payment dates, accrual dates, fixing dates,
and the calculated day counts for each period.

# Fields
- `config::FloatRateStreamConfig`: The configuration for the floating-rate stream.
- `pay_dates::Vector{D}`: A vector of payment dates.
- `fixing_dates::Vector{D}`: A vector of fixing dates.
- `accrual_dates::Vector{D}`: A vector of accrual period start dates.
- `accrual_day_counts::Vector{T}`: A vector of calculated day counts for each accrual period.
"""
struct SimpleFloatRateStream{P,S} <: FlowStream where {P,S}
    config::FlowStreamConfig{P,SimpleInstrumentRate,S}
    schedules::SimpleRateStreamSchedules
end

function SimpleFloatRateStream(config::FlowStreamConfig{P,SimpleInstrumentRate,S}) where {P,S}
    return SimpleFloatRateStream(config, SimpleRateStreamSchedules(config))
end