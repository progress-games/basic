--string
function string:split(s)
    if not s then s = "%s" end
    local out = {}
    for str in self:gmatch("([^" .. s .. "]+)") do
      table.insert(out, str)
    end
    return out
end

--table
function table.copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            t2[k] = table.copy(v)
        else
            t2[k] = v
        end
    end
    return t2
end

function table.inkeys(t, k)
    return self[k] ~= nil
end

function table.invals(t, v)
    for i, k in ipairs(t) do
        if v == k then return i end
    end
end

--calls each table function
function table.call(t, func, ...)
    for _, v in pairs(t) do
        func(v, ...)
    end
end

--creates a new table where each item is the original passed through a funciton
function table.apply(t, func)
    local res = {}
    for _, v in pairs(t) do
        table.insert(res, func(v))
    end
    return res
end

function table.stringify(t)
    local t2 = '{'
    for k, v in pairs(t) do
        if type(v) == 'table' then
            t2 = t2..'['..k..'] = '..table.stringify(v)
        else
            t2 = t2..'['..k..'] = \''..v..'\''
        end
        t2 = t2..', '
    end 
    return t2..'}'
end

function table.print(t)
    print(table.stringify(t))
end

function random_float(m, n)
    return math.random()*math.abs(m-n) + math.min(m, n)
end

function to_dt(n) return n*60 end

function table.get_key(t, v, v_name)
    for k, val in pairs(t) do
        if val[v_name] == v then
            return k
        end
    end
end

function table.get_keys(t, v, v_name)
    local res = {}
    for k, val in pairs(t) do
        if val[v_name] == v then
            table.insert(res, k)
        end
    end
    return res
end 

function table.max(t, k)
    local max = -math.huge
    for _, v in pairs(t) do
        max = math.max(v[k], max)
    end
    return max
end

function table.min(t, k)
    local min = math.huge
    for _, v in pairs(t) do
        min = math.min(v[k], min)
    end
    return min 
end

function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function set_font(name)
    graphics.setFont(font[config.language][name])
    font.current = font[config.language][name]
end

--used when calling a function that may or may not exist
function call(func, ...)
    if func then func(...) end
end