# AngusUI Unit Tests

This directory contains unit tests for the AngusUI World of Warcraft addon with mocked WoW API functions.

## Overview

Since WoW addons run inside the game client, we've created a testing framework that:
- Mocks the WoW API (C_QuestLog, C_EditMode, CreateFrame, etc.)
- Simulates game events
- Tests addon functionality without requiring the game

## Test Framework

### Components

1. **test_framework.lua** - Simple unit testing framework
   - Test suite creation
   - Assertion helpers (equals, isTrue, isNil, etc.)
   - Mock object creation
   - Test runner with colored output

2. **wow_mock.lua** - WoW API mocks
   - Simulates quest completion status
   - Mocks achievement data
   - Simulates screen resolutions
   - Mocks item and inventory systems
   - Captures print() output for testing

3. **Test Files**
   - `test_ui.lua` - Tests for UI layout switching
   - `test_delves.lua` - Tests for delve speedrun timer
   - `test_crests.lua` - Tests for crest quest tracking

## Running Tests

### Run All Tests
```bash
cd /home/runner/work/AngusUI/AngusUI
lua5.3 tests/run_tests.lua
```

### Run Individual Test
```bash
lua5.3 tests/test_ui.lua
lua5.3 tests/test_delves.lua
lua5.3 tests/test_crests.lua
```

## Writing New Tests

### Basic Test Structure

```lua
local TestFramework = require("tests.test_framework")
local WoWMock = require("tests.wow_mock")

-- Set up WoW mocks
WoWMock.setup()

-- Create test suite
local suite = TestFramework.new("My Test Suite")

-- Setup before each test
suite:before(function()
    WoWMock.reset()
end)

-- Add a test
suite:test("should do something", function(assert)
    -- Arrange
    WoWMock.setQuestCompleted(12345, true)
    
    -- Act
    local result = MyFunction()
    
    -- Assert
    assert.isTrue(result)
end)

-- Run tests
local success = suite:run()
os.exit(success and 0 or 1)
```

### Available Assertions

- `assert.equals(actual, expected, message)`
- `assert.notEquals(actual, expected, message)`
- `assert.isTrue(value, message)`
- `assert.isFalse(value, message)`
- `assert.isNil(value, message)`
- `assert.isNotNil(value, message)`
- `assert.throws(func, message)`

### Mocking WoW API

```lua
-- Quest completion
WoWMock.setQuestCompleted(questId, true)

-- Achievements
WoWMock.setAchievement(achievementId, {
    id = achievementId,
    name = "Achievement Name",
    wasEarnedByMe = true
})

-- Screen size
WoWMock.setScreenSize(1920, 1080)

-- Layouts
WoWMock.setLayouts({
    activeLayout = 5,
    layouts = {
        {layoutName = "Layout 1"},
        {layoutName = "Layout 2"}
    }
})

-- Inventory
WoWMock.setInventorySlot(slotId, itemLevel)

-- Items
WoWMock.setItem(itemId, count, cooldown)

-- Equipped back item
WoWMock.setEquippedBack(itemId)

-- Check printed messages
local messages = WoWMock.getPrintedMessages()
WoWMock.clearPrintedMessages()
```

### Creating Mocks for Testing

```lua
-- Create a mock object
local mockFrame = TestFramework.createMock()

-- Set return values
TestFramework.mockReturn(mockFrame, "GetWidth", 100)

-- Use the mock
local width = mockFrame:GetWidth()  -- Returns 100

-- Verify method was called
assert.isTrue(TestFramework.wasCalled(mockFrame, "GetWidth"))

-- Check call count
local count = TestFramework.callCount(mockFrame, "GetWidth")
assert.equals(count, 1)

-- Get call arguments
local args = TestFramework.getCallArgs(mockFrame, "SomeMethod", 1)
```

## Test Coverage

### UI.lua Tests
- ✓ Early return for nil layouts
- ✓ Early return for activeLayout < 3
- ✓ 4K layout selection (3840x2160, 2560x1440)
- ✓ Ultrawide layout selection (aspect ratio > 2:1)
- ✓ Default layout selection (standard resolutions)
- ✓ Non-AngusUI layout handling
- ✓ Case-insensitive layout name matching

### Delves.lua Tests
- ✓ Start speedrun when not active
- ✓ Prevent starting when already active
- ✓ Stop speedrun when active
- ✓ Prevent stopping when not active
- ✓ Allow restart after stopping (nil vs false fix)
- ✓ Elapsed time calculation

### Crests.lua Tests
- ✓ Print completed quests in green
- ✓ Print incomplete quests in red
- ✓ Warning for missing achievements
- ✓ Print slots needing upgrade
- ✓ Handle all achievements earned

## Continuous Integration

To add these tests to CI/CD:

1. Install Lua 5.3 in CI environment
2. Run `lua5.3 tests/run_tests.lua`
3. Check exit code (0 = success, 1 = failure)

Example GitHub Actions:
```yaml
- name: Run Tests
  run: |
    sudo apt-get install -y lua5.3
    lua5.3 tests/run_tests.lua
```

## Limitations

- Tests run outside WoW, so some integration testing still needed in-game
- Some UI interactions can't be fully tested without the actual game client
- Event timing and frame updates are simulated, not real

## Future Improvements

- Add tests for TeleportBack.lua
- Add tests for Reputations.lua
- Add tests for MythicPlus.lua
- Add integration tests that run in-game
- Add performance benchmarks
- Add code coverage reporting

## Requirements

- Lua 5.3 or higher
- No external dependencies (self-contained framework)

## Troubleshooting

### "module not found" errors
Make sure you're running tests from the repository root:
```bash
cd /home/runner/work/AngusUI/AngusUI
lua5.3 tests/test_ui.lua
```

### Tests fail with nil errors
Check that WoWMock.setup() is called before loading modules

### Assertion failures
Review the error message - it shows expected vs actual values

## Contributing

When adding new features to AngusUI:
1. Write tests first (TDD approach recommended)
2. Run all tests to ensure no regressions
3. Add new test cases for your feature
4. Update this README if adding new test utilities

---

**Note:** These tests validate the logic of the addon code but don't replace the need for in-game testing. Always test changes in World of Warcraft before releasing.
