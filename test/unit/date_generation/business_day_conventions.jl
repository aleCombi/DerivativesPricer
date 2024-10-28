@testsnippet BusinessDayConvention begin
    using Dates
    using BusinessDays
    using DerivativesPricer

    # Define a mock calendar
    struct CustomCalendar <: HolidayCalendar end
    BusinessDays.isholiday(::CustomCalendar, dt::Date) = dt in [Date(2023, 1, 1), Date(2023, 12, 25)] || dayofweek(dt) in [6, 7]  # Monday to Friday are working days, first and last day of the year are holidays in 2023
    calendar = CustomCalendar()
end

@testitem "PreviousBusinessDay" setup=[BusinessDayConvention] begin
    date = Date(2023, 1, 1)  # First of the year
    expected_date = Date(2022, 12, 30)  # Previous Friday
    result = adjust_date(date, calendar, PrecedingBusinessDay())
    @test result == expected_date
end

@testitem "NextBusinessDay" setup=[BusinessDayConvention] begin
    date = Date(2023, 12, 24)  # A Sunday
    expected_date = Date(2023, 12, 26)  # Next Tuesday (25th is a holiday)
    result = adjust_date(date, calendar, FollowingBusinessDay())
    @test result == expected_date
end

@testitem "Indifferent" setup=[BusinessDayConvention] begin
    date = Date(2023, 7, 15)  # A Saturday
    expected_date = date  # No adjustment
    result = adjust_date(date, calendar, NoneBusinessDayConvention())
    @test result == expected_date
end

@testitem "ModifiedFollowing" setup=[BusinessDayConvention] begin
    date = Date(2023, 12, 31)  # A Sunday
    expected_date = Date(2023, 12, 29)  # Previous Friday (next business day is in the next month)
    result = adjust_date(date, calendar, ModifiedFollowing())
    @test result == expected_date
end

@testitem "ModifiedPreceding" setup=[BusinessDayConvention] begin
    date = Date(2023, 1, 1)  # A Sunday
    expected_date = Date(2023, 1, 2)  # Next monday (next business day is in the next month)
    result = adjust_date(date, calendar, ModifiedPreceding())
    @test result == expected_date

    date = Date(2023, 10, 14)  # A Saturday
    expected_date = Date(2023, 10, 13)  # Previous Friday
    result = adjust_date(date, calendar, ModifiedPreceding())
    @test result == expected_date
end