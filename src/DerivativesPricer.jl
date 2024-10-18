module DerivativesPricer

# Include all the required files
include("day_count_conventions.jl")
include("rate_conventions.jl")
include("date_generation/calendars.jl")
include("date_generation/roll_conventions.jl")
include("date_generation/business_days_conventions.jl")
include("date_generation/date_shift.jl")
include("date_generation/schedule_generation.jl")
include("fixed_rate_stream.jl")
# include("float_rate.jl")
# include("rate_curves.jl")
# include("float_rate_stream.jl")
# include("discount_pricing.jl")

# include runtests in VSCODE: necessary to have code completion
if isdefined(@__MODULE__,:LanguageServer)
    include("../test/runtests.jl")
    include("../notebooks/includer.jl")
end

# Export relevant functions and types for external use
export  # date_generation/business_days_convention.jl
        BusinessDayConvention, Following, ModifiedFollowing, PrecedingBusinessDay, FollowingBusinessDay, ModifiedPreceding, NoneBusinessDayConvention, adjust_date, roll_date, NoRollConvention, EOMRollConvention, RollConvention,
        # date_generation/date_shft.jl
        AbstractShift, NoShift, TimeShift, relative_schedule, WeekendsOnly, NoHolidays,
        # date_generation/schedule_generation.jl
        AbstractScheduleConfig, ScheduleConfig, date_corrector, generate_unadjusted_dates, generate_schedule, date_corrector,
        StubPosition, UpfrontStubPosition, InArrearsStubPosition, StubLength, ShortStubLength, LongStubLength, StubPeriod,
        # date_generation/schedule_generation.jl
        DayCountConvention, ACT360, ACT365, day_count_fraction,
        # day_count_conventions.jl
        RateType, Linear, Compounded, Exponential, calculate_interest,
        # rate_conventions.jl
        FlowStream, ScheduleConfig, FixedRateStreamConfig, FixedRateStream,
        # fixed_rate_stream.jl
        RateCurve, RateCurveInputs, create_rate_curve, discount_factor,
        # rate_curves.jl
        FloatRateStreamConfig, FloatingRateStream,
        # float_rate_stream.jl
        price_fixed_flows_stream, calculate_forward_rates, price_float_rate_stream,
        # discount_pricing.jl
        AbstractRateIndex, RateIndex
        # float_rate.jl
end
