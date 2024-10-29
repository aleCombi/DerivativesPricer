@testsnippet IntegrationScheduleGen begin
    using Dates
    using BusinessDays
    calendar_weekends = WeekendsOnly()
    calendar_us = BusinessDays.USGovernmentBond()   
end

# Test 1: Generate schedule with short stub, weekend-only calendar, no roll convention, and modified following business day adjustment
@testitem "Generate Schedule - Short Stub, WeekendsOnly Calendar, No Roll, Modified Following Adjustment" setup=[IntegrationScheduleGen] begin
    start_date = Date(2023, 1, 10)
    end_date = Date(2023, 3, 5)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = ModifiedFollowing()
    termination_bd_convention = ModifiedFollowing()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # ScheduleConfig setup
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_weekends, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    
    # Generate schedule
    schedule = generate_schedule(start_date, end_date, schedule_config)
    
    # Expected dates after adjustment to business days
    expected_dates = [Date(2023, 1, 10), Date(2023, 2, 10), Date(2023, 3, 6)]  # March 5 is Sunday, adjusted to Monday
    
    @test schedule == expected_dates
end

# Test 2: Generate schedule with long stub, US calendar, EOM roll convention, following business day adjustment
@testitem "Generate Schedule - Long Stub, US Calendar, EOM Roll, Following Adjustment" setup=[IntegrationScheduleGen] begin
    start_date = Date(2021, 1, 31)
    end_date = Date(2021, 5, 29)
    period = Month(1)
    roll_convention = EOMRollConvention()
    business_day_convention = FollowingBusinessDay()
    termination_bd_convention = FollowingBusinessDay()
    stub_period = StubPeriod(InArrearsStubPosition(), LongStubLength())
    
    # ScheduleConfig setup
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    
    # Generate schedule
    schedule = generate_schedule(start_date, end_date, schedule_config)
    
    # Expected dates with end-of-month roll and following business day adjustment
    expected_dates = [Date(2021, 2, 1), Date(2021, 3, 1), Date(2021, 3, 31), Date(2021, 6, 1)] # last days of january, february and may are holidays
    
    @test schedule == expected_dates
end

# Test 3: Generate schedule with short upfront stub, WeekendsOnly calendar, no roll, and preceding business day adjustment for termination date
@testitem "Generate Schedule - Short Upfront Stub, WeekendsOnly Calendar, No Roll, Preceding Termination Adjustment" setup=[IntegrationScheduleGen] begin
    start_date = Date(2023, 1, 5)
    end_date = Date(2023, 4, 20)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = PrecedingBusinessDay()
    termination_bd_convention = PrecedingBusinessDay()
    stub_period = StubPeriod(UpfrontStubPosition(), ShortStubLength())
    
    # ScheduleConfig setup
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_weekends, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    
    # Generate schedule
    schedule = generate_schedule(start_date, end_date, schedule_config)
    
    # Expected dates with preceding adjustment for termination date
    expected_dates = [Date(2023, 1, 5), Date(2023, 1, 20), Date(2023, 2, 20), Date(2023, 3, 20), Date(2023, 4, 20)]
    
    @test schedule == expected_dates
end

# Test 4: Generate schedule with long upfront stub, US calendar, EOM roll, modified following business day adjustment for both
@testitem "Generate Schedule - Long Upfront Stub, US Calendar, EOM Roll, Modified Following Adjustment" setup=[IntegrationScheduleGen] begin
    start_date = Date(2023, 1, 15)
    end_date = Date(2023, 7, 31)
    period = Month(2)
    roll_convention = EOMRollConvention()
    business_day_convention = ModifiedFollowing()
    termination_bd_convention = ModifiedFollowing()
    stub_period = StubPeriod(UpfrontStubPosition(), LongStubLength())
    
    # ScheduleConfig setup
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    
    # Generate schedule
    schedule = generate_schedule(start_date, end_date, schedule_config)
    
    # Expected dates with EOM roll and modified following adjustment
    expected_dates = [Date(2023, 1, 31), Date(2023, 3, 31), Date(2023, 5, 31), Date(2023, 7, 31)]
    
    @test schedule == expected_dates
end

# Test 5: Generate schedule with short stub, US calendar, no roll, and no business day adjustments
@testitem "Generate Schedule - Short Stub, US Calendar, No Roll, No Adjustments" setup=[IntegrationScheduleGen] begin
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 3, 15)
    period = Month(1)
    roll_convention = NoRollConvention()
    business_day_convention = NoneBusinessDayConvention()
    termination_bd_convention = NoneBusinessDayConvention()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # ScheduleConfig setup
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_day_convention,
                                     calendar=calendar_us, stub_period=stub_period, termination_bd_convention=termination_bd_convention)
    
    # Generate schedule
    schedule = generate_schedule(start_date, end_date, schedule_config)
    
    # Expected dates without any business day adjustments
    expected_dates = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 3, 15)]
    
    @test schedule == expected_dates
end
