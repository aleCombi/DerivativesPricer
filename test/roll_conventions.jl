@testsnippet RollConventions begin
    using Dates
end


@testitem "NoRollConvention" setup=[RollConventions] begin
    date = Date(2023, 7, 15)  # Any date
    expected_date = date  # No adjustment
    result = roll_date(date, NoRollConvention())
    @test result == expected_date
end

@testitem "EOMRollConvention" setup=[RollConventions] begin
    date = Date(2023, 7, 15)  # Any date in July
    expected_date = Date(2023, 7, 31)  # Last day of July
    result = roll_date(date, EOMRollConvention())
    @test result == expected_date

    date = Date(2023, 2, 10)  # Any date in February
    expected_date = Date(2023, 2, 28)  # Last day of February (non-leap year)
    result = roll_date(date, EOMRollConvention())
    @test result == expected_date

    date = Date(2024, 2, 10)  # Any date in February
    expected_date = Date(2024, 2, 29)  # Last day of February (leap year)
    result = roll_date(date, EOMRollConvention())
    @test result == expected_date
end