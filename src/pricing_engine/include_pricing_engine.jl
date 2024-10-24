include("rate_curves.jl")
include("discount_pricing.jl")
include("forward_rate.jl")

export
    # rate_curves.jl
    RateCurve, RateCurveInputs, create_rate_curve, discount_factor,
    # discount_pricing.jl
    price_fixed_flows_stream, 
    # forward_rate.jl
    calculate_forward_rate, price_float_rate_stream