"""
    MarginConfig

An abstract type representing the configuration for margin. Concrete types for margin configurations, 
such as `AdditiveMargin` and `MultiplicativeMargin`, should subtype this.
"""
abstract type MarginConfig end

"""
    AdditiveMargin{N<:Number}

A concrete type representing an additive margin, where a fixed amount is added to the base rate.

# Fields
- `margin::N`: The margin value to be added, of type `N` (typically a `Float64` or `Int`).
"""
struct AdditiveMargin{N<:Number} <: MarginConfig
    margin::N
end

function AdditiveMargin()
    return AdditiveMargin(0)
end

"""
    MultiplicativeMargin{N<:Number}

A concrete type representing a multiplicative margin, where the base rate is multiplied by a factor.

# Fields
- `margin::N`: The margin value used as a multiplier, of type `N` (typically a `Float64` or `Int`).
"""
struct MultiplicativeMargin{N<:Number} <: MarginConfig
    margin::N
end

"""
    CompoundMargin

An abstract type representing a margin configuration for compounded rates. 
Concrete types like `MarginOnUnderlying` and `MarginOnCompoundedRate` should subtype this.
"""
abstract type CompoundMargin end

"""
    MarginOnUnderlying{M<:MarginConfig} <: CompoundMargin

A concrete type representing a margin applied on the underlying rate (before compounding), 
parameterized by the margin configuration `M`.

# Fields
- `marginConfig::M`: The margin configuration applied to the underlying rate, 
  typically of type `AdditiveMargin` or `MultiplicativeMargin`.
"""
struct MarginOnUnderlying{M<:MarginConfig} <: CompoundMargin
    margin_config::M
end

"""
    MarginOnCompoundedRate{M<:MarginConfig} <: CompoundMargin

A concrete type representing a margin applied on the compounded rate (after compounding), 
parameterized by the margin configuration `M`.

# Fields
- `marginConfig::M`: The margin configuration applied to the compounded rate, 
  typically of type `AdditiveMargin` or `MultiplicativeMargin`.
"""
struct MarginOnCompoundedRate{M<:MarginConfig} <: CompoundMargin
    margin_config::M
end

"""
    apply_margin(rate, margin::AdditiveMargin)

Applies an additive margin to a given rate. This function takes a base rate and 
adds a specified additive margin to it.

# Arguments
- `rate`: The base rate to which the margin will be applied.
- `margin::AdditiveMargin`: An instance of `AdditiveMargin` containing the margin value to add.

# Returns
- The rate after applying the additive margin (i.e., `rate + margin.margin`).
"""
function apply_margin(rate, margin::AdditiveMargin)
    return rate .+ margin.margin
end

"""
    apply_margin(rate, margin::MultiplicativeMargin)

Applies a multiplicative margin to a given rate. This function takes a base rate 
and multiplies it by `(1 + margin)`.

# Arguments
- `rate`: The base rate to which the margin will be applied.
- `margin::MultiplicativeMargin`: An instance of `MultiplicativeMargin` containing the margin value to multiply by.

# Returns
- The rate after applying the multiplicative margin (i.e., `rate * (1 + margin.margin)`).
"""
function apply_margin(rate, margin::MultiplicativeMargin)
    return rate .* (1 .+ margin.margin)
end