include("flow_stream.jl")
include("fixed_rate_stream.jl")
include("simple_rate_float_stream.jl")

export
    # flow_stream.jl
    AbstractFlowStreamConfig, FlowStreamConfig, FlowStream, 
    # fixed_rate_stream.jl
    FixedRateStream,
    # simple_rate_float_stream.jl
    SimpleRateStreamSchedules, SimpleFloatRateStream