"""
    AbstractFlowStream

An abstract type that represents a generalized flow stream of financial instruments.
This is intended to be a parent type for different implementations of flow streams.
"""
abstract type AbstractFlowStreamConfig end

"""
    struct FlowStream{P<:Number, R<:AbstractInstrumentRate, S<:AbstractInstrumentSchedule}

A parametric composite type `FlowStream` that represents a flow stream with a principal, 
rate, and schedule. It is designed to be flexible for financial modeling purposes, where:

- `P<:Number`: Represents the principal amount in the flow stream, typically a number.
- `R<:AbstractInstrumentRate`: Represents the rate (interest rate, discount rate, etc.) associated with the financial instrument.
- `S<:AbstractInstrumentSchedule`: Represents the schedule (time periods) over which the flow stream occurs.

# Fields
- `principal::P`: The principal value of the flow stream.
- `rate::R`: The rate associated with the instrument.
- `schedule::S`: The schedule or timetable for the flow stream.
"""
struct FlowStreamConfig{P<:Number, R<:AbstractInstrumentRate, S<:AbstractInstrumentSchedule}
    principal::P
    rate::R
    schedule::S
end

"""
    FlowStream

An abstract type representing a stream of cash flows. Concrete stream types such as `FixedRateStream` will inherit from this type.
"""
abstract type FlowStream end

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
struct FloatingRateStream{D, T} <: FlowStream
    config::FlowStreamConfig
    pay_dates::Vector{D}
    fixing_dates::Vector{D}
    fixing_end_dates::Vector{D}
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

function FloatingRateStream(stream_config::FlowStreamConfig{P,F,S}) where {P,F<:FloatRate,S}
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
    accrual_day_counts = day_count_fraction(accrual_dates, stream_config.rate.rate_config.day_count_convention)
    fixing_dates = relative_schedule(accrual_dates, stream_config.rate.rate_config.fixing_shift)
    fixing_end_dates = generate_end_date(fixing_dates, stream_config.schedule.schedule_config)
    return FloatingRateStream(stream_config, pay_dates, fixing_dates, fixing_end_dates, accrual_dates, accrual_day_counts)
end

"""
    FixedRateStream <: FlowStream

A concrete type representing a stream of fixed-rate cash flows. This includes the payment dates, accrual dates, and the calculated cash flows.

# Fields
- `pay_dates`: A vector of payment dates.
- `accrual_dates`: A vector of accrual period start dates.
- `cash_flows`: A vector of calculated cash flows for each period.
"""
struct FixedRateStream{D, T} <: FlowStream
    pay_dates::Vector{D}
    accrual_dates::Vector{D}
    cash_flows::Vector{T}
end

"""
    FixedRateStream(stream_config::FixedRateStreamConfig) -> FixedRateStream

Creates a `FixedRateStream` from a given `FixedRateStreamConfig`. This function generates the accrual schedule, calculates the time fractions
between accrual periods using the specified day count convention, and computes the cash flows based on the principal, interest rate, and rate convention.

# Arguments
- `stream_config::FixedRateStreamConfig`: The configuration specifying the parameters for the fixed-rate stream.

# Returns
- A `FixedRateStream` containing the payment dates, accrual dates, and cash flows.

# Example
- config = FixedRateStreamConfig( 100000, 0.05, ScheduleConfig(Date(2023, 1, 1), Date(2024, 1, 1), Monthly(), ACT360()), Linear() ) stream = FixedRateStream(config)
"""
function FixedRateStream(stream_config::FlowStreamConfig{P, F, S}) where {P,F<:FixedRate, S}
    accrual_dates = generate_schedule(stream_config.schedule)
    pay_dates = relative_schedule(accrual_dates, stream_config.schedule.pay_shift)
    time_fractions = day_count_fraction(accrual_dates, stream_config.rate.rate_config.day_count_convention)
    cash_flows = calculate_interest([stream_config.principal], [stream_config.rate.rate], time_fractions, stream_config.rate.rate_config.rate_convention)
    return FixedRateStream(pay_dates, accrual_dates, cash_flows)
end