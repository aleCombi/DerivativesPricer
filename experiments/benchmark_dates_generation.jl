using Dates
using BenchmarkTools
using Base.Iterators
 
# Your functions here
function generate_schedules_0(start_date, end_date)
    accrual = start_date:Month(1):end_date
    pay = accrual[2:end] + Day(1)
    fixing = accrual[2:end] - Day(1)
    return collect(accrual), collect(pay), collect(fixing)
end

function generate_schedules_1(start_date, end_date)
    accrual = collect(start_date:Month(1):end_date)
    
    n = length(accrual) - 1
    fixing = Vector{Date}(undef, n)
    pay = Vector{Date}(undef, n)

    for (i, d) in enumerate(accrual[2:end])
        fixing[i] = d - Day(1)
        pay[i] = d + Day(1)
    end

    return accrual, pay, fixing
end

using Base.Iterators

function generate_schedules_opt5(start_date, end_date)
    accrual = start_date:Month(1):end_date

    # Create lazy iterators for pay and fixing
    pay = map(d -> d + Day(1), accrual[2:end])
    fixing = map(d -> d - Day(1), accrual[2:end])

    return collect(accrual), collect(pay), collect(fixing)
end

function generate_schedules_broadcasting(start_date, end_date)
    accrual = collect(start_date:Month(1):end_date)  # Collect once

    # Generate `pay` and `fixing` using broadcasting
    pay = accrual[2:end] .+ Day(1)
    fixing = accrual[2:end] .- Day(1)

    return pay, fixing
end

# Define the start and end dates
start_date = Date(2011,1,1)
end_date = Date(2012,1,1)

# Benchmark the two functions
benchmark_0 = @benchmark generate_schedules_0($start_date, $end_date)
benchmark_1 = @benchmark generate_schedules_1($start_date, $end_date)
benchmark_2 = @benchmark generate_schedules_opt5($start_date, $end_date)
benchmark_3 = @benchmark generate_schedules_broadcasting($start_date, $end_date)

println("Benchmark for generate_schedules_0:")
display(benchmark_0)

println("\nBenchmark for generate_schedules_1:")
display(benchmark_1)

println("\nBenchmark for generate_schedules_opt5:")
display(benchmark_2)

println("\nBenchmark for generate_schedules_broadcasting:")
display(benchmark_3)