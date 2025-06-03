--[[
    Copyright (c) 2025 xesdoog (SAMURAI)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    Except as contained in this notice, the name(s) of the above copyright holder(s)
    shall not be used in advertising or otherwise to promote the sale, use or
    other dealings in this Software without prior written authorization.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
]]



---@param t table
---@return table
function ConstEnum(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function(_, key)
            error(
                string.format(
                    "Attempt to modify read-only enum: '%s'", key
                )
            )
        end,
        __metatable = false
    })
end

---@param t table
table.isempty = function(t)
    return type(t) == "table" and next(t) == nil
end

--- Returns true if the table is an array.
---@param t table
---@return boolean
function table.isarray(t)
    if type(t) ~= "table" then
        return false
    end

    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end

    return true
end

--- Returns true if the table is a dictionary.
---@param t table
---@return boolean
function table.isdict(t)
    return not table.isarray(t)
end

-- Returns the number of values in a table. Doesn't count nil fields.
---@param t table
---@return number
table.getlen = function(t)
    local count = 0

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

-- Returns the number of duplicate values in a table.
---@param t table
---@param value string | number | integer | table
table.getdupes = function(t, value)
    local dupes = 0

    for _, v in ipairs(t) do
        if value == v then
            dupes = dupes + 1
        end
    end

    return dupes
end

---@param t table
---@param key string|number
---@param value any
table.matchbykey = function(t, key, value)
    return t[key] and (t[key] == value)
end

---@param t table
---@param value any
---@param seen? table
function table.find(t, value, seen)
    seen = seen or {}

    if seen[t] then
        return false
    end
    seen[t] = true

    for _, v in pairs(t) do
        if (type(v) == "table") then
            if table.find(v, value, seen) then
                return true
            end
        elseif (v == value) then
            return true
        end
    end

    return false
end

-- Serializes tables in pretty format and accounts for circular references.
---@param tbl table
---@param indent? number
---@param key_order? table
---@param seen? table
table.serialize = function(tbl, indent, key_order, seen)
    indent = indent or 0
    seen = seen or {}

    if seen[tbl] then
        return '"<circular reference>"'
    end

    seen[tbl] = true

    local function get_indent(level)
        return string.rep(" ", level)
    end

    local is_array = table.isarray(tbl)
    local pieces = {}

    local function serialize_value(v, depth)
        if type(v) == "string" then
            return string.format("%q", v)
        elseif type(v) == "number" or type(v) == "boolean" then
            return tostring(v)
        elseif type(v) == "table" then
            if table.isempty(v) then
                return "{}"
            elseif seen[v] then
                return '"<circular reference>"'
            else
                return table.serialize(v, depth, key_order, seen)
            end
        else
            return "\"<unsupported>\""
        end
    end

    table.insert(pieces, get_indent(indent) .. "{\n")

    local keys = {}

    if is_array then
        for i = 1, #tbl do
            table.insert(keys, i)
        end
    else
        if key_order then
            for _, k in ipairs(key_order) do
                if tbl[k] ~= nil then
                    table.insert(keys, k)
                end
            end

            for k in pairs(tbl) do
                if not table.find(keys, k) then
                    table.insert(keys, k)
                end
            end
        else
            for k in pairs(tbl) do
                table.insert(keys, k)
            end

            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)
        end
    end

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local ind = get_indent(indent + 1)

        if is_array then
            table.insert(pieces, ind .. serialize_value(v, indent + 1) .. ",\n")
        else
            local key
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                key = k
            else
                key = "[" .. serialize_value(k, indent + 1) .. "]"
            end

            table.insert(pieces, ind .. key .. " = " .. serialize_value(v, indent + 1) .. ",\n")
        end
    end

    table.insert(pieces, get_indent(indent) .. "}")
    return table.concat(pieces)
end
