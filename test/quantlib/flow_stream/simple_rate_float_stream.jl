# act360, linear rate, modified following, 1 month
@testitem "Quantlib: 6 Month, Linear, ACT360, ModifiedFollowing, Target calendar (for accrual), WeekendsOnly calendar (for fixing), 10 business days fixing shifter from start" setup=[QuantlibSetup] begin
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
    rate_config = SimpleRateConfig(day_count, rate_type, BusinessDayShift(-10, WeekendsOnly(), false), AdditiveMargin())
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

    index = ql.IborIndex("MyIndex", ql.Period(6, ql.Months), 10, ql.USDCurrency(), ql.WeekendsOnly(), ql.Following, false, to_ql_day_count(day_count))
    floating_rate_leg = ql.IborLeg([principal], schedule, index)
    coupons = [float_rate_stream.schedules[i] for i in 1:length(float_rate_stream.schedules)]
    # ql coupon
    ql_coupon = ql.as_floating_rate_coupon(floating_rate_leg[1])
    ql_coupons = [ql.as_floating_rate_coupon(el) for el in floating_rate_leg]

    # compare schedules per coupon
    for (i, (ql_coupon, coupon)) in enumerate(zip(ql_coupons, coupons))
        @assert coupon.accrual_start == to_julia_date(ql_coupon.accrualStartDate())
        @assert coupon.accrual_end == to_julia_date(ql_coupon.accrualEndDate())
        println(coupon.fixing_date)
        println(to_julia_date(ql_coupon.fixingDate()))
        @assert coupon.fixing_date == to_julia_date(ql_coupon.fixingDate())
        @assert coupon.pay_date == to_julia_date(ql_coupon.date())
    end
end