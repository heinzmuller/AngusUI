-- Simple Test Framework for AngusUI
-- Provides basic unit testing with mocking capabilities

local TestFramework = {}
TestFramework.__index = TestFramework

-- Create a new test suite
function TestFramework.new(name)
    local self = setmetatable({}, TestFramework)
    self.name = name
    self.tests = {}
    self.beforeEach = nil
    self.afterEach = nil
    self.passed = 0
    self.failed = 0
    self.errors = {}
    return self
end

-- Register a test
function TestFramework:test(description, testFunc)
    table.insert(self.tests, {
        description = description,
        func = testFunc
    })
end

-- Set up before each test
function TestFramework:before(func)
    self.beforeEach = func
end

-- Clean up after each test
function TestFramework:after(func)
    self.afterEach = func
end

-- Assertion helpers
local Assert = {}

function Assert.equals(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s",
            message or "Assertion failed",
            tostring(expected),
            tostring(actual)))
    end
end

function Assert.notEquals(actual, expected, message)
    if actual == expected then
        error(string.format("%s\nExpected not to equal: %s",
            message or "Assertion failed",
            tostring(expected)))
    end
end

function Assert.isTrue(value, message)
    if value ~= true then
        error(message or "Expected true but got " .. tostring(value))
    end
end

function Assert.isFalse(value, message)
    if value ~= false then
        error(message or "Expected false but got " .. tostring(value))
    end
end

function Assert.isNil(value, message)
    if value ~= nil then
        error(message or "Expected nil but got " .. tostring(value))
    end
end

function Assert.isNotNil(value, message)
    if value == nil then
        error(message or "Expected value but got nil")
    end
end

function Assert.throws(func, message)
    local success = pcall(func)
    if success then
        error(message or "Expected function to throw an error")
    end
end

-- Mock object creator
function TestFramework.createMock()
    local mock = {
        _calls = {},
        _returnValues = {}
    }
    
    local mt = {
        __index = function(t, key)
            if key == "_calls" or key == "_returnValues" then
                return rawget(t, key)
            end
            
            return function(...)
                local args = {...}
                table.insert(t._calls, {method = key, args = args})
                
                if t._returnValues[key] then
                    return table.unpack(t._returnValues[key])
                end
            end
        end,
        __newindex = function(t, key, value)
            if key == "_calls" or key == "_returnValues" then
                rawset(t, key, value)
            else
                rawset(t, key, value)
            end
        end
    }
    
    setmetatable(mock, mt)
    return mock
end

-- Set return value for a mocked method
function TestFramework.mockReturn(mock, method, ...)
    mock._returnValues[method] = {...}
end

-- Check if a mocked method was called
function TestFramework.wasCalled(mock, method)
    for _, call in ipairs(mock._calls) do
        if call.method == method then
            return true
        end
    end
    return false
end

-- Get number of times a method was called
function TestFramework.callCount(mock, method)
    local count = 0
    for _, call in ipairs(mock._calls) do
        if call.method == method then
            count = count + 1
        end
    end
    return count
end

-- Get arguments from a specific call
function TestFramework.getCallArgs(mock, method, callIndex)
    local index = 0
    for _, call in ipairs(mock._calls) do
        if call.method == method then
            index = index + 1
            if index == callIndex or callIndex == nil then
                return call.args
            end
        end
    end
    return nil
end

-- Run all tests
function TestFramework:run()
    print("\n========================================")
    print("Running Test Suite: " .. self.name)
    print("========================================\n")
    
    for _, test in ipairs(self.tests) do
        -- Run beforeEach
        if self.beforeEach then
            self.beforeEach()
        end
        
        -- Run test
        local success, err = pcall(function()
            test.func(Assert, TestFramework)
        end)
        
        if success then
            self.passed = self.passed + 1
            print("✓ " .. test.description)
        else
            self.failed = self.failed + 1
            print("✗ " .. test.description)
            print("  Error: " .. tostring(err))
            table.insert(self.errors, {
                test = test.description,
                error = err
            })
        end
        
        -- Run afterEach
        if self.afterEach then
            self.afterEach()
        end
    end
    
    -- Print summary
    print("\n========================================")
    print(string.format("Results: %d passed, %d failed, %d total",
        self.passed, self.failed, self.passed + self.failed))
    print("========================================\n")
    
    return self.failed == 0
end

return TestFramework
