using Symbolics
using BenchmarkTools

# Define symbolic variables and create symbolic expression
@variables x y
expr = x^2 + 3x + y

# Build a callable Julia function from the symbolic expression
# Convert the returned object to an actual Julia function (if needed)
f = eval(build_function(expr, [x, y]; type_annotations=[Float64, Float64]))

function g(x::Float64, y::Float64)::Float64
    return x^2 + 3x + y
end

benchmark_f = @benchmark f([2.0, 2.0])
benchmark_g = @benchmark g(2.0, 2.0)

# Print the results
println("Benchmarking for f(2,2): ", benchmark_f)
println("Benchmarking for g(2,2): ", benchmark_g)