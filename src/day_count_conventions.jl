module DayCount

using Dates

"""
    DayCountConvention

Abstract type representing a day count convention. This serves as the base type for all specific day count conventions.
"""
abstract type DayCountConvention end

# Export the abstract type and concrete types
export DayCountConvention, ACT360, ACT365, day_count_fraction

"""
    ACT360 <: DayCountConvention

Concrete type representing the ACT/360 day count convention, where the actual number of days between two dates is divided by 360.
"""
struct ACT360 <: DayCountConvention end

"""
    ACT365 <: DayCountConvention

Concrete type representing the ACT/365 day count convention, where the actual number of days between two dates is divided by 365.
"""
struct ACT365 <: DayCountConvention end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ACT360) -> Float64

Calculates the day count fraction between two dates according to the ACT/360 convention. The number of days between the two dates is divided by 360.

# Arguments
- `start_date::Date`: The start date.
- `end_date::Date`: The end date.
- `::ACT360`: The ACT/360 convention type.

# Returns
- `Float64`: The day count fraction calculated according to the ACT/360 convention.
"""
function day_count_fraction(start_date::Date, end_date::Date, ::ACT360)
    days = Dates.value(end_date - start_date)
    return days / 360
end

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
function day_count_fraction(start_dates::Vector{Date}, end_dates::Vector{Date}, ::ACT360)::Vector{Float64}
    return (Dates.value.(end_dates .- start_dates)) ./ 360
end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ACT365) -> Float64

Calculates the day count fraction between two dates according to the ACT/365 convention. The number of days between the two dates is divided by 365.

# Arguments
- `start_date::Date`: The start date.
- `end_date::Date`: The end date.
- `::ACT365`: The ACT/365 convention type.

# Returns
- `Float64`: The day count fraction calculated according to the ACT/365 convention.
"""
function day_count_fraction(start_date::Date, end_date::Date, ::ACT365)
    days = Dates.value(end_date - start_date)
    return days / 365
end

"""
    day_count_fraction(start_dates::Vector{Date}, end_dates::Vector{Date}, ::ACT365) -> Vector{Float64}

Calculates the day count fractions between multiple pairs of start and end dates according to the ACT/365 convention.

# Arguments
- `start_dates::Vector{Date}`: A vector of start dates.
- `end_dates::Vector{Date}`: A vector of end dates.
- `::ACT365`: The ACT/365 convention type.

# Returns
- `Vector{Float64}`: A vector of day count fractions for each pair of dates, calculated according to the ACT/365 convention.
"""
function day_count_fraction(start_dates::Vector{Date}, end_dates::Vector{Date}, ::ACT365)::Vector{Float64}
    return (Dates.value.(end_dates .- start_dates)) ./ 365
end

"""
    day_count_fraction(dates::Vector{Date}, ::DayCountConvention) -> Vector{Float64}

Calculates the day count fractions between consecutive dates in the input vector according to the specified day count convention.

# Arguments
- `dates::Vector{Date}`: A vector of dates.
- `::DayCountConvention`: The day count convention to use (e.g., ACT/360, ACT/365).

# Returns
- `Vector{Float64}`: A vector of day count fractions calculated between consecutive dates according to the provided convention.
"""
function day_count_fraction(dates::Vector{Date}, day_count_convention::DayCountConvention)::Vector{Float64}
    return day_count_fraction(dates[1:end-1], dates[2:end], day_count_convention)
end

end