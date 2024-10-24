include("rate_conventions.jl")
include("fixed_rate.jl")
include("margin.jl")
include("float_rate.jl")

export 
    # rate_conventions.jl
    RateType, LinearRate, Compounded, Exponential, Yield, calculate_interest, discount_interest,
    # fixed_rate.jl
    FixedRateConfig, FixedRate,
    # float_rate.jl
    AbstractRateIndex, RateIndex, FloatRateConfig, SimpleRateConfig, CompoundRateConfig, SimpleInstrumentRate,
    # margin.jl
    AdditiveMargin, MultiplicativeMargin