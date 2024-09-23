using Dates
using DerivativesPricer
using BenchmarkTools

# Define the FixedRateStream struct
struct FixedRateStream{D, T} <: FlowStream
    pay_dates::Vector{D}
    accrual_dates::Vector{D}
    cash_flows::Vector{T}
end

# Define the FixedRateStreamConfig struct
struct FixedRateStreamConfig{P, R, S<:ScheduleConfig, T<:RateType}
    principal::P
    rate::R
    schedule_config::S
    rate_convention::T
end

# Define the constructor for FixedRateStream
function FixedRateStream(pay_dates::Vector{D}, accrual_dates::Vector{D}, cash_flows::Vector{T}) where {D, T}
    return FixedRateStream{D, T}(pay_dates, accrual_dates, cash_flows)
end

# Define the constructor for FixedRateStream using FixedRateStreamConfig
function FixedRateStream(config::FixedRateStreamConfig)
    accrual_dates = generate_schedule(config.schedule_config) |> collect
    time_fractions = day_count_fraction(accrual_dates, config.schedule_config.day_count_convention)
    cash_flows = calculate_interest([config.principal], [config.rate], time_fractions, config.rate_convention)

    return FixedRateStream(accrual_dates, accrual_dates, cash_flows)
end

# Define the constructor for FixedRateStream with individual inputs
function FixedRateStream(principal::Float64, rate::Float64, schedule_start::Date, schedule_end::Date, frequency::F, day_count_convention::D, rate_convention::T) where {F, T, D}
    schedule_config = ScheduleConfig(schedule_start, schedule_end, frequency, day_count_convention)
    accrual_dates = generate_schedule(schedule_config) |> collect
    time_fractions = day_count_fraction(accrual_dates, day_count_convention)
    cash_flows = calculate_interest([principal], [rate], time_fractions, rate_convention)

    return FixedRateStream(accrual_dates, accrual_dates, cash_flows)
end

# Example usage
pay_dates = [Date(2023, 1, 1), Date(2023, 2, 1)]
accrual_dates = [Date(2023, 1, 1), Date(2023, 2, 1)]
cash_flows = [100.0, 200.0]

# Example usage with FixedRateStreamConfig
config = FixedRateStreamConfig(
    100000.0,
    0.05,
    ScheduleConfig(Date(2023, 1, 1), Date(2024, 1, 1), Monthly(), ACT360()),
    Linear()
)

@btime FixedRateStreamConfig(
    100000.0,
    0.05,
    ScheduleConfig(Date(2023, 1, 1), Date(2024, 1, 1), Monthly(), ACT360()),
    Linear()
)

# Benchmarking the second method
@btime stream_from_config = FixedRateStream($config)

# Benchmarking the new method with individual inputs
@btime stream_individual = FixedRateStream(100000.0, 0.05, Date(2023, 1, 1), Date(2024, 1, 1), Monthly(), ACT360(), Linear())
