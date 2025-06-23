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



os.path = {}

local sep = package.config:sub(1, 1) or "/"
os.isNT = (sep == "\\")

-- Returns the last part of the path
---@param p string
function os.path.basename(p)
    return p:match("([^" .. sep .. "]+)$") or ""
end

-- Returns the directory part of the path
---@param p string
function os.path.dirname(p)
    local i = p:match(".*()" .. sep)
    return i and p:sub(1, i - 1) or ""
end

-- Returns the file extension if the path is a file
---@param p string
---@return string|nil
function os.path.ext(p)
    local name = os.path.basename(p)
    local i = name:match("^.*()%.")

    if i and i > 1 then
        return name:sub(i)
    end

    return nil
end

-- Joins multiple path segments
function os.path.join(...)
    local parts = (type(...) == "table") and ... or { ... }
    return table.concat(parts, sep):gsub(sep .. "+", sep)
end

-- Splits path into {dir, file}
---@param p string
function os.path.split(p)
    return os.path.dirname(p), os.path.basename(p)
end

-- Normalizes path (removes ., ..)
---@param p string
function os.path.normalize(p)
    local parts = {}

    for part in p:gmatch("[^" .. sep .. "]+") do
        if part == ".." then
            if #parts > 0 then table.remove(parts) end
        elseif part ~= "." and part ~= "" then
            table.insert(parts, part)
        end
    end

    local prefix = (p:sub(1, 1) == sep) and sep or ""
    return prefix .. table.concat(parts, sep)
end

-- Returns true if path is absolute
---@param p string
function os.path.isabs(p)
    return p:sub(1, 1) == sep or p:match("^%a:[/\\]") ~= nil
end

-- Check if path exists and is a file
---@param p string
function os.path.isfile(p)
    local f = io.open(p, "r")

    if f then
        f:close()
        return true
    end

    return false
end

-- Check if path exists and is a directory
---@param p string
function os.path.isdir(p)
    local test = p:sub(-1) == sep and p or (p .. sep)
    local ok, _, code = os.rename(test, test)

    if ok or (code == 13) then
        return true
    end

    return false
end

-- Convert relative path to absolute, if you know the base path.
---@param p string
---@param base string
function os.path.abspath(p, base)
    if os.path.isabs(p) then
        return os.path.normalize(p)
    end

    base = base or "."
    return os.path.normalize(os.path.join(base, p))
end
