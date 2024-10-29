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

# test date_corrector

# test termination_date_corrector

# test generate_end_date

# test generate_schedule 