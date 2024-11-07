@testitem "Quantlib PreviousBusinessDay" setup=[QuantlibBusinessDayConvention, QuantlibSetup] begin
    date = Date(2023, 1, 1)  # First of the year

    business_day_convention = ql.Preceding
    original_date = ql.Date(1, 1, 2023)
    ql_calendar = ql.WeekendsOnly()
    ql_calendar.addHoliday(ql.Date(1, 1, 2023))
    ql_calendar.addHoliday(ql.Date(25, 12, 2023))
    expected_date = ql_calendar.adjust(original_date, business_day_convention) |> to_julia_date
    ql_calendar.removeHoliday(ql.Date(1, 1, 2023))# add Holiday changes the calendar globally, hence it has to be undone
    ql_calendar.removeHoliday(ql.Date(25, 12, 2023))

    result = adjust_date(date, calendar, PrecedingBusinessDay()) 
    @test result == expected_date
end

@testitem "Quantlib NextBusinessDay" setup=[QuantlibBusinessDayConvention, QuantlibSetup] begin
    date = Date(2023, 12, 24)  # A Sunday
    ql_calendar = ql.WeekendsOnly()
    ql_calendar.addHoliday(ql.Date(1, 1, 2023))
    ql_calendar.addHoliday(ql.Date(25, 12, 2023))
    business_day_convention = ql.Following
    original_date = ql.Date(24, 12, 2023)
    expected_date = ql_calendar.adjust(original_date, business_day_convention) |> to_julia_date
    ql_calendar.removeHoliday(ql.Date(1, 1, 2023))# add Holiday changes the calendar globally, hence it has to be undone
    ql_calendar.removeHoliday(ql.Date(25, 12, 2023))

    result = adjust_date(date, calendar, FollowingBusinessDay())
    @test result == expected_date
end

@testitem "Quantlib Indifferent" setup=[QuantlibBusinessDayConvention, QuantlibSetup] begin
    date = Date(2023, 7, 15)  # A Saturday
    
    business_day_convention = ql.Unadjusted
    original_date = ql.Date(15, 7, 2023)
    expected_date = ql.WeekendsOnly().adjust(original_date, business_day_convention) |> to_julia_date

    result = adjust_date(date, calendar, NoneBusinessDayConvention())
    @test result == expected_date
end

@testitem "Quantlib ModifiedFollowing" setup=[QuantlibBusinessDayConvention, QuantlibSetup] begin
    date = Date(2023, 12, 31)  # A Sunday
    
    business_day_convention = ql.ModifiedFollowing
    original_date = ql.Date(31, 12, 2023)
    expected_date = ql.WeekendsOnly().adjust(original_date, business_day_convention) |> to_julia_date

    result = adjust_date(date, calendar, ModifiedFollowing())
    @test result == expected_date
end

@testitem "Quantlib ModifiedPreceding" setup=[QuantlibBusinessDayConvention, QuantlibSetup] begin
    date = Date(2023, 1, 1)  # A Sunday

    ql_calendar = ql.WeekendsOnly()
    ql_calendar.addHoliday(ql.Date(1, 1, 2023))
    ql_calendar.addHoliday(ql.Date(25, 12, 2023))

    business_day_convention = ql.ModifiedPreceding
    original_date = ql.Date(1, 1, 2023)
    expected_date = ql_calendar.adjust(original_date, business_day_convention) |> to_julia_date

    result = adjust_date(date, calendar, ModifiedPreceding())
    @test result == expected_date

    date = Date(2023, 10, 14)  # A Saturday
    original_date = ql.Date(14, 10, 2023)
    expected_date = ql_calendar.adjust(original_date, business_day_convention) |> to_julia_date
    ql_calendar.removeHoliday(ql.Date(1, 1, 2023)) # add Holiday changes the calendar globally, hence it has to be undone
    ql_calendar.removeHoliday(ql.Date(25, 12, 2023))

    result = adjust_date(date, calendar, ModifiedPreceding())
    @test result == expected_date
end