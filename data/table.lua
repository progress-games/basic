function table.map(t, f)
    local out = {}
    for _, v in pairs(t) do
        table.insert(out, f[v])
    end
    return out
end

function table.reduce(t, f, a)
    for _, v in pairs(t) do
        a = f(a, v)
    end
    return a
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

function table.index(t, v)
    for i, k in pairs(t) do
        if type(v) == 'table' and type(k) == 'table' then
            if table.match(v, k) then return i end
        elseif v == k then return i end
    end
end

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function table.for_each(t, func, ...)
    for _, v in pairs(t) do
        func(v, ...)
    end
end

function table.stringify(t)
    local t2 = '{'
    for k, v in pairs(t) do
        local s = ''

        if type(k) ~= 'number' then
            s = '[\''..k..'\'] = '
        end
        
        if type(v) == 'table' then
            t2 = t2..s..table.stringify(v)
        elseif type(v) == 'number' then
            t2 = t2..s..v
        elseif type(v) == 'string' then
            t2 = t2..s.."\""..v.."\""
        elseif type(v) == 'boolean' then
            t2 = t2..s..bool_to_str(v)
        end--lse error(type(v)) end
        t2 = t2..', '
    end 
    return t2..'}'
end

function table.match(a, b)
    return table.concat(a) == table.concat(b)
end

function table.print(t)
    print(table.stringify(t))
end

function table.shift(t, amount)
    local t2 = {}
    for i=0, amount - 1 do
        table.insert(t2, t[#t - i])
    end
    for i=1, #t - amount do
        table.insert(t2, t[i])
    end
    return t2
end

function table.get_key(t, v, v_name)
    for k, val in pairs(t) do
        if val[v_name] == v then
            return k
        end
    end
end

function table.either(t1, t2)
    return (t1[1] == t2[1] and t1[2] == t2[2]) or
    (t1[2] == t2[1] and t1[1] == t2[1])
end

function table.merge(t1, t2)
    local t = table.copy(t1)
    for _, v in pairs(t2) do
        t[#t+1] = v
    end
    return t
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

--returns a random element from a given table
function table.choose(t)
    for k, v in pairs(t) do
        if type(k) ~= 'number' then
            return table.alt_choose(t)
        end
    end
    return t[math.random(1, #t)]
end

--returns a random element from a given k+v table
function table.alt_choose(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return t[table.choose(keys)]
end

function table.min(t, k)
    local min = math.huge
    for _, v in pairs(t) do
        min = math.min(v[k], min)
    end
    return min 
end

function table.cut(t, v, n)
    local n = n or 1
    for i=1, #t do
        if t[i] == v then
            table.remove(t, i)
            n = n - 1
        end
        if n == 0 then return t end
    end
    return t
end