using Symbolics
using Dates 

struct FixedRateCashFlow
    cash_flows::Vector{Num}  # Symbolic cash flows
    dates::Vector{Date}       # Corresponding dates for each cash flow
end

function create_fixed_cash_flow_stream(rate::Num, start_date::Date, num_periods::Int)
    # Calculate the dates for each period
    dates = [start_date + Dates.Month(12 * i / num_periods) for i in 0:num_periods]

    # Initialize the cash flows vector
    cash_flows = Vector{Num}(undef, length(dates))

    # Calculate the cash flows based on ACT/365 convention using proper indexing
    for i in eachindex(dates)[2:end]  # Start from the second index
        days = Dates.value(dates[i] - dates[i-1])
        cash_flows[i] = rate * days / 365 |> simplify
    end

    cash_flows[1] = 0  # The initial cash flow is usually 0

    # Create the FixedRateCashFlow instance
    return FixedRateCashFlow(cash_flows, dates)
end

# Vectorized function to discount cash flows
function discount_cash_flows(cfs::FixedRateCashFlow, today::Date, discount_rate::Num)::Num
    # Calculate the time in years for each cash flow date relative to today
    time_years = Dates.value.(cfs.dates .- today) ./ 365
    
    # Calculate the discounted cash flows
    discounted_cash_flows = cfs.cash_flows ./ (1 .+ discount_rate) .^ time_years
    
    # Sum of discounted cash flows (Present Value)
    present_value = sum(discounted_cash_flows)
    
    return present_value
end

@variables x, discount_rate
date = Date(2024, 7, 7)
todays_date = date
num_periods = 4
cash_flows = create_fixed_cash_flow_stream(x, date, num_periods)
value = discount_cash_flows(cash_flows, todays_date, discount_rate)
gradient = Symbolics.gradient(value, Symbolics.get_variables(value)) |> Symbolics.simplify