using DerivativesPricer
using Dates

start_date = Date(2022,1,1)
end_date = Date(2022,10,1)
day_count = day_count_fraction(start_date, end_date, ACT360()) 
println(day_count)