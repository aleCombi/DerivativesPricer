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
    return margined_rate(discount_factor_ratio, time_fraction, rate_type, margin_config)
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
function forward_rate(schedules::SimpleRateStreamSchedules, rate_curve::C, rate_config::R) where {C<:AbstractRateCurve, R<:FloatRateConfig}
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
   return forward_rate(rate_curve, schedules, rate_config.rate_type, rate_config.margin)
end

"""
    forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_type::T, margin_config::M) 

Calculates compounded forward rates for each period specified in the `schedules`, using the given rate type and margin configuration.

# Arguments
- `rate_curve::R`: The rate curve object containing interest rate data.
- `schedules::CompoundedRateStreamSchedules`: Schedule containing compounding periods for each segment.
- `rate_type::T`: The type of rate (e.g., compounded, simple) for calculation.
- `margin_config::MarginOnCompoundedRate`: Margin configuration applied to the compounded rates.

# Returns
- The compounded forward rate for each period in `schedules`, with the specified margin applied.
"""
function forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_type::T, margin_config::MarginOnCompoundedRate) where {R<:AbstractRateCurve, T<:RateType}
    period_accrual_func = s -> period_compounded_accrual(s, rate_curve, rate_type, margin_config)
    period_accruals = period_accrual_func.(schedules.compounding_schedules)
    return margined_rate(period_accruals, schedules.accrual_day_counts, rate_type, margin_config.margin_config)
end

"""
    forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_type::T, margin_config::M) 

Calculates compounded forward rates for each period specified in the `schedules`, using the given rate type and margin configuration.

# Arguments
- `rate_curve::R`: The rate curve object containing interest rate data.
- `schedules::CompoundedRateStreamSchedules`: Schedule containing compounding periods for each segment.
- `rate_type::T`: The type of rate (e.g., compounded, simple) for calculation.
- `margin_config::MarginOnUnderlying`: Margin configuration applied to the underlying rates.

# Returns
- The compounded forward rate for each period in `schedules`, with the specified margin applied.
"""
function forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_type::T, margin_config::MarginOnUnderlying) where {R<:AbstractRateCurve, T<:RateType}
    period_accrual_func = s -> period_compounded_accrual(s, rate_curve, rate_type, margin_config)
    period_accruals = period_accrual_func.(schedules.compounding_schedules)
    return implied_rate(period_accruals, schedules.accrual_day_counts, rate_type)
end

"""
    period_compounded_accrual(simple_schedule::SimpleRateStreamSchedules, rate_curve::R, rate_type::T, margin_config::MarginOnCompoundedRate) 

Calculates the compounded interest accruals over each period in `simple_schedule`, applying the specified margin configuration to the compounded rate.

# Arguments
- `simple_schedule::SimpleRateStreamSchedules`: Schedule data containing start and end dates for each period.
- `rate_curve::R`: The rate curve object representing interest rate data.
- `rate_type::T`: Rate type for calculation (e.g., compounded).
- `margin_config::MarginOnCompoundedRate`: Margin configuration applied directly to the compounded rate.

# Returns
- A vector of interest accruals for each period, compounded with the specified margin.
"""
function period_compounded_accrual(simple_schedule::SimpleRateStreamSchedules, rate_curve::R, rate_type::T, ::MarginOnCompoundedRate) where {R<:AbstractRateCurve, T<:RateType}
    forwards = forward_rate(simple_schedule, rate_curve, rate_type)
    compounding_factors = compounding_factor(forwards, simple_schedule.accrual_day_counts, rate_type)
    interest_accruals = prod(compounding_factors)
    return interest_accruals
end

"""
    period_compounded_accrual(simple_schedule::SimpleRateStreamSchedules, rate_curve::R, rate_type::T, margin_config::MarginOnUnderlying)

Calculates the compounded interest accruals over each period in `simple_schedule`, applying the specified margin configuration to the underlying rate.

# Arguments
- `simple_schedule::SimpleRateStreamSchedules`: Schedule data with start and end dates for each period.
- `rate_curve::R`: The rate curve object representing interest rate data.
- `rate_type::T`: Type of rate (e.g., simple or compounded).
- `margin_config::MarginOnUnderlying`: Margin configuration applied to the underlying rate before compounding.

# Returns
- The total compounded interest accrual for the period, adjusted for the underlying margin.

# Notes
- This function computes compound factors for each forward rate, then applies the accruals and margin sequentially.
"""
function period_compounded_accrual(simple_schedule::SimpleRateStreamSchedules, rate_curve::R, rate_type::T, margin_config::MarginOnUnderlying) where {R<:AbstractRateCurve, T<:RateType}
    forwards = forward_rate(simple_schedule, rate_curve, rate_type, margin_config.margin_config)
    compounding_factors = compounding_factor(forwards, simple_schedule.accrual_day_counts, rate_type)
    compound_after_i = vcat([prod(compounding_factors[i+1:end]) for i in 1:(length(compounding_factors).-1)],1)
    sub_addend = simple_schedule.accrual_day_counts .* forwards
    return 1 .+ sum(sub_addend .* compound_after_i)
end
