function randomFloat(m, n)
    return math.random()*math.abs(m-n) + math.min(m, n)
end

function toDt(n) return n*60 end