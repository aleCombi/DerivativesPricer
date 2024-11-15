# for the quantlib implementation, cf. https://www.implementingquantlib.com/2024/09/sub-periods-coupons.html 
# unfortunately, this looks quite newly implemented in ql, hence it should be taken with caution and tested otherwise
# act360, linear rate, modified following, 1 month
@testitem "Quantlib: compound schedules" setup=[QuantlibSetup] begin
    ## Getting Quanatlib Results
    start_date = Date(2019, 6, 27)
    end_date = Date(2029, 6, 27)
    business_day_convention=ModifiedFollowing()
    period = Month(3)
    sub_period = Month(1)
    calendar=BusinessDays.TARGET()
    schedule_config = ScheduleConfig(period; business_days_convention=business_day_convention, calendar=calendar)
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # rate configuration
    rate = 0.0047
    day_count = ACT360()
    rate_type = LinearRate()
    compound_schedule = ScheduleConfig(sub_period; stub_period=StubPeriod(UpfrontStubPosition(), ShortStubLength()))
    rate_config = CompoundRateConfig(ACT360(), LinearRate(), BusinessDayShift(-2, WeekendsOnly(),false), compound_schedule, MarginOnUnderlying(AdditiveMargin(0)), CompoundedRate())
    instrument_rate = CompoundInstrumentRate(RateIndex("compounded_rate_index"), rate_config)

    # fixed rate stream configuration
    principal = 1.0
    stream_config = FloatStreamConfig(principal, instrument_rate, instrument_schedule)

    # float rate stream calculations
    float_rate_stream = CompoundFloatRateStream(stream_config)
    compounding_schedules = float_rate_stream.schedules.compounding_schedules
    compounding_schedules = [x for x in compounding_schedules]
    coupons = [coupon for schedule in compounding_schedules for coupon in schedule]

    # quantlib

    # Define schedule
    schedule = get_quantlib_schedule(start_date, end_date, period, calendar, NoRollConvention(), business_day_convention, business_day_convention, schedule_config.stub_period.position)

    yts = ql.YieldTermStructureHandle(ql.FlatForward(2, ql.TARGET(), 0.05, to_ql_day_count(day_count)))
    engine = ql.DiscountingSwapEngine(yts)

    index = ql.IborIndex("MyIndex", ql.Period(1, ql.Months), 2, ql.USDCurrency(), ql.WeekendsOnly(), ql.Following, false, to_ql_day_count(day_count))
    nominal = 100.0
    sub_period_leg = ql.SubPeriodsLeg(
        [nominal],
        schedule,
        index,
        paymentLag=2,
        averagingMethod=ql.RateAveraging.Compound)

    settlement_days = 3
    calendar = ql.TARGET()
    bond = ql.Bond(settlement_days, calendar, schedule[1], sub_period_leg)

    ql_coupons = [ql.as_sub_periods_coupon(cf) for cf in bond.cashflows()]
    # println(length(ql_coupons[1:end-1]))
    # println(length(compounding_schedules))

    # compare schedules per coupon
    for (i, (ql_coupon, c)) in enumerate(zip(ql_coupons[1:end-1], compounding_schedules))
        @assert to_julia_date(ql_coupon.accrualStartDate()) == c.accrual_dates[1]
        @assert to_julia_date(ql_coupon.accrualEndDate()) == c.accrual_dates[end]
        # println(pybuiltin("dir")(ql_coupon))
        # println(pybuiltin("type")(ql_coupon))

        for (j, (ql_fixing_date,fixing_date)) in enumerate(zip(ql_coupon.fixingDates(),c.fixing_dates))
            # println(to_julia_date(ql_fixing_date), " vs ", fixing_date)
            # println(c[j].accrual_start)
            @assert to_julia_date(ql_fixing_date) == fixing_date
        end
    end
end