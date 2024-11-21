# Test 1: Test generate_unadjusted_dates with a period of 1 month and InArrearsStubPosition with ShortStubLength
@testitem "Generate Unadjusted Dates - InArrears Short Stub, 1 Month Period" begin
    using Dates
    start_date = Date(2023, 1, 10)
    end_date = Date(2023, 3, 5)
    period = Month(1)
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # Generate unadjusted dates
    unadjusted_dates = generate_unadjusted_dates(start_date, end_date, stub_period, period)
    
    # Expected behavior: periods up to end_date, with a short stub at the end
    expected_dates = [Date(2023, 1, 10), Date(2023, 2, 10), Date(2023, 3, 5)]
    
    @test unadjusted_dates == expected_dates
end

# Test 2: Test generate_unadjusted_dates with a period of 2 weeks and InArrearsStubPosition with LongStubLength
@testitem "Generate Unadjusted Dates - InArrears Long Stub, 2 Weeks Period" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 2, 10)
    period = Week(2)
    stub_period = StubPeriod(InArrearsStubPosition(), LongStubLength())
    
    # Generate unadjusted dates
    unadjusted_dates = generate_unadjusted_dates(start_date, end_date, stub_period, period)
    
    # Expected behavior: periods up to end_date, with a long stub at the end
    expected_dates = [Date(2023, 1, 1), Date(2023, 1, 15), Date(2023, 2, 10)]
    
    @test unadjusted_dates == expected_dates
end

# Test 3: Test generate_unadjusted_dates with a period of 3 months and UpfrontStubPosition with ShortStubLength
@testitem "Generate Unadjusted Dates - Upfront Short Stub, 3 Months Period" begin
    using Dates
    start_date = Date(2023, 1, 15)
    end_date = Date(2023, 7, 1)
    period = Month(3)
    stub_period = StubPeriod(UpfrontStubPosition(), ShortStubLength())
    
    # Generate unadjusted dates
    unadjusted_dates = generate_unadjusted_dates(start_date, end_date, stub_period, period)
    
    # Expected behavior: upfront short stub period to start_date, then regular intervals
    expected_dates = [Date(2023, 1, 15), Date(2023, 4, 1), Date(2023, 7, 1)]
    
    @test unadjusted_dates == expected_dates
end

# Test 4: Test generate_unadjusted_dates with a period of 1 week and UpfrontStubPosition with LongStubLength
@testitem "Generate Unadjusted Dates - Upfront Long Stub, 1 Week Period" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 1, 25)
    period = Week(1)
    stub_period = StubPeriod(UpfrontStubPosition(), LongStubLength())
    
    # Generate unadjusted dates
    unadjusted_dates = generate_unadjusted_dates(start_date, end_date, stub_period, period)
    
    # Expected behavior: long upfront stub, followed by regular weekly intervals
    expected_dates = [Date(2023, 1, 1), Date(2023, 1, 11), Date(2023, 1, 18), Date(2023, 1, 25)]
    
    @test unadjusted_dates == expected_dates
end

# Test 5: Test generate_unadjusted_dates with a period of 10 days and InArrearsStubPosition with ShortStubLength
@testitem "Generate Unadjusted Dates - InArrears Short Stub, 10 Days Period" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 1, 29)
    period = Day(10)
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # Generate unadjusted dates
    unadjusted_dates = generate_unadjusted_dates(start_date, end_date, stub_period, period)
    
    # Expected behavior: regular intervals up to end_date, with a short stub at the end
    expected_dates = [Date(2023, 1, 1), Date(2023, 1, 11), Date(2023, 1, 21), Date(2023, 1, 29)]
    
    @test unadjusted_dates == expected_dates
end

@testsnippet ScheduleGeneration begin
    using Dates
    using BusinessDays
    calendar = WeekendsOnly()
end

# Test 6: Test ScheduleConfig creation
@testitem "ScheduleConfig Creation Tests" setup=[ScheduleGeneration] begin
    start_date = Date(2023, 1, 10)
    end_date = Date(2024, 1, 10)
    period = Month(1)
    roll_convention = EOMRollConvention()
    business_days_convention = ModifiedFollowing()
    calendar = WeekendsOnly()
    stub_period = StubPeriod(InArrearsStubPosition(), ShortStubLength())
    
    # Create a ScheduleConfig
    schedule_config = ScheduleConfig(period; roll_convention=roll_convention, business_days_convention=business_days_convention, calendar=calendar, stub_period=stub_period)
    
    # Assert that the schedule config was created correctly
    @test schedule_config.period == period
    @test schedule_config.roll_convention == roll_convention
    @test schedule_config.business_days_convention == business_days_convention
    @test schedule_config.calendar == calendar
end

# Test 7: Test date correction logic
@testitem "Date Correction Tests, ModifiedFollowing" setup=[ScheduleGeneration] begin
    start_date = Date(2023, 1, 1)
    stub_period = StubPeriod(UpfrontStubPosition(), ShortStubLength())
    schedule_config = ScheduleConfig(Month(1), business_days_convention=ModifiedFollowing(), calendar=WeekendsOnly(), stub_period=stub_period)
    
    date_correction_fn = date_corrector(schedule_config)
    
    # Test that date correction moves weekend dates to the next business day
    @test date_correction_fn(Date(2023, 1, 7)) == Date(2023, 1, 9)  # Assuming weekend moves to Monday
end

# Test 2: Test generation of end dates from start dates
@testitem "Date Correction Tests, " setup=[ScheduleGeneration] begin
    start_dates = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1)] 
    end_dates = generate_end_date(start_dates, Month(1), WeekendsOnly(), ModifiedFollowing())
    
    # Test that date correction moves weekend dates to the next business day
    @test end_dates == [Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 4, 3)]  # First of april is a saturday
end