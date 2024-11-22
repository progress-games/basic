function random_float(m, n)
    return math.random()*math.abs(m-n) + math.min(m, n)
end

function nothing(...) end

function to_dt(n) return n*60 end