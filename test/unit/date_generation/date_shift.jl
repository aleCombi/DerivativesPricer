using Test
using Dates

# Test suite for AbstractShift-related types and functions

# Test TimeShift constructor and fields
@testitem "TimeShift Tests" begin
    using Dates
    # Test TimeShift with a day period and from_end = true
    shift_period = Day(5)
    ts = TimeShift(shift_period, true)
    @test typeof(ts) == TimeShift{Day}
    @test ts.shift == shift_period
    @test ts.from_end == true

    # Test TimeShift with a month period and from_end = false
    shift_period = Month(1)
    ts = TimeShift(shift_period, false)
    @test typeof(ts) == TimeShift{Month}
    @test ts.shift == shift_period
    @test ts.from_end == false
end

# Test NoShift constructor and fields
@testitem "NoShift Tests" begin
    # Test NoShift with from_end = true
    ns = NoShift(true)
    @test typeof(ns) == NoShift
    @test ns.from_end == true

    # Test NoShift with from_end = false
    ns = NoShift(false)
    @test typeof(ns) == NoShift
    @test ns.from_end == false

    # Test default NoShift constructor (from_end should default to true)
    ns = NoShift()
    @test ns.from_end == true
end

# Test relative_schedule function
@testitem "shifted_trimmed_schedule Tests" begin
    using Dates
    accrual_schedule = [Date(2024, 1, 1), Date(2024, 1, 15), Date(2024, 1, 31)]

    # Test with NoShift from_end = true (should return all but the first date)
    ns = NoShift(true)
    schedule_shifted = shifted_trimmed_schedule(accrual_schedule, ns)
    @test schedule_shifted == [Date(2024, 1, 15), Date(2024, 1, 31)]

    # Test with NoShift from_end = false (should return all but the last date)
    ns = NoShift(false)
    schedule_shifted = shifted_trimmed_schedule(accrual_schedule, ns)
    @test schedule_shifted == [Date(2024, 1, 1), Date(2024, 1, 15)]

    # Test with an empty accrual schedule (edge case)
    accrual_schedule = []
    schedule_shifted = shifted_trimmed_schedule(accrual_schedule, NoShift(true))
    @test schedule_shifted == []

    # Test with a single element schedule (edge case)
    accrual_schedule = [Date(2024, 1, 1)]
    schedule_shifted = shifted_trimmed_schedule(accrual_schedule, NoShift(true))
    @test schedule_shifted == []

    schedule_shifted = shifted_trimmed_schedule(accrual_schedule, NoShift(false))
    @test schedule_shifted == []
end

@testitem "shifted_schedule Tests" begin
    using Dates, BusinessDays
    accrual_schedule = [Date(2024, 1, 1), Date(2024, 1, 15), Date(2024, 1, 31)]

    # Test with TimeShift shifting by 5 days from the start of the period
    ts = TimeShift(Day(5), false)
    schedule_shifted = shifted_schedule(accrual_schedule, ts)
    @test schedule_shifted == [Date(2024, 1, 6), Date(2024, 1, 20), Date(2024, 2, 5)]

    # Test with TimeShift shifting by 10 days from the end of the period
    ts = TimeShift(Day(10), true)
    schedule_shifted = shifted_schedule(accrual_schedule, ts)
    @test schedule_shifted == [Date(2024, 1, 11), Date(2024, 1, 25), Date(2024, 2, 10)]

    # Test with TimeShift with no shift (shift period is zero)
    ts = TimeShift(Day(0), true)
    schedule_shifted = shifted_schedule(accrual_schedule, ts)
    @test schedule_shifted == accrual_schedule

    # Test BusinessDayShift shifting by 2 business days forward on a simple holiday calendar
    struct MyCustomCalendar <: HolidayCalendar end
    BusinessDays.isholiday(::MyCustomCalendar, dt::Date) = dt in [Date(2024, 1, 1), Date(2024, 1, 20)]  # Monday to Friday are working days, first and last day of the year are holidays in 2023
    calendar = MyCustomCalendar()
    bds = BusinessDayShift(2, calendar, false)
    schedule_shifted = shifted_schedule(accrual_schedule, bds)
    @test schedule_shifted == [
        Date(2024, 1, 4),  # 1st -> 2, skipping 1st (holiday)
        Date(2024, 1, 17), # 15th -> 17th, no holiday
        Date(2024, 2, 2)   # 31st -> 2nd, no holiday
    ]

    # Test BusinessDayShift shifting backward by 1 business day from end of period
    bds = BusinessDayShift(-1, calendar, true)
    schedule_shifted = shifted_schedule(accrual_schedule, bds)
    @test schedule_shifted == [
        Date(2023, 12, 29),  # 1st -> previous business day
        Date(2024, 1, 12),   # 15th -> previous business day
        Date(2024, 1, 30)    # 31st -> previous business day
    ]
end