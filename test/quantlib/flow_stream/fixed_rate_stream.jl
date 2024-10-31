@testsnippet QuantlibDateConversion begin
    using PyCall
    ql = pyimport("QuantLib")

    function ql_to_julia_date(ql_date)
        # Extract year, month, and day from the QuantLib.Date object
        year = Int(ql_date.year())
        month = Int(ql_date.month())
        day = Int(ql_date.dayOfMonth())
        
        # Construct and return the Julia Date
        return Date(year, month, day)
    end

    function julia_to_ql_date(julia_date)
        return ql.Date(day(julia_date), month(julia_date), year(julia_date))
    end
end
# act360, linear rate, modified following, 1 month
@testitem "Quantlib: 2 Month, Linear, ACT360, ModifiedFollowing, Target calendar" setup=[QuantlibDateConversion] begin
    using Dates
    using BusinessDays
    ## Getting DerivativesPricer Results
    # schedule configuration
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    schedule_config = ScheduleConfig(Month(1); business_days_convention=ModifiedFollowing(), calendar=BusinessDays.TARGET())
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.0047
    rate_config = FixedRateConfig(ACT360(), LinearRate())
    instrument_rate = FixedRate(rate, rate_config)

    # fixed rate stream configuration
    principal = 1
    stream_config = FixedStreamConfig(principal, instrument_rate, instrument_schedule)

    # fixed rate stream calculations
    fixed_rate_stream = FixedRateStream(stream_config)

    ## Getting Quanatlib Results

    ql_start_date = julia_to_ql_date(start_date)
    ql_end_date = julia_to_ql_date(end_date)

    # Define schedule with NullCalendar (treat all days as business)
    schedule = ql.Schedule(ql_start_date, ql_end_date, ql.Period(ql.Monthly),
                            ql.TARGET(), ql.ModifiedFollowing, ql.ModifiedFollowing,
                           ql.DateGeneration.Forward, false)

    ql_fixed_rate_leg = ql.FixedRateLeg(schedule, ql.Actual360(), [principal], [rate])
    ql_fixed_flows = [cash_flow.amount() for cash_flow in ql_fixed_rate_leg]

    @test isapprox(ql_fixed_flows, fixed_rate_stream.cash_flows; atol=1e-15)
end

@testitem "Quantlib: 2 Month, Linear, ACT360, ModifiedFollowing, Target calendar" setup=[QuantlibDateConversion] begin
    using Dates
    using BusinessDays
    ## Getting DerivativesPricer Results
    # schedule configuration
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    schedule_config = ScheduleConfig(Month(1); business_days_convention=ModifiedFollowing(), calendar=BusinessDays.TARGET())
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.0047
    rate_config = FixedRateConfig(ACT360(), LinearRate())
    instrument_rate = FixedRate(rate, rate_config)

    # fixed rate stream configuration
    principal = 1
    stream_config = FixedStreamConfig(principal, instrument_rate, instrument_schedule)

    # fixed rate stream calculations
    fixed_rate_stream = FixedRateStream(stream_config)

    ## Getting Quanatlib Results

    ql_start_date = julia_to_ql_date(start_date)
    ql_end_date = julia_to_ql_date(end_date)

    # Define schedule with NullCalendar (treat all days as business)
    schedule = ql.Schedule(ql_start_date, ql_end_date, ql.Period(ql.Monthly),
                            ql.TARGET(), ql.ModifiedFollowing, ql.ModifiedFollowing,
                           ql.DateGeneration.Forward, false)

    ql_fixed_rate_leg = ql.FixedRateLeg(schedule, ql.Actual360(), [principal], [rate])
    ql_fixed_flows = [cash_flow.amount() for cash_flow in ql_fixed_rate_leg]

    @test isapprox(ql_fixed_flows, fixed_rate_stream.cash_flows; atol=1e-15)
end
# act365, cmp rate, modified preceding, 3 months, 2 days pay delay
# 30360, exp rate, following, 1 year, 3 bd pay delay, target calendar