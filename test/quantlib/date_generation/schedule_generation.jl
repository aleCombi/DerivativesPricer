@testsnippet QuantlibSetup begin
    using Dates
    using BusinessDays
    using PyCall
    ql = pyimport("QuantLib")

    function julia_date_to_ql(date::Date)
        return ql.Date(day(date), month(date), year(date))
    end

    # Helper function to generate QuantLib schedule for comparison
    function generate_quantlib_schedule(
        start_date::Date, 
        end_date::Date, 
        period::Period, 
        calendar, 
        roll_convention, 
        business_day_convention, 
        termination_bd_convention, 
        stub_position;
        first_date=nothing,
        next_to_last_date=nothing)

        # Convert Julia Dates to QuantLib Dates
        ql_start = ql.Date(day(start_date), month(start_date), year(start_date))
        ql_end = ql.Date(day(end_date), month(end_date), year(end_date))
        
        ql_first_date = ql.Date()
        if !isnothing(first_date)
            ql_first_date = julia_date_to_ql(first_date) 
        end

        ql_next_to_last_date = ql.Date()
        if !isnothing(next_to_last_date)
            ql_next_to_last_date = julia_date_to_ql(next_to_last_date) 
        end

        # Set up QuantLib period
        ql_period = ql.Period(period.value, ql.Months)  # Assuming period is of type Month for this function

        # Set up QuantLib calendar
        ql_calendar = if calendar === calendar_weekends
            ql.WeekendsOnly()
        else
            ql.UnitedStates(ql.UnitedStates.GovernmentBond)
        end

        # Set up QuantLib roll convention
        end_of_month = roll_convention isa EOMRollConvention

        # Set up QuantLib business day conventions
        ql_business_day_convention = if business_day_convention isa FollowingBusinessDay
            ql.Following
        elseif business_day_convention isa PrecedingBusinessDay
            ql.Preceding
        elseif business_day_convention isa ModifiedFollowing
            ql.ModifiedFollowing
        elseif business_day_convention isa ModifiedPreceding
            ql.ModifiedPreceding
        elseif business_day_convention isa NoneBusinessDayConvention
            ql.None
        else
            error("Unsupported business day convention")
        end

        ql_termination_bd_convention = if termination_bd_convention isa FollowingBusinessDay
            ql.Following
        elseif termination_bd_convention isa PrecedingBusinessDay
            ql.Preceding
        elseif termination_bd_convention isa ModifiedFollowing
            ql.ModifiedFollowing
        elseif termination_bd_convention isa ModifiedPreceding
            ql.ModifiedPreceding
        elseif termination_bd_convention isa NoneBusinessDayConvention
            ql.Unadjusted
        else
            error("Unsupported termination business day convention")
        end

        # Stub positioning
        ql_stub = if stub_position isa InArrearsStubPosition
            ql.DateGeneration.Forward
        elseif stub_position isa UpfrontStubPosition
            ql.DateGeneration.Backward
        else
            error("Unsupported stub position")
        end

        # Generate the QuantLib schedule
        ql_schedule = ql.Schedule(
            ql_start, 
            ql_end, 
            ql_period, 
            ql_calendar, 
            ql_business_day_convention, 
            ql_termination_bd_convention, 
            ql_stub,
            end_of_month,
            ql_first_date,
            ql_next_to_last_date
        )
        
        # Convert QuantLib Dates back to Julia Dates
        return [Date(dt.year(), dt.month(), dt.dayOfMonth()) for dt in ql_schedule]
    end
    calendar_weekends = WeekendsOnly()
    calendar_us = BusinessDays.USGovernmentBond()
end

# Test Case 1: Short Stub with WeekendsOnly Calendar, No Roll, and Modified Following Adjustment
@testitem "QuantLib Comparison - Short Stub, WeekendsOnly Calendar, No Roll, Modified Following Adjustment" setup=[QuantlibSetup] begin
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
@testitem "QuantLib Comparison - Short Stub, Modified Following, Modified Preceding Termination Adjustment" setup=[QuantlibSetup] begin
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
@testitem "QuantLib Comparison - Long Stub, Modified Preceding, Following Termination Adjustment" setup=[QuantlibSetup] begin
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
@testitem "QuantLib Comparison - Short Upfront Stub, Preceding, Modified Following Termination Adjustment" setup=[QuantlibSetup] begin
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
@testitem "QuantLib Comparison - Long Upfront Stub, Following, Modified Preceding Termination Adjustment" setup=[QuantlibSetup] begin
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
@testitem "QuantLib Comparison - Short Stub, Modified Following, No Termination Adjustment" setup=[QuantlibSetup] begin
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
