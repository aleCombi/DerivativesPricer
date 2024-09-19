using BenchmarkTools
using Dates
using IterTools: partition

# Eager version functions
function generate_schedule(start_date::Date, end_date::Date)::Vector{Date}
    return collect(start_date:Month(1):end_date)
end

function day_count_fraction(start_dates::Vector{Date}, end_dates::Vector{Date})::Vector{Float64}
    return (Dates.value.(end_dates .- start_dates)) ./ 360
end

function day_count_fraction(dates::Vector{Date})::Vector{Float64}
    return day_count_fraction(dates[1:end-1], dates[2:end])
end

function eager_process(start_date::Date, end_date::Date)::Vector{Float64}
    schedule = generate_schedule(start_date, end_date)
    return day_count_fraction(schedule)
end

# Lazy version functions
function lazy_generate_schedule(start_date::Date, end_date::Date)
    return start_date:Month(1):end_date
end

function lazy_day_count_fraction(dates::StepRange{Date})
    return (Dates.value(b - a) / 360 for (a, b) in partition(dates, 2, 1))
end

function lazy_process(start_date::Date, end_date::Date)::Vector{Float64}
    schedule = lazy_generate_schedule(start_date, end_date)
    return collect(lazy_day_count_fraction(schedule))
end

# Benchmark setup
start_date = Date(2023, 1, 1)
end_date = Date(2070, 1, 1)

# Run benchmarks
println("Eager version:")
@benchmark eager_process($start_date, $end_date)

println("Lazy version:")
@benchmark lazy_process($start_date, $end_date)