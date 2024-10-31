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