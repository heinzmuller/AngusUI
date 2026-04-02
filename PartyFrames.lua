local _, AngusUI = ...

local defaultPartyLabelText
local defaultCompactPartyTitleText

local function ShouldHidePartyLabel()
    return AngusUIDB == nil or AngusUIDB.hidePartyLabel ~= false
end

local function GetPartyLabelText()
    return ShouldHidePartyLabel() and "" or defaultPartyLabelText
end

local function GetCompactPartyTitleText()
    return ShouldHidePartyLabel() and "" or defaultCompactPartyTitleText
end

local function ApplySelectionLabel(label, text)
    if not label then
        return
    end

    label:SetText(text)

    if text == "" then
        label:Hide()
    else
        label:Show()
    end
end

local function ApplyPartyFrameLabel()
    if not PartyFrame then
        return
    end

    if defaultPartyLabelText == nil then
        defaultPartyLabelText = PartyFrame.systemNameString
    end

    local labelText = GetPartyLabelText()

    PartyFrame.systemNameString = labelText

    if not PartyFrame.Selection then
        return
    end

    ApplySelectionLabel(PartyFrame.Selection.Label, labelText)
    ApplySelectionLabel(PartyFrame.Selection.HorizontalLabel, labelText)
    ApplySelectionLabel(PartyFrame.Selection.VerticalLabel, labelText)
end

local function ApplyCompactPartyLabel()
    if not CompactPartyFrame then
        return
    end

    if defaultCompactPartyTitleText == nil then
        defaultCompactPartyTitleText = CompactPartyFrame.titleText
    end

    local titleText = GetCompactPartyTitleText()

    CompactPartyFrame.titleText = titleText

    if not CompactPartyFrame.title then
        return
    end

    CompactPartyFrame.title:SetText(titleText)

    if titleText == "" then
        CompactPartyFrame.title:Hide()
    else
        CompactPartyFrame.title:Show()
    end
end

function AngusUI:PartyFrames()
    ApplyPartyFrameLabel()
    ApplyCompactPartyLabel()

    if not self.partyFramesUpdateHooked and UpdateRaidAndPartyFrames then
        hooksecurefunc("UpdateRaidAndPartyFrames", function()
            AngusUI:PartyFrames()
        end)

        self.partyFramesUpdateHooked = true
    end

    if not self.partyFramesGenerateHooked and CompactPartyFrame_Generate then
        hooksecurefunc("CompactPartyFrame_Generate", function()
            AngusUI:PartyFrames()
        end)

        self.partyFramesGenerateHooked = true
    end
end
