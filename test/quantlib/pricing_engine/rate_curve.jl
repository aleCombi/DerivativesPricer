@testitem "Flat Rate Curve" setup=[QuantlibSetup] begin
    day_count = ACT360()
    pricing_date = Date(2017,1,1)
    discount_date = Date(2020,1,1)
    rate = 0.05
    yts = ql.YieldTermStructureHandle(ql.FlatForward(0, ql.NullCalendar(), rate, to_ql_day_count(day_count)))
    engine = ql.DiscountingSwapEngine(yts)
    ql.Settings.instance().evaluationDate = to_ql_date(pricing_date)
    df_quantlib = yts.discount(to_ql_date(discount_date))

    rate_curve = FlatRateCurve("Flat Curve", pricing_date, rate, day_count, Exponential())
    df_hedgehog = discount_factor(rate_curve, discount_date)
    
    @test df_hedgehog ≈ df_quantlib atol=1e-8
end
