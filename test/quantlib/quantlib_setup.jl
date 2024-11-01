@testsnippet QuantlibDateConversion begin
    using PyCall
    ql = pyimport("QuantLib")

    function ql_to_julia_date(ql_date)
        # Extract year, month, and day from the QuantLib.Date object
        year = Int(ql_date.year())
        month = Int(ql_date.month())
        day = Int(ql_date.dayOfMonth())
        
        # Construct and return the Julia Date
        return Date(year, month, day)
    end

    function julia_to_ql_date(julia_date)
        return ql.Date(day(julia_date), month(julia_date), year(julia_date))
    end
end

@testsnippet QuantlibBusinessDayConvention begin
    using Dates
    using BusinessDays
    using DerivativesPricer

    # Define a mock calendar
    struct CustomCalendar <: HolidayCalendar end
    BusinessDays.isholiday(::CustomCalendar, dt::Date) = dt in [Date(2023, 1, 1), Date(2023, 12, 25)] || dayofweek(dt) in [6, 7]  # Monday to Friday are working days, first and last day of the year are holidays in 2023
    calendar = CustomCalendar()

    using PyCall
    ql = pyimport("QuantLib")
    using Dates

    ql_calendar = ql.WeekendsOnly()
    ql_calendar.addHoliday(ql.Date(1,1,2023))
    ql_calendar.addHoliday(ql.Date(25,12,2023))

    function ql_to_julia_date(ql_date)
        # Extract year, month, and day from the QuantLib.Date object
        year = Int(ql_date.year())
        month = Int(ql_date.month())
        day = Int(ql_date.dayOfMonth())
        
        # Construct and return the Julia Date
        return Date(year, month, day)
    end

    function julia_to_ql_date(julia_date)
        return ql.Date(day(julia_date), month(julia_date), year(julia_date))
    end
end
