"""
    price_fixed_flows_stream(stream_config::FixedRateStream, rate_curve::RateCurve)

Calculate the price of a fixed-rate stream of cash flows using a given rate curve. This function discounts the cash flows using the discount factors
from the rate curve and returns the total price.

# Arguments
- `stream_config::FixedRateStream`: The fixed-rate stream of cash flows.
- `rate_curve::RateCurve`: The rate curve used to discount the cash flows.

# Returns
- The price of the fixed-rate stream of cash flows.
"""
function price_fixed_flows_stream(payment_dates::D, cash_flows::N, rate_curve::RateCurve) where D<:Vector{<:TimeType} where N<:Vector{<:Number}
    discount_factors = discount_factor(rate_curve, payment_dates)
    return sum(cash_flows .* discount_factors)
end
"""
    forward_rates(rate_curve::RateCurve, dates, day_count_convention::DayCountConvention)

Calculate the forward rates between the dates in the given rate curve using the specified day count convention.

# Arguments
- `rate_curve::RateCurve`: The rate curve used to calculate the forward rates.
- `dates::Vector{Date}`: The dates for which to calculate the forward rates.
- `day_count_convention::DayCountConvention`: The day count convention used to calculate the time fractions.

# Returns
- An array of forward rates between the given dates.
"""
function forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::DayCountConvention=rate_curve.day_count_convention) where D<:TimeType
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    return map(x -> (discount_factors[x+1] / discount_factors[x] - 1) / day_counts[x], 1:length(discount_factors)-1)
end

"""
    price_float_rate_stream(stream::FloatRateStream, rate_curve::RateCurve)

Calculate the price of a floating-rate stream of cash flows using a given rate curve. This function calculates the forward rates
for each accrual period, discounts the cash flows using the discount factors from the rate curve, and returns the total price.

# Arguments
- `stream::FloatRateStream`: The floating-rate stream of cash flows.
- `rate_curve::RateCurve`: The rate curve used to discount the cash flows.

# Returns
- The price of the floating-rate stream of cash flows.
"""
function price_float_rate_stream(stream::FloatingRateStream, rate_curve::RateCurve)
    forward_rates = forward_rates(rate_curve, stream.accrual_dates, stream.config.day_count_convention)
    discount_factors = discount_factor(rate_curve, stream.pay_dates)
    return sum(stream.config.principal .* discount_factors .* forward_rates)
end