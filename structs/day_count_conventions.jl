module DayCount

"""
    DayCountConvention

Abstract type representing a day count convention. This serves as the base type for all specific day count conventions.
"""
abstract type DayCountConvention end

# Export the abstract type and concrete types
export DayCountConvention, ACT360, ACT365, ISDA_30_360, day_count_fraction

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
    ISDA_30_360 <: DayCountConvention

Concrete type representing the ISDA 30/360 day count convention, where months are considered to have 30 days and years 360 days, with specific adjustments for end-of-month dates.
"""
struct ISDA_30_360 <: DayCountConvention end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ACT360) -> Float64

Calculates the day count fraction between two dates according to the ACT/360 convention. The number of days is divided by 360.

# Arguments
- `start_date::Date`: The start date.
- `end_date::Date`: The end date.
- `::ACT360`: The ACT/360 convention type.

# Returns
- `Float64`: The day count fraction based on ACT/360.
"""
function day_count_fraction(start_date::Date, end_date::Date, ::ACT360)
    days = Dates.value(end_date - start_date)
    return days / 360
end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ACT365) -> Float64

Calculates the day count fraction between two dates according to the ACT/365 convention. The number of days is divided by 365.

# Arguments
- `start_date::Date`: The start date.
- `end_date::Date`: The end date.
- `::ACT365`: The ACT/365 convention type.

# Returns
- `Float64`: The day count fraction based on ACT/365.
"""
function day_count_fraction(start_date::Date, end_date::Date, ::ACT365)
    days = Dates.value(end_date - start_date)
    return days / 365
end

"""
    day_count_fraction(start_date::Date, end_date::Date, ::ISDA_30_360) -> Float64

Calculates the day count fraction between two dates according to the ISDA 30/360 convention. Both months are considered to have 30 days and years 360 days, with adjustments for months that have 31 days.

# Arguments
- `start_date::Date`: The start date.
- `end_date::Date`: The end date.
- `::ISDA_30_360`: The ISDA 30/360 convention type.

# Returns
- `Float64`: The day count fraction based on ISDA 30/360.
"""
function day_count_fraction(start_date::Date, end_date::Date, ::ISDA_30_360)
    y1, m1, d1 = Dates.year(start_date), Dates.month(start_date), Dates.day(start_date)
    y2, m2, d2 = Dates.year(end_date), Dates.month(end_date), Dates.day(end_date)

    if d1 == 31
        d1 = 30
    end
    if d2 == 31 && d1 == 30
        d2 = 30
    end

    adjusted_days = (y2 - y1) * 360 + (m2 - m1) * 30 + (d2 - d1)
    return adjusted_days / 360
end

end
