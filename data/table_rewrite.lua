function table.map(t, f)
    local out = {}
    for _, v in pairs(t) do
        table.insert(out, f[v])
    end
    return out
end