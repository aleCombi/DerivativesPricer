# act360, linear rate, modified following, 1 month
@testitem "Quantlib: 2 Month, Linear, ACT360, ModifiedFollowing, Target calendar" setup=[QuantlibSetup] begin
    ## Getting DerivativesPricer Results
    # schedule configuration
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    schedule_config = ScheduleConfig(Month(1); business_days_convention=ModifiedFollowing(), calendar=BusinessDays.TARGET())
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.0047
    rate_config = SimpleRateConfig(ACT360(), LinearRate())
    instrument_rate = SimpleInstrumentRate(RateIndex("rate_index"), rate_config)

    # fixed rate stream configuration
    principal = 1
    stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

    # fixed rate stream calculations
    float_rate_stream = SimpleFloatRateStream(stream_config)

    ## Getting Quanatlib Results

    ql_start_date = to_ql_date(start_date)
    ql_end_date = to_ql_date(end_date)

    # Define schedule with NullCalendar (treat all days as business)
    schedule = ql.Schedule(ql_start_date, ql_end_date, ql.Period(ql.Monthly),
                            ql.TARGET(), ql.ModifiedFollowing, ql.ModifiedFollowing,
                           ql.DateGeneration.Forward, false)

    ql_fixed_rate_leg = ql.FixedRateLeg(schedule, ql.Actual360(), [principal], [rate])
    ql_fixed_flows = [cash_flow.amount() for cash_flow in ql_fixed_rate_leg]

    @test isapprox(ql_fixed_flows, fixed_rate_stream.cash_flows; atol=1e-15)
end