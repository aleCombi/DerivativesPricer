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
    calculate_expected_flows(stream::FloatingRateStream, forward_rates)

Calculates the expectation of the floating interest rate flows under the forward measure relative to the payment date. Note that in case of pay or fixing delays a convexity delay is ignored.

# Arguments
- `stream_::FloatingRateStream`: The floating rate stream representation.
- `forward_rates`: The list of forward rates.

# Returns
- The list of expected future cash flows.
"""
function calculate_expected_flows(stream::SimpleFloatRateStream, forward_rates)
    return calculate_interest(stream.config.principal, forward_rates, stream.schedules.accrual_day_counts, stream.config.rate.rate_config.rate_type)
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
function price_float_rate_stream(stream::SimpleFloatRateStream, rate_curve::RateCurve)
    forward_rates = calculate_forward_rate(stream, rate_curve)
    discount_factors = discount_factor(rate_curve, stream.schedules.pay_dates)
    flows = calculate_expected_flows(stream, forward_rates)
    return sum(discount_factors .* flows)
end

function calculate_forward_rate(stream::SimpleFloatRateStream, rate_curve::RateCurve)
    return calculate_forward_rate(rate_curve, stream.schedules, stream.config.rate.rate_config)
end