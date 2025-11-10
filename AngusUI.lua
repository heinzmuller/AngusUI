local _, AngusUI = ...

local darkness = .6

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
    if (addon == "Blizzard_TimeManager") then
        -- Darken menu bar end caps
        if MainMenuBar and MainMenuBar.EndCaps then
            for _, v in pairs(
                {
                    MainMenuBar.EndCaps.LeftEndCap,
                    MainMenuBar.EndCaps.RightEndCap,
                }
            ) do
                if v then
                    v:SetVertexColor(darkness, darkness, darkness)
                end
            end
        end

        -- Darken various UI textures
        for _, v in pairs(
            {
                MainMenuBar and MainMenuBar.BorderArt,
                MinimapCompassTexture,
                PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.FrameTexture,
                PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
                TargetFrame and TargetFrame.TargetFrameContainer and TargetFrame.TargetFrameContainer.FrameTexture,
            }
        ) do
            if v then
                v:SetVertexColor(.25, .25, .25)
            end
        end

        -- Darken action button textures
        for _, v in pairs(
            {
                "MultiBarBottomLeftButton",
                "MultiBarBottomRightButton",
                "ActionButton",
            }
        ) do
            for i = 1, 12 do
                local frame = _G[v .. i .. "NormalTexture"]

                if frame then
                    frame:SetVertexColor(.5, .5, .5)
                end
            end
        end

        -- Expand friends frame
        if FriendsFrame and FriendsListFrame then
            FRIENDS_FRAME_FRIEND_HEIGHT = 17

            local widen = 50
            local heighten = 300
            FriendsFrame:SetWidth(FriendsFrame:GetWidth() + widen)
            FriendsFrame:SetHeight(FriendsFrame:GetHeight() + heighten)
            FriendsListFrame:SetWidth(FriendsListFrame:GetWidth() + widen)
            FriendsListFrame:SetHeight(FriendsListFrame:GetHeight() + heighten)
            
            if FriendsListFrame.ScrollBox then
                FriendsListFrame.ScrollBox:SetWidth(FriendsListFrame.ScrollBox:GetWidth() + widen)
                FriendsListFrame.ScrollBox:SetHeight(FriendsListFrame.ScrollBox:GetHeight() + heighten)
            end
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if (event == "ADDON_LOADED") then
            self:ADDON_LOADED(self, ...)
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
