abstract type AbstractMarginConfig end

struct AdditiveMargin{N<:Number}
    margin::N
end

struct MultiplicativeMargin{N<:Number}
    margin::N
end

abstract type AbstractCompoundMarginMode end

struct MarginOnUnderlying{M<:AbstractMarginConfig} <: AbstractCompoundMarginMode
    marginConfig::M
end
struct MarginOnCompoundedRate{M<:AbstractMarginConfig} <: AbstractCompoundMarginMode
    marginConfig::M
end