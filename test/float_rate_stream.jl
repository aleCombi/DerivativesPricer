# Test case
@testitem "FloatRateStream Tests" begin
    include("float_rate_stream_setup.jl")
    # Create a dummy schedule configuration
    start_date = Date(2024, 1, 1)
    end_date = Date(2025, 1, 1)
    schedule_config = DummyScheduleConfig()
    day_count_convention = DummyDayCountConvention()

    # Create a dummy floating rate stream configuration
    principal = 1000.0  # Assume a principal amount
    rate_index = DummyRateIndex()  # Dummy rate index
    rate_convention = DummyRateType()  # Dummy rate convention
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)
    rate_config = SimpleRateConfig(day_count_convention, rate_convention, NoShift(), AdditiveMargin(0))
    instrument_rate = FloatRate(rate_index, rate_config)
    stream_config = FlowStreamConfig(principal, instrument_rate, instrument_schedule)

    # Create the floating rate stream
    stream = FloatingRateStream(stream_config)

    # Check if the generated accrual dates are correct
    expected_dates = collect(start_date:Month(6):end_date)
    @test stream.schedules.accrual_dates == expected_dates
    @test stream.schedules.pay_dates == expected_dates[2:end]
    @test stream.schedules.fixing_dates == expected_dates[2:end]

    # Check if the generated accrual day counts are correct
    expected_day_counts = [0.25 for _ in 1:length(expected_dates) - 1]
    @test stream.schedules.accrual_day_counts == expected_day_counts
end
