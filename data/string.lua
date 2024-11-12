function string:split(s)
    if not s then s = "%s" end
    local out = {}
    for str in self:gmatch("([^" .. s .. "]+)") do
      table.insert(out, str)
    end
    return out
end