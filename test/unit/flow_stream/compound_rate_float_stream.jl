@testitem "Library Compound Schedules" begin
    using Dates
    using BusinessDays
    using Test

    # Set up schedule and rate configurations
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    business_day_convention = ModifiedFollowing()
    period = Month(3)
    sub_period = Month(1)
    calendar = BusinessDays.TARGET()
    schedule_config = ScheduleConfig(period; business_days_convention=business_day_convention, calendar=calendar)
    pay_calendar = BusinessDays.USNYSE()
    pay_shift = BusinessDayShift(1, pay_calendar, true)
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config, pay_shift)

    # Rate configuration
    day_count = ACT360()
    rate_type = LinearRate()
    compound_schedule = ScheduleConfig(sub_period; stub_period=StubPeriod(UpfrontStubPosition(), ShortStubLength()))
    fixing_calendar = WeekendsOnly()
    rate_config = CompoundRateConfig(
        ACT360(), 
        LinearRate(), 
        BusinessDayShift(-2, fixing_calendar, false), 
        compound_schedule, 
        MarginOnUnderlying(AdditiveMargin(0))
    )
    instrument_rate = CompoundInstrumentRate(RateIndex("compounded_rate_index"), rate_config)

    # Fixed rate stream configuration
    principal = 1.0
    stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

    # Perform library calculations
    float_rate_stream = CompoundFloatRateStream(stream_config)
    compounding_schedules = [x for x in float_rate_stream.schedules.compounding_schedules]
    coupons = [coupon for schedule in compounding_schedules for coupon in schedule]

    # Assertions for schedule consistency and compounding
    # Test that each schedule starts and ends correctly
    for schedule in compounding_schedules
        @test schedule.accrual_dates[1] >= start_date
        @test schedule.accrual_dates[end] <= end_date
    end

    # Test for correct compounding periods and expected number of schedules
    expected_periods = Int(floor(Int, (Dates.year(end_date) - Dates.year(start_date)) * 12 / period.value))
    @test length(compounding_schedules) == expected_periods

    # Date checks for each coupon in each schedule
    for schedule in compounding_schedules
        for coupon in schedule
            # Check accrual start and end dates are within the overall instrument period
            @test coupon.accrual_start >= start_date
            @test coupon.accrual_end <= end_date
            @test coupon.accrual_end > coupon.accrual_start

            # Generate and check fixing date
            bds = BusinessDayShift(-2, fixing_calendar, false)# Apply 2-bday lag
            expected_fixing_date = shifted_schedule(coupon.accrual_start, bds)

            @test coupon.fixing_date == expected_fixing_date  # Ensure generated fixing date matches actual
            @test coupon.fixing_date < coupon.pay_date

            # Ensure payment date is after accrual end date and adjusted for business day convention
            expected_payment_date = shifted_schedule(coupon.accrual_end, pay_shift)
            @test coupon.pay_date == expected_payment_date
            @test coupon.pay_date > coupon.accrual_end
        end
    end
end
