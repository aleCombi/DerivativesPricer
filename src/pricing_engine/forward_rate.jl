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

TODO: Mathematical approximation?
TODO: add sensible defaults.
"""
function calculate_forward_rate(rate_curve::A, schedules::SimpleRateStreamSchedules, rate_type::R, margin_config::M=AdditiveMargin(0)) where {M<:MarginConfig, R<:RateType, A<:AbstractRateCurve}
    end_discount_factors = discount_factor(rate_curve, schedules.discount_end_dates)
    start_discount_factors = discount_factor(rate_curve, schedules.discount_start_dates)
    discount_factor_ratios =  start_discount_factors ./ end_discount_factors
    forward_rates_without_margin = implied_rate(discount_factor_ratios, schedules.accrual_day_counts, rate_type)
    return apply_margin(forward_rates_without_margin, margin_config)
end

"""
    calculate_forward_rate(rate_curve::RateCurve, dates::Vector{D}, rate_config::F) where {D<:TimeType, F <: FloatRateConfig}

Calculates the forward rate based on a rate curve, a set of dates, and a rate configuration.

# Arguments
- `rate_curve::RateCurve`: The rate curve from which discount factors are derived.
- `dates::Vector{D}`: A vector of date objects representing the time points for forward rate calculation. The type `D` is constrained to `TimeType` (e.g., `Date`, `DateTime`).
- `rate_config::F`: The rate configuration object, containing parameters such as the rate type, day count convention, and margin. `F` must be a subtype of `FloatRateConfig`.

# Returns
- The forward rate calculated by delegating to the appropriate method, using the rate configuration's `rate_type`, `day_count_convention`, and margin.
"""
function calculate_forward_rate(rate_curve::C, schedules::SimpleRateStreamSchedules, rate_config::SimpleRateConfig) where C<:AbstractRateCurve
    return calculate_forward_rate(rate_curve, schedules, rate_config.rate_type, rate_config.margin)
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
function calculate_forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_config::CompoundRateConfig) where R<:AbstractRateCurve
    if isa(rate_config.margin, MarginOnUnderlying)
        error("Not implemented margin on underlying coumpounded rates")
    end
    interest_accruals = []
    for i in 1:length( schedules.compounding_schedules)
        forward_rates = calculate_forward_rate(rate_curve, schedules.compounding_schedules[i], rate_config.rate_type, rate_config.margin.margin_config)
        compound_factors = compounding_factor(forward_rates, schedules.compounding_schedules[i].accrual_day_counts, rate_config.rate_type)
        interest_accrual = prod(compound_factors) 
        push!(interest_accruals, interest_accrual)
    end

    return calculate_forward_rate(interest_accruals, schedules.accrual_day_counts, rate_config.rate_type)
end