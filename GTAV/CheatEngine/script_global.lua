---@diagnostic disable

openProcess("GTA5.exe")

local ok = autoAssemble([[
aobscanmodule(SG_PTR, GTA5.exe, 48 8D 15 ? ? ? ? 4C 8B C0 E8 ? ? ? ? 48 85 FF 48 89 1D)
registerSymbol(SG_PTR)
]])

assert(ok, "Failed to find pattern!")

local SG_PTR = getAddress("SG_PTR")
-- https://github.com/Mr-X-GTA/YimMenu/blob/master/src/pointers.cpp#L142
SG_PTR = SG_PTR + readInteger(SG_PTR + 3) + 7
unregisterSymbol("SG_PTR")
registerSymbol("SG_PTR", SG_PTR, true)



---@class ScriptGlobal
---@field m_address number
---@overload fun(address: integer): ScriptGlobal
local ScriptGlobal = {}
setmetatable(
    ScriptGlobal,
    { 
        __call = function(_, address)
            return ScriptGlobal.new(address)
        end
    }
)

--------------------------
-- Constructors (2)
--------------------------

---@param address integer
---@return ScriptGlobal
function ScriptGlobal.new(address)
    assert(type(address) == "number")

    return setmetatable(
        {
            m_address = readQword(getAddress(SG_PTR)
            + ((address >> 0x12 & 0x3F) * 8))
            + ((address & 0x3FFFF) * 8)
        },
        ScriptGlobal
    )
end

-- Internal
---@param address integer
---@return ScriptGlobal
function ScriptGlobal.FromAddress(address)
    assert(type(address) == "number")

    return setmetatable(
        {
            m_address = address
        },
        ScriptGlobal
    )
end

--------------------------

function ScriptGlobal:__index(key)
    if ScriptGlobal[key] then
        return ScriptGlobal[key]
    elseif type(key) == "number" then
        return ScriptGlobal.FromAddress(self.m_address + key * 8)
    end
end

function ScriptGlobal:__tostring()
    return string.format("Global_%d", self.m_address)
end

---@param offset number
function ScriptGlobal:At(offset)
    return ScriptGlobal.FromAddress(self.m_address + offset * 8)
end

function ScriptGlobal:GetAddress()
    return self.m_address
end

-- Same as `ReadInt` for a 32bit process and `ReadQword` for 64bit
function ScriptGlobal:ReadPointer()
    return readPointer(self.m_address)
end

---@param numOfBytes number
---@param asTable? boolean return the result as table instead of tuple
---@return bytes|table
function ScriptGlobal:ReadBytes(numOfBytes, asTable)
    return readBytes(self.m_address, numOfBytes, asTable)
end

---@param ... any -- Btyes to write (table or tuple)
function ScriptGlobal:WriteBytes(...)
    writeBytes(self.m_address, ...)
end

---@return number
function ScriptGlobal:ReadWord()
    return readSmallInteger(self.m_address)
end

---@param value number
function ScriptGlobal:WriteWord(value)
    return writeSmallInteger(self.m_address, value)
end

---@return number
function ScriptGlobal:ReadInt()
    return readInteger(self.m_address, true)
end

---@param value number
function ScriptGlobal:WriteInt(value)
    return writeInteger(self.m_address, value)
end

---@return number
function ScriptGlobal:ReadUint()
    return readInteger(self.m_address, false)
end

---@param value number
function ScriptGlobal:WriteUint(value)
    return writeInteger(self.m_address, value)
end

---@return number
function ScriptGlobal:ReadQword()
    return readQword(self.m_address)
end

---@param value number
function ScriptGlobal:WriteQword(value)
    writeQword(self.m_address, value)
end

---@return number
function ScriptGlobal:ReadFloat()
    return readFloat(self.m_address)
end

---@param value number
function ScriptGlobal:WriteFloat(value)
    return writeFloat(self.m_address, value)
end

---@param maxLength number
---@return string
function ScriptGlobal:ReadString(maxLength)
    return readString(self.m_address, maxLength, false)
end

---@param value string
function ScriptGlobal:WriteString(value)
    return writeString(self.m_address, value, false)
end

-- test
local fKickVotesNeededRatio = ScriptGlobal(262145):At(6):ReadFloat()
assert(math.abs(fKickVotesNeededRatio - 0.66) < 0.01, "Samurai, you're a dumbass.")

return ScriptGlobal
