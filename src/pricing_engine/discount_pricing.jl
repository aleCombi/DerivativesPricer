"""
    price_fixed_flows_stream(payment_dates::Vector{D}, cash_flows::Vector{N}, rate_curve::RateCurve)

Calculate the price of a fixed-rate stream of cash flows using a given rate curve. This function discounts the cash flows using the discount factors
from the rate curve and returns the total price.

# Arguments
- `stream_config::FixedRateStream`: The fixed-rate stream of cash flows.
- `rate_curve::RateCurve`: The rate curve used to discount the cash flows.

# Returns
- The price of the fixed-rate stream of cash flows.
"""
function price_fixed_flows_stream(payment_dates::Vector{D}, cash_flows::Vector{N}, rate_curve) where D<:TimeType where N<:Number
    discount_factors = discount_factor(rate_curve, payment_dates)
    return sum(cash_flows .* discount_factors)
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
    forward_rates = calculate_forward_rate(rate_curve, stream.accrual_dates, stream.config.rate.rate_config)
    discount_factors = discount_factor(rate_curve, stream.pay_dates)
    return sum(stream.config.principal .* discount_factors .* forward_rates)
end