"""
    AbstractFlowStream

An abstract type that represents a generalized flow stream of financial instruments.
This is intended to be a parent type for different implementations of flow streams.
"""
abstract type AbstractFlowStream end

"""
    struct FlowStream{P<:Number, R<:AbstractInstrumentRate, S<:AbstractInstrumentSchedule}

A parametric composite type `FlowStream` that represents a flow stream with a principal, 
rate, and schedule. It is designed to be flexible for financial modeling purposes, where:

- `P<:Number`: Represents the principal amount in the flow stream, typically a number.
- `R<:AbstractInstrumentRate`: Represents the rate (interest rate, discount rate, etc.) associated with the financial instrument.
- `S<:AbstractInstrumentSchedule`: Represents the schedule (time periods) over which the flow stream occurs.

# Fields
- `principal::P`: The principal value of the flow stream.
- `rate::R`: The rate associated with the instrument.
- `schedule::S`: The schedule or timetable for the flow stream.
"""
struct FlowStream{P<:Number, R<:AbstractInstrumentRate, S<:AbstractInstrumentSchedule}
    principal::P
    rate::R
    schedule::S
end
