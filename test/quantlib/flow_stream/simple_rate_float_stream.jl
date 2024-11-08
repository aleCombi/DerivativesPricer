# act360, linear rate, modified following, 1 month
@testitem "Quantlib: 6 Month, Linear, ACT360, ModifiedFollowing, Target calendar (for accrual), WeekendsOnly calendar (for fixing), 10 business days fixing shifter from start" begin
    using Dates
    using BusinessDays
    using PyCall
    ql = pyimport("QuantLib")

    to_julia_date(ql_date) = Date(Int(ql_date.year()), Int(ql_date.month()), Int(ql_date.dayOfMonth()))
    to_ql_date(julia_date) = ql.Date(day(julia_date), month(julia_date), year(julia_date))

    to_ql_business_day_convention(::FollowingBusinessDay) = ql.Following
    to_ql_business_day_convention(::PrecedingBusinessDay) = ql.Preceding
    to_ql_business_day_convention(::ModifiedPreceding) = ql.ModifiedPreceding
    to_ql_business_day_convention(::NoneBusinessDayConvention) = ql.Unadjusted
    to_ql_business_day_convention(::ModifiedFollowing) = ql.ModifiedFollowing

    to_ql_date_generation(::InArrearsStubPosition) = ql.DateGeneration.Forward
    to_ql_date_generation(::UpfrontStubPosition) = ql.DateGeneration.Backward

    to_ql_calendar(::WeekendsOnly) = ql.WeekendsOnly()
    to_ql_calendar(::BusinessDays.USGovernmentBond) = ql.UnitedStates(ql.UnitedStates.GovernmentBond)
    to_ql_calendar(::BusinessDays.TARGET) = ql.TARGET()
    to_ql_day_count(::ACT360) = ql.Actual360()
    to_ql_day_count(::ACT365) = ql.Actual365Fixed()
    # Helper function to generate QuantLib schedule for comparison
    function get_quantlib_schedule(
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

        # Setting first date and penultimate date, this is how quantlib does long stubs
        ql_first_date = isnothing(first_date) ? ql.Date() : to_ql_date(first_date)
        ql_next_to_last_date = isnothing(next_to_last_date) ? ql.Date() : to_ql_date(next_to_last_date)

        # settings ql schedule arguments
        ql_start = to_ql_date(start_date)
        ql_end = to_ql_date(end_date)
        ql_period = ql.Period(period.value, ql.Months)  # Assuming period is of type Month for this function
        ql_calendar = to_ql_calendar(calendar)
        end_of_month = roll_convention isa EOMRollConvention
        ql_business_day_convention = to_ql_business_day_convention(business_day_convention)
        ql_termination_bd_convention = to_ql_business_day_convention(termination_bd_convention)
        ql_date_generation_direction = to_ql_date_generation(stub_position)

        # Generate the QuantLib schedule
        ql_schedule = ql.Schedule(
            ql_start,
            ql_end,
            ql_period,
            ql_calendar,
            ql_business_day_convention,
            ql_termination_bd_convention,
            ql_date_generation_direction,
            end_of_month,
            ql_first_date,
            ql_next_to_last_date
        )

        return ql_schedule
    end

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
        ql_schedule = get_quantlib_schedule(start_date, end_date, period, calendar, roll_convention, business_day_convention, termination_bd_convention, stub_position; first_date=first_date, next_to_last_date=next_to_last_date)
        return [to_julia_date(dt) for dt in ql_schedule]
    end
    ## Getting DerivativesPricer Results
    # schedule configuration
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    business_day_convention=ModifiedFollowing()
    period = Month(1)
    calendar=BusinessDays.TARGET()
    schedule_config = ScheduleConfig(period; business_days_convention=business_day_convention, calendar=calendar)
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.0047
    day_count = ACT360()
    rate_type = LinearRate()
    fixing_days_delay = 2
    rate_config = SimpleRateConfig(day_count, rate_type, BusinessDayShift(-fixing_days_delay, WeekendsOnly(), false), AdditiveMargin())
    instrument_rate = SimpleInstrumentRate(RateIndex("rate_index"), rate_config)

    # fixed rate stream configuration
    principal = 1.0
    stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

    # float rate stream calculations
    float_rate_stream = SimpleFloatRateStream(stream_config)

    ## Getting Quanatlib Results
    ql_start_date = to_ql_date(start_date)
    ql_end_date = to_ql_date(end_date)

    # Define schedule
    schedule = get_quantlib_schedule(start_date, end_date, period, calendar, NoRollConvention(), business_day_convention, business_day_convention, schedule_config.stub_period.position)
    
    yts = ql.YieldTermStructureHandle(ql.FlatForward(2, ql.TARGET(), 0.05, to_ql_day_count(day_count)))
    engine = ql.DiscountingSwapEngine(yts)

    index = ql.IborIndex("MyIndex", ql.Period(6, ql.Months), fixing_days_delay, ql.USDCurrency(), ql.WeekendsOnly(), ql.Following, false, to_ql_day_count(day_count))
    floating_rate_leg = ql.IborLeg([principal], schedule, index)
    coupons = [float_rate_stream.schedules[i] for i in 1:length(float_rate_stream.schedules)]
    # ql coupon
    ql_coupon = ql.as_floating_rate_coupon(floating_rate_leg[1])
    ql_coupons = [ql.as_floating_rate_coupon(el) for el in floating_rate_leg]

    # compare schedules per coupon
    for (i, (ql_coupon, coupon)) in enumerate(zip(ql_coupons, coupons))
        # println("Quantlib accrual start date: ", to_julia_date(ql_coupon.accrualStartDate()))
        # println("DP accrual start date: ", coupon.accrual_start)
        @assert coupon.accrual_start == to_julia_date(ql_coupon.accrualStartDate())
        @assert coupon.accrual_end == to_julia_date(ql_coupon.accrualEndDate())
        # println("DP fixing date: ",coupon.fixing_date)
        # println("Quantlib fixing date: ", to_julia_date(ql_coupon.fixingDate()))
        @assert coupon.fixing_date == to_julia_date(ql_coupon.fixingDate())
        @assert coupon.pay_date == to_julia_date(ql_coupon.date())
    end
end