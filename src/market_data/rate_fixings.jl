abstract type RateFixingSource end

struct RateFixingTuples{D<:TimeType, R<:AbstractRateIndex} <: RateFixingSource
    date::D
    rate_index::R
    fixings::Base.ImmutableDict
end 

function get_fixing(date, fixing_source::RateFixingTuples)
    return fixing_source.fixings[date]
end

abstract type MarketData end

struct RateMarketData{R<:AbstractRateCurve, F<:RateFixingSource} <: MarketData
    rate_curve::R
    fixing_source::F
end

function market_data_date(market_date::RateMarketData)
    return market_date.fixing_source.date
end

function RateMarketData(rate_curve::R) where {R<:AbstractRateCurve}
    return RateMarketData(rate_curve, RateFixingTuples(rate_curve.date, RateIndex("Index"), Base.ImmutableDict{Date, Float64}()))
end