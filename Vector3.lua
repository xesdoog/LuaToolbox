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

    Except as contained in this notice, the name(s) of the above copyright holders
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


---@class vec3
---@field x number
---@field y number
---@field z number
vec3 = {}
vec3.__index = vec3

setmetatable(
    vec3,
    {
        __call = function(_, arg)
            arg = vec3:assert(arg)
            return vec3:new(arg.x, arg.y, arg.z)
        end
    }
)

---@param arg any
---@return vec3
function vec3:assert(arg)
    if (type(arg) == "table") or (type(arg) == "userdata") and arg.x and arg.y and arg.z then
        return vec3:new(arg.x, arg.y, arg.z)
    else
        error(
            string.format("Invalid argument. Expected 3D vector, got %s instead", type(arg))
        )
    end
end


-- Constructor
---@param x number
---@param y number
---@param z number
function vec3:new(x, y, z)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0,
            z = z or 0
        },
        self
    )
end

function vec3:zero()
    return vec3:new(0, 0, 0)
end

function vec3:__tostring()
    return string.format(
        "(%.3f, %.3f, %.3f)",
        self.x,
        self.y,
        self.z
    )
end

---@param b number|vec3
---@return vec3
function vec3:__add(b)
    if type(b) == "number" then
        return vec3:new(self.x + b, self.y + b, self.z + b)
    end

    b = self:assert(b)
    return vec3:new(self.x + b.x, self.y + b.y, self.z + b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__sub(b)
    if type(b) == "number" then
        return vec3:new(self.x - b, self.y - b, self.z - b)
    end

    b = self:assert(b)
    return vec3:new(self.x - b.x, self.y - b.y, self.z - b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__mul(b)
    if type(b) == "number" then
        return vec3:new(self.x * b, self.y * b, self.z * b)
    end

    b = self:assert(b)
    return vec3:new(self.x * b.x, self.y * b.y, self.z * b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__div(b)
    if type(b) == "number" then
        return vec3:new(self.x / b, self.y / b, self.z / b)
    end

    b = self:assert(b)
    return vec3:new(self.x / b.x, self.y / b.y, self.z / b.z)
end

---@param b number|vec3
---@return boolean
function vec3:__eq(b)
    b = self:assert(b)
    return self.x == b.x and self.y == b.y and self.z == b.z
end

---@param b number|vec3
---@return boolean
function vec3:__lt(b)
    b = self:assert(b)
    return self.x < b.x and self.y < b.y and self.z < b.z
end

---@param b number|vec3
---@return boolean
function vec3:__le(b)
    b = self:assert(b)
    return self.x <= b.x and self.y <= b.y and self.z <= b.z
end

---@return number
function vec3:length()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

---@param b vec3
---@return number
function vec3:dot(b)
    b = self:assert(b)

    return self.x * b.x + self.y * b.y + self.z * b.z
end

---@param b vec3
---@return number
function vec3:distance(b)
    b = self:assert(b)

    local dist_x = (self.x - b.x)^2
    local dist_y = (self.y - b.y)^2
    local dist_z = (self.z - b.z)^2

    return math.sqrt(dist_x + dist_y + dist_z)
end

---@return vec3
function vec3:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec3:zero()
    end

    return self / len
end

---@param b vec3
---@return vec3
function vec3:cross(b)
    b = self:assert(b)

    return vec3:new(
        self.y * b.z - self.z * b.y,
        self.z * b.x - self.x * b.z,
        self.x * b.y - self.y * b.x
    )
end

---@param to vec3
---@param dt number Delta time
---@return vec3
function vec3:lerp(to, dt)
    return vec3:new(
        self.x + (to.x - self.x) * dt,
        self.y + (to.y - self.y) * dt,
        self.z + (to.z - self.z) * dt
    )
end

---@param includeZ? boolean
---@return vec3
function vec3:inverse(includeZ)
    return vec3:new(-self.x, -self.y, includeZ and -self.z or self.z)
end

---@return vec3
function vec3:copy()
    return vec3:new(self.x, self.y, self.z)
end

---@return boolean
function vec3:is_zero()
    return self.x == 0 and self.y == 0 and self.z == 0
end

---@return vec2
function vec3:as_vec2()
    return vec2:new(self.x, self.y)
end
