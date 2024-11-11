@testsnippet QuantlibBusinessDayConvention begin
    using Dates
    using BusinessDays
    using Hedgehog
    using PyCall

    # Define a custom calendar with weekends, Christmas and New Year
    struct CustomCalendar <: HolidayCalendar end
    BusinessDays.isholiday(::CustomCalendar, dt::Date) = dt in [Date(2023, 1, 1), Date(2023, 12, 25)] || dayofweek(dt) in [6, 7]  # Monday to Friday are working days, first and last day of the year are holidays in 2023
    calendar = CustomCalendar()
end

@testsnippet QuantlibSetup begin
    using Dates
    using BusinessDays
    using PyCall
    ql = pyimport("QuantLib")

    to_julia_date(ql_date) = Date(Int(ql_date.year()), Int(ql_date.month()), Int(ql_date.dayOfMonth()))
    to_ql_date(julia_date) = ql.Date(day(julia_date), month(julia_date), year(julia_date))

    to_ql_business_day_convention(::FollowingBusinessDay) = ql.Following
    to_ql_business_day_convention(::PrecedingBusinessDay) = ql.Preceding
    to_ql_business_day_convention(::ModifiedPreceding) = ql.ModifiedPreceding
    to_ql_business_day_convention(::NoneBusinessDayConvention) = ql.Unadjusted
    to_ql_business_day_convention(::ModifiedFollowing) = ql.ModifiedFollowing

    to_ql_date_generation(::InArrearsStubPosition) = ql.DateGeneration.Forward
    to_ql_date_generation(::UpfrontStubPosition) = ql.DateGeneration.Backward

    to_ql_calendar(::WeekendsOnly) = ql.WeekendsOnly()
    to_ql_calendar(::BusinessDays.USGovernmentBond) = ql.UnitedStates(ql.UnitedStates.GovernmentBond)
    to_ql_calendar(::BusinessDays.TARGET) = ql.TARGET()
    to_ql_day_count(::ACT360) = ql.Actual360()
    to_ql_day_count(::ACT365) = ql.Actual365Fixed()
    # Helper function to generate QuantLib schedule for comparison
    function get_quantlib_schedule(
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

        # Setting first date and penultimate date, this is how quantlib does long stubs
        ql_first_date = isnothing(first_date) ? ql.Date() : to_ql_date(first_date)
        ql_next_to_last_date = isnothing(next_to_last_date) ? ql.Date() : to_ql_date(next_to_last_date)

        # settings ql schedule arguments
        ql_start = to_ql_date(start_date)
        ql_end = to_ql_date(end_date)
        ql_period = ql.Period(period.value, ql.Months)  # Assuming period is of type Month for this function
        ql_calendar = to_ql_calendar(calendar)
        end_of_month = roll_convention isa EOMRollConvention
        ql_business_day_convention = to_ql_business_day_convention(business_day_convention)
        ql_termination_bd_convention = to_ql_business_day_convention(termination_bd_convention)
        ql_date_generation_direction = to_ql_date_generation(stub_position)

        # Generate the QuantLib schedule
        ql_schedule = ql.Schedule(
            ql_start,
            ql_end,
            ql_period,
            ql_calendar,
            ql_business_day_convention,
            ql_termination_bd_convention,
            ql_date_generation_direction,
            end_of_month,
            ql_first_date,
            ql_next_to_last_date
        )

        return ql_schedule
    end

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
        ql_schedule = get_quantlib_schedule(start_date, end_date, period, calendar, roll_convention, business_day_convention, termination_bd_convention, stub_position; first_date=first_date, next_to_last_date=next_to_last_date)
        return [to_julia_date(dt) for dt in ql_schedule]
    end
end
