local _, AngusUI = ...

local baseSizes = nil

function AngusUI:FriendsFrame()
    if not FriendsFrame or not FriendsListFrame or not AngusUIDB then
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

    local extraWidth = AngusUIDB.friendsFrameExtraWidth or 50
    local extraHeight = AngusUIDB.friendsFrameExtraHeight or 300

    FriendsFrame:SetWidth(baseSizes.frameWidth + extraWidth)
    FriendsFrame:SetHeight(baseSizes.frameHeight + extraHeight)
    FriendsListFrame:SetWidth(baseSizes.listWidth + extraWidth)
    FriendsListFrame:SetHeight(baseSizes.listHeight + extraHeight)

    if FriendsListFrame.ScrollBox and baseSizes.scrollWidth and baseSizes.scrollHeight then
        FriendsListFrame.ScrollBox:SetWidth(baseSizes.scrollWidth + extraWidth)
        FriendsListFrame.ScrollBox:SetHeight(baseSizes.scrollHeight + extraHeight)
    end
end
