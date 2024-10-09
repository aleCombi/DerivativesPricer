using DerivativesPricer
using Dates

schedule_config = ScheduleConfig(Date(2023, 1, 1), Date(2024, 1, 1), Monthly(), ACT360(), NoShift(true))
float_schedule_config = FloatScheduleConfig(schedule_config, TimeShift(Month(1), true))
schedule = generate_schedule(schedule_config)
float_schedule = generate_schedule(float_schedule_config)

println(schedule)
println(float_schedule)