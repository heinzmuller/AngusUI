-- Resizes the Friends window so it better fits the player's preferred amount of social information.
local _, AngusUI = ...

local baseSizes = nil
local friendsFrameWatcher = CreateFrame("Frame")

friendsFrameWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
friendsFrameWatcher:SetScript("OnEvent", function()
    AngusUI:FriendsFrame()
end)

-- Expands the Friends window using the user's saved size preferences.
function AngusUI:FriendsFrame()
    local settingsDB = self.GetSettingsDB and self:GetSettingsDB() or nil
    if not FriendsFrame or not FriendsListFrame or not settingsDB then
        return
    end

    FRIENDS_FRAME_FRIEND_HEIGHT = 17

    if not baseSizes then
        baseSizes = {
            frameWidth = FriendsFrame:GetWidth(),
            frameHeight = FriendsFrame:GetHeight(),
            listWidth = FriendsListFrame:GetWidth(),
            listHeight = FriendsListFrame:GetHeight(),
            scrollWidth = FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox:GetWidth() or nil,
            scrollHeight = FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox:GetHeight() or nil,
        }
    end

    local extraWidth = settingsDB.friendsFrameExtraWidth or 50
    local extraHeight = settingsDB.friendsFrameExtraHeight or 300

    FriendsFrame:SetWidth(baseSizes.frameWidth + extraWidth)
    FriendsFrame:SetHeight(baseSizes.frameHeight + extraHeight)
    FriendsListFrame:SetWidth(baseSizes.listWidth + extraWidth)
    FriendsListFrame:SetHeight(baseSizes.listHeight + extraHeight)

    if FriendsListFrame.ScrollBox and baseSizes.scrollWidth and baseSizes.scrollHeight then
        FriendsListFrame.ScrollBox:SetWidth(baseSizes.scrollWidth + extraWidth)
        FriendsListFrame.ScrollBox:SetHeight(baseSizes.scrollHeight + extraHeight)
    end
end
