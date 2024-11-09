function forward_rate(rate_curve::C, start_date, end_date, time_fraction; 
        rate_type::R=rate_curve.rate_type,
        margin_config::M=AdditiveMargin(0)) where {C <: AbstractRateCurve, R<:RateType, M<:MarginConfig}
    end_discount_factor = discount_factor(rate_curve, end_date)
    start_discount_factor = discount_factor(rate_curve, start_date)
    discount_factor_ratio = start_discount_factor ./ end_discount_factor
    rates = implied_rate(discount_factor_ratio, time_fraction, rate_type)
    return apply_margin(rates, margin_config)
end

function forward_rate(rate_curve::A, schedules::SimpleRateStreamSchedules, rate_type::R, margin_config::M=AdditiveMargin(0)) where {M<:MarginConfig, R<:RateType, A<:AbstractRateCurve}
    return forward_rate(rate_curve, schedules.discount_start_dates, schedules.discount_end_dates,
        schedules.accrual_day_counts;
        rate_type=rate_type,
        margin_config=margin_config)
end

function forward_rate(rate_curve::C, start_date, end_date; 
        rate_type::R=rate_curve.rate_type, 
        day_count::D=rate_curve.day_count,
        margin_config::M=AdditiveMargin(0)) where {C <: AbstractRateCurve, R<:RateType, D<:DayCount, M<:MarginConfig}
    time_fraction = day_count_fraction(start_date, end_date, day_count)
    return forward_rate(rate_curve, start_date, end_date, time_fraction;
        rate_type=rate_type,
        margin_config=margin_config)
end


function forward_rate(rate_curve::C, schedules::SimpleRateStreamSchedules, rate_config::SimpleRateConfig) where C<:AbstractRateCurve
    return forward_rate(rate_curve, schedules, rate_config.rate_type, rate_config.margin)
end

function forward_rate(rate_curve::R, schedules::CompoundedRateStreamSchedules, rate_config::CompoundRateConfig) where R<:AbstractRateCurve
    if isa(rate_config.margin, MarginOnUnderlying)
        error("Not implemented margin on underlying coumpounded rates")
    end
    interest_accruals = []
    for i in 1:length( schedules.compounding_schedules)
        forward_rates = forward_rate(rate_curve, schedules.compounding_schedules[i], rate_config.rate_type, rate_config.margin.margin_config)
        compound_factors = compounding_factor(forward_rates, schedules.compounding_schedules[i].accrual_day_counts, rate_config.rate_type)
        interest_accrual = prod(compound_factors) 
        push!(interest_accruals, interest_accrual)
    end

    return forward_rate(interest_accruals, schedules.accrual_day_counts, rate_config.rate_type)
end