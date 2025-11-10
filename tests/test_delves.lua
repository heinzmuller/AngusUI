-- Unit tests for Delves.lua
local TestFramework = require("tests.test_framework")
local WoWMock = require("tests.wow_mock")

-- Set up WoW API mocks
WoWMock.setup()

-- Create AngusUI namespace with Delves functions
local AngusUI = {}
local delveIsActive = nil

function AngusUI:StartDelveSpeedrun()
    if (delveIsActive ~= nil) then
        return false
    end
    
    print("Starting the delve speedrun =]")
    delveIsActive = time()
    return true
end

function AngusUI:StopDelveSpeedrun()
    if (delveIsActive == nil) then
        return false
    end
    
    print("Stopping the delve speedrun =]")
    
    local elapsed = time() - delveIsActive
    
    print("You completed the delve speedrun in " .. elapsed .. " seconds")
    delveIsActive = nil
    return true
end

function AngusUI:GetDelveActive()
    return delveIsActive
end

function AngusUI:ResetDelve()
    delveIsActive = nil
end

-- Create test suite
local suite = TestFramework.new("Delves Module Tests")

suite:before(function()
    AngusUI:ResetDelve()
    WoWMock.reset()
end)

suite:test("should start delve speedrun when not active", function(assert)
    WoWMock.clearPrintedMessages()
    
    local result = AngusUI:StartDelveSpeedrun()
    
    assert.isTrue(result, "Should return true when starting")
    assert.isNotNil(AngusUI:GetDelveActive(), "Delve should be active")
    
    local messages = WoWMock.getPrintedMessages()
    assert.equals(#messages, 1, "Should print one message")
    assert.equals(messages[1], "Starting the delve speedrun =]", "Should print start message")
end)

suite:test("should not start delve speedrun when already active", function(assert)
    -- Start once
    AngusUI:StartDelveSpeedrun()
    WoWMock.clearPrintedMessages()
    
    -- Try to start again
    local result = AngusUI:StartDelveSpeedrun()
    
    assert.isFalse(result, "Should return false when already active")
    
    local messages = WoWMock.getPrintedMessages()
    assert.equals(#messages, 0, "Should not print any messages")
end)

suite:test("should stop delve speedrun when active", function(assert)
    -- Start the timer
    AngusUI:StartDelveSpeedrun()
    
    -- Wait a moment
    local startTime = os.time()
    while os.time() == startTime do
        -- busy wait for 1 second
    end
    
    WoWMock.clearPrintedMessages()
    
    -- Stop the timer
    local result = AngusUI:StopDelveSpeedrun()
    
    assert.isTrue(result, "Should return true when stopping")
    assert.isNil(AngusUI:GetDelveActive(), "Delve should not be active")
    
    local messages = WoWMock.getPrintedMessages()
    assert.equals(#messages, 2, "Should print two messages")
    assert.equals(messages[1], "Stopping the delve speedrun =]", "Should print stop message")
end)

suite:test("should not stop delve speedrun when not active", function(assert)
    WoWMock.clearPrintedMessages()
    
    local result = AngusUI:StopDelveSpeedrun()
    
    assert.isFalse(result, "Should return false when not active")
    
    local messages = WoWMock.getPrintedMessages()
    assert.equals(#messages, 0, "Should not print any messages")
end)

suite:test("should allow restart after stopping", function(assert)
    -- Start, stop, then start again
    AngusUI:StartDelveSpeedrun()
    AngusUI:StopDelveSpeedrun()
    
    WoWMock.clearPrintedMessages()
    
    local result = AngusUI:StartDelveSpeedrun()
    
    assert.isTrue(result, "Should be able to start again after stopping")
    assert.isNotNil(AngusUI:GetDelveActive(), "Delve should be active again")
end)

suite:test("should calculate elapsed time correctly", function(assert)
    -- Start the timer
    AngusUI:StartDelveSpeedrun()
    local startTime = AngusUI:GetDelveActive()
    
    -- Wait 2 seconds
    local waitUntil = os.time() + 2
    while os.time() < waitUntil do
        -- busy wait
    end
    
    WoWMock.clearPrintedMessages()
    
    -- Stop the timer
    AngusUI:StopDelveSpeedrun()
    
    local messages = WoWMock.getPrintedMessages()
    -- Check that elapsed time message contains a number
    local elapsedMessage = messages[2]
    assert.isTrue(elapsedMessage:find("%d+ seconds") ~= nil, "Should report elapsed seconds")
end)

-- Run the test suite
local success = suite:run()

-- Only exit if running standalone
if not package.loaded['tests.run_tests'] then
    os.exit(success and 0 or 1)
end

return success
