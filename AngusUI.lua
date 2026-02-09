local _, AngusUI = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

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
        delves = function() AngusUI:Delves() end,
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
    end

    if (addon == "Blizzard_TimeManager") then
        AngusUI:ApplyTheme()
        AngusUI:FriendsFrame()

        self:UnregisterEvent("ADDON_LOADED")
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
        end

        if (event == "PLAYER_SPECIALIZATION_CHANGED") or (event == "PLAYER_ENTERING_WORLD") then
            AngusUI:UI()
        end

        if (event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
            if (ChallengesFrame == nil) then
                return
            end

            AngusUI:MythicPlus()
            self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
        end
    end
)
