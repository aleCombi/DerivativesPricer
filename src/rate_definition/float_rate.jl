"""
    AbstractRateIndex

An abstract type representing a rate index. This type is used to define the rate index for a floating-rate stream.
"""
abstract type AbstractRateIndex end

"""
    RateIndex

A structure representing a rate index. 
This object should be mapped to data sources.

# Fields
- `name::String`: The name of the rate index (e.g., LIBOR, EURIBOR, SOFR).
"""
struct RateIndex
    name::String
end

"""
    FloatRateConfig <: AbstractRateConfig

An abstract type that represents the configuration for floating rates. 
Concrete floating rate configurations (e.g., `SimpleRateConfig`, `CompoundRateConfig`) should subtype this.
"""
abstract type FloatRateConfig <: AbstractRateConfig end

"""
    SimpleRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, N<:MarginConfig} <: FloatRateConfig

A concrete configuration for simple floating rates, parameterized by a day count convention `D`, 
a rate type `L`, a shift `C` for fixing, and a margin configuration `N`.

# Fields
- `day_count_convention::D`: The day count convention for calculating time fractions (e.g., Actual/360).
- `rate_convention::L`: The type of floating rate (e.g., overnight, term rates).
- `fixing_shift::C`: A fixing shift that adjusts for market practice in rate determination (e.g., a 2-day shift).
- `margin::N`: The margin or spread applied over the floating rate.
"""
struct SimpleRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, N<:MarginConfig} <: FloatRateConfig
    day_count_convention::D
    rate_type::L
    fixing_shift::C
    margin::N
end

"""
    struct CompoundRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, S<:AbstractScheduleConfig, M<:CompoundMargin} <: FloatRateConfig

A concrete configuration for compounded floating rates, parameterized by a day count convention `D`, 
a fixing shift `C`, a compounding schedule `S`, and a margin configuration `M`.

# Fields
- `day_count_convention::D`: The day count convention for calculating time fractions.
- `rate_convention::L`: The convention indicating the rates are compounded.
- `fixing_shift::C`: A fixing shift for rate determination adjustments.
- `compound_schedule::S`: A schedule configuration that defines the compounding intervals.
- `margin::M`: The margin or spread applied over the compounded floating rate.

# Notes
Ensure the compounding schedule is compatible with the accrual schedule.
"""
struct CompoundRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, S<:AbstractScheduleConfig, M<:CompoundMargin} <: FloatRateConfig
    day_count_convention::D
    rate_type::L
    fixing_shift::C
    compound_schedule::S
    margin::M
end

struct SimpleInstrumentRate <: AbstractInstrumentRate
    rate_index::RateIndex
    rate_config::SimpleRateConfig
end