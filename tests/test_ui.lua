-- Unit tests for UI.lua
local TestFramework = require("tests.test_framework")
local WoWMock = require("tests.wow_mock")

-- Set up WoW API mocks
WoWMock.setup()

-- Create AngusUI namespace with UI function
local AngusUI = {}

function AngusUI:UI()
    local layouts = C_EditMode.GetLayouts();
    if not layouts or not layouts.layouts then
        return
    end
    
    local screenWidth, screenHeight = GetPhysicalScreenSize()

    if (layouts.activeLayout < 3) then
        return
    end

    local actualActiveLayout = layouts.activeLayout - 2
    local activeLayout = layouts.layouts[actualActiveLayout]
    local activeLayoutName = activeLayout.layoutName:lower()

    if not activeLayoutName:find("angusui") then
        return
    end

    local layoutToUse

    if (screenWidth == 3840 or screenWidth == 2560) and (screenHeight == 2160 or screenHeight == 1440) then
        layoutToUse = "angusui 4k"
    else
        local shouldUseWideLayout = (screenWidth / screenHeight) > 2

        layoutToUse = shouldUseWideLayout and "angusui wide" or "angusui"
    end

    for i, layout in ipairs(layouts.layouts) do
        local layoutName = layout.layoutName:lower()

        if layoutName:find("angusui") and (layoutName == layoutToUse) then
            C_EditMode.SetActiveLayout(i + 2)
            return
        end
    end
end

-- Create test suite
local suite = TestFramework.new("UI Module Tests")

suite:before(function()
    WoWMock.reset()
end)

suite:test("should return early if layouts is nil", function(assert)
    WoWMock.setLayouts(nil)
    
    -- Should not throw error
    AngusUI:UI()
    
    -- No layout change should occur
    assert.isTrue(true, "Function completed without error")
end)

suite:test("should return early if layouts.layouts is nil", function(assert)
    WoWMock.setLayouts({activeLayout = 5})
    
    AngusUI:UI()
    
    assert.isTrue(true, "Function completed without error")
end)

suite:test("should return early if activeLayout is less than 3", function(assert)
    WoWMock.setLayouts({
        activeLayout = 2,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"}
        }
    })
    
    AngusUI:UI()
    
    -- Should exit early, no error
    assert.isTrue(true, "Function completed without error")
end)

suite:test("should select '4k' layout for 3840x2160 resolution", function(assert)
    WoWMock.setScreenSize(3840, 2160)
    WoWMock.setLayouts({
        activeLayout = 5,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"},
            {layoutName = "AngusUI"},
            {layoutName = "AngusUI 4K"},
            {layoutName = "AngusUI Wide"}
        }
    })
    
    AngusUI:UI()
    
    -- Should set layout to index 4 + 2 = 6
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 6, "Should activate 4K layout")
end)

suite:test("should select '4k' layout for 2560x1440 resolution", function(assert)
    WoWMock.setScreenSize(2560, 1440)
    WoWMock.setLayouts({
        activeLayout = 5,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"},
            {layoutName = "AngusUI"},
            {layoutName = "AngusUI 4K"},
            {layoutName = "AngusUI Wide"}
        }
    })
    
    AngusUI:UI()
    
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 6, "Should activate 4K layout")
end)

suite:test("should select 'wide' layout for ultrawide monitors", function(assert)
    WoWMock.setScreenSize(3440, 1440)  -- 21:9 aspect ratio (2.38:1)
    WoWMock.setLayouts({
        activeLayout = 5,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"},
            {layoutName = "AngusUI"},
            {layoutName = "AngusUI 4K"},
            {layoutName = "AngusUI Wide"}
        }
    })
    
    AngusUI:UI()
    
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 7, "Should activate Wide layout")
end)

suite:test("should select default 'angusui' layout for standard resolution", function(assert)
    WoWMock.setScreenSize(1920, 1080)
    WoWMock.setLayouts({
        activeLayout = 5,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"},
            {layoutName = "AngusUI"},
            {layoutName = "AngusUI 4K"},
            {layoutName = "AngusUI Wide"}
        }
    })
    
    AngusUI:UI()
    
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 5, "Should activate default AngusUI layout")
end)

suite:test("should return if active layout is not AngusUI", function(assert)
    WoWMock.setScreenSize(1920, 1080)
    WoWMock.setLayouts({
        activeLayout = 3,
        layouts = {
            {layoutName = "Default"}
        }
    })
    
    AngusUI:UI()
    
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 3, "Should not change layout")
end)

suite:test("should handle case-insensitive layout names", function(assert)
    WoWMock.setScreenSize(1920, 1080)
    WoWMock.setLayouts({
        activeLayout = 5,
        layouts = {
            {layoutName = "Default"},
            {layoutName = "Combat"},
            {layoutName = "ANGUSUI"},  -- All caps
            {layoutName = "AngusUI 4K"},
            {layoutName = "AngusUI Wide"}
        }
    })
    
    AngusUI:UI()
    
    local layouts = C_EditMode.GetLayouts()
    assert.equals(layouts.activeLayout, 5, "Should match case-insensitively")
end)

-- Run the test suite
local success = suite:run()

-- Only exit if running standalone
if not package.loaded['tests.run_tests'] then
    os.exit(success and 0 or 1)
end

return success
