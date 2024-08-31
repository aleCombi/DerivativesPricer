using Symbolics
using BenchmarkTools

function discount(flow, rate, time)
    return flow * exp(-rate*time)
end

function generate_cash_flows(principal, rate, frequency::Int, maturity::Int)
    # Calculate the payment amount per period (fixed-rate payment)
    num_payments = maturity * frequency
    payment = principal * rate / frequency  # Assuming interest-only payments
    
    # Generate the cash flow stream
    cash_flows = [(payment, t / frequency) for t in 1:num_payments]
    
    return cash_flows
end

function discount_cash_flows(cash_flows, discount_rate)
    # Initialize the present value to zero
    present_value = 0.0

    # Loop through each cash flow and discount it
    for (amount, time) in cash_flows
        present_value += discount(amount, discount_rate, time)
    end

    return present_value
end

function evaluate_cash_flow_stream(principal, rate, frequency::Int, maturity::Int, discount_rate)
    generate_cash_flows(principal, rate, frequency, maturity) |> 
    cash_flows -> discount_cash_flows(cash_flows, discount_rate)
end

principal = 1000
rate = 0.04
discount_rate = 0.04
frequency = 4
maturity = 1
value = evaluate_cash_flow_stream(principal, rate, frequency, maturity, discount_rate)

@variables x, y
expression = evaluate_cash_flow_stream(principal, x, frequency, maturity, y)
value_expression_function = build_function(Symbolics.simplify(expression), x, y, expression=Val{false})

println(expression)
println(value)
# Benchmarking both functions
benchmark_f = @benchmark value_expression_function(0.04, 0.04)
benchmark_g = @benchmark evaluate_cash_flow_stream(principal, rate, frequency, maturity, discount_rate)

println(benchmark_f)
println(benchmark_g)