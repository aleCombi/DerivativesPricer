"""
    AbstractRateIndex

An abstract type representing a rate index. This type is used to define the rate index for a floating-rate stream.
"""
abstract type AbstractRateIndex end

"""
    RateIndex

A structure representing a rate index.

# Fields
- `name::String`: The name of the rate index.
"""
struct RateIndex
    name::String
end

"""
    FloatRateStreamConfig{P, R<:RateIndex, S<:ScheduleConfig, T<:RateType} <: FlowStreamConfig

Configuration for a floating-rate stream of cash flows. This includes the principal amount, the rate index, the schedule
for the payments, and the convention for calculating interest.

# Fields
- `principal::P`: The principal amount for the floating-rate cash flows.
- `rate_index::R`: The rate index used for the floating rate (e.g., LIBOR, EURIBOR).
- `schedule_config::S`: The schedule configuration that defines the rules needed to generate the accrual and payment schedules.
- `rate_convention::T`: The rate convention used to calculate interest (e.g., `Linear`, `Compounded`).
- `fixing_schedule_shift`: Fixing Schedule shift from the accrual schedule.
"""
struct FloatRateStreamConfig{P, R<:AbstractRateIndex, S<:AbstractScheduleConfig, T<:RateType, D<:DayCountConvention, C<:AbstractShift} <: FlowStreamConfig
    principal::P
    rate_index::R
    schedule_config::S
    day_count_convention::D
    rate_convention::T
    fixing_schedule_shift::C
end

"""
    FloatingRateStream{D, T} <: FlowStream

A concrete type representing a stream of floating-rate cash flows. This includes the payment dates, accrual dates, fixing dates,
and the calculated day counts for each period.

# Fields
- `config::FloatRateStreamConfig`: The configuration for the floating-rate stream.
- `pay_dates::Vector{D}`: A vector of payment dates.
- `accrual_day_counts::Vector{T}`: A vector of calculated day counts for each accrual period.
"""
struct FloatingRateStream{D, T} <: FlowStream
    config::FloatRateStreamConfig
    pay_dates::Vector{D}
    fixing_dates::Vector{D}
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

function FloatingRateStream(stream_config::FloatRateStreamConfig) 
    pay_dates_iter, accrual_dates_iter = generate_schedule(stream_config.schedule_config)
    pay_dates = collect(pay_dates_iter)
    accrual_dates = collect(accrual_dates_iter)
    accrual_day_counts = day_count_fraction(accrual_dates, stream_config.day_count_convention)
    fixing_dates = relative_schedule(accrual_dates, stream_config.fixing_schedule_shift)
    return FloatingRateStream(stream_config, pay_dates, fixing_dates, accrual_dates, accrual_day_counts)
end