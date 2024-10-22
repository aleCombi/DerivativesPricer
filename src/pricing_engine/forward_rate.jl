"""
    calculate_forward_rate(discount_factor_ratio, year_fraction, ::LinearRate)

Calculates the forward rate using a linear rate approach.

# Arguments
- `discount_factor_ratio`: A numeric value or array representing the ratio of discount factors.
- `year_fraction`: A numeric value or array representing the time period as a fraction of a year.
- `::LinearRate`: The rate type, indicating the linear rate model.

# Returns
- The forward rate calculated as `(discount_factor_ratio - 1) / year_fraction`.
"""
function calculate_forward_rate(discount_factor_ratio, year_fraction, ::LinearRate)
    return (discount_factor_ratio .- 1) ./ year_fraction
end

"""
    calculate_forward_rate(discount_factor_ratio, year_fraction, ::Exponential)

Calculates the forward rate using an exponential (logarithmic) rate approach.

# Arguments
- `discount_factor_ratio`: A numeric value or array representing the ratio of discount factors.
- `year_fraction`: A numeric value or array representing the time period as a fraction of a year.
- `::Exponential`: The rate type, indicating the exponential rate model.

# Returns
- The forward rate calculated as `log(discount_factor_ratio) / year_fraction`.
"""
function calculate_forward_rate(discount_factor_ratio, year_fraction, ::Exponential)
    return log.(discount_factor_ratio) ./ year_fraction
end

"""
    calculate_forward_rate(discount_factor_ratio, year_fraction, ::Yield)

Calculates the forward rate using the yield rate approach.

# Arguments
- `discount_factor_ratio`: A numeric value or array representing the ratio of discount factors.
- `year_fraction`: A numeric value or array representing the time period as a fraction of a year.
- `::Yield`: The rate type, indicating the yield model.

# Returns
- The forward rate calculated as `discount_factor_ratio^(1 / year_fraction) - 1`.
"""
function calculate_forward_rate(discount_factor_ratio, year_fraction, ::Yield)
    return discount_factor_ratio.^(1 ./ year_fraction) .- 1
end

"""
    calculate_forward_rate(discount_factor_ratio, year_fraction, rate_type::Compounded)

Calculates the forward rate using a compounded rate approach, adjusting for the frequency of compounding.

# Arguments
- `discount_factor_ratio`: A numeric value or array representing the ratio of discount factors.
- `year_fraction`: A numeric value or array representing the time period as a fraction of a year.
- `rate_type::Compounded`: The rate type, indicating the compounded rate model, including its frequency of compounding.

# Returns
- The forward rate calculated as `discount_factor_ratio^(frequency / year_fraction) - 1`.
"""
function calculate_forward_rate(discount_factor_ratio, year_fraction, rate_type::Compounded)
    return discount_factor_ratio.^(rate_type.frequency ./ year_fraction) .- 1
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
TODO: add sensible defaults.
"""
function calculate_forward_rate(rate_curve::RateCurve, dates::Vector{D}, rate_type::R, day_count::C, margin_config::M=AdditiveMargin(0)) where {D<:TimeType, M<:MarginConfig, R<:RateType, C<:DayCount}
    year_fractions = day_count_fraction(dates, day_count)
    discount_factors = discount_factor(rate_curve, dates)
    discount_factor_ratios = map(x -> discount_factors[x+1] / discount_factors[x], 1:length(discount_factors)-1)
    forward_rates_without_margin = calculate_forward_rate(discount_factor_ratios, year_fractions, rate_type)
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
function calculate_forward_rate(rate_curve::RateCurve, dates::Vector{D}, rate_config::F) where {D<:TimeType, F <: FloatRateConfig}
    return calculate_forward_rate(rate_curve, dates, rate_config.rate_type, rate_config.day_count_convention, rate_config.margin)
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