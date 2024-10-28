# Test for WeekendsOnly calendar
@testitem "Quantlib WeekendsOnly Calendar" begin
    using Test, Dates, BusinessDays, PyCall
    ql = pyimport("QuantLib")
    ql_calendar = ql.WeekendsOnly()
    calendar = WeekendsOnly()
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 28)) == ql_calendar.isHoliday(ql.Date(28,10,2024))  # Monday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 29)) == ql_calendar.isHoliday(ql.Date(29,10,2024))  # Tuesday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 26)) == ql_calendar.isHoliday(ql.Date(26,10,2024))   # Saturday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 27)) == ql_calendar.isHoliday(ql.Date(27,10,2024))   # Sunday
end