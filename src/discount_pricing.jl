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
    forward_rates(rate_curve::RateCurve, dates, day_count_convention::DayCount)

Calculate the forward rates between the dates in the given rate curve using the specified day count convention.

# Arguments
- `rate_curve::RateCurve`: The rate curve used to calculate the forward rates.
- `dates::Vector{Date}`: The dates for which to calculate the forward rates.
- `day_count_convention::DayCount`: The day count convention used to calculate the time fractions.

# Returns
- An array of forward rates between the given dates.
"""
function calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C) where {D<:TimeType, C<:DayCount}
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    return map(x -> (discount_factors[x+1] / discount_factors[x] - 1) / day_counts[x], 1:length(discount_factors)-1)
end

"""
    calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C, margin_config::M) where {D<:TimeType, M<:MarginConfig, C<:DayCount}

Calculate the forward rates between the dates using a given curve, dates and applying margin for a simple rate.

# Arguments
- `rate_curve::RateCurve`: The rate curve used to calculate the forward rates.
- `dates::Vector{D}`: The dates for which to calculate the forward rates.
- `day_count_convention::C`: The day count convention used to calculate the time fractions.
- `margin_config`: The margin specifications.

# Returns
- An array of forward rates between the given dates with margin applied.

TODO:Mathematical approximation? Should this depend on the rate convention?
"""
function calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C, margin_config::M) where {D<:TimeType, M<:MarginConfig, C<:DayCount}
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    forward_rate_map = x -> (discount_factors[x+1] / discount_factors[x] - 1) / day_counts[x]
    forward_rate_plus_margin_map = x -> apply_margin(forward_rate_map(x), margin_config)
    
    return map(forward_rate_plus_margin_map, 1:length(discount_factors)-1)
end

"""
    calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C, compound_margin::M) where {D<:TimeType, M<:CompoundMargin, C<:DayCount}

# Arguments
- `rate_curve::RateCurve`: The rate curve used to calculate the forward rates.
- `dates::Vector{D}`: The dates for which to calculate the forward rates.
- `day_count_convention::C`: The day count convention used to calculate the time fractions.
- `compound_margin`: The compounded rate margin specifications (for instance applied before or after compounding).

# Returns
- An array of forward rates between the given dates with margin applied.

Calculate the forward rates between the provided dates using the given RateCurve, for a compounded floating rate with the selected compound margin convention.

TODO:Mathematical approximation? Should this depend on the rate convention? 2 dispatches needed
"""
function calculate_forward_rates(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C, compound_margin::M) where {D<:TimeType, M<:CompoundMargin, C<:DayCount}
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
    forward_rates = calculate_forward_rates(rate_curve, stream.accrual_dates, stream.config.rate.rate_config.day_count_convention)
    discount_factors = discount_factor(rate_curve, stream.pay_dates)
    return sum(stream.config.principal .* discount_factors .* forward_rates)
end