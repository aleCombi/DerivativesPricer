using BenchmarkTools
using Dates

function day_count_fraction_vect(start_dates::Vector{T}, end_dates::Vector{T}) where T
    return (Dates.value.(end_dates .- start_dates)) ./ 360
end

function day_count_fraction_generic(start_dates, end_dates)
    return (Dates.value.(end_dates .- start_dates)) ./ 360
end

start_dates = [Date(2017,1,1), Date(2017,2,1), Date(2017,3,1)]
end_dates = [Date(2017,2,1), Date(2017,3,1), Date(2017,4,1)]

y = @benchmark day_count_fraction_vect($start_dates, $end_dates)
display(y)
x = @benchmark day_count_fraction_generic($start_dates, $end_dates)
display(x)

y = @benchmark day_count_fraction_vect($start_dates, $end_dates)
display(y)
x = @benchmark day_count_fraction_generic($start_dates, $end_dates)
display(x)