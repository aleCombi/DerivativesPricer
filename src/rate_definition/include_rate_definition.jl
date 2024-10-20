include("rate_conventions.jl")
include("fixed_rate.jl")
include("margin.jl")
include("float_rate.jl")

export FloatRate, FloatRateConfig, FixedRateConfig, FixedRate, SimpleRateConfig,
AdditiveMargin, MultiplicativeMargin