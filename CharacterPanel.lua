local _, AngusUI = ...

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

function AngusUI:RefreshCharacterPanel()
    if self.RefreshInventoryOverlays then
        self:RefreshInventoryOverlays()
    end

    RefreshCharacterStatsItemLevel()
end
