"""
    Abstract type representing the stub position in a schedule.
"""
abstract type StubPosition end

"""
    UpfrontStubPosition <: StubPosition

Represents the stub position at the start (upfront) of a schedule.
"""
struct UpfrontStubPosition <: StubPosition end

"""
    InArrearsStubPosition <: StubPosition

Represents the stub position at the end (in arrears) of a schedule.
"""
struct InArrearsStubPosition <: StubPosition end

"""
    Abstract type representing the stub length in a schedule.
"""
abstract type StubLength end

"""
    ShortStubLength <: StubLength

Represents a short stub length in a schedule.
"""
struct ShortStubLength <: StubLength end

"""
    LongStubLength <: StubLength

Represents a long stub length in a schedule.
"""
struct LongStubLength <: StubLength end

"""
    StubPeriod{P<:StubPosition, L<:StubLength}

Represents the stub period in a schedule, consisting of a position (`P`) and a length (`L`).

# Fields
- `position::P`: The position of the stub (e.g., upfront or in arrears).
- `length::L`: The length of the stub (e.g., short or long).
"""
struct StubPeriod{P<:StubPosition, L<:StubLength}
    position::P
    length::L
end

"""
    StubPeriod() -> StubPeriod{InArrearsStubPosition, ShortStubLength}

Creates a default `StubPeriod` with the position set to `InArrearsStubPosition` and length set to `ShortStubLength`.
"""
function StubPeriod()
    return StubPeriod(InArrearsStubPosition(), ShortStubLength())
end

"""
    AbstractScheduleConfig

Abstract type representing the configuration for generating an accrual schedule in a stream of cash flows.
"""
abstract type AbstractScheduleConfig end

"""
    ScheduleConfig{P <: Period, R <: RollConvention, B <: BusinessDayConvention, D <: BusinessDayConvention, C <: HolidayCalendar} <: AbstractScheduleConfig

Represents the configuration for generating a schedule. It includes the period, roll convention, business day convention, 
termination business day convention, holiday calendar, and the stub period.

# Fields
- `period::P`: The period for generating dates.
- `roll_convention::R`: The roll convention to adjust dates.
- `business_days_convention::B`: The business day convention for adjusting non-business days.
- `termination_bd_convention::D`: The convention for adjusting the termination date.
- `calendar::C`: The holiday calendar.
- `stub_period::StubPeriod`: The configuration of the stub period.

# Constructor with default values
- `period::P`: The period (required).
- `roll_convention`: The roll convention (default `NoRollConvention`).
- `business_days_convention`: The business day convention (default `NoneBusinessDayConvention`).
- `termination_bd_convention`: The convention for adjusting the termination date (default `NoneBusinessDayConvention`).
- `calendar`: The holiday calendar (default `NoHolidays`).
- `stub_period`: The configuration of the stub period (default to `StubPeriod()`).
"""
struct ScheduleConfig{P <: Period, R <: RollConvention, B <: BusinessDayConvention, D <: BusinessDayConvention, C <: HolidayCalendar} <: AbstractScheduleConfig
    period::P
    roll_convention::R
    business_days_convention::B
    termination_bd_convention::D
    calendar::C
    stub_period::StubPeriod

    # Constructor with default values
    function ScheduleConfig(period::P,
                   roll_convention = NoRollConvention(),
                   business_days_convention = NoneBusinessDayConvention(),
                   termination_bd_convention = NoneBusinessDayConvention(),
                   calendar = NoHolidays(),
                   stub_period = StubPeriod()) where P<:Period
        return new{P, typeof(roll_convention), typeof(business_days_convention), typeof(termination_bd_convention), typeof(calendar)}(
            period, roll_convention, business_days_convention, termination_bd_convention, calendar, stub_period)
    end
end

"""
    ScheduleConfig(period::P, roll_convention::R, business_days_convention::B, calendar::C, stub_period::StubPeriod) -> ScheduleConfig

Alternate constructor for `ScheduleConfig` with customizable period, roll convention, business day convention, calendar, and stub period.

# Arguments
- `period::P`: The period.
- `roll_convention::R`: The roll convention.
- `business_days_convention::B`: The business day convention.
- `calendar::C`: The holiday calendar.
- `stub_period::StubPeriod`: The stub period configuration.

# Returns
- A `ScheduleConfig` object.
"""
function ScheduleConfig(period::P,
    roll_convention::R = NoRollConvention(),
    business_days_convention::B = NoneBusinessDayConvention(),
    calendar::C = NoHolidays(),
    stub_period::StubPeriod = StubPeriod()) where {P <:Period, R <: RollConvention, B <: BusinessDayConvention, D <: BusinessDayConvention, C <: HolidayCalendar}
    return ScheduleConfig(period, roll_convention, business_days_convention, business_days_convention, calendar, stub_period)
end

"""
    date_corrector(schedule_config::S)

Returns a function that adjusts a date according to the given schedule configuration, applying first adjustment conventions like EOM and then business day adjustment.

# Arguments
- `schedule_config::S`: The schedule configuration.

# Returns
- A function that adjusts a date according to the given schedule configuration.
"""
function date_corrector(schedule_config::ScheduleConfig)
    return date -> adjust_date(roll_date(date, schedule_config.roll_convention), schedule_config.calendar, schedule_config.business_days_convention)
end

"""
    generate_unadjusted_dates(start_date, end_date, stub_period::StubPeriod, period::P) where P <: Period

Generates a stream of unadjusted dates according to the given period and stub period.

# Arguments
- `start_date`: The start date of the schedule.
- `end_date`: The end date of the schedule.
- `stub_period::StubPeriod`: The stub period configuration.
- `period::P`: The period.

# Returns
- A stream of unadjusted dates.
"""
function generate_unadjusted_dates(start_date, end_date, stub_period::StubPeriod, period::P) where P <: Period
    if isa(stub_period.position, InArrearsStubPosition)
        return Iterators.flatten((start_date:period:(end_date - period), [end_date]))
    elseif isa(stub_period.position, UpfrontStubPosition)
        return Iterators.flatten((end_date:-period:(start_date + period), [start_date]))
    else
        throw(ArgumentError("Invalid stub period position."))
    end
end

"""
    generate_schedule(unadjusted_dates, schedule_config::S) where S <: AbstractScheduleConfig

Generates a schedule of adjusted dates according to the given schedule configuration.

# Arguments
- `unadjusted_dates`: A stream of unadjusted dates.
- `schedule_config::S`: The schedule configuration.

# Returns
- A schedule of adjusted dates.
"""
function generate_schedule(unadjusted_dates, schedule_config::S) where S <: AbstractScheduleConfig
    corrector = date_corrector(schedule_config)
    adjusted_dates = Iterators.map(corrector, unadjusted_dates)
    return adjusted_dates
end