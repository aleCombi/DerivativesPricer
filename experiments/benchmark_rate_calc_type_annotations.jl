using BenchmarkTools
using Symbolics

# Define the calculate_interest function with type annotations
function calculate_interest(principal::Float64, rate::Float64, time_fraction::Float64)
    return principal * rate * time_fraction
end

# Define a vectorized version of the calculate_interest function with type annotations
function calculate_interest_vectorized(principals::Vector{Float64}, rates::Vector{Float64}, time_fractions::Vector{Float64})
    return principals .* rates .* time_fractions
end

# Define generic counterparts without type annotations
function calculate_interest_generic(principal, rate, time_fraction)
    return principal * rate * time_fraction
end

function calculate_interest_vectorized_generic(principals, rates, time_fractions)
    return principals .* rates .* time_fractions
end

# Define a version with a symbolic rate
function calculate_interest_symbolic(principal::Float64, rate::Num, time_fraction::Float64)
    return principal * rate * time_fraction
end

# Define a vectorized version with a symbolic rate
function calculate_interest_vectorized_symbolic(principals::Vector{Float64}, rates::Vector{Num}, time_fractions::Vector{Float64})
    return principals .* rates .* time_fractions
end

# Sample data for benchmarking
principal = 1000.0
rate = 0.05
time_fraction = 0.25

principals = rand(1000) .* 1000
rates = rand(1000) .* 0.1
time_fractions = rand(1000) .* 0.5

# Symbolic rate
@variables symbolic_rate
symbolic_rates = [symbolic_rate for _ in 1:1000]

# Benchmark the functions
println("Benchmarking calculate_interest:")
@btime calculate_interest($principal, $rate, $time_fraction)

println("Benchmarking calculate_interest_vectorized:")
@btime calculate_interest_vectorized($principals, $rates, $time_fractions)

println("Benchmarking calculate_interest_generic:")
@btime calculate_interest_generic($principal, $rate, $time_fraction)

println("Benchmarking calculate_interest_vectorized_generic:")
@btime calculate_interest_vectorized_generic($principals, $rates, $time_fractions)

println("Benchmarking calculate_interest_symbolic:")
@btime calculate_interest_symbolic($principal, $symbolic_rate, $time_fraction)

println("Benchmarking calculate_interest_generic with symbolic rate:")
@btime calculate_interest_generic($principal, $symbolic_rate, $time_fraction)

println("Benchmarking calculate_interest_vectorized_symbolic:")
@btime calculate_interest_vectorized_symbolic($principals, $symbolic_rates, $time_fractions)

println("Benchmarking calculate_interest_vectorized_generic with symbolic rate:")
@btime calculate_interest_vectorized_generic($principals, $symbolic_rates, $time_fractions)