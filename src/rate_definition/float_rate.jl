"""
    AbstractRateIndex

An abstract type representing a rate index. This type serves as a base for defining the rate index 
in a floating-rate stream, encapsulating the general concept of a rate index.
"""
abstract type AbstractRateIndex end

"""
    RateIndex

A structure representing a rate index. This object typically maps to data sources for different rate indices.

# Fields
- `name::String`: The name of the rate index (e.g., LIBOR, EURIBOR, SOFR).
"""
struct RateIndex
    name::String
end

"""
    FloatRateConfig <: AbstractRateConfig

An abstract type representing the configuration for floating rates. Subtypes of this define specific configurations 
for floating-rate instruments (e.g., `SimpleRateConfig`, `CompoundRateConfig`).
"""
abstract type FloatRateConfig <: AbstractRateConfig end

"""
    SimpleRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, N<:MarginConfig} <: FloatRateConfig

A concrete configuration for simple floating rates, parameterized by a day count convention `D`, 
a rate type `L`, a shift `C` for rate fixing, and a margin configuration `N`.

# Fields
- `day_count_convention::D`: The day count convention used to calculate time fractions (e.g., Actual/360).
- `rate_type::L`: The type of floating rate (e.g., overnight rates, term rates).
- `fixing_shift::C`: A fixing shift to adjust for market conventions (e.g., a 2-day shift).
- `margin::N`: The margin or spread added to the floating rate.
"""
struct SimpleRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, N<:MarginConfig} <: FloatRateConfig
    day_count_convention::D
    rate_type::L
    fixing_shift::C
    margin::N
end

function SimpleRateConfig(day_count_convention::D, rate_type::L) where {D<:DayCount, L<:RateType}
    return SimpleRateConfig(day_count_convention, rate_type, NoShift(), AdditiveMargin())
end

"""
    CompoundRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, S<:AbstractScheduleConfig, M<:CompoundMargin} <: FloatRateConfig

A concrete configuration for compounded floating rates, parameterized by a day count convention `D`, 
a rate type `L`, a fixing shift `C`, a compounding schedule `S`, and a margin configuration `M`.

# Fields
- `day_count_convention::D`: The day count convention for calculating time fractions (e.g., Actual/360).
- `rate_type::L`: Specifies the rate type, indicating that rates are compounded.
- `fixing_shift::C`: A fixing shift for rate determination adjustments, based on market practices.
- `compound_schedule::S`: A schedule configuration defining the intervals for compounding.
- `margin::M`: The margin or spread added over the compounded floating rate.
"""
struct CompoundRateConfig{D<:DayCount, L<:RateType, C<:AbstractShift, S<:AbstractScheduleConfig, M<:CompoundMargin} <: FloatRateConfig
    day_count_convention::D
    rate_type::L
    fixing_shift::C
    compound_schedule::S
    margin::M
end

"""
    SimpleInstrumentRate

A structure representing a simple floating-rate instrument, defined by a rate index and a simple rate configuration.

# Fields
- `rate_index::RateIndex`: The rate index associated with this instrument (e.g., LIBOR).
- `rate_config::SimpleRateConfig`: The configuration parameters for calculating the simple floating rate.
"""
struct SimpleInstrumentRate <: AbstractInstrumentRate
    rate_index::RateIndex
    rate_config::SimpleRateConfig
end

"""
    CompoundInstrumentRate

A structure representing a compounded floating-rate instrument, defined by a rate index and a compounded rate configuration.

# Fields
- `rate_index::RateIndex`: The rate index associated with this instrument (e.g., SOFR).
- `rate_config::CompoundRateConfig`: The configuration parameters for calculating the compounded floating rate.
"""
struct CompoundInstrumentRate <: AbstractInstrumentRate
    rate_index::RateIndex
    rate_config::CompoundRateConfig
end