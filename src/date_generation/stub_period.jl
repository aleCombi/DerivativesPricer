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