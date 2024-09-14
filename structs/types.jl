module Types

# types.jl or common.jl
using Symbolics

# Alias that supports both scalars and arrays of Real and Num
const CalcValue = Union{Real, Num, AbstractArray{<:Real}, AbstractArray{<:Num}}

end