-- Enhances the character panel so gear quality, item level, and missing upgrades are easier to spot.
local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local TOOLTIP_LINE_GEM_SOCKET = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.GemSocket or 3
local TOOLTIP_LINE_ITEM_ENCHANTMENT_PERMANENT = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.ItemEnchantmentPermanent or 15
local characterWatcher

-- Refreshes the character panel when a relevant bank interaction opens.
local function RefreshCharacterForInteraction(interactionType)
    if
        interactionType ~= Enum.PlayerInteractionType.Banker and
        interactionType ~= Enum.PlayerInteractionType.AccountBanker
    then
        return
    end

    AngusUI:RefreshCharacterPanel()
end

-- Keeps the extra item-level text visually matched to the stat frame.
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

-- Creates or reuses the extra text that shows the higher average item level.
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

-- Shows a second average item level when carried gear beats equipped gear.
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

local midnightAlwaysEnchantableSlots = {
    [INVSLOT_HEAD] = true,
    [INVSLOT_SHOULDER] = true,
    [INVSLOT_CHEST] = true,
    [INVSLOT_FEET] = true,
    [INVSLOT_FINGER1] = true,
    [INVSLOT_FINGER2] = true,
}

local midnightWeaponEnchantLocations = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_WEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
}

local characterSlotFrames = {
    "CharacterHeadSlot",
    "CharacterNeckSlot",
    "CharacterShoulderSlot",
    "CharacterBackSlot",
    "CharacterChestSlot",
    "CharacterShirtSlot",
    "CharacterTabardSlot",
    "CharacterWristSlot",
    "CharacterHandsSlot",
    "CharacterWaistSlot",
    "CharacterLegsSlot",
    "CharacterFeetSlot",
    "CharacterFinger0Slot",
    "CharacterFinger1Slot",
    "CharacterTrinket0Slot",
    "CharacterTrinket1Slot",
    "CharacterMainHandSlot",
    "CharacterSecondaryHandSlot",
}

-- Creates or reuses per-slot text for displaying item level.
local function PrepareCharacterItemLevelText(button)
    if not button then
        return nil
    end

    local overlay = button.AngusUICharacterOverlay
    if not overlay then
        overlay = CreateFrame("Frame", nil, button)
        overlay:SetAllPoints()
        button.AngusUICharacterOverlay = overlay
    end

    overlay:SetFrameLevel(button:GetFrameLevel() + 1)

    local text = button.AngusUICharacterItemLevelText
    if not text then
        text = overlay:CreateFontString(nil, "OVERLAY")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 1)
        button.AngusUICharacterItemLevelText = text
    end

    text:SetFont(Inconsolata, 11, "OUTLINE")
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", button, "BOTTOM", 0, 4)

    return text
end

-- Chooses a safe quality color for character slot overlays.
local function GetCharacterQualityColor(quality)
    local r, g, b = quality and C_Item and C_Item.GetItemQualityColor and C_Item.GetItemQualityColor(quality)
    if r and g and b then
        return r, g, b
    end

    local itemQualityColor = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if itemQualityColor then
        return itemQualityColor.r or 1, itemQualityColor.g or 1, itemQualityColor.b or 1
    end

    return 1, 0.82, 0
end

-- Gets a dependable item level value for an equipped item.
local function GetCharacterItemLevel(item)
    if not item or item.IsItemEmpty and item:IsItemEmpty() then
        return nil
    end

    local itemLevel = item.GetCurrentItemLevel and item:GetCurrentItemLevel() or nil
    if itemLevel and itemLevel > 0 then
        return floor(itemLevel)
    end

    local itemLink = item.GetItemLink and item:GetItemLink() or nil
    if itemLink and C_Item and C_Item.GetDetailedItemLevelInfo then
        return floor(C_Item.GetDetailedItemLevelInfo(itemLink))
    end

    return nil
end

-- Clears the item-level overlay from a character slot.
local function HideCharacterItemLevel(button)
    local text = button and button.AngusUICharacterItemLevelText
    if text then
        text:SetText("")
        text:Hide()
    end
end

-- Shows item level on a character slot when it is worth displaying.
local function UpdateCharacterItemLevel(button, item)
    local text = PrepareCharacterItemLevelText(button)
    if not text then
        return
    end

    local itemLevel = GetCharacterItemLevel(item)
    local quality = item and item.GetItemQuality and item:GetItemQuality() or nil
    if itemLevel and quality ~= (Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0) then
        text:SetText(itemLevel)
        text:SetTextColor(GetCharacterQualityColor(quality))
        text:Show()
    else
        HideCharacterItemLevel(button)
    end
end

-- Creates or reuses per-slot text for enchant and socket warnings.
local function PrepareCharacterWarningText(button)
    if not button then
        return nil
    end

    local overlay = button.AngusUICharacterOverlay
    if not overlay then
        overlay = CreateFrame("Frame", nil, button)
        overlay:SetAllPoints()
        button.AngusUICharacterOverlay = overlay
    end

    overlay:SetFrameLevel(button:GetFrameLevel() + 1)

    local text = button.AngusUICharacterWarningText
    if not text then
        text = overlay:CreateFontString(nil, "OVERLAY")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 1)
        button.AngusUICharacterWarningText = text
    end

    text:SetFont(Inconsolata, 10, "OUTLINE")
    return text
end

-- Clears the warning overlay from a character slot.
local function HideCharacterWarning(button)
    local text = button and button.AngusUICharacterWarningText
    if text then
        text:SetText("")
        text:Hide()
    end
end

-- Resets all custom overlays on character equipment slots.
local function ClearCharacterDecorations()
    for _, frameName in ipairs(characterSlotFrames) do
        local button = _G[frameName]
        HideCharacterWarning(button)
        HideCharacterItemLevel(button)
    end
end

-- Detects whether an item link already contains a permanent enchant.
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

-- Extracts link fields needed for gem and enchant checks.
local function GetLinkValues(link)
    if type(link) ~= "string" or not LinkUtil or not LinkUtil.ExtractLink then
        return nil
    end

    local linkType, linkOptions = LinkUtil.ExtractLink(link)
    if linkOptions then
        return linkType, strsplit(":", linkOptions)
    end

    return linkType
end

-- Checks tooltip data for a specific kind of warning line.
local function HasTooltipLineType(tooltipData, lineType)
    local lines = tooltipData and tooltipData.lines
    if not lines then
        return false
    end

    for _, line in ipairs(lines) do
        if line and line.type == lineType then
            return true
        end
    end

    return false
end

-- Fetches tooltip data for an equipped inventory slot.
local function GetInventoryTooltipData(slotID)
    if not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem then
        return nil
    end

    return C_TooltipInfo.GetInventoryItem("player", slotID)
end

-- Determines whether an equipped item has a permanent enhancement.
local function HasInventoryPermanentEnhancement(slotID, itemLink)
    if GetPermanentEnchantId(itemLink) then
        return true
    end

    return HasTooltipLineType(GetInventoryTooltipData(slotID), TOOLTIP_LINE_ITEM_ENCHANTMENT_PERMANENT)
end

-- Determines whether an equipped item still has an unfilled socket.
local function HasEmptyGemSocket(slotID, itemLink)
    if type(itemLink) == "string" then
        local getItemStats = C_Item and C_Item.GetItemStats or GetItemStats
        local stats = getItemStats and getItemStats(itemLink)
        if stats then
            local sockets = 0
            for label in pairs(stats) do
                if type(label) == "string" and label:match("EMPTY_SOCKET_") then
                    sockets = sockets + 1
                end
            end

            if sockets == 0 then
                return false
            end

            local gem1, gem2, gem3, gem4 = select(4, GetLinkValues(itemLink))
            local gems = (gem1 ~= "" and gem1 and 1 or 0)
                + (gem2 ~= "" and gem2 and 1 or 0)
                + (gem3 ~= "" and gem3 and 1 or 0)
                + (gem4 ~= "" and gem4 and 1 or 0)

            return sockets > gems
        end
    end

    return HasTooltipLineType(GetInventoryTooltipData(slotID), TOOLTIP_LINE_GEM_SOCKET)
end

-- Recognizes weapon types that can take Midnight enchants.
local function IsMidnightEnchantableWeapon(itemEquipLoc)
    return midnightWeaponEnchantLocations[itemEquipLoc] == true
end

-- Decides whether a slot should be treated as enchantable for warnings.
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

-- Places warning text where it stays readable around the slot.
local function PositionCharacterWarningText(button, text)
    text:ClearAllPoints()

    if button.GetID and button:GetID() == INVSLOT_MAINHAND then
        text:SetJustifyH("RIGHT")
        text:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, 2)
        return
    end

    if button.GetID and button:GetID() == INVSLOT_OFFHAND then
        text:SetJustifyH("LEFT")
        text:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 2)
        return
    end

    local buttonCenterX = button.GetCenter and button:GetCenter() or nil
    local parent = button.GetParent and button:GetParent() or nil
    local parentCenterX = parent and parent.GetCenter and parent:GetCenter() or nil

    if buttonCenterX and parentCenterX and buttonCenterX > parentCenterX then
        text:SetJustifyH("RIGHT")
        text:SetPoint("RIGHT", button, "LEFT", -2, 0)
        return
    end

    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", button, "RIGHT", 2, 0)
end

-- Decides which socket or enchant status message the slot should show.
local function BuildCharacterWarningText(slotID, itemLink, itemID)
    local warnings = {}
    local hasPermanentEnhancement = HasInventoryPermanentEnhancement(slotID, itemLink)
    local isEnchantable = IsMidnightEnchantableSlot(slotID, itemLink, itemID)
    local isLegSlot = slotID == INVSLOT_LEGS

    if isEnchantable and not hasPermanentEnhancement then
        warnings[#warnings + 1] = "Unenchanted"
    end

    if isLegSlot and not hasPermanentEnhancement and not isEnchantable then
        warnings[#warnings + 1] = "Unenchanted"
    end

    if HasEmptyGemSocket(slotID, itemLink) then
        warnings[#warnings + 1] = "Gem"
    end

    if #warnings > 0 then
        return table.concat(warnings, "\n"), 1, 0.2, 0.2
    end

    if (isEnchantable or isLegSlot) and hasPermanentEnhancement then
        return "Enchanted", 0.2, 0.9, 0.2
    end

    return nil
end

-- Refreshes a slot's item-level and warning overlays after item data loads.
local function UpdateCharacterSlotWarning(button)
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
        UpdateCharacterItemLevel(button, item)
        local warningText, warningR, warningG, warningB = BuildCharacterWarningText(slotID, itemLink, item:GetItemID())
        local text = PrepareCharacterWarningText(button)
        if not text then
            return
        end

        if warningText then
            PositionCharacterWarningText(button, text)
            text:SetText(warningText)
            text:SetTextColor(warningR or 1, warningG or 0.2, warningB or 0.2)
            text:Show()
        else
            HideCharacterWarning(button)
        end
    end)
end

-- Fully rebuilds custom overlays for one equipment slot.
local function RefreshCharacterSlot(button)
    HideCharacterWarning(button)
    HideCharacterItemLevel(button)

    if not button or not button.GetID then
        return
    end

    local slotID = button:GetID()
    if slotID < INVSLOT_FIRST_EQUIPPED or slotID > INVSLOT_LAST_EQUIPPED then
        return
    end

    UpdateCharacterSlotWarning(button)
end

-- Refreshes overlays for all visible character equipment slots.
function AngusUI:CharacterSlotWarnings()
    ClearCharacterDecorations()

    for _, frameName in ipairs(characterSlotFrames) do
        RefreshCharacterSlot(_G[frameName])
    end
end

-- Refreshes the character panel's custom item-level and warning displays.
function AngusUI:CharacterPanel()
    RefreshCharacterStatsItemLevel()
    self:CharacterSlotWarnings()
end

-- Provides a single entry point for refreshing the custom character view.
function AngusUI:RefreshCharacterPanel()
    self:CharacterPanel()
end

-- Hooks character updates so the panel overlays stay current.
function AngusUI:CharacterInit()
    if self.characterSlotHooked or not PaperDollItemSlotButton_Update then
        return
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        RefreshCharacterSlot(button)
    end)

    self.characterSlotHooked = true

    characterWatcher = characterWatcher or CreateFrame("Frame")
    characterWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    characterWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    characterWatcher:RegisterEvent("UNIT_INVENTORY_CHANGED")
    characterWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    characterWatcher:RegisterEvent("BAG_UPDATE_DELAYED")
    characterWatcher:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
    characterWatcher:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_INVENTORY_CHANGED" then
            if ... ~= "player" then
                return
            end

            AngusUI:RefreshCharacterPanel()
            return
        end

        if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
            RefreshCharacterForInteraction(...)
            return
        end

        AngusUI:RefreshCharacterPanel()
    end)
end
