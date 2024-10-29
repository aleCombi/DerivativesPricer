@testitem "Stub Types Tests" begin
    # Test individual type instantiation
    @test UpfrontStubPosition() isa UpfrontStubPosition
    @test InArrearsStubPosition() isa InArrearsStubPosition
    @test ShortStubLength() isa ShortStubLength
    @test LongStubLength() isa LongStubLength
end

@testitem "StubPeriod Tests" begin
    # Test default StubPeriod
    default_stub = StubPeriod()
    @test default_stub.position isa InArrearsStubPosition
    @test default_stub.length isa ShortStubLength

    # Test StubPeriod with custom parameters
    custom_stub = StubPeriod(UpfrontStubPosition(), LongStubLength())
    @test custom_stub.position isa UpfrontStubPosition
    @test custom_stub.length isa LongStubLength
end
