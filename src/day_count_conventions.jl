using Dates

"""
    DayCountConvention

Abstract type representing a day count convention. This serves as the base type for all specific day count conventions.
"""
abstract type DayCountConvention end

"""
    ACT360 <: DayCountConvention

Concrete type representing the ACT/360 day count convention, where the actual number of days between two dates is divided by 360.
"""
struct ACT360 <: DayCountConvention end

"""
    day_count_fraction(start_dates::Vector{Date}, end_dates::Vector{Date}, ::ACT360) -> Vector{Float64}

Calculates the day count fractions between multiple pairs of start and end dates according to the ACT/360 convention.

# Arguments
- `start_dates::Vector{Date}`: A vector of start dates.
- `end_dates::Vector{Date}`: A vector of end dates.
- `::ACT360`: The ACT/360 convention type.

# Returns
- `Vector{Float64}`: A vector of day count fractions for each pair of dates, calculated according to the ACT/360 convention.
"""
function day_count_fraction(start_dates, end_dates, ::ACT360)
    return (Dates.value.(end_dates .- start_dates)) ./ 360
end

"""
    day_count_fraction(dates::Vector{Date}, ::ACT360) -> Vector{Float64}

Calculates the day count fractions between consecutive dates in a vector according to the ACT/360 convention.

# Arguments
- `dates::Vector{Date}`: A vector of dates.
- `::ACT360`: The ACT/360 convention type.

# Returns
- `Vector{Float64}`: A vector of day count fractions for each consecutive pair of dates, calculated according to the ACT/360 convention.
"""
function day_count_fraction(dates, ::ACT360)
    return Dates.value.(diff(dates)) ./ 360
end

"""
    ACT365 <: DayCountConvention

Concrete type representing the ACT/365 day count convention, where the actual number of days between two dates is divided by 365.
"""
struct ACT365 <: DayCountConvention end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ACT365) -> Float64

Calculates the day count fraction between two dates according to the ACT/365 convention. The number of days between the two dates is divided by 365.

# Arguments
- `start_date`: The start date.
- `end_date`: The end date.
- `::ACT365`: The ACT/365 convention type.

# Returns
- The day count fraction calculated according to the ACT/365 convention.
"""
function day_count_fraction(start_date, end_date, ::ACT365)
    return Dates.value.(end_date .- start_date) / 365
end

"""
    day_count_fraction(dates, ::ACT365) -> Vector{Float64}

Calculates the day count fractions between consecutive dates in a vector according to the ACT/365 convention.

# Arguments
- `dates`: A vector of dates.
- `::ACT365`: The ACT/365 convention type.

# Returns
- A vector of day count fractions for each consecutive pair of dates, calculated according to the ACT/365 convention.
"""
function day_count_fraction(dates, ::ACT365)
    return Dates.value.(diff(dates)) ./ 365
end

"""
    DayCount30360 <: DayCountConvention

Concrete type representing the 30/360 day count convention, where the number of days between two dates is calculated as the difference in days, months, and years, and then divided by 360.

The day count is calculated as follows:
- The number of days is the difference in days between the two dates.
- The number of months is the difference in months between the two dates.
- The number of years is the difference in years between the two dates.
- The day count is then calculated as `(years * 360 + months * 30 + days) / 360`.
"""
struct DayCount30360 <: DayCountConvention end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::DayCount30360) -> Float64

Calculates the day count fraction between two dates according to the 30/360 convention. The day count is calculated as the difference in days, months, and years between the two dates, divided by 360.

# Arguments
- `start_date`: The start date.
- `end_date`: The end date.
- `::DayCount30360`: The 30/360 convention type.

# Returns
- The day count fraction calculated according to the 30/360 convention.
"""
function day_count_fraction(start_date, end_date, ::DayCount30360)
    year_diff = Dates.year(end_date) - Dates.year(start_date)
    month_diff = Dates.month(end_date) - Dates.month(start_date)
    day_diff = Dates.day(end_date) - Dates.day(start_date)
    return (year_diff * 360 + month_diff * 30 + day_diff) / 360
end

"""
    day_count_fraction(dates, ::DayCount30360) -> Vector{Float64}

Calculates the day count fractions between consecutive dates in a vector according to the 30/360 convention.

# Arguments
- `dates`: A vector of dates.
- `::DayCount30360`: The 30/360 convention type.

# Returns
- A vector of day count fractions for each consecutive pair of dates, calculated according to the 30/360 convention.
"""
function day_count_fraction(dates, ::DayCount30360)
    return [day_count_fraction(dates[i], dates[i + 1], DayCount30360()) for i in 1:length(dates) - 1]
end