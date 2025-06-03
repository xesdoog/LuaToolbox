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



---@class vec2
---@field x number
---@field y number
local vec2 = {}
vec2.__index = vec2

setmetatable(
    vec2,
    {
        __call = function(_, arg)
            arg = vec2:assert(arg)
            return vec2:new(arg.x, arg.y)
        end
    }
)

---@param arg any
---@return vec2
function vec2:assert(arg)
    if (type(arg) == "table" or type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" then
        return vec2:new(arg.x, arg.y)
    else
        error(
            string.format("Invalid argument! Expected 2D vector, got %s instead", type(arg))
        )
    end
end

-- Constructor
---@param x number
---@param y number
---@return vec2
function vec2:new(x, y)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0
        },
        self
    )
end

---@return vec2
function vec2:zero()
    return vec2:new(0, 0)
end

function vec2:__tostring()
    return string.format(
        "(%.3f, %.3f)",
        self.x,
        self.y
    )
end

---@param b number|vec2
---@return vec2
function vec2:__add(b)
    if type(b) == "number" then
        return vec2:new(self.x + b, self.y + b)
    end

    b = self:assert(b)
    return vec2:new(self.x + b.x, self.y + b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__sub(b)
    if type(b) == "number" then
        return vec2:new(self.x - b, self.y - b)
    end

    b = self:assert(b)
    return vec2:new(self.x - b.x, self.y - b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__mul(b)
    if type(b) == "number" then
        return vec2:new(self.x * b, self.y * b)
    end

    b = self:assert(b)
    return vec2:new(self.x * b.x, self.y * b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__div(b)
    if type(b) == "number" then
        return vec2:new(self.x / b, self.y / b)
    end

    b = self:assert(b)
    return vec2:new(self.x / b.x, self.y / b.y)
end

---@param b number|vec2
---@return boolean
function vec2:__eq(b)
    b = self:assert(b)
    return self.x == b.x and self.y == b.y
end

---@param b number|vec2
---@return boolean
function vec2:__lt(b)
    b = self:assert(b)
    return self.x < b.x and self.y < b.y
end

---@param b number|vec2
---@return boolean
function vec2:__le(b)
    b = self:assert(b)
    return self.x <= b.x and self.y <= b.y
end

---@return vec2
function vec2:__unm()
    return vec2:new(-self.x, -self.y)
end

---@return number, number
function vec2:unpack()
    return self.x, self.y
end

---@return number
function vec2:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

---@param b vec2
---@return number
function vec2:distance(b)
    b = self:assert(b)

    local dist_x = (self.x - b.x) ^ 2
    local dist_y = (self.y - b.y) ^ 2

    return math.sqrt(dist_x + dist_y)
end

---@return number
function vec2:dot(b)
    b = self:assert(b)
    return self.x * b.x + self.y * b.y
end

---@return vec2
function vec2:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec2:new(0, 0)
    end

    return self / len
end

---@return vec2
function vec2:inverse()
    return self:__unm()
end

---@return vec2
function vec2:copy()
    return vec2:new(self.x, self.y)
end

---@return boolean
function vec2:is_zero()
    return (self.x == 0) and (self.y == 0)
end

---@return vec2
function vec2:perpendicular()
    return vec2:new(-self.y, self.x)
end

---@return number
function vec2:angle()
    return math.atan(self.y, self.x)
end

---@param b vec2
---@param dt number Delta time
---@return vec2
function vec2:lerp(b, dt)
    return vec2:new(
        self.x + (b.x - self.x) * dt,
        self.y + (b.y - self.y) * dt
    )
end

---@param n number
---@return vec2
function vec2:rotate(n)
    local a, b = math.cos(n), math.sin(n)

    return vec2:new(
        a * self.x - b * self.y,
        b * self.x + a * self.y
    )
end

---@param atLength number
---@return vec2
function vec2:trim(atLength)
    local s = atLength * atLength / self:length()

    s = (s > 1) and 1 or math.sqrt(s)
    return vec2:new(self.x * s, self.y * s)
end

---@param angle number
---@param radius? number
---@return vec2
function vec2:from_polar(angle, radius)
    radius = radius or 1
    return vec2:new(math.cos(angle) * radius, math.sin(angle) * radius)
end

---@return number, number
function vec2:to_polar()
    return math.atan(self.y, self.x), self:length()
end

return vec2
