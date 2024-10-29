using Dates
using Test

# Test 1: InstrumentSchedule creation with default NoShift
@testitem "InstrumentSchedule Creation - Default NoShift" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    period = Month(1)
    schedule_config = ScheduleConfig(period)

    # Create InstrumentSchedule with default NoShift
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # Verify fields and default pay shift
    @test instrument_schedule.start_date == start_date
    @test instrument_schedule.end_date == end_date
    @test instrument_schedule.schedule_config == schedule_config
    @test instrument_schedule.pay_shift isa NoShift
end

# Test 2: InstrumentSchedule creation with explicit pay shift
@testitem "InstrumentSchedule Creation - Explicit Pay Shift" begin    
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    period = Month(1)
    schedule_config = ScheduleConfig(period)
    pay_shift = TimeShift(Day(2))

    # Create InstrumentSchedule with an explicit pay shift
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config, pay_shift)

    # Verify fields and explicit pay shift
    @test instrument_schedule.start_date == start_date
    @test instrument_schedule.end_date == end_date
    @test instrument_schedule.schedule_config == schedule_config
    @test instrument_schedule.pay_shift == pay_shift
end

# Test 3: InstrumentSchedule constructor with start_date, end_date, and period
@testitem "InstrumentSchedule Creation - Start Date, End Date, and Period" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 12, 31)
    period = Month(1)

    # Create InstrumentSchedule using start_date, end_date, and period
    instrument_schedule = InstrumentSchedule(start_date, end_date, period)

    # Verify fields and that default ScheduleConfig is used
    @test instrument_schedule.start_date == start_date
    @test instrument_schedule.end_date == end_date
    @test instrument_schedule.schedule_config.period == period
    @test instrument_schedule.schedule_config.roll_convention isa NoRollConvention
    @test instrument_schedule.schedule_config.business_days_convention isa NoneBusinessDayConvention
    @test instrument_schedule.schedule_config.calendar isa NoHolidays
end

# Test 4: generate_schedule function with InstrumentSchedule
@testitem "Generate Schedule - InstrumentSchedule" begin
    using Dates
    start_date = Date(2023, 1, 1)
    end_date = Date(2023, 6, 1)
    period = Month(1)
    schedule_config = ScheduleConfig(period)

    # Create InstrumentSchedule
    instrument_schedule = InstrumentSchedule(start_date, end_date, schedule_config)

    # Generate schedule and verify
    schedule = generate_schedule(instrument_schedule)
    expected_dates = [Date(2023, 1, 1), Date(2023, 2, 1), Date(2023, 3, 1), Date(2023, 4, 1), Date(2023, 5, 1), Date(2023, 6, 1)]

    @test schedule == expected_dates
end
