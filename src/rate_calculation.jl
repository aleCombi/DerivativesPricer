abstract type AbstractRateConfig end

struct FixedRateConfig{D<:DayCountConvention, R<:RateConvention} <: AbstractRateConfig
    day_count_convention::D
    rate_convention::R
end

struct FloatRateConfig{I<: AbstractRateIndex, D<:DayCountConvention, R<:RateConvention} <: AbstractRateConfig
    rate_index::I
    day_count_convention::D
    rate_convention::R
end

abstract type AbstractInstrumentRate end

struct FixedRate{V<:Number, R<:AbstractRateConfig} <: AbstractInstrumentRate
    rate::V
    rate_config::R
end

