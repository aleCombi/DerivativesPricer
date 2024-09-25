using BenchmarkTools

# Define the two approaches

# Approach using slicing (ranges)
function ratios_using_ranges(v)
    return v[2:end] ./ v[1:end-1]
end

# Approach using map!
function ratios_using_map!(v)
    ratios = Vector{Float64}(undef, length(v) - 1)
    map!(x -> v[x+1] / v[x], ratios, 1:length(v)-1)
end

# Approach using map!
function ratios_using_map(v)
    map(x -> v[x+1] / v[x], 1:length(v)-1)
end

function diff_using_map(v)
    map(x -> v[x+1] - v[x], 1:length(v)-1)
end

# Approach using map!
function ratios_mult_using_map(v, u)
    map(x -> v[x+1] / v[x] * u[x], 1:length(v)-1)
end

function ratio_mult_using_broadcast(v, u)
    map(x -> v[x+1] / v[x], 1:length(v)-1) .* u
end

# Benchmark the two methods
function benchmark_ratios()
    v = rand(1_000_000)  # Large vector with 1 million elements    
    u = rand(1_000_000 - 1)  # Large vector with 1 million - 1 elements    

    println("Benchmarking map approach...")
    @btime ratios_mult_using_map($v, $u)

    println("Benchmarking broadcast approach...")
    @btime ratio_mult_using_broadcast($v, $u)
end

# Run the benchmark
benchmark_ratios()
