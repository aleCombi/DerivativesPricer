using Symbolics
using BenchmarkTools
using InteractiveUtils

# Define symbolic variables and create symbolic expression
@variables x
expr = x*x

# Build a callable Julia function from the symbolic expression with type annotations
# Modify how the function is built if applicable
f = build_function(expr, x, expression=Val{false})

# Manually defined function with type annotations
function g(x::Float64)::Float64
    return x*x
end

# Benchmarking both functions
benchmark_f = @benchmark f(2.0)
benchmark_g = @benchmark g(2.0)

# Print benchmark results
println("Benchmarking for f(2.0, 2.0) with type annotations: ")
println(benchmark_f)

println("\nBenchmarking for g(2.0, 2.0): ")
println(benchmark_g)

# # Introspection using @code_llvm and @code_native
# println("\nCompiled LLVM code for f([2.0, 2.0]) with type annotations:")
# @code_llvm f(2.0, 2.0)

# println("\nCompiled LLVM code for g(2.0, 2.0):")
# @code_llvm g(2.0, 2.0)

# println("\nNative assembly code for f([2.0, 2.0]) with type annotations:")
# @code_native f(2.0, 2.0)

# println("\nNative assembly code for g(2.0, 2.0):")
# @code_native g(2.0, 2.0)
