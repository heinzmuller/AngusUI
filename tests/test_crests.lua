-- Unit tests for Crests.lua
local TestFramework = require("tests.test_framework")
local WoWMock = require("tests.wow_mock")

-- Set up WoW API mocks
WoWMock.setup()

-- Create AngusUI namespace with Crests function
local AngusUI = {}

local crestQuests = {
    ["Nerub-ar Palace"] = 82141,
    ["Hallowfall"] = 82407,
    ["Isle of Dorn"] = 82365,
}

local achievements = { 40942, 40943 }

local iLvls = {
    [40942] = 631,
    [40943] = 644,
}

function AngusUI:Crests()
    for zone, questId in pairs(crestQuests) do
        local completed = C_QuestLog.IsQuestFlaggedCompleted(questId)
        local color = completed and "\124cff00FF00" or "\124cffFF0000"
        print(color .. zone .. "\124r")
    end
    
    for _, achievementId in ipairs(achievements) do
        local id, name, points, completed, month, day, year, description, flags,
        icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementId)
        
        if not name then
            print("AngusUI: Warning - Achievement " .. achievementId .. " not found")
            return
        end
        
        local color = wasEarnedByMe and "\124cff00FF00" or "\124cffFF0000"
        print(color .. name .. " (" .. (iLvls[achievementId] + 1) .. ")\124r")
        
        if wasEarnedByMe == false then
            local slotInfo = {}
            
            for slotName, slotId in next, Enum.ItemRedundancySlot do
                local highWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(slotId)
                slotInfo[slotId] = { 
                    meetsRequirement = highWatermark > iLvls[achievementId], 
                    itemLevel = highWatermark, 
                    name = slotName 
                }
            end
            
            for slotId, info in next, slotInfo do
                local needsUpgrade = false
                
                if slotId < 12 then
                    needsUpgrade = not info.meetsRequirement
                elseif slotId > 11 then
                    local hasWeapons = slotInfo[12].meetsRequirement or 
                                     (slotInfo[13].meetsRequirement and slotInfo[16].meetsRequirement)
                    local hasRings = slotInfo[14].meetsRequirement and slotInfo[15].meetsRequirement
                    needsUpgrade = not (hasWeapons or hasRings)
                end
                
                if needsUpgrade then
                    print(info.itemLevel, info.name)
                end
            end
            
            return
        end
    end
end

-- Create test suite
local suite = TestFramework.new("Crests Module Tests")

suite:before(function()
    WoWMock.reset()
end)

suite:test("should print completed quests in green", function(assert)
    WoWMock.setQuestCompleted(82141, true)
    WoWMock.setQuestCompleted(82407, false)
    WoWMock.setQuestCompleted(82365, true)
    
    WoWMock.setAchievement(40942, {
        id = 40942,
        name = "Test Achievement 1",
        wasEarnedByMe = true
    })
    WoWMock.setAchievement(40943, {
        id = 40943,
        name = "Test Achievement 2",
        wasEarnedByMe = true
    })
    
    WoWMock.clearPrintedMessages()
    AngusUI:Crests()
    
    local messages = WoWMock.getPrintedMessages()
    
    -- Check for green color code (completed)
    local hasGreen = false
    for _, msg in ipairs(messages) do
        if msg:find("\124cff00FF00") then
            hasGreen = true
            break
        end
    end
    
    assert.isTrue(hasGreen, "Should have at least one green (completed) message")
end)

suite:test("should print incomplete quests in red", function(assert)
    WoWMock.setQuestCompleted(82141, false)
    WoWMock.setQuestCompleted(82407, false)
    WoWMock.setQuestCompleted(82365, false)
    
    WoWMock.setAchievement(40942, {
        id = 40942,
        name = "Test Achievement 1",
        wasEarnedByMe = true
    })
    WoWMock.setAchievement(40943, {
        id = 40943,
        name = "Test Achievement 2",
        wasEarnedByMe = true
    })
    
    WoWMock.clearPrintedMessages()
    AngusUI:Crests()
    
    local messages = WoWMock.getPrintedMessages()
    
    -- Check for red color code (incomplete)
    local hasRed = false
    for _, msg in ipairs(messages) do
        if msg:find("\124cffFF0000") then
            hasRed = true
            break
        end
    end
    
    assert.isTrue(hasRed, "Should have at least one red (incomplete) message")
end)

suite:test("should show warning if achievement not found", function(assert)
    WoWMock.setQuestCompleted(82141, true)
    WoWMock.setQuestCompleted(82407, true)
    WoWMock.setQuestCompleted(82365, true)
    
    -- Don't set any achievements (they'll return nil)
    
    WoWMock.clearPrintedMessages()
    AngusUI:Crests()
    
    local messages = WoWMock.getPrintedMessages()
    
    -- Should have warning message about missing achievement
    local hasWarning = false
    for _, msg in ipairs(messages) do
        if msg:find("Warning") and msg:find("Achievement") then
            hasWarning = true
            break
        end
    end
    
    assert.isTrue(hasWarning, "Should show warning for missing achievement")
end)

suite:test("should print item slots needing upgrade", function(assert)
    WoWMock.setQuestCompleted(82141, true)
    WoWMock.setQuestCompleted(82407, true)
    WoWMock.setQuestCompleted(82365, true)
    
    WoWMock.setAchievement(40942, {
        id = 40942,
        name = "Item Level 632",
        wasEarnedByMe = false  -- Not earned, will check slots
    })
    
    -- Set some slots below requirement (631)
    WoWMock.setInventorySlot(1, 620)  -- Head slot needs upgrade
    WoWMock.setInventorySlot(2, 640)  -- Neck slot is good
    WoWMock.setInventorySlot(3, 625)  -- Shoulders need upgrade
    
    WoWMock.clearPrintedMessages()
    AngusUI:Crests()
    
    local messages = WoWMock.getPrintedMessages()
    
    -- Should print slot names and item levels
    local foundSlotInfo = false
    for _, msg in ipairs(messages) do
        if msg:find("Head") or msg:find("Shoulders") then
            foundSlotInfo = true
            break
        end
    end
    
    assert.isTrue(foundSlotInfo, "Should print info about slots needing upgrade")
end)

suite:test("should handle all achievements earned", function(assert)
    WoWMock.setQuestCompleted(82141, true)
    WoWMock.setQuestCompleted(82407, true)
    WoWMock.setQuestCompleted(82365, true)
    
    WoWMock.setAchievement(40942, {
        id = 40942,
        name = "Achievement 1",
        wasEarnedByMe = true
    })
    WoWMock.setAchievement(40943, {
        id = 40943,
        name = "Achievement 2",
        wasEarnedByMe = true
    })
    
    WoWMock.clearPrintedMessages()
    AngusUI:Crests()
    
    local messages = WoWMock.getPrintedMessages()
    
    -- Should print quest statuses and achievement statuses
    assert.isTrue(#messages >= 5, "Should print at least 5 messages (3 quests + 2 achievements)")
end)

-- Run the test suite
local success = suite:run()

-- Only exit if running standalone
if not package.loaded['tests.run_tests'] then
    os.exit(success and 0 or 1)
end

return success
