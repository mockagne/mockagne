--- Mockagne - Lua Mock Library
-- https://github.com/PunchWolf/mockagne
--
-- @copyright PunchWolf
-- @author Janne Sinivirta
-- @author Marko Pukari

local M = {}

local latest_invoke = {}

local function deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)

    if ty1 ~= ty2 then return false end
    --if objects are same or have same memory address
    if(t1 == t2) then return true end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end

    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end

    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end

    return true
end

local function compareToAny(any, value)
    if not any.itemType then return true end
    if type(value) == "table" and value.any and any.itemType == value.itemType then return true end
    if any.itemType == type(value) then return true end

    return false
end

local function anyMatch(v1, v2)
    if type(v1) == "table" and v1.any then
        if compareToAny(v1, v2) then return true end
    end

    if type(v2) == "table" and v2.any then
        if compareToAny(v2, v1) then return true end
    end

    return false
end

local function compareValues(v1, v2, strict)
    if v1 == v2 then
        return true
    end

    if not strict then
        if anyMatch(v1, v2) then return true, true end -- second true implies that any's were used
    end
    if type(v1) ~= type(v2) then return false end

    return deepcompare(v1, v2)
end

local function compareArgs(args1, args2, strict)
    if #args1 ~= #args2 then return false end

    local anysUsed = false
    for i, v1 in ipairs(args1) do
        local match, anyUsed = compareValues(v1, args2[i], strict)
        if not match then
            return false
        end
        if anyUsed then anysUsed = true end
    end
    return true, anysUsed
end

local function matchesNilledField(self, field)
    for i, nilField in ipairs(self.nilledFields) do
        if nilField == field then return true end
    end
    return false
end

local function getReturn(self, method, ...)
    for i = 1, #self.expected_returns do
        local candidate = self.expected_returns[i]
        if (candidate.mock == self and candidate.key == method and compareArgs({...}, candidate.args)) then
            return unpack(candidate.returnvalue)
        end
    end
    return nil
end

local function find_invoke(mock, method, expected_call_arguments, strict)
    local stored_calls = mock.stored_calls
    for i = 1, #stored_calls do
        local invocation = stored_calls[i]
        if (invocation.key == method and compareArgs(invocation.args, expected_call_arguments, strict)) then
            return stored_calls[i], i
        end
    end
end

local function capture(reftable, refkey)
    if matchesNilledField(reftable, refkey) then return nil end
    return function(...)
        local args = {...}

        local captured = { key = refkey, args = args, count = 1 }
        latest_invoke = { mock = reftable, key = refkey, args = args }

        local found = find_invoke(reftable, refkey, args, true)
        if (found) then
            found.count = found.count + 1
        else
            table.insert(reftable.stored_calls, captured)
        end
        return getReturn(reftable, refkey, ...)
    end
end

local function remove_invoke(mock, method, ...)
    local found, i = find_invoke(mock, method, {...}, true)
    if found then
        if (found.count > 1) then found.count = found.count - 1
        else table.remove(mock.stored_calls, i) end
    end
end

local function expect(self, method, returnvalue, ...)
    local expectation = { mock = self, key = method, returnvalue = returnvalue, args = {...} }

    table.insert(self.expected_returns, expectation)
end

local function thenAnswer(...)
    latest_invoke.mock:expect(latest_invoke.key, {...}, unpack(latest_invoke.args))
    remove_invoke(latest_invoke.mock, latest_invoke.key, unpack(latest_invoke.args))
end

local function getName(self)
    return self.mockname
end

local function setNil(self, field)
    self.nilledFields[#self.nilledFields + 1] = field
end

local function describeArgs(mock, args)
    local description = ""
    for i,v in ipairs(args) do
        if (i == 1 and v == mock) then description = description .. "self"
        else description = description .. tostring(v) end
        if i < #args then description = description .. ", " end
    end
    return description
end

local function describeInvoke(capture, suppliedMock)
    local mock = capture.mock or suppliedMock
    return tostring(capture.key) .. "(" .. describeArgs(mock, capture.args) .. ")"
end

local function describeAllInvokes(mock)
    local description = "  "
    local stored_calls = mock.stored_calls
    for i = 1, #stored_calls do
        local invocation = stored_calls[i]
        description = description .. describeInvoke(invocation, mock) .. "\n  "
    end
    return description
end

local function do_verify(mockinvoke)
    remove_invoke(latest_invoke.mock, latest_invoke.key, unpack(latest_invoke.args)) -- remove invocation made for verify
    local stored_calls = latest_invoke.mock.stored_calls
    for i = 1, #stored_calls do
        invocation = stored_calls[i]
        if invocation.key == latest_invoke.key and compareArgs(invocation.args, latest_invoke.args) then
            return true
        end
    end
    return false
end

--- Verify that a given invocation happened
function M.verify(mockinvoke)
    if not do_verify(mockinvoke) then
        error("Expected call to " .. describeInvoke(latest_invoke) .. " but no invocation made.\nCaptured invokes:\n" .. describeAllInvokes(latest_invoke.mock))
    end
end

--- Verify that a given invocation did not happen
function M.verify_no_call(mockinvoke)
    if do_verify(mockinvoke) then
        error("Expected no call to " .. describeInvoke(latest_invoke) .. " but an invocation was made.")
    end
end

--- Returns a mock instance
-- @param name name for the mock (optional)
-- @return mock instance
function M.getMock(name)
    mock = { 
        mockname = name or "",
        type = "mock",
        stored_calls = {},
        expected_returns = {},
        expect = expect,
        getName = getName,
        nilledFields = {},
        setNil = setNil
    }

    setmetatable(mock, { __index = capture })

    return mock
end

--- Used for teaching mock to return values with specific invocation
-- @param fcall function call expected to have a return value
-- @return table with thenAnswer function that is used to set the return value
function M.when(fcall)
    return { thenAnswer = thenAnswer }
end

--- Any matcher. Used to describe calls to mocks with parameters that don't matter (ie. can be anything)
-- @param item if item is given, it's type will be used as a constraint. For example if item is a table, only tables will be accepted by this any
function M.any(item)
    local mockType = {}
    mockType.any = true

    if item then
        mockType.itemType = type(item)
    end

    return mockType
end

return M
