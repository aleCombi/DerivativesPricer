"""
    forward_rate(rate_curve::C, start_date, end_date, time_fraction; 
                 rate_type::R=rate_curve.rate_type, 
                 margin_config::M=AdditiveMargin(0)) 

Calculates the forward rate over a specified time period based on the discount factors 
at the start and end dates, the time fraction, rate type, and any applicable margin.

# Arguments
- `rate_curve::C`: The rate curve object representing interest rate data.
- `start_date`: The start date for the forward rate calculation.
- `end_date`: The end date for the forward rate calculation.
- `time_fraction`: Fraction of time between `start_date` and `end_date` (typically in years).
- `rate_type::R`: The type of rate (e.g., simple or compounded). Defaults to the type of `rate_curve`.
- `margin_config::M`: The margin configuration to adjust the calculated rate. Defaults to `AdditiveMargin(0)`.

# Returns
- The forward rate with the applied margin.
"""
function forward_rate(rate_curve::C, start_date, end_date, time_fraction; 
                      rate_type::R=rate_curve.rate_type, 
                      margin_config::M=AdditiveMargin(0)) where {C<:AbstractRateCurve, R<:RateType, M<:MarginConfig}
    end_discount_factor = discount_factor(rate_curve, end_date)
    start_discount_factor = discount_factor(rate_curve, start_date)
    discount_factor_ratio = start_discount_factor ./ end_discount_factor
    rates = implied_rate(discount_factor_ratio, time_fraction, rate_type)
    return apply_margin(rates, margin_config)
end

"""
    forward_rate(rate_curve::C, start_date, end_date; 
                 rate_type::R=rate_curve.rate_type, 
                 day_count::D=rate_curve.day_count, 
                 margin_config::M=AdditiveMargin(0)) 

Calculates the forward rate between two dates using a specified day count convention.
It first calculates the time fraction and then computes the forward rate.

# Arguments
- `rate_curve::C`: The rate curve object containing rate information.
- `start_date`: Start date for the forward rate period.
- `end_date`: End date for the forward rate period.
- `rate_type::R`: Rate type for calculation (e.g., simple, compounded). Defaults to `rate_curve`'s rate type.
- `day_count::D`: Day count convention used to compute the time fraction. Defaults to `rate_curve`'s day count convention.
- `margin_config::M`: Margin configuration for rate adjustment. Defaults to `AdditiveMargin(0)`.

# Returns
- The forward rate over the specified period.
"""
function forward_rate(rate_curve::C, start_date, end_date; 
                      rate_type::R=rate_curve.rate_type, 
                      day_count::D=rate_curve.day_count_convention, 
                      margin_config::M=AdditiveMargin(0)) where {C<:AbstractRateCurve, R<:RateType, D<:DayCount, M<:MarginConfig}
    time_fraction = day_count_fraction(start_date, end_date, day_count)
    return forward_rate(rate_curve, start_date, end_date, time_fraction; 
                        rate_type=rate_type, 
                        margin_config=margin_config)
end

"""
    forward_rate(rate_curve::C, schedules::SimpleRateStreamSchedules, rate_type::R, margin_config::M=AdditiveMargin(0))

Calculates forward rates over multiple periods as defined in the `schedules`. For each period,
it applies the specified `rate_type` and `margin_config` to compute the forward rates.

# Arguments
- `rate_curve::C`: The rate curve object representing interest rate data.
- `schedules::SimpleRateStreamSchedules`: Schedule data with start and end dates for each period.
- `rate_type::R`: Type of rate for calculation (e.g., simple, compounded).
- `margin_config::M`: Margin configuration for rate adjustment. Defaults to `AdditiveMargin(0)`.

# Returns
- A list of forward rates for each period in the schedule.
"""
function forward_rate(schedules::SimpleRateStreamSchedules, rate_curve::C, rate_type::R, margin_config::M=AdditiveMargin(0)) where {C<:AbstractRateCurve, R<:RateType, M<:MarginConfig}
    println("ciao")
    return forward_rate(rate_curve, schedules.discount_start_dates, schedules.discount_end_dates, 
                        schedules.accrual_day_counts; 
                        rate_type=rate_type, 
                        margin_config=margin_config)
end

"""
    forward_rate(rate_curve::C, schedules::SimpleRateStreamSchedules, rate_config::SimpleRateConfig)

Calculates forward rates over periods specified in the schedules using the configuration specified in `rate_config`.

# Arguments
- `rate_curve::C`: The rate curve object representing interest rate data.
- `schedules::SimpleRateStreamSchedules`: Schedule data containing start and end dates for each period.
- `rate_config::SimpleRateConfig`: Configuration object specifying rate type and margin adjustments.

# Returns
- A list of forward rates for each period, computed using `rate_config`.
"""
function forward_rate(schedules::SimpleRateStreamSchedules, rate_curve::C, rate_config::SimpleRateConfig) where C<:AbstractRateCurve
    return forward_rate(schedules, rate_curve, rate_config.rate_type, rate_config.margin)
end

"""
    forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_config::CompoundRateConfig)

Calculates compounded forward rates over periods specified in `schedules`. It computes forward rates 
for each compounding schedule and applies any margin configurations on the compounded rates.

# Arguments
- `rate_curve::R`: The rate curve object containing interest rate data.
- `schedules::CompoundedRateStreamSchedules`: Schedule data containing compounding periods for each segment.
- `rate_config::CompoundRateConfig`: Configuration object specifying rate type and margin adjustments.

# Returns
- The compounded forward rate across all periods defined in `schedules`.

# Throws
- `Error` if the margin is specified on an underlying compounded rate, as this functionality is not implemented.
"""
function forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_config::CompoundRateConfig) where R<:AbstractRateCurve
    if isa(rate_config.margin, MarginOnUnderlying)
        error("Not implemented margin on underlying compounded rates")
    end
    interest_accruals = []
    for i in 1:length(schedules.compounding_schedules)
        forward_rates = forward_rate(rate_curve, schedules.compounding_schedules[i], rate_config.rate_type, rate_config.margin.margin_config)
        compound_factors = compounding_factor(forward_rates, schedules.compounding_schedules[i].accrual_day_counts, rate_config.rate_type)
        interest_accrual = prod(compound_factors) 
        push!(interest_accruals, interest_accrual)
    end

    return forward_rate(interest_accruals, schedules.accrual_day_counts, rate_config.rate_type)
end
