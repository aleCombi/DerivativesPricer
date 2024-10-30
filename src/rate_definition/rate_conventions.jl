"""
    RateType

Abstract type representing a rate type. This serves as the base type for all specific interest rate types such as linear (simple) interest and compound interest.
"""
abstract type RateType end

"""
    Linear <: RateType

Concrete type representing linear (simple) interest, where the interest is calculated as a fixed percentage of the principal over time.
"""
struct LinearRate <: RateType end

"""
    Compounded <: RateType

Concrete type representing compound interest, where interest is calculated and added to the principal after each period, and the interest is calculated on the new balance. 

# Fields
- `frequency::Int`: The number of compounding periods per year (e.g., 12 for monthly compounding).
"""
struct Compounded <: RateType
    frequency::Int
end

"""
    Exponential <: RateType

Concrete type representing exponential interest, where the interest is calculated as the principal multiplied by the exponential of the interest rate times the time fraction.
"""
struct Exponential <: RateType end


function compounding_factor(rate, time_fraction, ::LinearRate)
    return (1 .+ rate .* time_fraction)
end

function compounding_factor(rate, time_fraction, rate_type::Compounded)
    return (1 .+ rate ./ rate_type.frequency) .^ (rate_type.frequency .* time_fraction)
end

function compounding_factor(rate, time_fraction, ::Exponential)
    return exp.(rate .* time_fraction)
end

function discount_interest(rate, time_fraction, rate_type::R) where {R<:RateType}
    return 1 ./ compounding_factor(rate, time_fraction, rate_type)
end

function calculate_interest(principal, rate, time_fraction, rate_type::R) where {R<:RateType}
    return principal .* (compounding_factor(rate, time_fraction, rate_type) - 1)
end

function calculate_interest(principal, rate, time_fraction, ::LinearRate)
    return principal .* rate .* time_fraction
end