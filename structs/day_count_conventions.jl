module DayCount

# Export the abstract type and concrete types
export DayCountConvention, ACT360, ACT365, ISDA_30_360, day_count_fraction

abstract type DayCountConvention end

# Define types for specific day count conventions
struct ACT360 <: DayCountConvention end
struct ACT365 <: DayCountConvention end
struct ISDA_30_360 <: DayCountConvention end

# Multiple dispatch: Define day count fraction function for ACT360
function day_count_fraction(start_date::Date, end_date::Date, ::ACT360)
    days = Dates.value(end_date - start_date)
    return days / 360
end

# Multiple dispatch: Define day count fraction function for ACT365
function day_count_fraction(start_date::Date, end_date::Date, ::ACT365)
    days = Dates.value(end_date - start_date)
    return days / 365
end

# Multiple dispatch: Define day count fraction function for ISDA 30/360
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

end  # End of module