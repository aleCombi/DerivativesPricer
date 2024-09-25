# Test file: test_float_rate_stream.jl
using Test
using DerivativesPricer
using Dates
import DerivativesPricer.day_count_fraction, DerivativesPricer.generate_schedule

# Dummy implementations of RateIndex, ScheduleConfig, and RateType for testing purposes.
struct DummyRateIndex <: RateIndex end
struct DummyRateType <: RateType end
struct DummyScheduleRule <: ScheduleRule end
struct DummyDayCountConvention <: DayCountConvention end
struct DummyScheduleConfig <: AbstractScheduleConfig
    start_date::Date
    end_date::Date
    schedule_rule::DummyScheduleRule
    day_count_convention::DummyDayCountConvention
end

# Dummy generate_schedule and day_count_fraction functions for testing purposes
function generate_schedule(schedule_config::DummyScheduleConfig)
    return Date(schedule_config.start_date):Month(3):Date(schedule_config.end_date)  # Quarterly schedule
end

function day_count_fraction(dates::Vector{Date}, day_count_convention::DummyDayCountConvention)
    return [0.25 for _ in 1:length(dates) - 1]  # Assume quarterly periods with a day count of 0.25
end

# Test case
@testset "FloatRateStream Tests" begin
    # Create a dummy schedule configuration
    start_date = Date(2024, 1, 1)
    end_date = Date(2025, 1, 1)
    schedule_config = DummyScheduleConfig(start_date, end_date, DummyScheduleRule(), DummyDayCountConvention())
    
    # Create a dummy floating rate stream configuration
    principal = 1000.0  # Assume a principal amount
    rate_index = DummyRateIndex()  # Dummy rate index
    rate_convention = DummyRateType()  # Dummy rate convention
    stream_config = FloatRateStreamConfig(principal, rate_index, schedule_config, rate_convention)

    # Create the floating rate stream
    stream = FloatingRateStream(stream_config)

    # Check if the generated accrual dates are correct
    expected_dates = collect(start_date:Month(3):end_date)
    @test stream.accrual_dates == expected_dates
    @test stream.pay_dates == expected_dates
    @test stream.fixing_dates == expected_dates

    # Check if the generated accrual day counts are correct
    expected_day_counts = [0.25 for _ in 1:length(expected_dates) - 1]
    @test stream.accrual_day_counts == expected_day_counts
end
