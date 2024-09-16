module RateConventions

# Export the abstract type and concrete rate types
export RateType, Linear, Compounded, calculate_interest

# Define an abstract type for rate types
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

Concrete type representing compound interest, where the interest is added to the principal after each period, and interest is calculated on the new balance.
"""
struct Compounded <: RateType end

"""
    calculate_interest(principal::Float64, rate::CalcValue, time_fraction::Float64, ::Linear) -> Float64

Calculates interest using the linear (simple) interest method. The interest is calculated as a percentage of the principal for a given time period.
Rate and return type are Float64 or symbolic expression.

# Arguments
- `principal::Float64`: The initial amount of money (the principal).
- `rate`: The interest rate to be applied.
- `time_fraction::Float64`: The fraction of the year the principal is invested for (e.g., 0.5 for 6 months).

# Returns
- The calculated simple interest.
"""
function calculate_interest(principal::Float64, rate, time_fraction::Float64, ::Linear)
    return principal * rate * time_fraction
end

"""
    calculate_interest(principal::Float64, rate::CalcValue, time_fraction::Float64, frequency::Int, ::Compounded) -> Float64

Calculates interest using the compound interest method. The interest is calculated on the principal and accumulated interest over multiple periods.
Rate and return type are Float64 or symbolic expression.

# Arguments
- `principal::Float64`: The initial amount of money (the principal).
- `rate`: The interest rate to be applied.
- `time_fraction::Float64`: The fraction of the year the principal is invested for (e.g., 0.5 for 6 months).
- `frequency::Int`: The number of compounding periods per year (e.g., 12 for monthly compounding).

# Returns
- The calculated compound interest.
"""
function calculate_interest(principal::Float64, rate, time_fraction::Float64, frequency::Int, ::Compounded)
    return principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
end

end