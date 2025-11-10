#!/usr/bin/env lua5.3
-- Test Runner for AngusUI
-- Runs all unit tests and reports results

-- Mark that we're running from test runner
package.loaded['tests.run_tests'] = true

local exitCode = 0

print("========================================")
print("   AngusUI Test Suite")
print("========================================")
print("")

-- Test files to run
local testFiles = {
    "tests/test_ui.lua",
    "tests/test_delves.lua",
    "tests/test_crests.lua"
}

-- Run each test file
for _, testFile in ipairs(testFiles) do
    print("\n▶ Running " .. testFile .. "...")
    
    local success, result = pcall(function()
        return dofile(testFile)
    end)
    
    if success and result == true then
        print("✓ " .. testFile .. " PASSED")
    else
        exitCode = 1
        print("✗ " .. testFile .. " FAILED")
        if not success then
            print("  Error: " .. tostring(result))
        end
    end
end

-- Print final summary
print("\n========================================")
if exitCode == 0 then
    print("✓ ALL TESTS PASSED")
else
    print("✗ SOME TESTS FAILED")
end
print("========================================\n")

os.exit(exitCode)
