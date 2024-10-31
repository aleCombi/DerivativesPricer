
using Dates
using BusinessDays
using PyCall
ql = pyimport("QuantLib")

function julia_date_to_ql(date::Date)
    return ql.Date(day(date), month(date), year(date))
end

# Helper function to generate QuantLib schedule for comparison
function generate_quantlib_schedule(
    start_date::Date, 
    end_date::Date, 
    period::Period, 
    calendar, 
    roll_convention, 
    business_day_convention, 
    termination_bd_convention, 
    stub_position;
    first_date=nothing,
    next_to_last_date=nothing)

    # Convert Julia Dates to QuantLib Dates
    ql_start = ql.Date(day(start_date), month(start_date), year(start_date))
    ql_end = ql.Date(day(end_date), month(end_date), year(end_date))
    
    ql_first_date = ql.Date()
    if !isnothing(first_date)
        ql_first_date = julia_date_to_ql(first_date) 
    end

    ql_next_to_last_date = ql.Date()
    if !isnothing(next_to_last_date)
        ql_next_to_last_date = julia_date_to_ql(next_to_last_date) 
    end

    # Set up QuantLib period
    ql_period = ql.Period(period.value, ql.Months)  # Assuming period is of type Month for this function

    # Set up QuantLib calendar
    ql_calendar = if calendar === calendar_weekends
        ql.WeekendsOnly()
    else
        ql.UnitedStates(ql.UnitedStates.GovernmentBond)
    end

    # Set up QuantLib roll convention
    end_of_month = roll_convention isa EOMRollConvention

    # Set up QuantLib business day conventions
    ql_business_day_convention = if business_day_convention isa FollowingBusinessDay
        ql.Following
    elseif business_day_convention isa PrecedingBusinessDay
        ql.Preceding
    elseif business_day_convention isa ModifiedFollowing
        ql.ModifiedFollowing
    elseif business_day_convention isa ModifiedPreceding
        ql.ModifiedPreceding
    elseif business_day_convention isa NoneBusinessDayConvention
        ql.None
    else
        error("Unsupported business day convention")
    end

    ql_termination_bd_convention = if termination_bd_convention isa FollowingBusinessDay
        ql.Following
    elseif termination_bd_convention isa PrecedingBusinessDay
        ql.Preceding
    elseif termination_bd_convention isa ModifiedFollowing
        ql.ModifiedFollowing
    elseif termination_bd_convention isa ModifiedPreceding
        ql.ModifiedPreceding
    elseif termination_bd_convention isa NoneBusinessDayConvention
        ql.Unadjusted
    else
        error("Unsupported termination business day convention")
    end

    # Stub positioning
    ql_stub = if stub_position isa InArrearsStubPosition
        ql.DateGeneration.Forward
    elseif stub_position isa UpfrontStubPosition
        ql.DateGeneration.Backward
    else
        error("Unsupported stub position")
    end

    # Generate the QuantLib schedule
    ql_schedule = ql.Schedule(
        ql_start, 
        ql_end, 
        ql_period, 
        ql_calendar, 
        ql_business_day_convention, 
        ql_termination_bd_convention, 
        ql_stub,
        end_of_month,
        ql_first_date,
        ql_next_to_last_date
    )
    
    # Convert QuantLib Dates back to Julia Dates
    return [Date(dt.year(), dt.month(), dt.dayOfMonth()) for dt in ql_schedule]
end
calendar_weekends = WeekendsOnly()
calendar_us = BusinessDays.USGovernmentBond()