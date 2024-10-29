# Test for NoHolidays calendar
@testitem "NoHolidays Calendar" begin
    using Test, Dates, BusinessDays
    calendar = NoHolidays()
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 28)) == false  # Any random date
    @test BusinessDays.isholiday(calendar, Date(2024, 12, 25)) == false  # Testing a public holiday
    @test BusinessDays.isholiday(calendar, Date(2024, 1, 1)) == false    # Testing New Year's Day
end

# Test for WeekendsOnly calendar
@testitem "WeekendsOnly Calendar" begin
    using Test, Dates, BusinessDays
    calendar = WeekendsOnly()
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 28)) == false  # Monday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 29)) == false  # Tuesday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 26)) == true   # Saturday
    @test BusinessDays.isholiday(calendar, Date(2024, 10, 27)) == true   # Sunday
end
