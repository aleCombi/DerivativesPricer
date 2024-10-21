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
function calculate_forward_rate(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C) where {D<:TimeType, C<:DayCount}
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

TODO:Mathematical approximation?
TODO: add sensible defaults, add version for FlowStream struct (orchestrator)
"""
function calculate_forward_rate(rate_curve::RateCurve,
        dates::Vector{D}, 
        rate_convention::R,
        day_count_convention::C, 
        margin_config::M) where {D<:TimeType, M<:MarginConfig, R<:RateType, C<:DayCount}
    day_counts = day_count_fraction(dates, day_count_convention)
    discount_factors = discount_factor(rate_curve, dates)
    forward_rate_map = x -> calculate_forward_rate(discount_factors[x+1] / discount_factors[x], day_counts[x], rate_convention)
    forward_rate_plus_margin_map = x -> apply_margin(forward_rate_map(x), margin_config)
    
    return map(forward_rate_plus_margin_map, 1:length(discount_factors)-1)
end

function calculate_forward_rate(discount_factor_ratio, year_fraction, ::LinearRate)
    return (discount_factor_ratio .- 1) ./ year_fraction
end

function calculate_forward_rate(discount_factor_ratio, year_fraction, ::Exponential)
    return log.(discount_factor_ratio) ./ year_fraction
end

function calculate_forward_rate(discount_factor_ratio, year_fraction, ::Yield)
    return discount_factor_ratio.^(1 ./ year_fraction) .- 1
end

function calculate_forward_rate(discount_factor_ratio, year_fraction, rate_type::Compounded)
    return discount_factor_ratio.^(rate_type.frequency ./ year_fraction) .- 1
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
TODO:Implement this one.
"""
function calculate_forward_rate(rate_curve::RateCurve, dates::Vector{D}, day_count_convention::C, compound_margin::M) where {D<:TimeType, M<:CompoundMargin, C<:DayCount}
end