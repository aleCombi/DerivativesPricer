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

struct Yield <: RateType
end

"""
    Exponential <: RateType

Concrete type representing exponential interest, where the interest is calculated as the principal multiplied by the exponential of the interest rate times the time fraction.
"""
struct Exponential <: RateType end

"""
    calculate_interest(principal, rate, time_fraction, ::Linear)

Calculates interest for multiple principals using the linear (simple) interest method. This vectorized version handles multiple investments.

# Arguments
- `principal`: A vector of principal amounts.
- `rate`: A vector of interest rates for each principal.
- `time_fraction`: A vector representing the fraction of the year for each investment.

# Returns
- A vector of calculated simple interest for each investment.
"""
function calculate_interest(principal, rate, time_fraction, ::LinearRate)
    return principal .* rate .* time_fraction
end

"""
    discount_interest(rate, time_fraction, ::Linear)

Discounts factor given a rate and time fraction in Linear mode.

# Arguments
- `rate`: Interest rate for discounting.
- `time_fraction`: Daycount between the reference date and the discounting date.
- `::Linear`: An instance of Linear specifying the discount calculation mode.

# Returns
A set of discount factors.
"""
function discount_interest(rate, time_fraction, ::LinearRate)
    return 1 ./ (1 .+ rate .* time_fraction)
end

"""
    calculate_interest(principal, rate, time_fraction, rate_type::Compounded) -> Vector{Float64}

Calculates compound interest for multiple principals. This vectorized version handles multiple investments with compounding.

# Arguments
- `principal`: A vector of principal amounts.
- `rate`: A vector of interest rates for each principal.
- `time_fraction`: A vector representing the fraction of the year for each investment.
- `rate_type::Compounded`: An instance of `Compounded` specifying the frequency of compounding.

# Returns
- A vector of calculated compound interest for each investment.
"""
function calculate_interest(principal, rate, time_fraction, rate_type::Compounded)
    return principal .* ((1 .+ rate ./ rate_type.frequency) .^ (rate_type.frequency .* time_fraction)) .- principal
end

function calculate_interest(principal, rate, time_fraction, ::Yield)
    return principal .* (1 .+ rate) .^ time_fraction - principal
end

"""
    discount_interest(rate, time_fraction, ::Linear)

Discounts factor given a rate and time fraction in Linear mode.

# Arguments
- `rate`: Interest rate for discounting.
- `time_fraction`: Daycount between the reference date and the discounting date.
- `::Compounded`: An instance of Compounded specifying the discount calculation mode.

# Returns
A set of discount factors.
"""
function discount_interest(rate, time_fraction, rate_type::Compounded)
    return (1 .+ rate ./ rate_type.frequency) .^ (- rate_type.frequency .* time_fraction)
end

function discount_interest(rate, time_fraction, rate_type::Yield)
    return (1 .+ rate) .^ (-time_fraction)
end

"""
    calculate_interest(principal, rate, time_fraction, ::Exponential)

Calculates exponential interest for multiple principals. This vectorized version handles multiple investments.

    # Arguments
- `principal`: A vector of principal amounts.
- `rate`: A vector of interest rates for each principal.
- `time_fraction`: A vector representing the fraction of the year for each investment.

# Returns
- A vector of calculated exponential interest for each investment.
"""
function calculate_interest(principal, rate, time_fraction, ::Exponential)
    return principal .* (exp.(rate .* time_fraction)) .- principal
end

"""
    discount_interest(rate, time_fraction, ::Linear)

Discounts factor given a rate and time fraction in Linear mode.

# Arguments
- `rate`: Interest rate for discounting.
- `time_fraction`: Daycount between the reference date and the discounting date.
- `::Exponential`: An instance of Exponential specifying the discount calculation mode.

# Returns
A set of discount factors.
"""
function discount_interest(rate, time_fraction, ::Exponential)
    return exp.(-rate .* time_fraction)
end