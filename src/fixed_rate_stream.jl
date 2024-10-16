"""
    FlowStreamConfig

An abstract type representing the configuration for a stream of cash flows.
This serves as a base type for specific cash flow stream configurations, like fixed-rate streams.
"""
abstract type FlowStreamConfig end

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
struct FixedRateStreamConfig{P, R, S<:ScheduleConfig, T<:RateType, D<:DayCountConvention} <: FlowStreamConfig
    principal::P
    rate::R
    start_date
    end_date
    schedule_config::S
    pay_shift
    day_count_convention::D
    rate_convention::T
end

"""
    FlowStream

An abstract type representing a stream of cash flows. Concrete stream types such as `FixedRateStream` will inherit from this type.
"""
abstract type FlowStream end

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
function FixedRateStream(stream_config::FixedRateStreamConfig)
    accrual_dates = generate_schedule(stream_config.schedule_config) .|> collect
    pay_dates = relative_schedule(accrual_dates, stream_config.pay_shift)
    time_fractions = day_count_fraction(accrual_dates, stream_config.day_count_convention)
    cash_flows = calculate_interest([stream_config.principal], [stream_config.rate], time_fractions, stream_config.rate_convention)

    return FixedRateStream(pay_dates, accrual_dates, cash_flows)
end