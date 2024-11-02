# act360, linear rate, modified following, 1 month
@testitem "Quantlib: 2 Month, Linear, ACT360, ModifiedFollowing, Target calendar" setup=[QuantlibSetup] begin
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
    rate_config = SimpleRateConfig(day_count, rate_type, BusinessDayShift(0, calendar, false), AdditiveMargin())
    instrument_rate = SimpleInstrumentRate(RateIndex("rate_index"), rate_config)

    # fixed rate stream configuration
    principal = 1
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

    index = ql.IborIndex("MyIndex", ql.Period(6, ql.Months), 0, ql.USDCurrency(), ql.TARGET(), ql.Following, false, to_ql_day_count(day_count))
    floating_rate_leg = ql.IborLeg([1], schedule, index)
    coupons = [float_rate_stream.schedules[i] for i in 1:length(float_rate_stream.schedules)]
    # ql coupon
    ql_coupon = ql.as_floating_rate_coupon(floating_rate_leg[1])
    ql_coupons = [ql.as_floating_rate_coupon(el) for el in floating_rate_leg]

    # println(ql_coupon.accrualStartDate())
    # println(ql_coupon.accrualEndDate())
    # println(ql_coupon.fixingDate())
    # println(ql_coupon.date())

    # # dp coupon
    # coupon = float_rate_stream.schedules[1]
    # coupon.accrual_start |> println
    # coupon.accrual_end |> println
    # coupon.fixing_date |> println
    # coupon.pay_date |> println
    # Assuming ql_coupons and coupons are the lists of coupons to compare
    for (i, (ql_coupon, coupon)) in enumerate(zip(ql_coupons, coupons))
        @assert coupon.accrual_start == to_julia_date(ql_coupon.accrualStartDate())
        @assert coupon.accrual_end == to_julia_date(ql_coupon.accrualEndDate())
        println(coupon.fixing_date, to_julia_date(ql_coupon.fixingDate()))
        @assert coupon.fixing_date == to_julia_date(ql_coupon.fixingDate())
        @assert coupon.pay_date == to_julia_date(ql_coupon.date())
    end



#     pd.DataFrame([{
#     'fixingDate': cf.fixingDate().ISO(),
#     'accrualStart': cf.accrualStartDate().ISO(),
#     'accrualEnd': cf.accrualEndDate().ISO(),
#     "paymentDate": cf.date().ISO(),
#     'gearing': cf.gearing(),
#     'forward': cf.indexFixing(),
#     'rate': cf.rate(),
#     "amount": cf.amount()
# } for cf in map(ql.as_floating_rate_coupon, swap.leg(1))])
end