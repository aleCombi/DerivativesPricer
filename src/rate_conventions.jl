"""
    RateType

Abstract type representing a rate type. This serves as the base type for all specific interest rate types such as linear (simple) interest and compound interest.
"""
abstract type RateType end

"""
    Linear <: RateType

Concrete type representing linear (simple) interest, where the interest is calculated as a fixed percentage of the principal over time.
"""
struct Linear <: RateType end

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

"""
    calculate_interest(principals::Vector{Float64}, rates::Vector{Float64}, time_fractions::Vector{Float64}, ::Linear) -> Vector{Float64}

Calculates interest for multiple principals using the linear (simple) interest method. This vectorized version handles multiple investments.

# Arguments
- `principals::Vector{Float64}`: A vector of principal amounts.
- `rates::Vector{Float64}`: A vector of interest rates for each principal.
- `time_fractions::Vector{Float64}`: A vector representing the fraction of the year for each investment.

# Returns
- `Vector{Float64}`: A vector of calculated simple interest for each investment.
"""
function calculate_interest(principal, rate, time_fractions, ::Linear)
    return principal .* rate .* time_fractions
end

"""
    calculate_interest(principals::Vector{Float64}, rates::Vector{Float64}, time_fractions::Vector{Float64}, rate_type::Compounded) -> Vector{Float64}

Calculates compound interest for multiple principals. This vectorized version handles multiple investments with compounding.

# Arguments
- `principals::Vector{Float64}`: A vector of principal amounts.
- `rates::Vector{Float64}`: A vector of interest rates for each principal.
- `time_fractions::Vector{Float64}`: A vector representing the fraction of the year for each investment.
- `rate_type::Compounded`: An instance of `Compounded` specifying the frequency of compounding.

# Returns
- `Vector{Float64}`: A vector of calculated compound interest for each investment.
"""
function calculate_interest(principal, rate, time_fraction, rate_type::Compounded)
    return principal .* ((1 .+ rate ./ rate_type.frequency) .^ (rate_type.frequency .* time_fraction)) .- principal
end

"""
    calculate_interest(principals::Vector{Float64}, rates::Vector{Float64}, time_fractions::Vector{Float64}, ::Exponential) -> Vector{Float64}

Calculates exponential interest for multiple principals. This vectorized version handles multiple investments.

    # Arguments
- `principals::Vector{Float64}`: A vector of principal amounts.
- `rates::Vector{Float64}`: A vector of interest rates for each principal.
- `time_fractions::Vector{Float64}`: A vector representing the fraction of the year for each investment.

# Returns
- `Vector{Float64}`: A vector of calculated exponential interest for each investment.
"""
function calculate_interest(principal, rate, time_fraction, ::Exponential)
    return principal .* (exp.(rate .* time_fraction)) .- principal
end