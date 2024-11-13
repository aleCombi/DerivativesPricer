@testitem "Flat Rate Curve" setup=[QuantlibSetup] begin
    day_count = ACT360()
    pricing_date = Date(2017,1,1)
    discount_date = Date(2020,1,1)
    rate = 0.05
    yts = ql.YieldTermStructureHandle(ql.FlatForward(0, ql.NullCalendar(), rate, to_ql_day_count(day_count)))
    ql.Settings.instance().evaluationDate = to_ql_date(pricing_date)
    df_quantlib = yts.discount(to_ql_date(discount_date))

    rate_curve = FlatRateCurve("Flat Curve", pricing_date, rate, day_count, Exponential())
    df_hedgehog = discount_factor(rate_curve, discount_date)
    
    @test df_hedgehog ≈ df_quantlib atol=1e-8
end

@testitem "Log Linear Interpolated Rate Curve" setup=[QuantlibSetup] begin
    day_count = ACT360()
    pricing_date = Date(2017,1,1)
    ql.Settings.instance().evaluationDate = to_ql_date(pricing_date)
    discount_date = Date(2020,2,1)
    dates = [Date(2020,1,1),Date(2021,1,1)]
    ql_dates = [to_ql_date(d) for d in dates]
    dfs = [1.0,2.0]
    dc = ql.DiscountCurve(ql_dates, dfs, to_ql_day_count(day_count))
    yts = ql.YieldTermStructureHandle(dc)
    df_quantlib = yts.discount(to_ql_date(discount_date))

    rate_curve = InterpolatedRateCurve(pricing_date; 
        input_values=dfs, input_type=Hedgehog.DiscountFactor(), day_count_convention=day_count, spine_dates=dates, rate_type=Exponential())
    df_hedgehog = discount_factor(rate_curve, discount_date)
    
    println(df_hedgehog)
    println(df_quantlib)
    @test df_hedgehog ≈ df_quantlib atol=1e-8
end
