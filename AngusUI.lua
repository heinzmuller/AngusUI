local _, AngusUI = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LOADING_SCREEN_DISABLED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
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
frame:RegisterEvent("ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED")
frame:RegisterEvent("CURRENCY_TRANSFER_LOG_UPDATE")
frame:RegisterEvent("ACCOUNT_MONEY")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
frame:RegisterEvent("TRADE_SKILL_DETAILS_UPDATE")
frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
frame:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED")
frame:RegisterEvent("LFG_UPDATE_RANDOM_INFO")

local function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local ADDON_NAME = "|cff0f7a0fAngus|cff7be426UI|r"
local PRINT_PREFIX = "|cff000000[|r" .. ADDON_NAME .. "|cff000000]|r"

function AngusUI:Print(...)
    if select("#", ...) == 0 then
        print(PRINT_PREFIX)
        return
    end

    print(PRINT_PREFIX .. " |cffffffff" .. strjoin(" ", tostringall(...)) .. "|r")
end

local function SlashCommand(command)
    command = command and strlower(strtrim(command)) or ""

    local commands = {
        back = function() AngusUI:TeleportBack() end,
        rep = function() AngusUI:Reputations() end,
        crests = function() AngusUI:Crests() end,
        treasuredebug = function() AngusUI:ToggleTreasureDebug() end,
        treasuredump = function() AngusUI:DumpTreasureDebug() end,
        ui = function() AngusUI:UI() end,
        toast = function() AngusUI:ShowChoresToast(true) end,
    }

    if commands[command] then
        commands[command]()
    else
        AngusUI:Print("These are the commands you're looking for")
        for availableCommand, _ in pairs(commands) do
            AngusUI:Print("/aui " .. availableCommand)
        end
    end
end

SlashCmdList.ANGUSUI = SlashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"
function frame:ADDON_LOADED(self, addon)
    if (addon == "AngusUI") then
        if AngusUI.ItemOverlays then
            AngusUI:ItemOverlays()
        end

        if AngusUI.BankInit then
            AngusUI:BankInit()
        end

        if AngusUI.MailInit then
            AngusUI:MailInit()
        end

        if AngusUI.SettingsInit then
            AngusUI:SettingsInit()
        end

        if AngusUI.GreatVaultInit then
            AngusUI:GreatVaultInit()
        end

        if AngusUI.ChoresInit then
            AngusUI:ChoresInit()
        end

        if AngusUI.DelvesInit then
            AngusUI:DelvesInit()
        end

        if AngusUI.SyncInit then
            AngusUI:SyncInit()
        end

        if AngusUI.TreasuresInit then
            AngusUI:TreasuresInit()
        end
    end

    if (addon == "Blizzard_TimeManager") then
        AngusUI:ApplyTheme()
        AngusUI:FriendsFrame()
    end

    if (addon == "Blizzard_CharacterUI") then
        if AngusUI.ItemOverlays then
            AngusUI:ItemOverlays()
        end

        if AngusUI.CharacterInit then
            AngusUI:CharacterInit()
        end
        AngusUI:RefreshCharacterPanel()
    end

    if (addon == "Blizzard_UIPanels_Game") then
        if AngusUI.ItemOverlays then
            AngusUI:ItemOverlays()
        end

        if AngusUI.BankInit then
            AngusUI:BankInit()
        end

        if AngusUI.MailInit then
            AngusUI:MailInit()
        end
    end

    if (addon == "Blizzard_PlayerSpells") then
        AngusUI:TalentRecommendationsRefresh()
    end

    if (addon == "Blizzard_ProfessionsTemplates") or (addon == "Blizzard_Professions") then
        if AngusUI.ProfessionLinksInit then
            AngusUI:ProfessionLinksInit()
        end
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
            local initialLogin, isReloadingUI = ...
            AngusUI:EnableActionRangeOverlay()
            AngusUI:ApplyTheme()
            AngusUI:FriendsFrame()
            if AngusUI.CharacterInit then
                AngusUI:CharacterInit()
            end
            AngusUI:RefreshCharacterPanel()
            AngusUI:TalentRecommendationsRefresh()
            AngusUI:PartyFrames()
            if AngusUI.ProfessionLinksInit then
                AngusUI:ProfessionLinksInit()
            end
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh()
            end
            if AngusUI.QueueSyncGildedRefresh then
                AngusUI:QueueSyncGildedRefresh()
            end

            if initialLogin or isReloadingUI then
                AngusUI.choresInitialToastPending = true
            end
        end

        if (event == "LOADING_SCREEN_DISABLED") then
            if AngusUI.choresInitialToastPending then
                AngusUI.choresInitialToastPending = false
                if AngusUI.ShowInitialChoresToast then
                    AngusUI:ShowInitialChoresToast()
                else
                    AngusUI:ShowChoresToast()
                end
            end
        end

        if (event == "CURRENCY_DISPLAY_UPDATE") then
            if AngusUI.SyncHandleCurrencyUpdate then
                AngusUI:SyncHandleCurrencyUpdate(...)
            end
        end

        if (event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED") or (event == "CURRENCY_TRANSFER_LOG_UPDATE") then
            if AngusUI.SyncHandleAccountCurrencyDataUpdate then
                AngusUI:SyncHandleAccountCurrencyDataUpdate()
            end
        end

        if (event == "ACCOUNT_MONEY") or (event == "PLAYER_MONEY") then
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh()
            end
        end

        if (event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW") then
            local interactionType = ...
            if
                interactionType == Enum.PlayerInteractionType.Banker or
                interactionType == Enum.PlayerInteractionType.AccountBanker
            then
                AngusUI:RefreshCharacterPanel()
                if AngusUI.SyncRefresh then
                    AngusUI:SyncRefresh()
                end
            end
        end

        if (event == "WEEKLY_REWARDS_UPDATE") or (event == "WEEKLY_REWARDS_ITEM_CHANGED") then
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh()
            end
        end

        if (event == "LFG_UPDATE_RANDOM_INFO") then
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh()
            end
        end

        if
            (event == "TRADE_SKILL_SHOW") or
            (event == "TRADE_SKILL_DATA_SOURCE_CHANGED") or
            (event == "TRADE_SKILL_DETAILS_UPDATE")
        then
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh(true)
            end
        end

        if (event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "PLAYER_ENTERING_WORLD") then
            AngusUI:UI()
            AngusUI:TalentRecommendationsRefresh()
        end

        if
            (event == "PLAYER_EQUIPMENT_CHANGED") or
            ((event == "UNIT_INVENTORY_CHANGED") and (...) == "player") or
            (event == "GET_ITEM_INFO_RECEIVED") or
            (event == "BAG_UPDATE_DELAYED")
        then
            AngusUI:RefreshCharacterPanel()
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
            if AngusUI.SyncRefresh then
                AngusUI:SyncRefresh()
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
