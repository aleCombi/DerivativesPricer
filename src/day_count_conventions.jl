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
@inline function day_count_fraction(start_date, end_date, ::ACT360)
    return Dates.value(end_date - start_date) / 360
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
@inline function day_count_fraction(start_dates::Vector{T}, end_dates::Vector{T}, ::ACT360) where T
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
@inline function day_count_fraction(dates, ::ACT360)
    return Dates.value.(diff(dates)) ./ 360
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
@inline function day_count_fraction(start_date, end_date, ::ACT365)
    return Dates.value(end_date - start_date) / 365
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
@inline function day_count_fraction(start_dates::Vector{T}, end_dates::Vector{T}, ::ACT365) where T
    return (Dates.value.(end_dates .- start_dates)) ./ 365
end

"""
    day_count_fraction(dates::Vector{Date}, ::ACT365) -> Vector{Float64}

Calculates the day count fractions between consecutive dates in a vector according to the ACT/365 convention.

# Arguments
- `dates::Vector{Date}`: A vector of dates.
- `::ACT365`: The ACT/365 convention type.

# Returns
- `Vector{Float64}`: A vector of day count fractions for each consecutive pair of dates, calculated according to the ACT/365 convention.
"""
@inline function day_count_fraction(dates, ::ACT365)
    return Dates.value.(diff(dates)) ./ 365
end