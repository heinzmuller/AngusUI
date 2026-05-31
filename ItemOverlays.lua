-- Adds bag, bank, and flyout overlays so important gear details can be judged at a glance.
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

-- Creates or reuses an overlay container for an item button.
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

-- Checks whether warband bank deposit actions are currently available.
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

-- Detects refundable items that require a safer deposit flow.
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

-- Deposits eligible items into the warband bank with confirmation when needed.
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

-- Shows the deposit shortcut only when it is useful.
local function RefreshDepositWarboundButton(button)
    if not button then
        return
    end

    local bankFrame = button:GetParent()
    local isCharacterBank = bankFrame and bankFrame.GetActiveBankType and bankFrame:GetActiveBankType() == CHARACTER_BANK_TYPE
    button:SetShown(bankFrame and bankFrame:IsShown() and isCharacterBank and CanUseAccountBank())
end

-- Creates or reuses the bank button for depositing warbound items.
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

-- Creates or reuses the bottom label for item level.
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

-- Creates or reuses the top label for bind status.
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

-- Creates or reuses a background to keep overlay text readable.
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

-- Finds the icon texture tied to an item button.
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

-- Creates or reuses a visual marker for junk items.
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

-- Clears and hides one text overlay and its background.
local function HideTextOverlay(text, background)
    if text then
        text:SetText("")
        text:Hide()
    end

    if background then
        background:Hide()
    end
end

-- Resets all custom overlay visuals on an item button.
local function HideButtonOverlays(button)
    if not button then
        return
    end

    HideTextOverlay(button.AngusUIItemLevelText, button.AngusUIItemLevelBackground)
    HideTextOverlay(button.AngusUIBindText, button.AngusUIBindBackground)

    local icon = GetButtonIcon(button)
    if icon and icon.SetDesaturated then
        icon:SetDesaturated(false)
        icon:SetVertexColor(1, 1, 1)
    end

    if button.AngusUIJunkIcon then
        button.AngusUIJunkIcon:Hide()
    end
end

-- Clears overlays from every item in one bag frame.
local function HideBagFrameItemOverlays(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        HideButtonOverlays(itemButton)
    end
end

-- Clears overlays from all visible bag frames.
local function HideBagItemOverlays()
    HideBagFrameItemOverlays(ContainerFrameCombinedBags)

    for index = 1, NUM_CONTAINER_FRAMES or 6 do
        HideBagFrameItemOverlays(_G["ContainerFrame" .. index])
    end
end

-- Clears overlays from equipment flyout buttons.
local function HideFlyoutItemOverlays()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame.buttons then
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        HideButtonOverlays(itemButton)
    end
end

-- Fits and places the label background behind overlay text.
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

-- Limits bind labels to items important enough to call out.
local function ShouldShowBindOverlayForQuality(quality)
    return quality and quality > ITEM_QUALITY_COMMON
end

-- Derives a readable overlay color from item quality.
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

-- Suppresses item levels too low to be worth showing.
local function NormalizeItemLevel(itemLevel)
    if not itemLevel or itemLevel <= 0 or itemLevel < MIN_ITEM_LEVEL_DISPLAY then
        return nil
    end

    return itemLevel
end

-- Identifies item types that should receive gear overlays.
local function IsRelevantEquipLocation(itemEquipLoc)
    return bagEquipLocations[itemEquipLoc] == true
end

-- Ignores bag items that are not equippable gear.
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

-- Gets a display-worthy item level from loaded item data.
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

-- Reads item quality from a bag or bank slot.
local function GetContainerQuality(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    return containerItemInfo and containerItemInfo.quality or nil
end

-- Identifies low-quality items that should be marked as junk.
local function IsJunkContainerItem(containerID, slotID)
    local containerItemInfo = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(containerID, slotID)
    return containerItemInfo and containerItemInfo.quality == ITEM_QUALITY_POOR and containerItemInfo.hasNoValue ~= true
end

-- Decides which bind label a container item should show, if any.
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

-- Shows or hides the item-level label for a button.
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

-- Shows or hides the bind-status label for a button.
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

-- Marks junk items with subdued visuals and an icon.
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

-- Refreshes all overlays for one bag or bank item button.
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

-- Resolves which item an equipment flyout entry represents.
local function GetFlyoutItem(button)
    if not button or not Item then
        return nil
    end

    local flyoutFrame = EquipmentFlyoutFrame
    local flyoutButton = flyoutFrame and flyoutFrame.button or nil
    local flyoutParent = flyoutButton and flyoutButton.GetParent and flyoutButton:GetParent() or nil
    local flyoutSettings = flyoutParent and flyoutParent.flyoutSettings or nil
    if flyoutSettings and flyoutSettings.useItemLocation then
        if button.GetItemLocation and Item.CreateFromItemLocation then
            local itemLocation = button:GetItemLocation()
            if itemLocation then
                return Item:CreateFromItemLocation(itemLocation)
            end
        end

        return nil
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
        if locationData and locationData.isBags and Item.CreateFromBagAndSlot then
            return Item:CreateFromBagAndSlot(locationData.bag, locationData.slot)
        end

        if locationData and locationData.isPlayer and Item.CreateFromEquipmentSlot then
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

-- Refreshes overlays for one equipment flyout button.
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
        UpdateItemLevelOverlay(button, GetItemLevelFromItem(item), 10, 1, item:GetItemQuality())
    end)
end

-- Refreshes overlays for all equipment flyout entries.
local function RefreshFlyoutItemLevels()
    if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame.buttons then
        HideFlyoutItemOverlays()
        return
    end

    for _, itemButton in ipairs(EquipmentFlyoutFrame.buttons) do
        RefreshFlyoutItemButton(itemButton)
    end
end

-- Refreshes overlays for one modern bag item button.
local function RefreshBagItemButton(itemButton)
    if not itemButton or not itemButton.GetBagID or not itemButton.GetID then
        return
    end

    UpdateContainerButton(itemButton, itemButton:GetBagID(), itemButton:GetID())
end

-- Refreshes overlays across all items in a bag frame.
local function RefreshBagFrameItemLevels(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        RefreshBagItemButton(itemButton)
    end
end

-- Refreshes overlays for older bag frame layouts.
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

-- Refreshes overlays for an older bank item button.
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

-- Refreshes bank overlays only when the bank's contents are accessible.
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

-- Attaches overlay refreshes to modern bag frame updates.
local function HookBagFrames()
    if ContainerFrame_Update then
        return
    end

    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.UpdateItems and not hookedRefreshFrames[ContainerFrameCombinedBags] then
        hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", RefreshBagFrameItemLevels)
        hookedRefreshFrames[ContainerFrameCombinedBags] = true
    end

    local containerFrames = (ContainerFrameContainer or UIParent).ContainerFrames
    if not containerFrames then
        return
    end

    for _, frame in ipairs(containerFrames) do
        if frame and frame.UpdateItems and not hookedRefreshFrames[frame] then
            hooksecurefunc(frame, "UpdateItems", RefreshBagFrameItemLevels)
            hookedRefreshFrames[frame] = true
        end
    end
end

-- Attaches overlay refreshes to a bank panel's item refresh points.
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

-- Installs all hooks needed to keep item overlays updated.
local function InstallHooks(self)
    if EquipmentFlyout_UpdateItems and not self.itemOverlayFlyoutHooked then
        hooksecurefunc("EquipmentFlyout_UpdateItems", RefreshFlyoutItemLevels)
        self.itemOverlayFlyoutHooked = true
    end

    if EquipmentFlyout_DisplayButton and not self.itemOverlayFlyoutDisplayHooked then
        hooksecurefunc("EquipmentFlyout_DisplayButton", RefreshFlyoutItemButton)
        self.itemOverlayFlyoutDisplayHooked = true
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

-- Initializes the item overlay system.
function AngusUI:ItemOverlays()
    InstallHooks(self)
end

-- Initializes the custom bank deposit button behavior.
function AngusUI:BankInit()
    if self.bankDefaultTabHooked or not BankFrame then
        return
    end

    local depositWarboundButton = EnsureDepositWarboundButton()

    BankFrame:HookScript("OnShow", function(bankFrame)
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
