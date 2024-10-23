using BusinessDays
using Dates

# RollConvention enum from FPML
abstract type RollConvention end
struct NoRollConvention <: RollConvention end
struct EOMRollConvention <: RollConvention end

"""
    roll_date(date::Date, ::NoRollConvention)

Roll convention that adjusts a date to the last day of the month.

# Arguments
- `date`: The date to be adjusted.
- `::NoRollConvention`: No roll date convention.

# Returns
- The adjusted date as a `Date`.
"""
function roll_date(date, ::NoRollConvention)
    return date
end

"""
    roll_date(date, calendar, ::EOMRollConvention)

Roll convention that adjusts a date to the last day of the month.

# Arguments
- `date`: The date to be adjusted.
- `::EOMRollConvention`: The End-Of-Month roll convention.

# Returns
- The adjusted date as a `Date`.
"""
function roll_date(date, ::EOMRollConvention)
    return lastdayofmonth.(date)
end
