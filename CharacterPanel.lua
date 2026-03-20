local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local MIN_ITEM_LEVEL_DISPLAY = 14
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
    if button.AngusUIItemLevelText then
        return button.AngusUIItemLevelText
    end

    local text = button:CreateFontString(nil, "OVERLAY")
    text:SetFont(Inconsolata, fontSize or 10, "OUTLINE")
    text:SetPoint("BOTTOM", button, "BOTTOM", 0, yOffset or 2)
    text:SetJustifyH("CENTER")
    text:SetShadowOffset(1, -1)
    text:SetShadowColor(0, 0, 0, 1)
    button.AngusUIItemLevelText = text

    return text
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
    return GetItemLevelFromLocation(itemLocation, slotButton)
end

local function IsRelevantBagItem(bag, slot)
    if not C_Container or not C_Container.GetContainerItemID then
        return false
    end

    local itemID = C_Container.GetContainerItemID(bag, slot)
    if not itemID or not C_Item or not C_Item.GetItemInfoInstant then
        return false
    end

    local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemID))
    return bagEquipLocations[itemEquipLoc] == true
end

local function GetBagItemLevel(itemButton)
    local bag = itemButton:GetBagID()
    local slot = itemButton:GetID()

    if not IsRelevantBagItem(bag, slot) then
        itemButton.AngusUIItemLevelPending = nil
        return nil
    end

    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
    return GetItemLevelFromLocation(itemLocation, itemButton)
end

local function GetFlyoutItemLink(itemButton)
    if not itemButton.location or itemButton.location >= (EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or 0xFFFFFFFD) then
        return nil
    end

    if not EquipmentManager_GetLocationData then
        return nil
    end

    local locationData = EquipmentManager_GetLocationData(itemButton.location)
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
    return GetItemLevelFromLink(itemLink, itemButton)
end

local function UpdateOverlay(button, itemLevel, fontSize, yOffset)
    local text = GetOverlay(button, fontSize, yOffset)

    if itemLevel then
        text:SetText(itemLevel)
        text:Show()
    else
        text:SetText("")
        text:Hide()
    end
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
            UpdateOverlay(slotButton, GetEquippedItemLevel(slotInfo.slotId, slotButton), 10, 2)
        end
    end
end

local function RefreshBagFrameItemLevels(frame)
    if not frame or not frame:IsShown() or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        UpdateOverlay(itemButton, GetBagItemLevel(itemButton), 9, 1)
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
            UpdateOverlay(itemButton, GetFlyoutItemLevel(itemButton), 9, 1)
        elseif itemButton.AngusUIItemLevelText then
            itemButton.AngusUIItemLevelText:SetText("")
            itemButton.AngusUIItemLevelText:Hide()
        end
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

function AngusUI:CharacterPanel()
    HookFrames(self)
    RefreshCharacterItemLevels()
    RefreshBagItemLevels()
    RefreshFlyoutItemLevels()
    QueueFlyoutRefresh(self)
end
