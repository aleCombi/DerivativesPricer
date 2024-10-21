using DerivativesPricer


function calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, rate_config::SimpleRateConfig) where {D<:TimeType}
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    forward_rate_map = x -> (discount_factors[x+1] / discount_factors[x] - 1) / day_counts[x]
    forward_rate_plus_margin_map = x -> apply_margin(forward_rate_map(x), rate_config.margin)

    return map(forward_rate_plus_margin_map, 1:length(discount_factors)-1)
end

function calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention:C, margin_config::M) where {D<:TimeType, M<:MarginConfig, C<:DayCount}
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    forward_rate_map = x -> (discount_factors[x+1] / discount_factors[x] - 1) / day_counts[x]
    forward_rate_plus_margin_map = x -> apply_margin(forward_rate_map(x), margin_config)
    
    return map(forward_rate_plus_margin_map, 1:length(discount_factors)-1)
end