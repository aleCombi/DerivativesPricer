using BusinessDays

struct NoHolidays<:HolidayCalendar end
BusinessDays.isholiday(::NoHolidays, dt::Date) = false

struct WeekendsOnly <: HolidayCalendar end
BusinessDays.isholiday(::WeekendsOnly, dt::Date) = dayofweek(dt) in [6, 7]  # Monday to Friday 

abstract type StubPosition end

struct UpfrontStubPosition <: StubPosition end
struct InArrearsStubPosition <: StubPosition end

abstract type StubLength end

struct ShortStubLength <: StubLength end
struct LongStubLength <: StubLength end

struct StubPeriod{P<:StubPosition, L<:StubLength}
    position::P
    length::L
end

function StubPeriod()
    return StubPeriod(InArrearsStubPosition(), ShortStubLength())
end

"""
    AbstractScheduleConfig

Abstract type representing the configuration for generating an accrual schedule in a stream of cash flows.
"""
abstract type AbstractScheduleConfig end

struct ScheduleConfig{P <: Period, R <: RollConvention, B <: BusinessDayConvention, C <: HolidayCalendar} <: AbstractScheduleConfig
    period::P
    roll_convention::R
    business_days_convention::B
    calendar::C
    stub_period::StubPeriod

    # Constructor with default values
    function ScheduleConfig(period::P,
                   roll_convention = NoRollConvention(),
                   business_days_convention = NoneBusinessDayConvention(),
                   calendar = NoHolidays(),
                   stub_period = StubPeriod()) where P<:Period
        return new{P, typeof(roll_convention), typeof(business_days_convention), typeof(calendar)}(
            period, roll_convention, business_days_convention, calendar, stub_period)
    end
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