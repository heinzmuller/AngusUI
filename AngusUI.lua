local _, angusui = ...

local darkness = .4

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

function SlashCommand(arg)
    if (arg == "back") then
        TeleportBack()
    else
        print("These are the commands you're looking for")
        print("/back")
    end
end

function TeleportBack()
    print("So you wanna teleport do you?")

    local cloaks = Set { 65274 }

    local itemId = GetInventoryItemID("player", 15)
    print("itemId:" .. itemId)

    function EquipTeleportCloak()
        print("Equipping teleport cloak")
        for i = 0, NUM_BAG_SLOTS do
            for z = 1, C_Container.GetContainerNumSlots(i) do
                if C_Container.GetContainerItemID(i, z) == 65274 then
                    local _, duration = C_Container.GetContainerItemCooldown(i, z)
                    if duration == 0 then
                        print("Item is ready!")
                        C_Item.EquipItemByName(65274)
                    else
                        print("Cooldown is " .. duration)
                    end
                    break
                end
            end
        end
    end

    if cloaks[itemId] then
        -- do something
        print("You have cloak equipped" .. itemId)
    else
        print("You NOT have equipped" .. itemId)
        EquipTeleportCloak()
    end
end

SlashCmdList.ANGUSUI = SlashCommand
SLASH_ANGUSUI1, SLASH_ANGUSUI2 = "/angusui", "/aui"
function frame:ADDON_LOADED(self, addon)
    if (addon == "Blizzard_TimeManager") then
        for i, v in pairs(
            {
                MainMenuBar.BorderArt,
                MainMenuBar.EndCaps.LeftEndCap,
                MainMenuBar.EndCaps.RightEndCap,
                MinimapCompassTexture
            }
        ) do
            v:SetVertexColor(darkness, darkness, darkness)
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
    end
)
