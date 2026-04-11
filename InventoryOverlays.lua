local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local MIN_ITEM_LEVEL_DISPLAY = 14
local ITEM_BIND_ON_EQUIP = Enum and Enum.ItemBind and Enum.ItemBind.OnEquip or 2
local ITEM_QUALITY_POOR = Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0
local ITEM_QUALITY_COMMON = Enum and Enum.ItemQuality and Enum.ItemQuality.Common or 1
local ITEM_LEVEL_Y_OFFSET_ADJUST = 2
local ITEM_LEVEL_QUALITY_LIGHTEN = 0.30
local LABEL_BACKGROUND_INSET = 1
local LABEL_BACKGROUND_PADDING = 4
local BIND_HIGHLIGHT_COLOR = { 0.45, 0.85, 1 }
local BLACK_GRADIENT_TOP = CreateColor and CreateColor(0, 0, 0, 1) or nil
local BLACK_GRADIENT_CLEAR = CreateColor and CreateColor(0, 0, 0, 0) or nil
local GetItemInfoFn = C_Item and C_Item.GetItemInfo or GetItemInfo

local equippableContainerItemLocations = {
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

local characterEquipmentSlots = {
    { slotId = INVSLOT_HEAD, frameName = "CharacterHeadSlot" },
    { slotId = INVSLOT_NECK, frameName = "CharacterNeckSlot" },
    { slotId = INVSLOT_SHOULDER, frameName = "CharacterShoulderSlot" },
    { slotId = INVSLOT_BACK, frameName = "CharacterBackSlot" },
    { slotId = INVSLOT_CHEST, frameName = "CharacterChestSlot" },
    { slotId = INVSLOT_BODY, frameName = "CharacterShirtSlot" },
    { slotId = INVSLOT_TABARD, frameName = "CharacterTabardSlot" },
    { slotId = INVSLOT_WRIST, frameName = "CharacterWristSlot" },
    { slotId = INVSLOT_HAND, frameName = "CharacterHandsSlot" },
    { slotId = INVSLOT_WAIST, frameName = "CharacterWaistSlot" },
    { slotId = INVSLOT_LEGS, frameName = "CharacterLegsSlot" },
    { slotId = INVSLOT_FEET, frameName = "CharacterFeetSlot" },
    { slotId = INVSLOT_FINGER1, frameName = "CharacterFinger0Slot" },
    { slotId = INVSLOT_FINGER2, frameName = "CharacterFinger1Slot" },
    { slotId = INVSLOT_TRINKET1, frameName = "CharacterTrinket0Slot" },
    { slotId = INVSLOT_TRINKET2, frameName = "CharacterTrinket1Slot" },
    { slotId = INVSLOT_MAINHAND, frameName = "CharacterMainHandSlot" },
    { slotId = INVSLOT_OFFHAND, frameName = "CharacterSecondaryHandSlot" },
}

local RefreshEquipmentSlotOverlay
local RefreshBagSlotOverlay
local RefreshBankSlotOverlay
local RefreshFlyoutSlotOverlay

local function GetSlotButton(frameName)
    return _G[frameName]
end

local function GetButtonIcon(button)
    if not button then
        return nil
    end

    if button.icon then
        return button.icon
    end

    if button.Icon then
        return button.Icon
    end

    if button.GetName then
        local name = button:GetName()
        if name then
            return _G[name .. "Icon"] or _G[name .. "IconTexture"]
        end
    end

    return nil
end

local function GetOrCreateItemLevelText(button, fontSize, yOffset)
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

local function GetOrCreateBindText(button)
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

local function GetOrCreateOverlayBackground(button, key)
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

local function HideTextOverlay(text, background)
    if text then
        text:SetText("")
        text:Hide()
    end

    if background then
        background:Hide()
    end
end

local function ClearItemLevelOverlay(button)
    HideTextOverlay(button and button.AngusUIItemLevelText, button and button.AngusUIItemLevelBackground)
end

local function ClearBindOverlay(button)
    HideTextOverlay(button and button.AngusUIBindText, button and button.AngusUIBindBackground)
end

local function GetOrCreateBindHighlight(button)
    local highlight = button.AngusUIBindHighlight

    if highlight then
        return highlight
    end

    highlight = button:CreateTexture(nil, "OVERLAY")
    highlight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.8)
    highlight:SetVertexColor(BIND_HIGHLIGHT_COLOR[1], BIND_HIGHLIGHT_COLOR[2], BIND_HIGHLIGHT_COLOR[3])
    highlight:Hide()
    button.AngusUIBindHighlight = highlight

    return highlight
end

local function SetBindHighlightShown(button, shown)
    local highlight = button and button.AngusUIBindHighlight

    if not shown then
        if highlight then
            highlight:Hide()
        end
        return
    end

    highlight = GetOrCreateBindHighlight(button)
    local size = math.max(button:GetWidth() or 0, button:GetHeight() or 0, 36) * 1.7
    highlight:ClearAllPoints()
    highlight:SetPoint("CENTER", button, "CENTER")
    highlight:SetSize(size, size)
    highlight:Show()
end

local function ShouldShowBindLabelForQuality(quality)
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

    local itemInfo = { GetItemInfoFn(itemLink) }
    return itemInfo[3]
end

local function NormalizeItemLevel(itemLevel)
    if not itemLevel or itemLevel <= 0 or itemLevel < MIN_ITEM_LEVEL_DISPLAY then
        return nil
    end

    return itemLevel
end

local function QueueButtonItemLoad(button, item)
    if not button or not item or button.AngusUIInventoryOverlayPending then
        return
    end

    local refresh = button.AngusUIInventoryOverlayRefresh
    if not refresh then
        return
    end

    button.AngusUIInventoryOverlayPending = true
    item:ContinueOnItemLoad(function()
        button.AngusUIInventoryOverlayPending = nil

        local callback = button.AngusUIInventoryOverlayRefresh or refresh
        if callback then
            callback(button)
        end
    end)
end

local function QueueButtonLocationLoad(button, itemLocation)
    if not Item or not Item.CreateFromItemLocation or not itemLocation or not itemLocation.IsValid or not itemLocation:IsValid() then
        return
    end

    local item = Item:CreateFromItemLocation(itemLocation)
    if item then
        QueueButtonItemLoad(button, item)
    end
end

local function QueueButtonLinkLoad(button, itemLink)
    if not Item or not Item.CreateFromItemLink or not itemLink then
        return
    end

    local item = Item:CreateFromItemLink(itemLink)
    if item then
        QueueButtonItemLoad(button, item)
    end
end

local function GetItemLevelFromLocation(itemLocation, button)
    if not itemLocation or not itemLocation.IsValid or not itemLocation:IsValid() then
        return nil
    end

    local currentItemLevel = C_Item and C_Item.GetCurrentItemLevel and C_Item.GetCurrentItemLevel(itemLocation)
    if currentItemLevel and currentItemLevel > 0 then
        return NormalizeItemLevel(currentItemLevel)
    end

    QueueButtonLocationLoad(button, itemLocation)
    return nil
end

local function GetItemLevelFromLink(itemLink, button)
    if not itemLink then
        return nil
    end

    local itemLevel = C_Item and C_Item.GetDetailedItemLevelInfo and C_Item.GetDetailedItemLevelInfo(itemLink)
    if itemLevel and itemLevel > 0 then
        return NormalizeItemLevel(itemLevel)
    end

    QueueButtonLinkLoad(button, itemLink)
    return nil
end

local function GetContainerItemInfo(containerID, slotID)
    if not C_Container or not C_Container.GetContainerItemInfo then
        return nil
    end

    return C_Container.GetContainerItemInfo(containerID, slotID)
end

local function GetContainerItemLink(containerID, slotID)
    if not C_Container or not C_Container.GetContainerItemLink then
        return nil
    end

    return C_Container.GetContainerItemLink(containerID, slotID)
end

local function IsEquippableContainerItem(containerID, slotID)
    if not C_Container or not C_Container.GetContainerItemID or not C_Item or not C_Item.GetItemInfoInstant then
        return false
    end

    local itemID = C_Container.GetContainerItemID(containerID, slotID)
    if not itemID then
        return false
    end

    local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemID))
    return equippableContainerItemLocations[itemEquipLoc] == true
end

local function UpdateItemLevelOverlay(button, itemLevel, fontSize, yOffset, quality)
    if not itemLevel then
        ClearItemLevelOverlay(button)
        return
    end

    local text = GetOrCreateItemLevelText(button, fontSize, yOffset)
    local background = GetOrCreateOverlayBackground(button, "AngusUIItemLevelBackground")
    text:SetText(itemLevel)
    text:SetTextColor(GetQualityColor(quality))
    text:Show()
    UpdateOverlayBackground(background, button, text, "BOTTOM")
end

local function ApplyPoorQualityState(button, quality, isLocked)
    local icon = GetButtonIcon(button)
    if not icon or not icon.SetDesaturated then
        return
    end

    local shouldDesaturateForPoorQuality = quality == ITEM_QUALITY_POOR
    button.AngusUIPoorQualityOverlay = shouldDesaturateForPoorQuality or nil
    icon:SetDesaturated(shouldDesaturateForPoorQuality or isLocked == true)
end

local function UpdateBindPresentation(button, label, r, g, b, shouldHighlight)
    if not label then
        ClearBindOverlay(button)
        SetBindHighlightShown(button, false)
        return
    end

    local text = GetOrCreateBindText(button)
    local background = GetOrCreateOverlayBackground(button, "AngusUIBindBackground")
    text:SetText(label)
    text:SetTextColor(r or 1, g or 1, b or 1)
    text:Show()
    UpdateOverlayBackground(background, button, text, "TOP")
    SetBindHighlightShown(button, shouldHighlight == true)
end

local function GetContainerBindPresentation(containerID, slotID, containerItemInfo, button)
    local quality = containerItemInfo and containerItemInfo.quality or nil
    if not ShouldShowBindLabelForQuality(quality) then
        return nil
    end

    local itemLocation = ItemLocation and ItemLocation.CreateFromBagAndSlot and ItemLocation:CreateFromBagAndSlot(containerID, slotID)
    local isValidLocation = itemLocation and itemLocation.IsValid and itemLocation:IsValid()
    local isBound = isValidLocation and C_Item and C_Item.IsBound and C_Item.IsBound(itemLocation)

    if not isBound and isValidLocation and C_Item and C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation) then
        return "WuE", 0.45, 0.85, 1, true
    end

    if isBound or (containerItemInfo and containerItemInfo.isBound) then
        return nil
    end

    local itemLink = GetContainerItemLink(containerID, slotID)
    if not itemLink then
        return nil
    end

    local itemInfo = { GetItemInfoFn(itemLink) }
    if not itemInfo[1] then
        QueueButtonLinkLoad(button, itemLink)
        return nil
    end

    local bindType = itemInfo[14]
    local itemQuality = itemInfo[3] or quality
    if bindType == ITEM_BIND_ON_EQUIP and ShouldShowBindLabelForQuality(itemQuality) then
        local r, g, b = GetQualityColor(itemQuality)
        return "BoE", r, g, b, false
    end

    return nil
end

local function RefreshContainerSlotOverlay(button, containerID, slotID)
    if not button or containerID == nil or slotID == nil then
        ClearItemLevelOverlay(button)
        ClearBindOverlay(button)
        SetBindHighlightShown(button, false)
        ApplyPoorQualityState(button, nil, false)
        return
    end

    local containerItemInfo = GetContainerItemInfo(containerID, slotID)
    local quality = containerItemInfo and containerItemInfo.quality or nil
    local isLocked = containerItemInfo and containerItemInfo.isLocked or false
    local itemLevel = nil

    if IsEquippableContainerItem(containerID, slotID) then
        if ItemLocation and ItemLocation.CreateFromBagAndSlot then
            itemLevel = GetItemLevelFromLocation(ItemLocation:CreateFromBagAndSlot(containerID, slotID), button)
        else
            itemLevel = GetItemLevelFromLink(GetContainerItemLink(containerID, slotID), button)
        end
    end

    UpdateItemLevelOverlay(button, itemLevel, 10, 1, quality)
    ApplyPoorQualityState(button, quality, isLocked)

    local label, r, g, b, shouldHighlight = GetContainerBindPresentation(containerID, slotID, containerItemInfo, button)
    UpdateBindPresentation(button, label, r, g, b, shouldHighlight)
end

function RefreshEquipmentSlotOverlay(slotButton)
    if not slotButton then
        return
    end

    slotButton.AngusUIInventoryOverlayRefresh = RefreshEquipmentSlotOverlay

    local slotId = slotButton.AngusUIEquipmentSlotID
    if not slotId then
        ClearItemLevelOverlay(slotButton)
        return
    end

    local itemLink = GetInventoryItemLink("player", slotId)
    if not itemLink then
        ClearItemLevelOverlay(slotButton)
        return
    end

    local itemLevel = nil
    if ItemLocation and ItemLocation.CreateFromEquipmentSlot then
        itemLevel = GetItemLevelFromLocation(ItemLocation:CreateFromEquipmentSlot(slotId), slotButton)
    else
        itemLevel = GetItemLevelFromLink(itemLink, slotButton)
    end

    UpdateItemLevelOverlay(slotButton, itemLevel, 11, 2, GetItemQualityFromLink(itemLink))
end

function RefreshBagSlotOverlay(itemButton)
    if not itemButton or not itemButton.GetBagID or not itemButton.GetID then
        return
    end

    itemButton.AngusUIInventoryOverlayRefresh = RefreshBagSlotOverlay
    RefreshContainerSlotOverlay(itemButton, itemButton:GetBagID(), itemButton:GetID())
end

function RefreshBankSlotOverlay(itemButton)
    if not itemButton or not itemButton.GetBankTabID or not itemButton.GetContainerSlotID then
        return
    end

    itemButton.AngusUIInventoryOverlayRefresh = RefreshBankSlotOverlay
    RefreshContainerSlotOverlay(itemButton, itemButton:GetBankTabID(), itemButton:GetContainerSlotID())
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
                return GetContainerItemLink(bag, slot)
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
        return GetContainerItemLink(locationData.bag, locationData.slot)
    end

    return GetInventoryItemLink("player", locationData.slot)
end

function RefreshFlyoutSlotOverlay(itemButton)
    if not itemButton then
        return
    end

    itemButton.AngusUIInventoryOverlayRefresh = RefreshFlyoutSlotOverlay

    local itemLink = GetFlyoutItemLink(itemButton)
    if not itemLink then
        ClearItemLevelOverlay(itemButton)
        return
    end

    local itemLevel = GetItemLevelFromLink(itemLink, itemButton)
    UpdateItemLevelOverlay(itemButton, itemLevel, 10, 1, GetItemQualityFromLink(itemLink))
end

local function RefreshEquipmentOverlays()
    if not CharacterFrame then
        return
    end

    for _, slotInfo in ipairs(characterEquipmentSlots) do
        local slotButton = GetSlotButton(slotInfo.frameName)
        if slotButton then
            slotButton.AngusUIEquipmentSlotID = slotInfo.slotId
            RefreshEquipmentSlotOverlay(slotButton)
        end
    end
end

local function RefreshVisibleBagFrameOverlays(frame)
    if not frame or not frame:IsShown() or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        RefreshBagSlotOverlay(itemButton)
    end
end

local function RefreshVisibleBagOverlays()
    RefreshVisibleBagFrameOverlays(ContainerFrameCombinedBags)

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        RefreshVisibleBagFrameOverlays(_G["ContainerFrame" .. index])
    end
end

local function RefreshVisibleFlyoutOverlays()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame:IsShown() or not EquipmentFlyoutFrame.buttons then
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        if itemButton:IsShown() then
            RefreshFlyoutSlotOverlay(itemButton)
        else
            ClearItemLevelOverlay(itemButton)
        end
    end
end

local function RefreshVisibleBankOverlays()
    if not BankPanel or not BankFrame or not BankFrame:IsShown() or not BankPanel.EnumerateValidItems then
        return
    end

    for itemButton in BankPanel:EnumerateValidItems() do
        RefreshBankSlotOverlay(itemButton)
    end
end

local function QueueFlyoutOverlayRefresh(self)
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame:IsShown() then
        return
    end

    if self.inventoryFlyoutOverlayRefreshQueued then
        return
    end

    self.inventoryFlyoutOverlayRefreshQueued = true
    C_Timer.After(0, function()
        self.inventoryFlyoutOverlayRefreshQueued = nil

        if EquipmentFlyoutFrame and EquipmentFlyoutFrame:IsShown() then
            RefreshVisibleFlyoutOverlays()
        end
    end)
end

local function HookRefreshOnShow(frame, callback, flag)
    if not frame or frame[flag] then
        return
    end

    frame:HookScript("OnShow", callback)
    frame[flag] = true
end

local function InitializeInventoryOverlayHooks(self)
    if CharacterFrame and not self.characterInventoryOverlayHooked then
        CharacterFrame:HookScript("OnShow", function()
            AngusUI:RefreshCharacterPanel()
        end)

        self.characterInventoryOverlayHooked = true
    end

    if EquipmentFlyout_Show and not self.characterFlyoutOverlayHooked then
        hooksecurefunc("EquipmentFlyout_Show", function()
            AngusUI:RefreshInventoryOverlays()
        end)

        self.characterFlyoutOverlayHooked = true
    end

    HookRefreshOnShow(EquipmentFlyoutFrame, function()
        AngusUI:RefreshInventoryOverlays()
    end, "AngusUIInventoryOverlayHooked")

    HookRefreshOnShow(BankFrame, function()
        AngusUI:RefreshInventoryOverlays()
    end, "AngusUIInventoryOverlayHooked")

    HookRefreshOnShow(ContainerFrameCombinedBags, function()
        AngusUI:RefreshInventoryOverlays()
    end, "AngusUIInventoryOverlayHooked")

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        HookRefreshOnShow(_G["ContainerFrame" .. index], function()
            AngusUI:RefreshInventoryOverlays()
        end, "AngusUIInventoryOverlayHooked")
    end

    if BankPanelItemButtonMixin and not self.bankItemOverlayHooked then
        hooksecurefunc(BankPanelItemButtonMixin, "Refresh", function(itemButton)
            RefreshBankSlotOverlay(itemButton)
        end)

        self.bankItemOverlayHooked = true
    end

    if ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.Update and not self.bagItemOverlayHooked then
        hooksecurefunc(ContainerFrameItemButtonMixin, "Update", function(itemButton)
            RefreshBagSlotOverlay(itemButton)
        end)

        self.bagItemOverlayHooked = true
    end

    if SetItemButtonDesaturated and not self.itemButtonDesaturationHooked then
        hooksecurefunc("SetItemButtonDesaturated", function(button)
            if not button or not button.AngusUIPoorQualityOverlay then
                return
            end

            local icon = GetButtonIcon(button)
            if icon and icon.SetDesaturated then
                icon:SetDesaturated(true)
            end
        end)

        self.itemButtonDesaturationHooked = true
    end
end

function AngusUI:RefreshInventoryOverlays()
    InitializeInventoryOverlayHooks(self)
    RefreshEquipmentOverlays()
    RefreshVisibleBagOverlays()
    RefreshVisibleBankOverlays()
    RefreshVisibleFlyoutOverlays()
    QueueFlyoutOverlayRefresh(self)
end
