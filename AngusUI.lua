local _, AngusUI = ...

local darkness = .6

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

function SlashCommand(command)
    local commands = {
        back = TeleportBack,
        rep = function() AngusUI:Reputations() end,
        crests = function() AngusUI:Crests() end,
        ui = function() AngusUI:UI() end,
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

local nonTeleportBack
local backIds = {
    65274,
    63207,
    63353,
    65360,
    63206,
    63352,
}
local backs = Set(backIds)

function TeleportBack()
    local equippedItemId = GetInventoryItemID("player", 15)

    function EquipTeleportBack()
        for _, backId in ipairs(backIds) do
            if C_Item.GetItemCount(backId, false) == 1 and C_Container.GetItemCooldown(backId) == 0 then
                C_Item.EquipItemByName(backId)
                break
            end
        end
    end

    if backs[equippedItemId] then
        local cooldown = C_Item.GetItemCooldown(equippedItemId)

        if cooldown > 0 then
            C_Item.EquipItemByName(nonTeleportBack)
        end
    else
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(INVSLOT_BACK)

        if itemLoc:IsValid() then
            nonTeleportBack = C_Item.GetItemGUID(itemLoc)
        end

        EquipTeleportBack()
    end
end

SlashCmdList.ANGUSUI = SlashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"
function frame:ADDON_LOADED(self, addon)
    if (addon == "Blizzard_TimeManager") then
        for _, v in pairs(
            {
                MainMenuBar.EndCaps.LeftEndCap,
                MainMenuBar.EndCaps.RightEndCap,
            }
        ) do
            v:SetVertexColor(darkness, darkness, darkness)
        end

        for _, v in pairs(
            {
                MainMenuBar.BorderArt,
                MinimapCompassTexture,
                PlayerFrame.PlayerFrameContainer.FrameTexture,
                PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
                TargetFrame.TargetFrameContainer.FrameTexture,
            }
        ) do
            v:SetVertexColor(.25, .25, .25)
        end

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
