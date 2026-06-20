-- Adds quality of life features to WoW.
local _, AngusUI = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

local ADDON_NAME = "|cff0f7a0fa|cff7be426UI|r"
local PRINT_PREFIX = "|cff000000[|r" .. ADDON_NAME .. "|cff000000]|r"

-- Prints addon messages with a consistent AngusUI prefix.
function AngusUI:Print(...)
    if select("#", ...) == 0 then
        print(PRINT_PREFIX)
        return
    end

    print(PRINT_PREFIX .. " |cffffffff" .. strjoin(" ", tostringall(...)) .. "|r")
end

-- Routes slash commands to addon features or shows available commands.
local function SlashCommand(command)
    command = command and strlower(strtrim(command)) or ""

    local commands = {
        back = function() AngusUI:TeleportBack() end,
        crests = function() AngusUI:Crests() end,
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
-- Initializes AngusUI features when the addon or Blizzard UI modules load.
function frame:ADDON_LOADED(self, addon)
    if (addon == "AngusUI") then
        if AngusUI.ItemOverlays then
            AngusUI:ItemOverlays()
        end

        local isCharacterUILoaded = (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_CharacterUI")) or CharacterFrame
        if isCharacterUILoaded then
            if AngusUI.CharacterInit then
                AngusUI:CharacterInit()
            end
            AngusUI:RefreshCharacterPanel()
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

        if AngusUI.ChoresInit then
            AngusUI:ChoresInit()
        end

        if AngusUI.DelvesInit then
            AngusUI:DelvesInit()
        end

        if AngusUI.SyncInit then
            AngusUI:SyncInit()
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

    if (addon == "Blizzard_ProfessionsTemplates") or (addon == "Blizzard_Professions") then
        if AngusUI.ProfessionLinksInit then
            AngusUI:ProfessionLinksInit()
        end
    end

    if (addon == "Blizzard_UnitFrame") then
        AngusUI:PartyFrames()
    end
end

frame:SetScript("OnEvent", frame.ADDON_LOADED)
