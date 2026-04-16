local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local MIN_ITEM_LEVEL_DISPLAY = 14
local ITEM_BIND_ON_EQUIP = Enum and Enum.ItemBind and Enum.ItemBind.OnEquip or 2
local ITEM_QUALITY_POOR = Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0
local ITEM_QUALITY_COMMON = Enum and Enum.ItemQuality and Enum.ItemQuality.Common or 1
local ACCOUNT_BANK_TYPE = Enum and Enum.BankType and Enum.BankType.Account or nil
local CHARACTER_BANK_TYPE = Enum and Enum.BankType and Enum.BankType.Character or nil
local ITEM_LEVEL_Y_OFFSET_ADJUST = 2
local ITEM_LEVEL_QUALITY_LIGHTEN = 0.30
local LABEL_BACKGROUND_INSET = 1
local LABEL_BACKGROUND_PADDING = 4
local BLACK_GRADIENT_TOP = CreateColor and CreateColor(0, 0, 0, 1) or nil
local BLACK_GRADIENT_CLEAR = CreateColor and CreateColor(0, 0, 0, 0) or nil
local hookedRefreshFrames = setmetatable({}, { __mode = "k" })
local hookedBankPanels = setmetatable({}, { __mode = "k" })

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

local midnightAlwaysEnchantableSlots = {
    [INVSLOT_CHEST] = true,
    [INVSLOT_FINGER1] = true,
    [INVSLOT_FINGER2] = true,
}

local midnightWeaponEnchantLocations = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_WEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
}

local slotFrames = {
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

local function PrepareItemButton(button)
    if not button then
        return nil
    end

    local overlay = button.AngusUIOverlay
    if not overlay then
        overlay = CreateFrame("Frame", nil, button)
        overlay:SetAllPoints()
        button.AngusUIOverlay = overlay
    end

    overlay:SetFrameLevel(button:GetFrameLevel() + 1)
    return overlay
end

local function GetSlotButton(frameName)
    return _G[frameName]
end

local function UpdateItemLevelFrameMaxTextFont(statFrame, text)
    local valueText = statFrame and statFrame.Value
    local fontObject = valueText and valueText:GetFontObject()

    if fontObject then
        text:SetFontObject(fontObject)
    else
        text:SetFontObject(GameFontNormalSmall)
    end

    if not valueText then
        return
    end

    local fontPath, fontSize, fontFlags = valueText:GetFont()
    if fontPath then
        text:SetFont(fontPath, math.max((fontSize or 12) - 4, 8), fontFlags)
    end
end

local function GetItemLevelFrameMaxText(statFrame)
    if statFrame.AngusUIMaxItemLevelText then
        return statFrame.AngusUIMaxItemLevelText
    end

    local text = statFrame:CreateFontString(nil, "OVERLAY")
    text:SetJustifyH("LEFT")
    text:SetShadowOffset(1, -1)
    text:SetShadowColor(0, 0, 0, 1)
    text:SetPoint("LEFT", statFrame.Value, "RIGHT", 4, 0)
    UpdateItemLevelFrameMaxTextFont(statFrame, text)
    statFrame.AngusUIMaxItemLevelText = text

    return text
end

local function RefreshCharacterStatsItemLevel()
    if not CharacterStatsPane or not CharacterStatsPane.ItemLevelFrame then
        return
    end

    local statFrame = CharacterStatsPane.ItemLevelFrame
    local maxText = GetItemLevelFrameMaxText(statFrame)
    UpdateItemLevelFrameMaxTextFont(statFrame, maxText)

    if not statFrame:IsShown() then
        maxText:SetText("")
        maxText:Hide()
        return
    end

    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    if not avgItemLevel or not avgItemLevelEquipped then
        maxText:SetText("")
        maxText:Hide()
        return
    end

    avgItemLevel = floor(avgItemLevel)
    avgItemLevelEquipped = floor(avgItemLevelEquipped)

    if avgItemLevel == avgItemLevelEquipped then
        maxText:SetText("")
        maxText:Hide()
        return
    end

    local r, g, b = statFrame.Value:GetTextColor()
    maxText:SetTextColor(r or 1, g or 1, b or 1, 0.9)
    maxText:SetText(format(" %d", avgItemLevel))
    maxText:Show()
end

local function CanUseAccountBank()
    if
        not ACCOUNT_BANK_TYPE or
        not C_Bank or
        not C_Bank.CanUseBank or
        not C_Bank.AutoDepositItemsIntoBank
    then
        return false
    end

    return C_Bank.CanUseBank(ACCOUNT_BANK_TYPE) == true
end

local function HasRefundableAccountBankItems()
    if
        not ACCOUNT_BANK_TYPE or
        not ItemUtil or
        not ItemUtil.IteratePlayerInventory or
        not C_Bank or
        not C_Bank.IsItemAllowedInBankType or
        not C_Item or
        not C_Item.CanBeRefunded
    then
        return false
    end

    return ItemUtil.IteratePlayerInventory(function(itemLocation)
        return C_Bank.IsItemAllowedInBankType(ACCOUNT_BANK_TYPE, itemLocation) and C_Item.CanBeRefunded(itemLocation)
    end) == true
end

local function DepositWarboundItemsToWarbandBank()
    if not CanUseAccountBank() then
        return
    end

    if HasRefundableAccountBankItems() then
        StaticPopup_Show("ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM", nil, nil, { bankType = ACCOUNT_BANK_TYPE })
    else
        C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
    end
end

local function RefreshDepositWarboundButton(button)
    if not button then
        return
    end

    local bankFrame = button:GetParent()
    local isCharacterBank = bankFrame and bankFrame.GetActiveBankType and bankFrame:GetActiveBankType() == CHARACTER_BANK_TYPE
    button:SetShown(bankFrame and bankFrame:IsShown() and isCharacterBank and CanUseAccountBank())
end

local function EnsureDepositWarboundButton()
    if not BankFrame then
        return nil
    end

    local button = BankFrame.AngusUIDepositWarboundButton
    if button then
        return button
    end

    local tabAnchor = BankFrame.TabSystem
    if not tabAnchor then
        return nil
    end

    button = CreateFrame("Button", nil, BankFrame, "UIPanelButtonTemplate")
    button:SetSize(150, 22)
    button:SetText("Deposit Warbound")
    button:SetPoint("BOTTOMLEFT", tabAnchor, "TOPLEFT", 0, 6)
    button:Hide()
    button:SetScript("OnClick", function(self)
        if PlaySound and SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        end

        DepositWarboundItemsToWarbandBank()
        RefreshDepositWarboundButton(self)
    end)

    BankFrame.AngusUIDepositWarboundButton = button
    return button
end

local function GetOrCreateItemLevelText(button, fontSize, yOffset)
    if not button then
        return nil
    end

    local overlay = PrepareItemButton(button)
    if not overlay then
        return nil
    end

    local text = button.AngusUIItemLevelText
    if not text then
        text = overlay:CreateFontString(nil, "OVERLAY")
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
    if not button then
        return nil
    end

    local overlay = PrepareItemButton(button)
    if not overlay then
        return nil
    end

    local text = button.AngusUIBindText
    if not text then
        text = overlay:CreateFontString(nil, "OVERLAY")
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

local function GetOrCreateMissingEnchantText(button)
    if not button then
        return nil
    end

    local overlay = PrepareItemButton(button)
    if not overlay then
        return nil
    end

    local text = button.AngusUIMissingEnchantText
    if not text then
        text = overlay:CreateFontString(nil, "OVERLAY")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 1)
        button.AngusUIMissingEnchantText = text
    end

    text:SetFont(Inconsolata, 10, "OUTLINE")

    return text
end

local function GetOrCreateOverlayBackground(button, key)
    if not button then
        return nil
    end

    local overlay = PrepareItemButton(button)
    if not overlay then
        return nil
    end

    local background = button[key]
    if not background then
        background = overlay:CreateTexture(nil, "ARTWORK")
        background:SetTexture("Interface\\Buttons\\WHITE8X8")
        background:Hide()
        button[key] = background
    end

    return background
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

local function GetOrCreateJunkIcon(button)
    if not button then
        return nil
    end

    local overlay = PrepareItemButton(button)
    if not overlay then
        return nil
    end

    local icon = button.AngusUIJunkIcon
    if not icon then
        icon = overlay:CreateTexture(nil, "OVERLAY")
        icon:SetAtlas("auctionhouse-icon-coin-gold")
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
        icon:SetSize(12, 12)
        icon:Hide()
        button.AngusUIJunkIcon = icon
    end

    return icon
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

local function HideButtonOverlays(button)
    if not button then
        return
    end

    HideTextOverlay(button.AngusUIItemLevelText, button.AngusUIItemLevelBackground)
    HideTextOverlay(button.AngusUIBindText, button.AngusUIBindBackground)
    HideTextOverlay(button.AngusUIMissingEnchantText)

    local icon = GetButtonIcon(button)
    if icon and icon.SetDesaturated then
        icon:SetDesaturated(false)
        icon:SetVertexColor(1, 1, 1)
    end

    if button.AngusUIJunkIcon then
        button.AngusUIJunkIcon:Hide()
    end
end

local function HideCharacterItemLevelOverlays()
    for _, slotInfo in ipairs(slotFrames) do
        HideButtonOverlays(GetSlotButton(slotInfo.frameName))
    end
end

local function HideBagFrameItemOverlays(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        HideButtonOverlays(itemButton)
    end
end

local function HideBagItemOverlays()
    HideBagFrameItemOverlays(ContainerFrameCombinedBags)

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        HideBagFrameItemOverlays(_G["ContainerFrame" .. index])
    end
end

local function HideFlyoutItemOverlays()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame.buttons then
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        HideButtonOverlays(itemButton)
    end
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

local function NormalizeItemLevel(itemLevel)
    if not itemLevel or itemLevel <= 0 or itemLevel < MIN_ITEM_LEVEL_DISPLAY then
        return nil
    end

    return itemLevel
end

local function IsRelevantEquipLocation(itemEquipLoc)
    return bagEquipLocations[itemEquipLoc] == true
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
    return IsRelevantEquipLocation(itemEquipLoc)
end

local function GetItemLevelFromItem(item)
    if not item or item.IsItemEmpty and item:IsItemEmpty() then
        return nil
    end

    local itemLevel = item.GetCurrentItemLevel and item:GetCurrentItemLevel() or nil
    if itemLevel and itemLevel > 0 then
        return NormalizeItemLevel(itemLevel)
    end

    local itemLink = item.GetItemLink and item:GetItemLink() or nil
    if itemLink and C_Item and C_Item.GetDetailedItemLevelInfo then
        return NormalizeItemLevel(C_Item.GetDetailedItemLevelInfo(itemLink))
    end

    return nil
end

local function GetContainerQuality(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    return containerItemInfo and containerItemInfo.quality or nil
end

local function IsJunkContainerItem(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    return containerItemInfo and containerItemInfo.quality == ITEM_QUALITY_POOR and containerItemInfo.hasNoValue ~= true
end

local function GetContainerBindData(containerID, slotID)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    local isSoulbound = itemLocation and itemLocation:IsValid() and C_Item and C_Item.IsBound and C_Item.IsBound(itemLocation)

    if containerItemInfo and not ShouldShowBindOverlayForQuality(containerItemInfo.quality) then
        return nil
    end

    if not isSoulbound and itemLocation and itemLocation:IsValid() and C_Item and C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation) then
        return "WuE", 0.45, 0.85, 1
    end

    if isSoulbound or (containerItemInfo and containerItemInfo.isBound) then
        return nil
    end

    local itemLink = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(containerID, slotID)
    if not itemLink then
        return nil
    end

    local itemInfo = C_Item and C_Item.GetItemInfo and { C_Item.GetItemInfo(itemLink) } or { GetItemInfo(itemLink) }
    if not itemInfo[1] then
        return nil
    end

    local bindType = itemInfo[14]
    local quality = itemInfo[3]
    if not ShouldShowBindOverlayForQuality(quality) then
        return nil
    end

    if bindType == ITEM_BIND_ON_EQUIP then
        local r, g, b = GetQualityColor(quality)
        return "BoE", r, g, b
    end

    return nil
end

local function GetPermanentEnchantId(itemLink)
    if type(itemLink) ~= "string" then
        return nil
    end

    local enchantId = tonumber(itemLink:match("item:[^:]*:([^:]+)"))
    if enchantId and enchantId > 0 then
        return enchantId
    end

    return nil
end

local function IsMidnightEnchantableWeapon(itemEquipLoc)
    return midnightWeaponEnchantLocations[itemEquipLoc] == true
end

local function IsMidnightEnchantableSlot(slotID, itemLink, itemID)
    if midnightAlwaysEnchantableSlots[slotID] then
        return true
    end

    if slotID ~= INVSLOT_MAINHAND and slotID ~= INVSLOT_OFFHAND then
        return false
    end

    if not C_Item or not C_Item.GetItemInfoInstant then
        return false
    end

    local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemLink or itemID))
    return IsMidnightEnchantableWeapon(itemEquipLoc)
end

local function PositionMissingEnchantText(button, text)
    text:ClearAllPoints()

    local buttonCenterX = button.GetCenter and button:GetCenter() or nil
    local parent = button.GetParent and button:GetParent() or nil
    local parentCenterX = parent and parent.GetCenter and parent:GetCenter() or nil

    if buttonCenterX and parentCenterX and buttonCenterX > parentCenterX then
        text:SetPoint("RIGHT", button, "LEFT", -2, 0)
        return
    end

    text:SetPoint("LEFT", button, "RIGHT", 2, 0)
end

local function UpdateMissingEnchantOverlay(button, slotID, itemLink, itemID)
    local text = GetOrCreateMissingEnchantText(button)
    if not text then
        return
    end

    if itemLink and IsMidnightEnchantableSlot(slotID, itemLink, itemID) and not GetPermanentEnchantId(itemLink) then
        PositionMissingEnchantText(button, text)
        text:SetText("Unenchanted")
        text:SetTextColor(1, 0.2, 0.2)
        text:Show()
    else
        HideTextOverlay(text)
    end
end

local function UpdateItemLevelOverlay(button, itemLevel, fontSize, yOffset, quality)
    local text = GetOrCreateItemLevelText(button, fontSize, yOffset)
    local background = GetOrCreateOverlayBackground(button, "AngusUIItemLevelBackground")
    if not text or not background then
        return
    end

    if itemLevel and quality ~= ITEM_QUALITY_POOR then
        text:SetText(itemLevel)
        text:SetTextColor(GetQualityColor(quality))
        text:Show()
        UpdateOverlayBackground(background, button, text, "BOTTOM")
    else
        HideTextOverlay(text, background)
    end
end

local function UpdateBindOverlay(button, label, r, g, b)
    local text = GetOrCreateBindText(button)
    local background = GetOrCreateOverlayBackground(button, "AngusUIBindBackground")
    if not text or not background then
        return
    end

    if label then
        text:SetText(label)
        text:SetTextColor(r or 1, g or 1, b or 1)
        text:Show()
        UpdateOverlayBackground(background, button, text, "TOP")
    else
        HideTextOverlay(text, background)
    end
end

local function UpdateJunkOverlay(button, isJunk)
    local icon = GetButtonIcon(button)
    if icon and icon.SetDesaturated then
        icon:SetDesaturated(isJunk == true)
        if isJunk then
            icon:SetVertexColor(0.75, 0.75, 0.75)
        else
            icon:SetVertexColor(1, 1, 1)
        end
    end

    local junkIcon = GetOrCreateJunkIcon(button)
    if junkIcon then
        junkIcon:SetShown(isJunk == true)
    end
end

local function UpdateContainerButton(button, containerID, slotID)
    HideButtonOverlays(button)

    if not button or containerID == nil or slotID == nil then
        return
    end

    if not IsRelevantContainerItem(containerID, slotID) or not Item or not Item.CreateFromBagAndSlot then
        return
    end

    local item = Item:CreateFromBagAndSlot(containerID, slotID)
    if not item or item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        local quality = item:GetItemQuality() or GetContainerQuality(containerID, slotID)
        UpdateItemLevelOverlay(button, GetItemLevelFromItem(item), 10, 1, quality)

        local label, r, g, b = GetContainerBindData(containerID, slotID)
        UpdateBindOverlay(button, label, r, g, b)
        UpdateJunkOverlay(button, IsJunkContainerItem(containerID, slotID))
    end)
end

local function UpdateCharacterItemButton(button)
    HideButtonOverlays(button)

    if not button or not button.GetID or not Item or not Item.CreateFromEquipmentSlot then
        return
    end

    local slotID = button:GetID()
    if slotID < INVSLOT_FIRST_EQUIPPED or slotID > INVSLOT_LAST_EQUIPPED then
        return
    end

    local item = Item:CreateFromEquipmentSlot(slotID)
    if not item or item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        local itemLink = item:GetItemLink() or GetInventoryItemLink("player", slotID)
        UpdateItemLevelOverlay(button, GetItemLevelFromItem(item), 11, 2, item:GetItemQuality())
        UpdateMissingEnchantOverlay(button, slotID, itemLink, item:GetItemID())
    end)
end

local function GetFlyoutItem(button)
    if not button or not Item then
        return nil
    end

    if button.GetItemLocation and Item.CreateFromItemLocation then
        local itemLocation = button:GetItemLocation()
        if itemLocation and itemLocation.IsValid and itemLocation:IsValid() then
            return Item:CreateFromItemLocation(itemLocation)
        end
    end

    local location = button.location
    if type(location) ~= "number" then
        return nil
    end

    if location >= (EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or 0xFFFFFFFD) then
        return nil
    end

    if EquipmentManager_GetLocationData then
        local locationData = EquipmentManager_GetLocationData(location)
        if not locationData or next(locationData) == nil then
            return nil
        end

        if locationData.isBags and Item.CreateFromBagAndSlot then
            return Item:CreateFromBagAndSlot(locationData.bag, locationData.slot)
        end

        if locationData.isPlayer and Item.CreateFromEquipmentSlot then
            return Item:CreateFromEquipmentSlot(locationData.slot)
        end
    elseif EquipmentManager_UnpackLocation then
        local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
        if type(voidStorage) ~= "boolean" then
            slot, bag = voidStorage, slot
            voidStorage = false
        end

        if bags and Item.CreateFromBagAndSlot then
            return Item:CreateFromBagAndSlot(bag, slot)
        end

        if player and not voidStorage and Item.CreateFromEquipmentSlot then
            return Item:CreateFromEquipmentSlot(slot)
        end
    end

    if EquipmentManager_GetItemInfoByLocation and Item.CreateFromItemID then
        local itemID = EquipmentManager_GetItemInfoByLocation(location)
        if itemID then
            return Item:CreateFromItemID(itemID)
        end
    end

    return nil
end

local function RefreshFlyoutItemButton(button)
    HideButtonOverlays(button)

    if not button or not button:IsShown() then
        return
    end

    local item = GetFlyoutItem(button)
    if not item or item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        local itemLink = item:GetItemLink()
        local itemID = item:GetItemID()
        local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemLink or itemID))
        if not IsRelevantEquipLocation(itemEquipLoc) then
            return
        end

        UpdateItemLevelOverlay(button, GetItemLevelFromItem(item), 10, 1, item:GetItemQuality())
    end)
end

local function RefreshFlyoutItemLevels()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame:IsShown() or not EquipmentFlyoutFrame.buttons then
        HideFlyoutItemOverlays()
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        RefreshFlyoutItemButton(itemButton)
    end
end

local function RefreshBagItemButton(itemButton)
    if not itemButton or not itemButton.GetBagID or not itemButton.GetID then
        return
    end

    UpdateContainerButton(itemButton, itemButton:GetBagID(), itemButton:GetID())
end

local function RefreshBagFrameItemLevels(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        RefreshBagItemButton(itemButton)
    end
end

local function RefreshLegacyContainerFrame(container)
    if not container then
        return
    end

    local bag = container:GetID()
    local name = container:GetName()
    if not name then
        return
    end

    for index = 1, container.size or 0 do
        local button = _G[name .. "Item" .. index]
        if button then
            UpdateContainerButton(button, bag, button:GetID())
        end
    end
end

local function RefreshLegacyBankItemButton(button)
    if not button or button.isBag then
        return
    end

    local parent = button:GetParent()
    if not parent then
        return
    end

    UpdateContainerButton(button, parent:GetID(), button:GetID())
end

local function RefreshBankPanel(panel)
    if not panel or not panel.EnumerateValidItems then
        return
    end

    local canUseBank = C_Bank and C_Bank.CanUseBank and panel.GetActiveBankType and C_Bank.CanUseBank(panel:GetActiveBankType())

    for itemButton in panel:EnumerateValidItems() do
        if canUseBank then
            local containerID = itemButton.GetBankTabID and itemButton:GetBankTabID() or nil
            local slotID = itemButton.GetContainerSlotID and itemButton:GetContainerSlotID() or nil
            UpdateContainerButton(itemButton, containerID, slotID)
        else
            HideButtonOverlays(itemButton)
        end
    end
end

local function HookBagFrames()
    if ContainerFrame_Update then
        return
    end

    local frames = { ContainerFrameCombinedBags }

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        frames[#frames + 1] = _G["ContainerFrame" .. index]
    end

    if ContainerFrameContainer and ContainerFrameContainer.ContainerFrames then
        for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
            frames[#frames + 1] = frame
        end
    end

    for _, frame in ipairs(frames) do
        if frame and frame.UpdateItems and not hookedRefreshFrames[frame] then
            hooksecurefunc(frame, "UpdateItems", RefreshBagFrameItemLevels)
            hookedRefreshFrames[frame] = true
        end
    end
end

local function HookBankPanel(panel)
    if not panel or hookedBankPanels[panel] then
        return
    end

    if panel.GenerateItemSlotsForSelectedTab then
        hooksecurefunc(panel, "GenerateItemSlotsForSelectedTab", RefreshBankPanel)
    end

    if panel.RefreshAllItemsForSelectedTab then
        hooksecurefunc(panel, "RefreshAllItemsForSelectedTab", RefreshBankPanel)
    end

    hookedBankPanels[panel] = true
end

local function InstallHooks(self)
    if PaperDollItemSlotButton_Update and not self.itemOverlayCharacterHooked then
        hooksecurefunc("PaperDollItemSlotButton_Update", UpdateCharacterItemButton)
        self.itemOverlayCharacterHooked = true
    end

    if EquipmentFlyout_UpdateItems and not self.itemOverlayFlyoutHooked then
        hooksecurefunc("EquipmentFlyout_UpdateItems", RefreshFlyoutItemLevels)
        self.itemOverlayFlyoutHooked = true
    end

    if ContainerFrame_Update and not self.itemOverlayLegacyBagHooked then
        hooksecurefunc("ContainerFrame_Update", RefreshLegacyContainerFrame)
        self.itemOverlayLegacyBagHooked = true
    end

    if BankFrameItemButton_Update and not self.itemOverlayLegacyBankHooked then
        hooksecurefunc("BankFrameItemButton_Update", RefreshLegacyBankItemButton)
        self.itemOverlayLegacyBankHooked = true
    end

    HookBagFrames()
    HookBankPanel(BankPanel)
    HookBankPanel(AccountBankPanel)
end

function AngusUI:ItemOverlays()
    InstallHooks(self)
end

function AngusUI:CharacterPanel()
    self:ItemOverlays()
    RefreshCharacterStatsItemLevel()
end

function AngusUI:RefreshCharacterPanel()
    self:CharacterPanel()
end

function AngusUI:BankInit()
    if self.bankDefaultTabHooked or not BankFrame then
        return
    end

    local depositWarboundButton = EnsureDepositWarboundButton()

    BankFrame:HookScript("OnShow", function(bankFrame)
        AngusUI:ItemOverlays()
        RefreshDepositWarboundButton(depositWarboundButton)
    end)

    BankFrame:HookScript("OnHide", function()
        RefreshDepositWarboundButton(depositWarboundButton)
    end)

    if depositWarboundButton and not self.bankDepositWarboundButtonHooked then
        hooksecurefunc(BankFrame, "SetTab", function()
            RefreshDepositWarboundButton(depositWarboundButton)
        end)
        self.bankDepositWarboundButtonHooked = true
    end

    self.bankDefaultTabHooked = true
end
