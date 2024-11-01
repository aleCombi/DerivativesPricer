"""
    struct SimpleRateStreamSchedules{D <: TimeType, T <: Number}

Represents a schedule for simple rate streams, including payment dates, fixing dates, discount dates, and accrual information.

# Fields
- `pay_dates::Vector{D}`: A vector containing the dates when payments are due.
- `fixing_dates::Vector{D}`: A vector of dates for fixing rates, typically set in advance of payment dates.
- `discount_start_dates::Vector{D}`: A vector of start dates for the discounting period.
- `discount_end_dates::Vector{D}`: A vector of end dates for the discounting period.
- `accrual_dates::Vector{D}`: A vector of accrual period start dates.
- `accrual_day_counts::Vector{T}`: A vector of day count fractions for each accrual period, representing the portion of the year.

This struct organizes dates and day count fractions relevant to simple rate calculations, facilitating accurate interest and discount calculations.
"""
struct SimpleRateStreamSchedules{D <: TimeType, T <: Number}
    pay_dates::Vector{D}
    fixing_dates::Vector{D}
    discount_start_dates::Vector{D}
    discount_end_dates::Vector{D}
    accrual_dates::Vector{D}
    accrual_day_counts::Vector{T}
end

"""
    SimpleRateStreamSchedules(stream_config::FloatStreamConfig{P, SimpleInstrumentRate}) -> SimpleRateStreamSchedules

Creates a `SimpleRateStreamSchedules` object from a given `FloatStreamConfig`, setting up schedules for payments, fixings, discounts,
and accruals.

# Arguments
- `stream_config::FloatStreamConfig{P, SimpleInstrumentRate}`: Configuration for the floating rate stream, including payment schedules and rate conventions.

# Returns
- A `SimpleRateStreamSchedules` instance with generated payment, fixing, discount, and accrual dates.
"""
function SimpleRateStreamSchedules(stream_config::FloatStreamConfig{P,SimpleInstrumentRate}) where P
    return SimpleRateStreamSchedules(stream_config.schedule, stream_config.rate.rate_config)
end

"""
    SimpleRateStreamSchedules(instrument_schedule::S, rate_config::SimpleRateConfig) -> SimpleRateStreamSchedules

Generates a `SimpleRateStreamSchedules` object using an `AbstractInstrumentSchedule` and a `SimpleRateConfig`. The schedule includes payment dates,
fixing dates, discount dates, accrual dates, and accrual day counts.

# Arguments
- `instrument_schedule::S <: AbstractInstrumentSchedule`: The instrument schedule containing information on accrual and payment dates.
- `rate_config::SimpleRateConfig`: Rate configuration specifying day count conventions and fixing shifts.

# Returns
- A `SimpleRateStreamSchedules` instance containing payment dates, fixing dates, discount start and end dates, accrual dates, and day counts.
"""
function SimpleRateStreamSchedules(instrument_schedule::S, rate_config::SimpleRateConfig) where S <: AbstractInstrumentSchedule
    accrual_dates = generate_schedule(instrument_schedule)
    time_fractions = day_count_fraction(accrual_dates, rate_config.day_count_convention)
    pay_dates = shifted_trimmed_schedule(accrual_dates, instrument_schedule.pay_shift)
    fixing_dates = shifted_trimmed_schedule(accrual_dates, rate_config.fixing_shift)
    discount_start_dates = fixing_dates
    discount_end_dates = generate_end_date(fixing_dates, instrument_schedule.schedule_config)
    return SimpleRateStreamSchedules(pay_dates, fixing_dates, discount_start_dates, discount_end_dates, accrual_dates, time_fractions)
end

"""
    struct FloatingRateStream{D, T} <: FlowStream

A type representing a stream of floating-rate cash flows with specified dates for payments, accrual, and rate fixings.

# Fields
- `config::FloatRateStreamConfig`: The configuration details for the floating-rate stream.
- `pay_dates::Vector{D}`: Vector of payment dates.
- `fixing_dates::Vector{D}`: Vector of fixing dates, determining when rates are set.
- `accrual_dates::Vector{D}`: Vector of start dates for each accrual period.
- `accrual_day_counts::Vector{T}`: Vector of day count fractions for each accrual period.

This struct is primarily used to calculate and manage floating-rate payment streams based on predefined schedules and rate conventions.
"""
struct SimpleFloatRateStream{P} <: FlowStream where P
    config::FloatStreamConfig{P, SimpleInstrumentRate}
    schedules::SimpleRateStreamSchedules
end

"""
    SimpleFloatRateStream(config::FloatStreamConfig{P, SimpleInstrumentRate}) -> SimpleFloatRateStream

Creates a `SimpleFloatRateStream` using a given `FloatStreamConfig` configuration. The function initializes the schedules
for payment, fixing, and accrual based on the input configuration.

# Arguments
- `config::FloatStreamConfig{P, SimpleInstrumentRate}`: The configuration for the floating-rate stream, specifying schedules and rate conventions.

# Returns
- A `SimpleFloatRateStream` instance with the calculated schedules.
"""
function SimpleFloatRateStream(config::FloatStreamConfig{P, SimpleInstrumentRate}) where P
    return SimpleFloatRateStream(config, SimpleRateStreamSchedules(config))
end
