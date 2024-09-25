using DerivativesPricer

function price_fixed_rate_stream(stream_config::FixedRateStream, rate_curve::RateCurve)
    discount_factors = rate_curve.discount_factor(stream_config.payment_dates)
    return sum(stream_config.cash_flows .* discount_factors)
end

function forward_rates(rate_curve::RateCurve, dates, day_count_convention::DayCountConvention)
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factor = rate_curve.discount_factor(dates)
    return map(x -> (discount_factor[x+1] / discount_factor[x] - 1) / day_counts[x], 1:length(discount_factor)-1)
end

function price_float_rate_stream(stream::FloatRateStream, rate_curve::RateCurve)
    forward_rates = forward_rates(rate_curve, stream.accrual_dates, stream.config.day_count_convention)
    discount_factors = rate_curve.discount_factor(stream.config.pay_dates)
    return sum(stream.config.principal .* discount_factors .* forward_rates)
end

