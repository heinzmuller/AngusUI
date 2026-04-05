local _, AngusUI = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("TASK_PROGRESS_UPDATE")
frame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:RegisterEvent("NEW_MOUNT_ADDED")
frame:RegisterEvent("NEW_PET_ADDED")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("UNIT_AURA")

local function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local function SlashCommand(command)
    local commands = {
        back = function() AngusUI:TeleportBack() end,
        rep = function() AngusUI:Reputations() end,
        crests = function() AngusUI:Crests() end,
        ui = function() AngusUI:UI() end,
        toast = function() AngusUI:ShowChoresToast(true) end,
    }

    if commands[command] then
        commands[command]()
    else
        print("These are the commands you're looking for")
        for availableCommand, _ in pairs(commands) do
            print("/aui " .. availableCommand)
        end
    end
end

SlashCmdList.ANGUSUI = SlashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"
function frame:ADDON_LOADED(self, addon)
    if (addon == "AngusUI") then
        if AngusUI.SettingsInit then
            AngusUI:SettingsInit()
        end

        if AngusUI.ChoresInit then
            AngusUI:ChoresInit()
        end
    end

    if (addon == "Blizzard_TimeManager") then
        AngusUI:ApplyTheme()
        AngusUI:FriendsFrame()
    end

    if (addon == "Blizzard_CharacterUI") then
        AngusUI:CharacterPanel()
    end

    if (addon == "Blizzard_PlayerSpells") then
        AngusUI:TalentRecommendations()
    end

    if (addon == "Blizzard_UnitFrame") then
        AngusUI:PartyFrames()
    end
end

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if (event == "ADDON_LOADED") then
            self:ADDON_LOADED(self, ...)
        end

        if (event == "PLAYER_ENTERING_WORLD") then
            AngusUI:ApplyTheme()
            AngusUI:FriendsFrame()
            AngusUI:CharacterPanel()
            AngusUI:TalentRecommendations()
            AngusUI:PartyFrames()
            if AngusUI.ChoresRefresh then
                AngusUI:ChoresRefresh()
            end
            if AngusUI.QueueChoresGildedRefresh then
                AngusUI:QueueChoresGildedRefresh()
            end
            AngusUI:ShowChoresToast()
        end

        if (event == "CURRENCY_DISPLAY_UPDATE") then
            if AngusUI.ChoresHandleCurrencyUpdate then
                AngusUI:ChoresHandleCurrencyUpdate(...)
            end
        end

        if (event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "PLAYER_ENTERING_WORLD") then
            AngusUI:UI()
            AngusUI:TalentRecommendations()
            AngusUI:TalentRecommendationsRefresh()
        end

        if (event == "PLAYER_EQUIPMENT_CHANGED") or (event == "GET_ITEM_INFO_RECEIVED") or (event == "BAG_UPDATE_DELAYED") then
            AngusUI:CharacterPanel()
        end

        if
            (event == "PLAYER_ENTERING_WORLD") or
            (event == "BAG_UPDATE_DELAYED") or
            ((event == "UNIT_AURA") and (...) == "player") or
            (event == "PLAYER_EQUIPMENT_CHANGED") or
            (event == "GET_ITEM_INFO_RECEIVED") or
            (event == "QUEST_LOG_UPDATE") or
            (event == "QUEST_ACCEPTED") or
            (event == "QUEST_REMOVED") or
            (event == "TASK_PROGRESS_UPDATE") or
            (event == "QUEST_WATCH_LIST_CHANGED")
        then
            AngusUI:QueueWorldQuestIconsRefresh()
            if AngusUI.ChoresRefresh then
                AngusUI:ChoresRefresh()
            end
        end

        if (event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
            if (ChallengesFrame == nil) then
                return
            end

            AngusUI:MythicPlus()
            self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
        end

        if (event == "PLAYER_LEVEL_UP") then
            AngusUI:TakeLevelUpScreenshot(...)
        end

        if (event == "ACHIEVEMENT_EARNED") then
            AngusUI:TakeAchievementScreenshot(...)
        end

        if (event == "NEW_MOUNT_ADDED") then
            AngusUI:TakeMountScreenshot(...)
        end

        if (event == "NEW_PET_ADDED") then
            AngusUI:TakePetScreenshot(...)
        end
    end
)
