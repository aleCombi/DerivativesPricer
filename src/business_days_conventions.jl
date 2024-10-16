using BusinessDays
using Dates

# Check 
# <xsd:element name="businessDayConvention" type="BusinessDayConventionEnum"/> on ISDA FPML documentation (https://www.fpml.org/spec/fpml-5-12-4-rec-1/html/confirmation/schemaDocumentation/index.html)
# It would be useful to have the same naming as ISDA FPML to make it easier to understand the code.

"""
    BusinessDayConvention

Abstract type representing a roll convention for adjusting dates to business days.
"""
abstract type BusinessDayConvention end

"""
    PrecedingBusinessDay <: BusinessDayConvention

Roll convention that adjusts a date to the previous business day.
"""
struct PrecedingBusinessDay <: BusinessDayConvention end

"""
    FollowingBusinessDay <: BusinessDayConvention

Roll convention that adjusts a date to the next business day.
"""
struct FollowingBusinessDay <: BusinessDayConvention end

"""
    ModifiedFollowing <: BusinessDayConvention

Roll convention that adjusts a date to the next business day, unless it falls in the next month, in which case it adjusts to the previous business day.
"""
struct ModifiedFollowing <: BusinessDayConvention end

"""
    NoneBusinessDayConvention <: BusinessDayConvention

Roll convention that does not adjust the date.
"""
struct NoneBusinessDayConvention <: BusinessDayConvention end

"""
    ModifiedPreceding <: BusinessDayConvention

Roll convention that adjusts a date to the previous business day, unless it falls in the previous month, in which case it adjusts to the next business day.
"""
struct ModifiedPreceding <: BusinessDayConvention end

"""
    roll_date(date, calendar, ::PreviousBusinessDay) -> Date

Adjusts the given date to the previous business day according to the specified calendar.

# Arguments
- `date`: The date to be adjusted.
- `calendar`: The business days calendar to use for adjustment.

# Returns
- The adjusted date as a `Date`.
"""
function adjust_date(date, calendar, ::PrecedingBusinessDay)
    return tobday(calendar, date; forward=false)
end

"""
    roll_date(date, calendar, ::NextBusinessDay) -> Date

Adjusts the given date to the next business day according to the specified calendar.

# Arguments
- `date`: The date to be adjusted.
- `calendar`: The business days calendar to use for adjustment.

# Returns
- The adjusted date as a `Date`.
"""
function adjust_date(date, calendar, ::FollowingBusinessDay)
    return tobday(calendar, date; forward=true)
end

"""
    roll_date(date, calendar, ::Indifferent) -> Date

Returns the given date without any adjustment.

# Arguments
- `date`: The date to be returned.
- `calendar`: The business days calendar (not used in this function).

# Returns
- The original date as a `Date`.
"""
function adjust_date(date, calendar, ::NoneBusinessDayConvention)
    return date
end

"""
    roll_date(date, calendar, ::ModifiedFollowing) -> Date

Adjusts the given date to the next business day according to the specified calendar, unless it falls in the next month, in which case it adjusts to the previous business day.

# Arguments
- `date`: The date to be adjusted.
- `calendar`: The business days calendar to use for adjustment.

# Returns
- The adjusted date as a `Date`.
"""
function adjust_date(date, calendar, ::ModifiedFollowing)
    next_business_day = tobday(calendar, date; forward=true)
    if month(next_business_day) != month(date)
        return tobday(calendar, date; forward=false)
    else
        return next_business_day
    end
end

"""
    roll_date(date, calendar, ::ModifiedPreceding) -> Date

Adjusts the given date to the previous business day according to the specified calendar, unless it falls in the previous month, in which case it adjusts to the following business day.

# Arguments
- `date`: The date to be adjusted.
- `calendar`: The business days calendar to use for adjustment.

# Returns
- The adjusted date as a `Date`.
"""
function adjust_date(date, calendar, ::ModifiedPreceding)
    previous_business_day = tobday(calendar, date; forward=false)
    if month(previous_business_day) != month(date)
        return tobday(calendar, date; forward=true)
    else
        return previous_business_day
    end
end

