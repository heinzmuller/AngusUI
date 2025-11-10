-- WoW API Mocks
-- Simulates World of Warcraft API functions for testing

local WoWMock = {}

-- Preserve original print
local originalPrint = print

-- Mock global functions that addons rely on
function WoWMock.setup()
    -- Global state
    _G.mockState = {
        questsCompleted = {},
        achievements = {},
        inventory = {},
        layouts = {},
        screenSize = {width = 1920, height = 1080},
        items = {},
        printedMessages = {}
    }
    
    -- Mock print function to capture output AND print to console
    _G.print = function(...)
        local args = {...}
        local message = ""
        for i, v in ipairs(args) do
            message = message .. tostring(v)
            if i < #args then
                message = message .. "\t"
            end
        end
        table.insert(_G.mockState.printedMessages, message)
        -- Also print to actual console
        originalPrint(message)
    end
    
    -- Mock CreateFrame
    _G.CreateFrame = function(frameType, name, parent, template)
        local frame = {
            frameType = frameType,
            name = name,
            parent = parent,
            template = template,
            scripts = {},
            children = {},
            shown = false,
            points = {},
            size = {width = 0, height = 0}
        }
        
        function frame:RegisterEvent(event)
            -- Mock event registration
        end
        
        function frame:UnregisterEvent(event)
            -- Mock event unregistration
        end
        
        function frame:SetScript(scriptType, handler)
            self.scripts[scriptType] = handler
        end
        
        function frame:SetSize(width, height)
            self.size.width = width
            self.size.height = height
        end
        
        function frame:SetPoint(...)
            table.insert(self.points, {...})
        end
        
        function frame:SetMovable(movable)
            self.movable = movable
        end
        
        function frame:EnableMouse(enable)
            self.mouseEnabled = enable
        end
        
        function frame:RegisterForDrag(button)
            self.dragButton = button
        end
        
        function frame:Show()
            self.shown = true
        end
        
        function frame:Hide()
            self.shown = false
        end
        
        function frame:CreateFontString(name, layer, template)
            local fontString = {
                text = "",
                font = nil,
                fontSize = 12
            }
            
            function fontString:SetText(text)
                self.text = text
            end
            
            function fontString:SetFont(font, size)
                self.font = font
                self.fontSize = size
            end
            
            function fontString:SetPoint(...)
                -- Mock point setting
            end
            
            return fontString
        end
        
        function frame:GetWidth()
            return self.size.width
        end
        
        function frame:GetHeight()
            return self.size.height
        end
        
        function frame:SetWidth(width)
            self.size.width = width
        end
        
        function frame:SetHeight(height)
            self.size.height = height
        end
        
        -- Mock TitleBg for frame templates
        frame.TitleBg = {
            Center = {}
        }
        
        return frame
    end
    
    -- Mock C_QuestLog API
    _G.C_QuestLog = {
        IsQuestFlaggedCompleted = function(questId)
            return _G.mockState.questsCompleted[questId] == true
        end,
        
        GetTitleForQuestID = function(questId)
            return "Quest " .. questId
        end
    }
    
    -- Mock C_EditMode API
    _G.C_EditMode = {
        GetLayouts = function()
            return _G.mockState.layouts
        end,
        
        SetActiveLayout = function(layoutIndex)
            _G.mockState.layouts.activeLayout = layoutIndex
        end
    }
    
    -- Mock GetPhysicalScreenSize
    _G.GetPhysicalScreenSize = function()
        return _G.mockState.screenSize.width, _G.mockState.screenSize.height
    end
    
    -- Mock GetAchievementInfo
    _G.GetAchievementInfo = function(achievementId)
        local achievement = _G.mockState.achievements[achievementId]
        if achievement then
            return achievement.id,
                   achievement.name,
                   achievement.points,
                   achievement.completed,
                   achievement.month,
                   achievement.day,
                   achievement.year,
                   achievement.description,
                   achievement.flags,
                   achievement.icon,
                   achievement.rewardText,
                   achievement.isGuild,
                   achievement.wasEarnedByMe,
                   achievement.earnedBy,
                   achievement.isStatistic
        end
        return nil
    end
    
    -- Mock C_ItemUpgrade API
    _G.C_ItemUpgrade = {
        GetHighWatermarkForSlot = function(slotId)
            return _G.mockState.inventory[slotId] or 600
        end
    }
    
    -- Mock Enum
    _G.Enum = {
        ItemRedundancySlot = {
            Head = 1,
            Neck = 2,
            Shoulders = 3,
            Chest = 5,
            Waist = 6,
            Legs = 7,
            Feet = 8,
            Wrist = 9,
            Hands = 10,
            Finger1 = 11,
            MainHand = 12,
            OffHand = 13,
            Finger2 = 14,
            Trinket1 = 15,
            TwoHand = 16
        }
    }
    
    -- Mock time function
    _G.time = function()
        return os.time()
    end
    
    -- Mock GetInventoryItemID
    _G.GetInventoryItemID = function(unit, slotId)
        if unit == "player" and slotId == 15 then
            return _G.mockState.equippedBackId
        end
        return nil
    end
    
    -- Mock C_Item API
    _G.C_Item = {
        GetItemCount = function(itemId, includeBank)
            return _G.mockState.items[itemId] or 0
        end,
        
        GetItemCooldown = function(itemId)
            return _G.mockState.items[itemId .. "_cooldown"] or 0
        end,
        
        EquipItemByName = function(itemId)
            _G.mockState.equippedBackId = itemId
        end,
        
        GetItemGUID = function(itemLocation)
            return "Item-0-0-0-0-" .. math.random(10000, 99999)
        end
    }
    
    -- Mock C_Container API
    _G.C_Container = {
        GetItemCooldown = function(itemId)
            return _G.mockState.items[itemId .. "_cooldown"] or 0
        end
    }
    
    -- Mock ItemLocation
    _G.ItemLocation = {
        CreateFromEquipmentSlot = function(slot)
            return {
                IsValid = function()
                    return _G.mockState.equippedBackId ~= nil
                end
            }
        end
    }
    
    -- Mock INVSLOT constants
    _G.INVSLOT_BACK = 15
    
    -- Mock color constants
    _G.RARE_BLUE_COLOR = {
        WrapTextInColorCode = function(text)
            return "|cff0070dd" .. text .. "|r"
        end
    }
    
    _G.ITEM_EPIC_COLOR = {
        WrapTextInColorCode = function(text)
            return "|cffa335ee" .. text .. "|r"
        end
    }
    
    _G.ITEM_LEGENDARY_COLOR = {
        WrapTextInColorCode = function(text)
            return "|cffff8000" .. text .. "|r"
        end
    }
    
    -- Mock UIParent
    _G.UIParent = CreateFrame("Frame", "UIParent")
    
    -- Mock ChallengesFrame
    _G.ChallengesFrame = {
        WeeklyInfo = CreateFrame("Frame", "WeeklyInfo")
    }
end

-- Helper functions for tests
function WoWMock.setQuestCompleted(questId, completed)
    _G.mockState.questsCompleted[questId] = completed
end

function WoWMock.setAchievement(achievementId, data)
    _G.mockState.achievements[achievementId] = data
end

function WoWMock.setScreenSize(width, height)
    _G.mockState.screenSize = {width = width, height = height}
end

function WoWMock.setLayouts(layouts)
    _G.mockState.layouts = layouts
end

function WoWMock.setInventorySlot(slotId, itemLevel)
    _G.mockState.inventory[slotId] = itemLevel
end

function WoWMock.setItem(itemId, count, cooldown)
    _G.mockState.items[itemId] = count
    if cooldown then
        _G.mockState.items[itemId .. "_cooldown"] = cooldown
    end
end

function WoWMock.setEquippedBack(itemId)
    _G.mockState.equippedBackId = itemId
end

function WoWMock.getPrintedMessages()
    return _G.mockState.printedMessages
end

function WoWMock.clearPrintedMessages()
    _G.mockState.printedMessages = {}
end

function WoWMock.reset()
    _G.mockState = {
        questsCompleted = {},
        achievements = {},
        inventory = {},
        layouts = {},
        screenSize = {width = 1920, height = 1080},
        items = {},
        printedMessages = {}
    }
end

return WoWMock
