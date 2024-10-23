@testsnippet ScheduleGeneration begin
    using Dates
    using BusinessDays
    calendar = WeekendsOnly()
end

# Test 1: Test ScheduleConfig creation
@testitem "ScheduleConfig Creation Tests" setup=[ScheduleGeneration] begin
    start_date = Date(2023, 1, 10)
    end_date = Date(2024, 1, 10)
    period = Month(1)
    roll_convention = EOMRollConvention()
    business_days_convention = ModifiedFollowing()
    calendar = WeekendsOnly()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # Create a ScheduleConfig
    schedule_config = ScheduleConfig(period, roll_convention, business_days_convention, calendar, stub_period)
    
    # Assert that the schedule config was created correctly
    @test schedule_config.period == period
    @test schedule_config.roll_convention == roll_convention
    @test schedule_config.business_days_convention == business_days_convention
    @test schedule_config.calendar == calendar
end

# Test 2: Test date correction logic
@testitem "Date Correction Tests" setup=[ScheduleGeneration] begin
    start_date = Date(2023, 1, 1)
    schedule_config = ScheduleConfig(Month(1), NoRollConvention(), ModifiedFollowing(), WeekendsOnly(), StubPeriod(UpfrontStubPosition(), ShortStubLength()))
    
    date_correction_fn = date_corrector(schedule_config)
    
    # Test that date correction moves weekend dates to the next business day
    @test date_correction_fn(Date(2023, 1, 7)) == Date(2023, 1, 9)  # Assuming weekend moves to Monday
end

# Test 2: Test generation of end dates from start dates
@testitem "Date Correction Tests" setup=[ScheduleGeneration] begin
    start_dates = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1)] 
    schedule_config = ScheduleConfig(Month(1), NoRollConvention(), ModifiedFollowing(), WeekendsOnly(), StubPeriod(UpfrontStubPosition(), ShortStubLength()))
    
    end_dates = generate_end_date(start_dates, schedule_config)
    
    # Test that date correction moves weekend dates to the next business day
    @test end_dates == [Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 4, 3)]  # First of april is a saturday
end
