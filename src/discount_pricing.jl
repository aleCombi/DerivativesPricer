using DerivativesPricer

function price_fixed_rate_stream(stream_config::FixedRateStream, rate_curve::RateCurve)
    discount_factors = rate_curve.discount_factor(stream_config.payment_dates)
    return sum(stream_config.cash_flows .* discount_factors)
end