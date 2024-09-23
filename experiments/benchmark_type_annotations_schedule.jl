using BenchmarkTools
using Dates

# Define the generate_schedule function with type annotations
function generate_schedule(start_date::Date, end_date::Date)::StepRange{Date}
    return start_date:Day(1):end_date
end

# Define a generic version of the generate_schedule function without type annotations
function generate_schedule_generic(start_date, end_date)
    return start_date:Day(1):end_date
end

# Sample data for benchmarking
start_date = Date(2023, 1, 1)
end_date = Date(2199, 12, 31)

# Benchmark the functions
println("Benchmarking generate_schedule with type annotations:")
@btime generate_schedule($start_date, $end_date)

println("Benchmarking generate_schedule_generic without type annotations:")
@btime generate_schedule_generic($start_date, $end_date)