# Test Case 1: Short Stub with WeekendsOnly Calendar, No Roll, and Modified Following Adjustment
@testitem "QuantLib Comparison - Short Stub, WeekendsOnly Calendar, No Roll, Modified Following Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2023, 1, 10)
    end_date = Date(2023, 3, 5)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = ModifiedFollowing()
    termination_bd_convention = ModifiedFollowing()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())

    # Generate our schedule
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_weekends, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    # Generate QuantLib schedule
    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_weekends, roll_convention, 
                                                   business_day_convention, termination_bd_convention, InArrearsStubPosition())

    @test julia_schedule == quantlib_schedule
end

# Test 1: Short stub, WeekendsOnly calendar, Modified Following convention, No Roll, Modified Preceding termination adjustment
@testitem "QuantLib Comparison - Short Stub, Modified Following, Modified Preceding Termination Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2023, 1, 15)
    end_date = Date(2023, 4, 5)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = ModifiedFollowing()
    termination_bd_convention = ModifiedPreceding()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())

    schedule_config = ScheduleConfig(period; roll_convention=NoRollConvention(), business_days_convention=business_day_convention,
                                     calendar=calendar_weekends, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_weekends, roll_convention, business_day_convention, 
                                                   termination_bd_convention, InArrearsStubPosition())

    @test julia_schedule == quantlib_schedule
end

# Test 2: Long stub, US calendar, Modified Preceding convention, No Roll, Following termination adjustment
@testitem "QuantLib Comparison - Long Stub, Modified Preceding, Following Termination Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2021, 2, 10)
    end_date = Date(2021, 6, 25)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = ModifiedPreceding()
    termination_bd_convention = FollowingBusinessDay()
    stub_period = StubPeriod(InArrearsStubPosition(), LongStubLength())

    schedule_config = ScheduleConfig(period; roll_convention=NoRollConvention(), business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_us, roll_convention, business_day_convention, 
                                                   termination_bd_convention, InArrearsStubPosition(), next_to_last_date=Date(2021,5,10))
               
    #note that quantlib handles long stub by explicitely passing the second or penultimate date (look https://implementingquantlib.substack.com/p/schedules-in-quantlib)
    @test julia_schedule == quantlib_schedule
end

# Test 3: Short upfront stub, WeekendsOnly calendar, Preceding convention, Modified Following termination adjustment
@testitem "QuantLib Comparison - Short Upfront Stub, Preceding, Modified Following Termination Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2023, 1, 3)
    end_date = Date(2023, 5, 10)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = PrecedingBusinessDay()
    termination_bd_convention = ModifiedFollowing()
    stub_period = StubPeriod(UpfrontStubPosition(), ShortStubLength())

    schedule_config = ScheduleConfig(period; roll_convention=NoRollConvention(), business_days_convention=business_day_convention,
                                     calendar=calendar_weekends, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_weekends, roll_convention, business_day_convention, 
                                                   termination_bd_convention, UpfrontStubPosition())

    @test julia_schedule == quantlib_schedule
end

# Test 4: Long upfront stub, US calendar, Following convention, Modified Preceding termination adjustment
@testitem "QuantLib Comparison - Long Upfront Stub, Following, Modified Preceding Termination Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2022, 3, 15)
    end_date = Date(2022, 9, 1)
    period = Month(2)
    roll_convention = NoRollConvention()
    business_day_convention = FollowingBusinessDay()
    termination_bd_convention = ModifiedPreceding()
    stub_period = StubPeriod(UpfrontStubPosition(), LongStubLength())

    schedule_config = ScheduleConfig(period; roll_convention=NoRollConvention(), business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_us, roll_convention, business_day_convention, 
                                                   termination_bd_convention, UpfrontStubPosition(), first_date=Date(2022,7,1))
    
    #note that quantlib handles long stub by explicitely passing the second or penultimate date (look https://implementingquantlib.substack.com/p/schedules-in-quantlib)

    @test julia_schedule == quantlib_schedule
end

# Test 5: Short stub, US calendar, Modified Following convention, None termination adjustment
@testitem "QuantLib Comparison - Short Stub, Modified Following, No Termination Adjustment" begin
    include("quantlib_conversion_setup.jl")
    start_date = Date(2021, 1, 1)
    end_date = Date(2021, 3, 15)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = ModifiedFollowing()
    termination_bd_convention = NoneBusinessDayConvention()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())

    schedule_config = ScheduleConfig(period; roll_convention=NoRollConvention(), business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    julia_schedule = generate_schedule(start_date, end_date, schedule_config)

    quantlib_schedule = generate_quantlib_schedule(start_date, end_date, period, calendar_us, roll_convention, business_day_convention, 
                                                   termination_bd_convention, InArrearsStubPosition())

    @test julia_schedule == quantlib_schedule
end
