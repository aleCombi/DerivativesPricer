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
@testset "NoShift Tests" begin
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
@testset "relative_schedule Tests" begin
    accrual_schedule = [Date(2024, 1, 1), Date(2024, 1, 15), Date(2024, 1, 31)]

    # Test with NoShift from_end = true (should return all but the first date)
    ns = NoShift(true)
    shifted_schedule = relative_schedule(accrual_schedule, ns)
    @test shifted_schedule == [Date(2024, 1, 15), Date(2024, 1, 31)]

    # Test with NoShift from_end = false (should return all but the last date)
    ns = NoShift(false)
    shifted_schedule = relative_schedule(accrual_schedule, ns)
    @test shifted_schedule == [Date(2024, 1, 1), Date(2024, 1, 15)]

    # Test with an empty accrual schedule (edge case)
    accrual_schedule = []
    shifted_schedule = relative_schedule(accrual_schedule, NoShift(true))
    @test shifted_schedule == []

    # Test with a single element schedule (edge case)
    accrual_schedule = [Date(2024, 1, 1)]
    shifted_schedule = relative_schedule(accrual_schedule, NoShift(true))
    @test shifted_schedule == []

    shifted_schedule = relative_schedule(accrual_schedule, NoShift(false))
    @test shifted_schedule == []
end