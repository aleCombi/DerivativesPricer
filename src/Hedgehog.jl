module Hedgehog

using BusinessDays, Dates, Interpolations

# Include all the required files
include("day_count_conventions.jl")
include("date_generation/include_date_generation.jl")
include("rate_definition/include_rate_definition.jl")
include("flow_stream/include_flow_stream.jl")
include("pricing_engine/include_pricing_engine.jl")

# fake include statements necessary to have LSP working on VS Code
if false
    include("../test/runtests.jl")
    include("../notebooks/includer.jl")
end

# Export relevant functions and types for external use. 
# Remark: Exports of functions contained in sub-directories of src are contained in the include_%Folder file of each of the directories.
export
    # day_count_conventions.jl
    DayCount, ACT360, ACT365, Thirty360, day_count_fraction
end