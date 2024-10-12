@testsnippet FloatRateStream begin
    using Dates
    include("dummy_struct_functions.jl")
end

# Test case
@testitem "FloatRateStream Tests" setup=[FloatRateStream] begin
    using Dates
    # Create a dummy schedule configuration
    start_date = Date(2024, 1, 1)
    end_date = Date(2025, 1, 1)
    schedule_config = DummyScheduleConfig(start_date, end_date, DummyScheduleRule())
    day_count_convention = DummyDayCountConvention()

    # Create a dummy floating rate stream configuration
    principal = 1000.0  # Assume a principal amount
    rate_index = DummyRateIndex()  # Dummy rate index
    rate_convention = DummyRateType()  # Dummy rate convention
    stream_config = FloatRateStreamConfig(principal, rate_index, schedule_config, day_count_convention, rate_convention)

    # Create the floating rate stream
    stream = FloatingRateStream(stream_config)

    # Check if the generated accrual dates are correct
    expected_dates = collect(start_date:Month(6):end_date)
    @test stream.accrual_dates == expected_dates
    @test stream.pay_dates == expected_dates[2:end]
    @test stream.fixing_dates == expected_dates[2:end]

    # Check if the generated accrual day counts are correct
    expected_day_counts = [0.25 for _ in 1:length(expected_dates) - 1]
    @test stream.accrual_day_counts == expected_day_counts
end
