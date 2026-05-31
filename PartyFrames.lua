-- Keeps party frame labels aligned with AngusUI's cleaner group-frame presentation preferences.
local _, AngusUI = ...

local defaultPartyLabelText
local defaultCompactPartyTitleText
local partyFramesWatcher = CreateFrame("Frame")

partyFramesWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
partyFramesWatcher:SetScript("OnEvent", function()
    AngusUI:PartyFrames()
end)

-- Centralizes whether party frame labels should be hidden.
local function ShouldHidePartyLabel()
    local settingsDB = AngusUI.GetSettingsDB and AngusUI:GetSettingsDB() or nil
    return settingsDB == nil or settingsDB.hidePartyLabel ~= false
end

-- Returns the correct standard party label text for the current setting.
local function GetPartyLabelText()
    return ShouldHidePartyLabel() and "" or defaultPartyLabelText
end

-- Returns the correct compact party title text for the current setting.
local function GetCompactPartyTitleText()
    return ShouldHidePartyLabel() and "" or defaultCompactPartyTitleText
end

-- Applies the desired visible state to a party-frame label widget.
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

-- Updates the standard party frame label to match addon settings.
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

-- Updates the compact party frame title to match addon settings.
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

-- Keeps party frame labels synchronized whenever Blizzard refreshes them.
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
