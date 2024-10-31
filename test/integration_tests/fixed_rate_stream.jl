# Test with TARGET calendar, 30360 day count convention, and ModifiedFollowing business days adjustment.
@testitem "Fixed rate stream test" begin
    using BusinessDays
    using Dates

    # schedule configuration
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    schedule_config = ScheduleConfig(Year(1); business_days_convention=ModifiedFollowing(), calendar=BusinessDays.TARGET())
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.00184
    rate_config = FixedRateConfig(Thirty360(), LinearRate())
    instrument_rate = FixedRate(rate, rate_config)

    # fixed rate stream configuration
    principal = 41800000.0
    stream_config = FixedStreamConfig(principal, instrument_rate, instrument_schedule)

    # fixed rate stream calculations
    fixed_rate_stream = FixedRateStream(stream_config)

    # Expected accrual dates obtained from QuantLib
    expected_accrual_date_strings = [
    "27 Jun 2019",
    "29 Jun 2020",
    "28 Jun 2021",
    "27 Jun 2022",
    "27 Jun 2023",
    "27 Jun 2024",
    "27 Jun 2025",
    "29 Jun 2026",
    "28 Jun 2027",
    "27 Jun 2028",
    "27 Jun 2029"]

    # Convert the strings into Date objects
    expected_accrual_schedule = [Date(date_str, "d u y") for date_str in expected_accrual_date_strings]

    expected_cash_flows = [77339.29, 76698.36, 76698.36, 76912, 76912, 76912, 77339.29, 76698.36, 76698.36, 76912]

    @test fixed_rate_stream.accrual_dates == expected_accrual_schedule
    @test fixed_rate_stream.cash_flows ≈ expected_cash_flows atol=1e-2
end