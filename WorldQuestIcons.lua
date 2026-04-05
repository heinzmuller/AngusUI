local _, AngusUI = ...

local rewardCache = {}
local rewardItemLevelCache = {}
local slotCache = {}
local rewardPriority = {
    gear = 3,
    special = 2,
    item = 1,
    currency = 0,
}

local rewardMaskTexture = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local rewardBorderColor = { 0.2, 1, 0.2, 0.95 }
local rewardBorderThickness = 1.5
local rewardBorderPadding = 1
local rewardBorderSegments = 32
local rewardBorderTexture = "Interface\\Buttons\\WHITE8X8"
local ignoredRewardCurrencyIDs = {
    [3316] = true,
}

local specialRewardCurrencyIDs = {
    [3310] = true,
}

local specialRewardItemIDs = {}

local worldMapPinTemplates = {
    "WorldMap_WorldQuestPinTemplate",
}

local ShouldShowUpgradeArrow

local function IsWorldQuestRewardsEnabled()
    local settingsDB = AngusUI.GetSettingsDB and AngusUI:GetSettingsDB() or nil
    return settingsDB == nil or settingsDB.worldQuestRewardIcons ~= false
end

local function IsWorldQuestUpgradeArrowEnabled()
    local settingsDB = AngusUI.GetSettingsDB and AngusUI:GetSettingsDB() or nil
    return settingsDB == nil or settingsDB.worldQuestUpgradeArrow ~= false
end

local function IsIgnoredRewardCurrency(currencyID)
    return currencyID ~= nil and ignoredRewardCurrencyIDs[currencyID] == true
end

local function IsSpecialRewardCurrency(currencyID)
    return currencyID ~= nil and specialRewardCurrencyIDs[currencyID] == true
end

local function IsSpecialRewardItem(itemID)
    return itemID ~= nil and specialRewardItemIDs[itemID] == true
end

local function QueueRefreshFromItem(item)
    if not item then
        return
    end

    item:ContinueOnItemLoad(function()
        AngusUI:QueueWorldQuestIconsRefresh(true)
    end)
end

local function QueueRefreshFromItemID(itemID)
    if not itemID or not Item or not Item.CreateFromItemID then
        return
    end

    local item = Item:CreateFromItemID(itemID)
    if item then
        QueueRefreshFromItem(item)
    end
end

local function GetDetailedRewardItemLevel(itemID)
    if not itemID then
        return nil
    end

    if rewardItemLevelCache[itemID] ~= nil then
        return rewardItemLevelCache[itemID] or nil
    end

    local itemLevel
    if C_Item and C_Item.GetDetailedItemLevelInfo then
        itemLevel = C_Item.GetDetailedItemLevelInfo(itemID)
    end

    if itemLevel and itemLevel > 0 then
        rewardItemLevelCache[itemID] = itemLevel
        return itemLevel
    end

    rewardItemLevelCache[itemID] = false
    QueueRefreshFromItemID(itemID)
    return nil
end

local function QueueRefreshFromItemLocation(itemLocation)
    if not itemLocation or not itemLocation:IsValid() or not Item or not Item.CreateFromItemLocation then
        return
    end

    local item = Item:CreateFromItemLocation(itemLocation)
    if item then
        QueueRefreshFromItem(item)
    end
end

local function CreateRewardOverlay(frame)
    if frame.AngusUIRewardIcon then
        return frame.AngusUIRewardIcon, frame.AngusUIRewardBorder
    end

    local icon = frame:CreateTexture(nil, "OVERLAY", nil, 6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetAlpha(1)
    icon:SetVertexColor(1, 1, 1, 1)
    icon:SetBlendMode("BLEND")
    icon:Hide()

    local border = CreateFrame("Frame", nil, frame)
    border:SetFrameStrata(frame:GetFrameStrata())
    border:SetFrameLevel(frame:GetFrameLevel() + 100)
    border:SetToplevel(true)
    border.segments = {}

    for index = 1, rewardBorderSegments do
        local segment = border:CreateTexture(nil, "OVERLAY", nil, 7)
        segment:SetTexture(rewardBorderTexture)
        segment:SetVertexColor(unpack(rewardBorderColor))
        border.segments[index] = segment
    end

    border:Hide()

    local iconMask = frame:CreateMaskTexture(nil, "OVERLAY")
    iconMask:SetTexture(rewardMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    icon:AddMaskTexture(iconMask)

    frame.AngusUIRewardIcon = icon
    frame.AngusUIRewardBorder = border
    frame.AngusUIRewardIconMask = iconMask

    return icon, border
end

local function AnchorBorder(border, anchor)
    if not border or not anchor or border == anchor then
        return
    end

    local parent = anchor.GetParent and anchor:GetParent() or nil
    if parent and border:GetParent() ~= parent then
        border:SetParent(parent)
    end

    if parent and parent.GetFrameStrata then
        border:SetFrameStrata(parent:GetFrameStrata())
    end

    if parent and parent.GetFrameLevel then
        border:SetFrameLevel(parent:GetFrameLevel() + 20)
    end

    border:ClearAllPoints()

    local width = (anchor.GetWidth and anchor:GetWidth() or 0) + (rewardBorderPadding * 2)
    local height = (anchor.GetHeight and anchor:GetHeight() or 0) + (rewardBorderPadding * 2)
    if width <= 0 or height <= 0 or not border.segments then
        return
    end

    local diameter = math.max(1, math.min(width, height))
    border:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    border:SetSize(diameter, diameter)

    local radius = math.max(1, (diameter * 0.5) - rewardBorderThickness)
    local step = (math.pi * 2) / rewardBorderSegments
    local segmentLength = math.max(1, ((math.pi * 2 * radius) / rewardBorderSegments) + rewardBorderThickness)

    for index, segment in ipairs(border.segments) do
        local startAngle = (index - 1) * step
        local endAngle = index * step
        local midAngle = (startAngle + endAngle) * 0.5
        local centerX = math.cos(midAngle) * radius
        local centerY = math.sin(midAngle) * radius

        segment:ClearAllPoints()
        segment:SetPoint("CENTER", border, "CENTER", centerX, centerY)
        segment:SetSize(segmentLength, rewardBorderThickness)
        segment:SetRotation(midAngle + (math.pi * 0.5))
    end
end

local function AnchorMask(mask, anchor)
    if not mask or not anchor then
        return
    end

    mask:ClearAllPoints()
    mask:SetAllPoints(anchor)
end

local function AnchorOverlay(frame, overlay, fallbackPoint, texture)
    overlay:ClearAllPoints()

    if texture then
        local width = texture.GetWidth and texture:GetWidth() or fallbackPoint.size
        local height = texture.GetHeight and texture:GetHeight() or fallbackPoint.size
        local inset = math.max(0, math.floor(math.min(width, height) * 0.05))
        overlay:SetPoint("TOPLEFT", texture, "TOPLEFT", inset, -inset)
        overlay:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", -inset, inset)
        if frame.AngusUIRewardIconMask then
            AnchorMask(frame.AngusUIRewardIconMask, overlay)
        end
        return texture
    end

    overlay:SetPoint(fallbackPoint.point, frame, fallbackPoint.relativePoint, fallbackPoint.xOffset,
        fallbackPoint.yOffset)
    overlay:SetSize(fallbackPoint.size, fallbackPoint.size)
    if frame.AngusUIRewardIconMask then
        AnchorMask(frame.AngusUIRewardIconMask, overlay)
    end
    return nil
end

local function ApplyRoundMask(frame, texture)
    if not frame or not texture or not texture.AddMaskTexture or not texture.RemoveMaskTexture then
        return
    end

    local mask = frame.AngusUIRewardTextureMask
    if not mask then
        mask = frame:CreateMaskTexture(nil, "OVERLAY")
        mask:SetTexture(rewardMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.AngusUIRewardTextureMask = mask
    end

    if frame.AngusUIRewardMaskTarget and frame.AngusUIRewardMaskTarget ~= texture then
        frame.AngusUIRewardMaskTarget:RemoveMaskTexture(mask)
    end

    AnchorMask(mask, texture)
    if frame.AngusUIRewardMaskTarget ~= texture then
        texture:AddMaskTexture(mask)
        frame.AngusUIRewardMaskTarget = texture
    end
end

local function RemoveRoundMask(frame)
    if not frame or not frame.AngusUIRewardTextureMask or not frame.AngusUIRewardMaskTarget then
        return
    end

    if frame.AngusUIRewardMaskTarget.RemoveMaskTexture then
        frame.AngusUIRewardMaskTarget:RemoveMaskTexture(frame.AngusUIRewardTextureMask)
    end

    frame.AngusUIRewardMaskTarget = nil
end

local function RestoreOriginalTexture(frame)
    local texture = frame and frame.AngusUIRewardTargetTexture
    if not texture then
        return
    end

    if frame.AngusUIOriginalTextureAtlas ~= nil and texture.SetAtlas then
        texture:SetAtlas(frame.AngusUIOriginalTextureAtlas)
    end

    if frame.AngusUIOriginalTexture ~= nil then
        texture:SetTexture(frame.AngusUIOriginalTexture)
    end

    if frame.AngusUIOriginalTextureCoords then
        texture:SetTexCoord(unpack(frame.AngusUIOriginalTextureCoords))
    end

    if frame.AngusUIOriginalTextureAlpha then
        texture:SetAlpha(frame.AngusUIOriginalTextureAlpha)
    end

    if frame.AngusUIOriginalTextureVertexColor then
        texture:SetVertexColor(unpack(frame.AngusUIOriginalTextureVertexColor))
    end

    if frame.AngusUIOriginalTextureBlendMode then
        texture:SetBlendMode(frame.AngusUIOriginalTextureBlendMode)
    end

    frame.AngusUIRewardTargetTexture = nil
    frame.AngusUIOriginalTexture = nil
    frame.AngusUIOriginalTextureAtlas = nil
    frame.AngusUIOriginalTextureCoords = nil
    frame.AngusUIOriginalTextureAlpha = nil
    frame.AngusUIOriginalTextureVertexColor = nil
    frame.AngusUIOriginalTextureBlendMode = nil
end

local function ReplaceTexture(frame, texture, rewardIcon)
    if not frame or not texture or not rewardIcon then
        return false
    end

    if frame.AngusUIRewardTargetTexture ~= texture then
        RestoreOriginalTexture(frame)

        frame.AngusUIRewardTargetTexture = texture
        frame.AngusUIOriginalTextureAtlas = texture.GetAtlas and texture:GetAtlas() or nil
        frame.AngusUIOriginalTexture = texture.GetTexture and texture:GetTexture() or nil
        if texture.GetTexCoord then
            frame.AngusUIOriginalTextureCoords = { texture:GetTexCoord() }
        end
        frame.AngusUIOriginalTextureAlpha = texture.GetAlpha and texture:GetAlpha() or 1
        if texture.GetVertexColor then
            frame.AngusUIOriginalTextureVertexColor = { texture:GetVertexColor() }
        end
        frame.AngusUIOriginalTextureBlendMode = texture.GetBlendMode and texture:GetBlendMode() or "BLEND"
    end

    if texture.SetAtlas then
        texture:SetAtlas(nil)
    end
    texture:SetTexture(rewardIcon)
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    texture:SetAlpha(1)
    texture:SetVertexColor(1, 1, 1, 1)
    texture:SetBlendMode("BLEND")
    return true
end

local function ResetOverlay(frame)
    if not frame then
        return
    end

    if frame.AngusUIRewardIcon then
        frame.AngusUIRewardIcon:Hide()
    end

    if frame.AngusUIRewardBorder then
        frame.AngusUIRewardBorder:Hide()
    end

    RemoveRoundMask(frame)
    RestoreOriginalTexture(frame)
end

local function GetInventorySlotsForEquipLocation(itemEquipLoc)
    if not itemEquipLoc then
        return nil
    end

    if slotCache[itemEquipLoc] then
        return slotCache[itemEquipLoc]
    end

    local slotsByEquipLoc = {
        INVTYPE_HEAD = { INVSLOT_HEAD },
        INVTYPE_NECK = { INVSLOT_NECK },
        INVTYPE_SHOULDER = { INVSLOT_SHOULDER },
        INVTYPE_BODY = { INVSLOT_BODY },
        INVTYPE_CHEST = { INVSLOT_CHEST },
        INVTYPE_ROBE = { INVSLOT_CHEST },
        INVTYPE_WAIST = { INVSLOT_WAIST },
        INVTYPE_LEGS = { INVSLOT_LEGS },
        INVTYPE_FEET = { INVSLOT_FEET },
        INVTYPE_WRIST = { INVSLOT_WRIST },
        INVTYPE_HAND = { INVSLOT_HAND },
        INVTYPE_FINGER = { INVSLOT_FINGER1, INVSLOT_FINGER2 },
        INVTYPE_TRINKET = { INVSLOT_TRINKET1, INVSLOT_TRINKET2 },
        INVTYPE_CLOAK = { INVSLOT_BACK },
        INVTYPE_WEAPON = { INVSLOT_MAINHAND, INVSLOT_OFFHAND },
        INVTYPE_2HWEAPON = { INVSLOT_MAINHAND },
        INVTYPE_WEAPONMAINHAND = { INVSLOT_MAINHAND },
        INVTYPE_WEAPONOFFHAND = { INVSLOT_OFFHAND },
        INVTYPE_HOLDABLE = { INVSLOT_OFFHAND },
        INVTYPE_SHIELD = { INVSLOT_OFFHAND },
        INVTYPE_RANGED = { INVSLOT_MAINHAND },
        INVTYPE_RANGEDRIGHT = { INVSLOT_MAINHAND },
        INVTYPE_TABARD = { INVSLOT_TABARD },
    }

    slotCache[itemEquipLoc] = slotsByEquipLoc[itemEquipLoc]
    return slotCache[itemEquipLoc]
end

local function GetEquippedItemLevel(slotId)
    local itemLocation = ItemLocation and ItemLocation:CreateFromEquipmentSlot(slotId)
    if not itemLocation or not itemLocation:IsValid() then
        return nil
    end

    local currentItemLevel = C_Item and C_Item.GetCurrentItemLevel and C_Item.GetCurrentItemLevel(itemLocation)
    if currentItemLevel and currentItemLevel > 0 then
        return currentItemLevel
    end

    QueueRefreshFromItemLocation(itemLocation)
    return nil
end

local function GetComparisonItemLevel(slots)
    if not slots then
        return nil
    end

    local comparisonLevel
    for _, slotId in ipairs(slots) do
        local currentItemLevel = GetEquippedItemLevel(slotId)
        if currentItemLevel then
            if comparisonLevel == nil or currentItemLevel < comparisonLevel then
                comparisonLevel = currentItemLevel
            end
        end
    end

    return comparisonLevel
end

local function BuildRewardEntry(kind, icon, itemID, itemLevel, itemName, currencyID, currencyName)
    if not icon then
        return nil
    end

    if kind == "currency" and IsIgnoredRewardCurrency(currencyID) then
        return nil
    end

    local isGear = false
    local isSpecialItem = false
    local isSpecialCurrency = false
    local itemEquipLoc
    if itemID and C_Item and C_Item.GetItemInfoInstant then
        local _, itemType, itemSubType, equipLoc = C_Item.GetItemInfoInstant(itemID)
        itemEquipLoc = equipLoc
        isGear = itemEquipLoc ~= nil and itemEquipLoc ~= "" and GetInventorySlotsForEquipLocation(itemEquipLoc) ~= nil
        isSpecialItem = IsSpecialRewardItem(itemID)

        if not itemEquipLoc or itemEquipLoc == "" then
            QueueRefreshFromItemID(itemID)
        end
    end

    if kind == "currency" then
        isSpecialCurrency = IsSpecialRewardCurrency(currencyID)
    end

    if isGear and (not itemLevel or itemLevel <= 0) then
        itemLevel = GetDetailedRewardItemLevel(itemID)
    end

    local normalizedKind = kind
    if isGear then
        normalizedKind = "gear"
    elseif isSpecialItem or isSpecialCurrency then
        normalizedKind = "special"
    elseif itemID then
        normalizedKind = "item"
    end

    if normalizedKind ~= "gear" and normalizedKind ~= "special" then
        return nil
    end

    return {
        kind = normalizedKind,
        icon = icon,
        itemID = itemID,
        itemName = itemName,
        currencyID = currencyID,
        currencyName = currencyName,
        itemLevel = itemLevel,
        itemEquipLoc = itemEquipLoc,
        priority = rewardPriority[normalizedKind] or 0,
    }
end

local function GetCurrencyRewardIcon(currencyInfo)
    if type(currencyInfo) ~= "table" then
        return nil
    end

    return currencyInfo["textureFileID"]
        or currencyInfo["textureFileId"]
        or currencyInfo["iconFileID"]
        or currencyInfo["icon"]
        or currencyInfo["texture"]
end

local function GetQuestReward(questID)
    if not questID then
        return nil
    end

    if rewardCache[questID] ~= nil then
        return rewardCache[questID]
    end

    local bestReward
    local hasIgnoredCurrencyReward = false
    local hasPreferredCurrencyReward = false
    local numRewards = GetNumQuestLogRewards and GetNumQuestLogRewards(questID) or 0
    for rewardIndex = 1, numRewards do
        local itemName, icon, _, _, _, itemID, itemLevel = GetQuestLogRewardInfo(rewardIndex, questID)
        local reward = BuildRewardEntry(itemID and "item" or "currency", icon, itemID, itemLevel, itemName)
        if reward and (not bestReward or reward.priority > bestReward.priority) then
            bestReward = reward
        end
    end

    local numChoices = GetNumQuestLogChoices and GetNumQuestLogChoices(questID) or 0
    for choiceIndex = 1, numChoices do
        local itemName, icon, _, _, _, itemID = GetQuestLogChoiceInfo(choiceIndex, questID)
        local reward = BuildRewardEntry(itemID and "item" or "currency", icon, itemID, nil, itemName)
        if reward and (not bestReward or reward.priority > bestReward.priority) then
            bestReward = reward
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestRewardCurrencies then
        local rewardCurrencies = C_QuestLog.GetQuestRewardCurrencies(questID)
        if rewardCurrencies then
            for _, currencyInfo in ipairs(rewardCurrencies) do
                if IsIgnoredRewardCurrency(currencyInfo.currencyID) then
                    hasIgnoredCurrencyReward = true
                end

                local reward = BuildRewardEntry(
                    "currency",
                    GetCurrencyRewardIcon(currencyInfo),
                    nil,
                    nil,
                    currencyInfo.name,
                    currencyInfo.currencyID,
                    currencyInfo.name
                )

                if reward and reward.kind == "special" then
                    hasPreferredCurrencyReward = true
                end

                if reward and (not bestReward or reward.priority > bestReward.priority) then
                    bestReward = reward
                end
            end
        end
    end

    if hasIgnoredCurrencyReward and bestReward and bestReward.kind ~= "gear" and not hasPreferredCurrencyReward then
        bestReward = nil
    end

    rewardCache[questID] = bestReward or false
    return bestReward or nil
end

local function IsRelevantWorldMapQuestPin(pin)
    if not pin or type(pin.questID) ~= "number" or pin.questID <= 0 then
        return false
    end

    if pin.worldQuest == true then
        return true
    end

    if C_QuestLog and C_QuestLog.IsQuestTask and not C_QuestLog.IsQuestTask(pin.questID) then
        return false
    end

    if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID and not C_TaskQuest.GetQuestInfoByQuestID(pin.questID) then
        return false
    end

    return pin.questTagInfo ~= nil or pin.tagInfo ~= nil or pin.worldQuestType ~= nil
end

ShouldShowUpgradeArrow = function(reward)
    if not reward or reward.kind ~= "gear" or not IsWorldQuestUpgradeArrowEnabled() then
        return false
    end

    if not reward.itemLevel or reward.itemLevel <= 0 then
        return false
    end

    local slots = GetInventorySlotsForEquipLocation(reward.itemEquipLoc)
    if not slots then
        return false
    end

    local equippedLevel = GetComparisonItemLevel(slots)
    if not equippedLevel then
        return false
    end

    return reward.itemLevel > equippedLevel
end

local function ApplyRewardToWorldMapPin(pin)
    if not IsRelevantWorldMapQuestPin(pin) then
        ResetOverlay(pin)
        return
    end

    local reward = GetQuestReward(pin.questID)
    if not IsWorldQuestRewardsEnabled() or not reward or not reward.icon then
        ResetOverlay(pin)
        return
    end

    local targetTexture = pin.Display and pin.Display.Icon or pin.Display or pin.NormalTexture or pin.Texture or pin
        .Icon
    local overlay, border = CreateRewardOverlay(pin)
    local replacedInPlace = ReplaceTexture(pin, targetTexture, reward.icon)
    local isUpgrade = ShouldShowUpgradeArrow(reward)

    if replacedInPlace then
        ApplyRoundMask(pin, targetTexture)
        if isUpgrade then
            AnchorOverlay(pin, overlay, {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = 0,
                size = 18,
            }, targetTexture)
            overlay:SetTexture(reward.icon)
            overlay:SetAlpha(1)
            overlay:SetVertexColor(1, 1, 1, 1)
            overlay:SetBlendMode("BLEND")
            overlay:Show()
            AnchorBorder(border, overlay)
        else
            overlay:Hide()
            AnchorBorder(border, targetTexture)
        end
    else
        AnchorOverlay(pin, overlay, {
            point = "CENTER",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = 0,
            size = 18,
        }, targetTexture)
        overlay:SetTexture(reward.icon)
        overlay:SetAlpha(1)
        overlay:SetVertexColor(1, 1, 1, 1)
        overlay:SetBlendMode("BLEND")
        overlay:Show()
        AnchorBorder(border, overlay)
    end

    if isUpgrade then
        border:Show()
    else
        border:Hide()
    end
end

local function RefreshWorldMapPins(worldMapFrame)
    if not worldMapFrame or not worldMapFrame.EnumeratePinsByTemplate then
        return
    end

    for _, template in ipairs(worldMapPinTemplates) do
        for pin in worldMapFrame:EnumeratePinsByTemplate(template) do
            ApplyRewardToWorldMapPin(pin)
        end
    end
end

local function ClearWorldMapPins(worldMapFrame)
    if not worldMapFrame or not worldMapFrame.EnumeratePinsByTemplate then
        return
    end

    for _, template in ipairs(worldMapPinTemplates) do
        for pin in worldMapFrame:EnumeratePinsByTemplate(template) do
            ResetOverlay(pin)
        end
    end
end

function AngusUI:ResetWorldQuestRewardCache()
    rewardCache = {}
    rewardItemLevelCache = {}
end

function AngusUI:QueueWorldQuestIconsRefresh(forceClearCache)
    if forceClearCache then
        self:ResetWorldQuestRewardCache()
    end

    if self.worldQuestIconsRefreshQueued then
        return
    end

    self.worldQuestIconsRefreshQueued = true
    C_Timer.After(0, function()
        AngusUI.worldQuestIconsRefreshQueued = false
        AngusUI:WorldQuestIcons()
    end)
end

function AngusUI:InitializeWorldQuestIcons()
    if self.worldQuestIconsInitialized then
        return
    end

    self.worldQuestIconsInitialized = true

    if WorldMapFrame then
        WorldMapFrame:HookScript("OnShow", function()
            AngusUI:QueueWorldQuestIconsRefresh(true)
        end)
    end

    if WorldMap_WorldQuestPinMixin and hooksecurefunc then
        hooksecurefunc(WorldMap_WorldQuestPinMixin, "RefreshVisuals", function(pin)
            AngusUI:QueueWorldQuestIconsRefresh()
        end)
    end
end

function AngusUI:WorldQuestIcons()
    self:InitializeWorldQuestIcons()

    if not IsWorldQuestRewardsEnabled() then
        ClearWorldMapPins(WorldMapFrame)
        return
    end

    RefreshWorldMapPins(WorldMapFrame)
end
