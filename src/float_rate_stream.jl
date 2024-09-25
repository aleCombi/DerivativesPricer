using .DerivativesPricer

"""
    FixedRateStreamConfig <: FlowStreamConfig

Configuration for a fixed-rate stream of cash flows. This includes the principal amount, the fixed interest rate, and the schedule
for the payments, along with the convention for calculating interest.

# Fields
- `principal::Float64`: The principal amount for the fixed-rate cash flows.
- `rate`: The fixed interest rate.
- `schedule_config::ScheduleConfig`: The schedule configuration that defines the start, end, and payment frequency.
- `rate_convention::RateType`: The rate convention used to calculate interest (e.g., `Linear`, `Compounded`).
"""
struct FloatRateStreamConfig{P, R<:RateIndex, S<:ScheduleConfig, T<:RateType} <: FlowStreamConfig
    principal::P
    rate_index::R
    schedule_config::S
    rate_convention::T
end
"""
    FixedRateStream <: FlowStream

A concrete type representing a stream of fixed-rate cash flows. This includes the payment dates, accrual dates, and the calculated cash flows.

# Fields
- `pay_dates::Vector{Date}`: A vector of payment dates.
- `accrual_dates::Vector{Date}`: A vector of accrual period start dates.
- `cash_flows::Vector{Float64}`: A vector of calculated cash flows for each period.
"""
struct FloatingRateStream{D, T} <: FlowStream
    config::FloatRateStreamConfig
    pay_dates::Vector{D}
    accrual_dates::Vector{D}
    accrual_day_counts::Vector{T}
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
function FloatRateStream(stream_config::FloatRateStreamConfig)
    accrual_dates = generate_schedule(stream_config.schedule_config) |> collect
    accrual_day_counts = day_count_fraction(accrual_dates, stream_config.schedule_config.day_count_convention)

    return FloatingRateStream(stream_config, accrual_dates, accrual_dates, accrual_day_counts)
end