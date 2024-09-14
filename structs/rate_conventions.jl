module RateType

using Types

# Define an abstract type for rate types
abstract type RateType end

# Export the abstract type and concrete rate types
export RateType, LIN, COM, calculate_interest

# Define rate types: Linear Interest (LIN) and Compound Interest (COM)
struct LIN <: RateType end  # Linear (simple) interest
struct COM <: RateType end  # Compound interest

# Multiple dispatch: Define the interest calculation for LIN (simple interest)
function calculate_interest(principal::Float64, rate::CalcValue, time_fraction::Float64, ::LIN)
    return principal * rate * time_fraction
end

# Multiple dispatch: Define the interest calculation for COM (compound interest)
function calculate_interest(principal::Float64, rate::CalcValue, time_fraction::Float64, frequency::Int, ::COM)
    return principal * (1 + rate / frequency)^(frequency * time_fraction) - principal
end

end  # End of module