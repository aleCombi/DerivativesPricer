"""
    ScheduleConfig

Represents the configuration for generating a payment schedule in a stream of cash flows.

# Fields
- `start_date::Date`: The start date of the schedule.
- `end_date::Date`: The end date of the schedule.
- `schedule_rule::ScheduleRule`: The rule for generating the schedule (e.g., monthly, quarterly).
- `day_count_convention::DayCountConvention`: The convention for calculating time fractions between accrual periods (e.g., ACT/360, ACT/365).
"""
struct ScheduleConfig
    start_date::Date
    end_date::Date
    schedule_rule::ScheduleRule
    day_count_convention::DayCountConvention
end

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
struct FixedRateStreamConfig <: FlowStreamConfig
    principal::Float64
    rate
    schedule_config::ScheduleConfig
    rate_convention::RateType
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
- `pay_dates::Vector{Date}`: A vector of payment dates.
- `accrual_dates::Vector{Date}`: A vector of accrual period start dates.
- `cash_flows::Vector{Float64}`: A vector of calculated cash flows for each period.
"""
struct FixedRateStream <: FlowStream
    pay_dates::Vector{Date}
    accrual_dates::Vector{Date}
    cash_flows::Vector{Float64}
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
- config = FixedRateStreamConfig( 100000, 0.05, ScheduleConfig(Date(2023, 1, 1), Date(2024, 1, 1), MonthlySchedule(), ACT360()), Linear() ) stream = FixedRateStream(config)
"""
function FixedRateStream(stream_config::FixedRateStreamConfig)
    accrual_dates = generate_schedule(
        stream_config.schedule_config.start_date, 
        stream_config.schedule_config.end_date, 
        stream_config.schedule_config.schedule_rule
    )
    
    time_fractions = day_count_fraction(accrual_dates, stream_config.schedule_config.day_count_convention)
    
    cash_flows = calculate_interest([stream_config.principal], [stream_config.rate], time_fractions, stream_config.rate_convention)
    
    return FixedRateStream(accrual_dates, accrual_dates, cash_flows)
end