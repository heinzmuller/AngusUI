local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local TOOLTIP_LINE_GEM_SOCKET = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.GemSocket or 3
local TOOLTIP_LINE_ITEM_ENCHANTMENT_PERMANENT = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.ItemEnchantmentPermanent or 15

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

local function HideCharacterItemLevel(button)
    local text = button and button.AngusUICharacterItemLevelText
    if text then
        text:SetText("")
        text:Hide()
    end
end

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

local function HideCharacterWarning(button)
    local text = button and button.AngusUICharacterWarningText
    if text then
        text:SetText("")
        text:Hide()
    end
end

local function ClearCharacterDecorations()
    for _, frameName in ipairs(characterSlotFrames) do
        local button = _G[frameName]
        HideCharacterWarning(button)
        HideCharacterItemLevel(button)
    end
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

local function GetInventoryTooltipData(slotID)
    if not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem then
        return nil
    end

    return C_TooltipInfo.GetInventoryItem("player", slotID)
end

local function HasInventoryPermanentEnhancement(slotID, itemLink)
    if GetPermanentEnchantId(itemLink) then
        return true
    end

    return HasTooltipLineType(GetInventoryTooltipData(slotID), TOOLTIP_LINE_ITEM_ENCHANTMENT_PERMANENT)
end

local function HasEmptyGemSocket(slotID)
    return HasTooltipLineType(GetInventoryTooltipData(slotID), TOOLTIP_LINE_GEM_SOCKET)
end

local function IsMidnightEnchantableWeapon(itemEquipLoc)
    return midnightWeaponEnchantLocations[itemEquipLoc] == true
end

local function IsMidnightEnchantableSlot(slotID, itemLink, itemID)
    if midnightAlwaysEnchantableSlots[slotID] then
        return true
    end

    if slotID ~= INVSLOT_MAINHAND and slotID ~= INVSLOT_SECONDARYHAND then
        return false
    end

    if not C_Item or not C_Item.GetItemInfoInstant then
        return false
    end

    local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemLink or itemID))
    return IsMidnightEnchantableWeapon(itemEquipLoc)
end

local function PositionCharacterWarningText(button, text)
    text:ClearAllPoints()

    if button.GetID and button:GetID() == INVSLOT_MAINHAND then
        text:SetJustifyH("RIGHT")
        text:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, 2)
        return
    end

    if button.GetID and button:GetID() == INVSLOT_SECONDARYHAND then
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

local function BuildCharacterWarningText(slotID, itemLink, itemID)
    local warnings = {}
    local hasPermanentEnhancement = HasInventoryPermanentEnhancement(slotID, itemLink)

    if IsMidnightEnchantableSlot(slotID, itemLink, itemID) and not hasPermanentEnhancement then
        warnings[#warnings + 1] = "Unenchanted"
    end

    if slotID == INVSLOT_LEGS and not hasPermanentEnhancement then
        warnings[#warnings + 1] = "No Leg Enh."
    end

    if HasEmptyGemSocket(slotID) then
        warnings[#warnings + 1] = "Missing Gem"
    end

    if #warnings == 0 then
        return nil
    end

    return table.concat(warnings, "\n")
end

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
        local warningText = BuildCharacterWarningText(slotID, itemLink, item:GetItemID())
        local text = PrepareCharacterWarningText(button)
        if not text then
            return
        end

        if warningText then
            PositionCharacterWarningText(button, text)
            text:SetText(warningText)
            text:SetTextColor(1, 0.2, 0.2)
            text:Show()
        else
            HideCharacterWarning(button)
        end
    end)
end

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

function AngusUI:CharacterSlotWarnings()
    ClearCharacterDecorations()

    for _, frameName in ipairs(characterSlotFrames) do
        RefreshCharacterSlot(_G[frameName])
    end
end

function AngusUI:CharacterPanel()
    RefreshCharacterStatsItemLevel()
    self:CharacterSlotWarnings()
end

function AngusUI:RefreshCharacterPanel()
    self:CharacterPanel()
end

function AngusUI:CharacterInit()
    if self.characterSlotHooked or not PaperDollItemSlotButton_Update then
        return
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        RefreshCharacterSlot(button)
    end)

    self.characterSlotHooked = true
end
