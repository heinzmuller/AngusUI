local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local MIN_ITEM_LEVEL_DISPLAY = 14
local ITEM_BIND_ON_EQUIP = Enum and Enum.ItemBind and Enum.ItemBind.OnEquip or 2
local ITEM_QUALITY_POOR = Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0
local ITEM_QUALITY_COMMON = Enum and Enum.ItemQuality and Enum.ItemQuality.Common or 1
local ITEM_QUALITY_RARE = Enum and Enum.ItemQuality and Enum.ItemQuality.Rare or 3
local ITEM_QUALITY_EPIC = Enum and Enum.ItemQuality and Enum.ItemQuality.Epic or 4
local ITEM_LEVEL_Y_OFFSET_ADJUST = 2
local ITEM_LEVEL_QUALITY_LIGHTEN = 0.30
local LABEL_BACKGROUND_INSET = 1
local LABEL_BACKGROUND_PADDING = 4
local BLACK_GRADIENT_TOP = CreateColor and CreateColor(0, 0, 0, 1) or nil
local BLACK_GRADIENT_CLEAR = CreateColor and CreateColor(0, 0, 0, 0) or nil
local bagEquipLocations = {
    INVTYPE_HEAD = true,
    INVTYPE_NECK = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_CHEST = true,
    INVTYPE_ROBE = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true,
    INVTYPE_FINGER = true,
    INVTYPE_TRINKET = true,
    INVTYPE_CLOAK = true,
    INVTYPE_WEAPON = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_SHIELD = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
}

local slotFrames = {
    { slotId = INVSLOT_HEAD,     frameName = "CharacterHeadSlot" },
    { slotId = INVSLOT_NECK,     frameName = "CharacterNeckSlot" },
    { slotId = INVSLOT_SHOULDER, frameName = "CharacterShoulderSlot" },
    { slotId = INVSLOT_BACK,     frameName = "CharacterBackSlot" },
    { slotId = INVSLOT_CHEST,    frameName = "CharacterChestSlot" },
    { slotId = INVSLOT_BODY,     frameName = "CharacterShirtSlot" },
    { slotId = INVSLOT_TABARD,   frameName = "CharacterTabardSlot" },
    { slotId = INVSLOT_WRIST,    frameName = "CharacterWristSlot" },
    { slotId = INVSLOT_HAND,     frameName = "CharacterHandsSlot" },
    { slotId = INVSLOT_WAIST,    frameName = "CharacterWaistSlot" },
    { slotId = INVSLOT_LEGS,     frameName = "CharacterLegsSlot" },
    { slotId = INVSLOT_FEET,     frameName = "CharacterFeetSlot" },
    { slotId = INVSLOT_FINGER1,  frameName = "CharacterFinger0Slot" },
    { slotId = INVSLOT_FINGER2,  frameName = "CharacterFinger1Slot" },
    { slotId = INVSLOT_TRINKET1, frameName = "CharacterTrinket0Slot" },
    { slotId = INVSLOT_TRINKET2, frameName = "CharacterTrinket1Slot" },
    { slotId = INVSLOT_MAINHAND, frameName = "CharacterMainHandSlot" },
    { slotId = INVSLOT_OFFHAND,  frameName = "CharacterSecondaryHandSlot" },
}

local function GetSlotButton(frameName)
    return _G[frameName]
end

local function GetOverlay(button, fontSize, yOffset)
    local text = button.AngusUIItemLevelText

    if not text then
        text = button:CreateFontString(nil, "OVERLAY")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 1)
        button.AngusUIItemLevelText = text
    end

    text:SetFont(Inconsolata, fontSize or 11, "OUTLINE")
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", button, "BOTTOM", 0, (yOffset or 2) + ITEM_LEVEL_Y_OFFSET_ADJUST)

    return text
end

local function GetOverlayBackground(button, key)
    local background = button[key]

    if not background then
        background = button:CreateTexture(nil, "ARTWORK")
        background:SetTexture("Interface\\Buttons\\WHITE8X8")
        background:Hide()
        button[key] = background
    end

    return background
end

local function UpdateOverlayBackground(background, button, text, anchor)
    local height = math.max(12, math.ceil((text:GetStringHeight() or 0) + LABEL_BACKGROUND_PADDING))

    background:ClearAllPoints()
    if anchor == "TOP" then
        background:SetPoint("TOPLEFT", button, "TOPLEFT", LABEL_BACKGROUND_INSET, -LABEL_BACKGROUND_INSET)
        background:SetPoint("TOPRIGHT", button, "TOPRIGHT", -LABEL_BACKGROUND_INSET, -LABEL_BACKGROUND_INSET)
        background:SetHeight(height)
        if background.SetGradient then
            background:SetGradient("VERTICAL", BLACK_GRADIENT_CLEAR, BLACK_GRADIENT_TOP)
        else
            background:Hide()
            return
        end
    else
        background:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", LABEL_BACKGROUND_INSET, LABEL_BACKGROUND_INSET)
        background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -LABEL_BACKGROUND_INSET, LABEL_BACKGROUND_INSET)
        background:SetHeight(height)
        if background.SetGradient then
            background:SetGradient("VERTICAL", BLACK_GRADIENT_TOP, BLACK_GRADIENT_CLEAR)
        else
            background:Hide()
            return
        end
    end

    background:Show()
end

local function GetBindOverlay(button)
    local text = button.AngusUIBindText

    if not text then
        text = button:CreateFontString(nil, "OVERLAY")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 1)
        button.AngusUIBindText = text
    end

    text:SetFont(Inconsolata, 9, "OUTLINE")
    text:ClearAllPoints()
    text:SetPoint("TOP", button, "TOP", 0, -1)

    return text
end

local function GetSpecialHighlight(button)
    return button and button.AngusUISpecialHighlight
end

local function FindSpecialHighlight(button)
    return button and (button.AngusUISpecialHighlight or button.SpellHighlight or button.spellHighlight or button.overlay)
end

local function SetSpecialHighlight(button, shown)
    if not button then
        return
    end

    local highlight = GetSpecialHighlight(button)

    if shown then
        if highlight and highlight:IsShown() then
            return
        end

        if ActionButton_ShowOverlayGlow then
            ActionButton_ShowOverlayGlow(button)
            button.AngusUISpecialHighlight = FindSpecialHighlight(button)
        end

        return
    end

    if not highlight then
        return
    end

    if ActionButton_HideOverlayGlow then
        ActionButton_HideOverlayGlow(button)
    else
        highlight:Hide()
    end
end

local function ShouldShowBindOverlayForQuality(quality)
    return quality and quality > ITEM_QUALITY_COMMON
end

local function GetQualityColor(quality)
    if quality ~= nil and C_Item and C_Item.GetItemQualityColor then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        if r and g and b then
            return r + (1 - r) * ITEM_LEVEL_QUALITY_LIGHTEN,
                g + (1 - g) * ITEM_LEVEL_QUALITY_LIGHTEN,
                b + (1 - b) * ITEM_LEVEL_QUALITY_LIGHTEN
        end
    end

    return 1, 1, 1
end

local function GetItemQualityFromLink(itemLink)
    if not itemLink then
        return nil
    end

    local itemInfo = C_Item and C_Item.GetItemInfo and { C_Item.GetItemInfo(itemLink) } or { GetItemInfo(itemLink) }
    return itemInfo[3]
end

local function QueueRefresh(source, button, isLink)
    if button.AngusUIItemLevelPending then
        return
    end

    if not Item then
        return
    end

    local item
    if isLink then
        if not Item.CreateFromItemLink or not source then
            return
        end

        item = Item:CreateFromItemLink(source)
    else
        if not Item.CreateFromItemLocation or not source then
            return
        end

        item = Item:CreateFromItemLocation(source)
    end

    if not item then
        return
    end

    button.AngusUIItemLevelPending = true
    item:ContinueOnItemLoad(function()
        button.AngusUIItemLevelPending = nil
        AngusUI:CharacterPanel()
    end)
end

local function NormalizeItemLevel(itemLevel)
    if not itemLevel or itemLevel <= 0 or itemLevel < MIN_ITEM_LEVEL_DISPLAY then
        return nil
    end

    return itemLevel
end

local function GetItemLevelFromLocation(itemLocation, button)
    if not itemLocation or not itemLocation:IsValid() then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    local currentItemLevel = C_Item.GetCurrentItemLevel and C_Item.GetCurrentItemLevel(itemLocation)
    if currentItemLevel and currentItemLevel > 0 then
        button.AngusUIItemLevelPending = nil
        return NormalizeItemLevel(currentItemLevel)
    end

    QueueRefresh(itemLocation, button)
    return nil
end

local function GetItemLevelFromLink(itemLink, button)
    if not itemLink then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    local itemLevel = C_Item.GetDetailedItemLevelInfo and C_Item.GetDetailedItemLevelInfo(itemLink)
    if itemLevel and itemLevel > 0 then
        button.AngusUIItemLevelPending = nil
        return NormalizeItemLevel(itemLevel)
    end

    QueueRefresh(itemLink, button, true)
    return nil
end

local function GetEquippedItemLevel(slotId, slotButton)
    local itemLink = GetInventoryItemLink("player", slotId)

    if not itemLink then
        slotButton.AngusUIItemLevelPending = nil
        return nil
    end

    local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
    local itemLevel = GetItemLevelFromLocation(itemLocation, slotButton)
    return itemLevel, GetItemQualityFromLink(itemLink)
end

local function IsRelevantContainerItem(containerID, slotID)
    if not C_Container or not C_Container.GetContainerItemID then
        return false
    end

    local itemID = C_Container.GetContainerItemID(containerID, slotID)
    if not itemID or not C_Item or not C_Item.GetItemInfoInstant then
        return false
    end

    local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemID))
    return bagEquipLocations[itemEquipLoc] == true
end

local function GetContainerItemLevel(containerID, slotID, button)
    if not IsRelevantContainerItem(containerID, slotID) then
        button.AngusUIItemLevelPending = nil
        return nil, nil
    end

    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(containerID, slotID)
    local itemLevel = GetItemLevelFromLocation(itemLocation, button)
    return itemLevel, containerItemInfo and containerItemInfo.quality or nil
end

local function GetBagItemLevel(itemButton)
    local bag = itemButton:GetBagID()
    local slot = itemButton:GetID()

    return GetContainerItemLevel(bag, slot, itemButton)
end

local function GetBankItemLevel(itemButton)
    local bankTabID = itemButton:GetBankTabID()
    local slotID = itemButton:GetContainerSlotID()

    return GetContainerItemLevel(bankTabID, slotID, itemButton)
end

local function GetContainerBindLabel(containerID, slotID, button)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)

    if containerItemInfo and containerItemInfo.isBound then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    if containerItemInfo and not ShouldShowBindOverlayForQuality(containerItemInfo.quality) then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    if itemLocation and itemLocation:IsValid() and C_Item and C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation) then
        return "WuE", 0.45, 0.85, 1, true
    end

    local itemLink = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(containerID, slotID)
    if not itemLink then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    local itemInfo = C_Item and C_Item.GetItemInfo and { C_Item.GetItemInfo(itemLink) } or { GetItemInfo(itemLink) }
    if not itemInfo[1] then
        QueueRefresh(itemLink, button, true)
        return nil
    end

    local bindType = itemInfo[14]
    local quality = itemInfo[3]
    if not ShouldShowBindOverlayForQuality(quality) then
        button.AngusUIItemLevelPending = nil
        return nil
    end

    if bindType == ITEM_BIND_ON_EQUIP then
        local r, g, b = GetQualityColor(quality)
        return "BoE", r, g, b, false
    end

    button.AngusUIItemLevelPending = nil
    return nil
end

local function GetFlyoutItemLink(itemButton)
    if itemButton.itemLink then
        return itemButton.itemLink
    end

    if itemButton.GetItemLocation then
        local itemLocation = itemButton:GetItemLocation()

        if itemLocation and itemLocation.IsValid and itemLocation:IsValid() then
            if itemLocation.IsBagAndSlot and itemLocation:IsBagAndSlot() then
                local bag, slot = itemLocation:GetBagAndSlot()
                return C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(bag, slot)
            end

            if itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
                return GetInventoryItemLink("player", itemLocation:GetEquipmentSlot())
            end
        end
    end

    local location = itemButton.location
    if type(location) ~= "number" then
        return nil
    end

    if location >= (EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or 0xFFFFFFFD) then
        return nil
    end

    if not EquipmentManager_GetLocationData then
        return nil
    end

    local locationData = EquipmentManager_GetLocationData(location)
    if not locationData or next(locationData) == nil then
        return nil
    end

    if locationData.isBags then
        return C_Container.GetContainerItemLink(locationData.bag, locationData.slot)
    end

    return GetInventoryItemLink("player", locationData.slot)
end

local function GetFlyoutItemLevel(itemButton)
    local itemLink = GetFlyoutItemLink(itemButton)
    local itemLevel = GetItemLevelFromLink(itemLink, itemButton)
    return itemLevel, GetItemQualityFromLink(itemLink)
end

local function UpdateOverlay(button, itemLevel, fontSize, yOffset, quality)
    local text = GetOverlay(button, fontSize, yOffset)
    local background = GetOverlayBackground(button, "AngusUIItemLevelBackground")

    if itemLevel then
        text:SetText(itemLevel)
        text:SetTextColor(GetQualityColor(quality))
        text:Show()
        UpdateOverlayBackground(background, button, text, "BOTTOM")
    else
        text:SetText("")
        text:Hide()
        background:Hide()
    end
end

local function UpdateBindOverlay(button, containerID, slotID)
    local text = GetBindOverlay(button)
    local background = GetOverlayBackground(button, "AngusUIBindBackground")
    local label, r, g, b, shouldHighlight = GetContainerBindLabel(containerID, slotID, button)

    if label then
        text:SetText(label)
        text:SetTextColor(r or 1, g or 1, b or 1)
        text:Show()
        UpdateOverlayBackground(background, button, text, "TOP")
    else
        text:SetText("")
        text:Hide()
        background:Hide()
    end

    SetSpecialHighlight(button, shouldHighlight == true)
end

local function UpdateBagBindOverlay(button)
    UpdateBindOverlay(button, button:GetBagID(), button:GetID())
end

local function UpdateBankBindOverlay(button)
    UpdateBindOverlay(button, button:GetBankTabID(), button:GetContainerSlotID())
end

local function HookBagFrame(frame)
    if not frame or frame.AngusUIItemLevelHooked then
        return
    end

    frame:HookScript("OnShow", function()
        AngusUI:CharacterPanel()
    end)

    frame.AngusUIItemLevelHooked = true
end

local function HookFrames(self)
    if CharacterFrame and not self.characterPanelHooked then
        CharacterFrame:HookScript("OnShow", function()
            AngusUI:CharacterPanel()
        end)

        self.characterPanelHooked = true
    end

    if EquipmentFlyout_Show and not self.characterFlyoutHooked then
        hooksecurefunc("EquipmentFlyout_Show", function()
            AngusUI:CharacterPanel()
        end)

        self.characterFlyoutHooked = true
    end

    if EquipmentFlyoutFrame and not self.characterFlyoutFrameHooked then
        EquipmentFlyoutFrame:HookScript("OnShow", function()
            AngusUI:CharacterPanel()
        end)

        self.characterFlyoutFrameHooked = true
    end

    if BankPanelItemButtonMixin and not self.bankItemButtonHooked then
        hooksecurefunc(BankPanelItemButtonMixin, "Refresh", function(itemButton)
            local itemLevel, quality = GetBankItemLevel(itemButton)
            UpdateOverlay(itemButton, itemLevel, 10, 1, quality)
            UpdateBankBindOverlay(itemButton)
        end)

        self.bankItemButtonHooked = true
    end

    HookBagFrame(ContainerFrameCombinedBags)

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        HookBagFrame(_G["ContainerFrame" .. index])
    end
end

local function RefreshCharacterItemLevels()
    if not CharacterFrame then
        return
    end

    for _, slotInfo in ipairs(slotFrames) do
        local slotButton = GetSlotButton(slotInfo.frameName)

        if slotButton then
            local itemLevel, quality = GetEquippedItemLevel(slotInfo.slotId, slotButton)
            UpdateOverlay(slotButton, itemLevel, 11, 2, quality)
        end
    end
end

local function RefreshBagFrameItemLevels(frame)
    if not frame or not frame:IsShown() or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        local itemLevel, quality = GetBagItemLevel(itemButton)
        UpdateOverlay(itemButton, itemLevel, 10, 1, quality)
        UpdateBagBindOverlay(itemButton)
    end
end

local function RefreshBagItemLevels()
    RefreshBagFrameItemLevels(ContainerFrameCombinedBags)

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        RefreshBagFrameItemLevels(_G["ContainerFrame" .. index])
    end
end

local function RefreshFlyoutItemLevels()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame:IsShown() or not EquipmentFlyoutFrame.buttons then
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        if itemButton:IsShown() then
            local itemLevel, quality = GetFlyoutItemLevel(itemButton)
            UpdateOverlay(itemButton, itemLevel, 10, 1, quality)
        elseif itemButton.AngusUIItemLevelText then
            itemButton.AngusUIItemLevelText:SetText("")
            itemButton.AngusUIItemLevelText:Hide()
            if itemButton.AngusUIItemLevelBackground then
                itemButton.AngusUIItemLevelBackground:Hide()
            end
        end
    end
end

local function RefreshBankItemOverlays()
    if not BankPanel or not BankFrame or not BankFrame:IsShown() or not BankPanel.EnumerateValidItems then
        return
    end

    for itemButton in BankPanel:EnumerateValidItems() do
        local itemLevel, quality = GetBankItemLevel(itemButton)
        UpdateOverlay(itemButton, itemLevel, 10, 1, quality)
        UpdateBankBindOverlay(itemButton)
    end
end

local function QueueFlyoutRefresh(self)
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame:IsShown() then
        return
    end

    if self.flyoutRefreshQueued then
        return
    end

    self.flyoutRefreshQueued = true
    C_Timer.After(0, function()
        self.flyoutRefreshQueued = nil

        if EquipmentFlyoutFrame and EquipmentFlyoutFrame:IsShown() then
            RefreshFlyoutItemLevels()
        end
    end)
end

function AngusUI:ItemOverlays()
    HookFrames(self)
    RefreshCharacterItemLevels()
    RefreshBagItemLevels()
    RefreshBankItemOverlays()
    RefreshFlyoutItemLevels()
    QueueFlyoutRefresh(self)
end
