using Dates
using BenchmarkTools

function day_count_fraction(dates::Vector{Date})::Vector{Float64}
    return Dates.value.(diff(dates)) ./ 360
end

function day_count_fraction1(dates)
    return Dates.value.(diff(dates)) ./ 360
end

x = [Date(2019, 1, 1), Date(2019, 2, 1), Date(2019, 3, 1), Date(2019, 4, 1)]

(@benchmark day_count_fraction($x)) |> display
(@benchmark day_count_fraction1($x)) |> display
