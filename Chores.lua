local _, AngusUI = ...

local toastMinWidth = 420
local toastSidePadding = 5
local toastTopPadding = 5
local toastBottomPadding = 5
local toastHeightAdjustment = 20
local toastDurationSeconds = 5
local toastInitialDurationSeconds = 8
local toastCompletionDurationSeconds = 2
local toastFadeInDurationSeconds = 0.4
local toastFadeOutDurationSeconds = 0.4
local toastLayoutName = "CharacterCreateDropdown"
local cofferKeyShardsWeeklyMaximum = 600

local gridTopOffset = toastTopPadding
local groupHeaderHeight = 18
local columnHeaderHeight = 18
local valueRowHeight = 34
local toastBaseHeight = gridTopOffset + groupHeaderHeight + columnHeaderHeight + valueRowHeight + toastBottomPadding + toastHeightAdjustment
local columnDividerWidth = 1
local wideColumnWidth = 74
local narrowColumnWidth = 60
local booleanIconSize = 18

local placeholderText = "-"
local readyTexture = "Interface\\RaidFrame\\ReadyCheck-Ready"
local notReadyTexture = "Interface\\RaidFrame\\ReadyCheck-NotReady"

local function GetBooleanColor(complete)
    if complete then
        return 0.2, 0.9, 0.35
    end

    return 1, 0.35, 0.35
end

local function GetProgressColor(current, total)
    if current >= total then
        return 0.2, 0.9, 0.35
    end

    if current == (total - 1) then
        return 1, 0.82, 0.2
    end

    return 1, 0.35, 0.35
end

local function CreateCellData(header, width, valueText, r, g, b, tooltipTitle, tooltipText, iconTexture)
    return {
        header = header,
        width = width,
        valueText = valueText,
        r = r,
        g = g,
        b = b,
        tooltipTitle = tooltipTitle,
        tooltipText = tooltipText,
        iconTexture = iconTexture,
    }
end

local function CreateBooleanCell(header, width, complete, tooltipTitle, tooltipText)
    local r, g, b = GetBooleanColor(complete)
    return CreateCellData(header, width, nil, r, g, b, tooltipTitle, tooltipText, complete and readyTexture or notReadyTexture)
end

local function CreateFractionCell(header, width, current, total, tooltipTitle, tooltipText)
    local r, g, b = GetProgressColor(current, total)
    return CreateCellData(header, width, current .. "/" .. total, r, g, b, tooltipTitle, tooltipText)
end

local function CreateRemainingCell(header, width, remaining, tooltipTitle, tooltipText)
    if remaining <= 0 then
        local r, g, b = GetBooleanColor(true)
        return CreateCellData(header, width, nil, r, g, b, tooltipTitle, tooltipText, readyTexture)
    end

    local r, g, b = GetBooleanColor(false)
    return CreateCellData(header, width, tostring(remaining), r, g, b, tooltipTitle, tooltipText)
end

local function CreatePlaceholderCell(header, width, tooltipTitle, tooltipText)
    return CreateCellData(header, width, placeholderText, 0.6, 0.6, 0.6, tooltipTitle, tooltipText)
end

local function ShowColumnTooltip(frame)
    if not frame.tooltipTitle then
        return
    end

    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetText(frame.tooltipTitle)
    if frame.tooltipText and frame.tooltipText ~= "" then
        GameTooltip:AddLine(frame.tooltipText, 0.85, 0.85, 0.85, true)
    end
    GameTooltip:Show()
end

local function EnsureToastStyle(frame)
    if frame.style then
        return frame.style
    end

    local style = CreateFrame("Frame", nil, frame)
    style:SetAllPoints()

    if NineSliceUtil and NineSliceUtil.GetLayout and NineSliceUtil.ApplyLayout then
        local layout = NineSliceUtil.GetLayout(toastLayoutName)
        if layout then
            NineSliceUtil.ApplyLayout(style, layout)
        end
    end

    frame.style = style

    return style
end

local function StopToastHideCountdown(toast)
    toast.hideAt = nil
    toast:SetScript("OnUpdate", nil)
end

local function StartToastHideCountdown(toast, durationSeconds)
    toast.hideAt = GetTime() + (durationSeconds or toastDurationSeconds)
    toast:SetScript("OnUpdate", function(frame)
        if frame.hideAt and GetTime() >= frame.hideAt then
            StopToastHideCountdown(frame)
            frame:FadeOut()
        end
    end)
end

local function EnsureToastFadeInAnimation(toast)
    if toast.fadeInAnimation then
        return toast.fadeInAnimation
    end

    local animationGroup = toast:CreateAnimationGroup()
    local animation = animationGroup:CreateAnimation("Alpha")
    animation:SetFromAlpha(0)
    animation:SetToAlpha(1)
    animation:SetDuration(toastFadeInDurationSeconds)
    animation:SetSmoothing("OUT")

    animationGroup:SetScript("OnFinished", function()
        toast:SetAlpha(1)
    end)

    toast.fadeInAnimation = animationGroup

    return animationGroup
end

local function PlayToastFadeIn(toast)
    local animationGroup = EnsureToastFadeInAnimation(toast)
    toast.pendingHideAfterFadeOut = false
    if toast.fadeOutAnimation then
        toast.fadeOutAnimation:Stop()
    end
    animationGroup:Stop()
    toast:SetAlpha(0)
    animationGroup:Play()
end

local function EnsureToastFadeOutAnimation(toast)
    if toast.fadeOutAnimation then
        return toast.fadeOutAnimation
    end

    local animationGroup = toast:CreateAnimationGroup()
    local animation = animationGroup:CreateAnimation("Alpha")
    animation:SetFromAlpha(1)
    animation:SetToAlpha(0)
    animation:SetDuration(toastFadeOutDurationSeconds)
    animation:SetSmoothing("IN")

    animationGroup:SetScript("OnFinished", function()
        if toast.pendingHideAfterFadeOut then
            toast.pendingHideAfterFadeOut = false
            toast:Hide()
        end
    end)

    toast.fadeOutAnimation = animationGroup

    return animationGroup
end

local function FadeOutToast(toast)
    if not toast:IsShown() then
        return
    end

    StopToastHideCountdown(toast)
    toast.pendingHideAfterFadeOut = true

    if toast.fadeInAnimation then
        toast.fadeInAnimation:Stop()
    end

    local animationGroup = EnsureToastFadeOutAnimation(toast)
    animationGroup:Stop()
    toast:SetAlpha(1)
    animationGroup:Play()
end

local function EnsureGroupLabel(toast, index)
    if toast.groupLabels[index] then
        return toast.groupLabels[index]
    end

    local label = toast.grid:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetTextColor(0.92, 0.92, 0.92)
    toast.groupLabels[index] = label

    return label
end

local function EnsureDivider(toast, index)
    if toast.dividers[index] then
        return toast.dividers[index]
    end

    local divider = toast.grid:CreateTexture(nil, "ARTWORK")
    toast.dividers[index] = divider

    return divider
end

local function EnsureColumn(toast, index)
    if toast.columns[index] then
        return toast.columns[index]
    end

    local column = CreateFrame("Frame", nil, toast.grid)
    column.header = column:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    column.header:SetPoint("TOPLEFT", column, "TOPLEFT", 2, -2)
    column.header:SetPoint("TOPRIGHT", column, "TOPRIGHT", -2, -2)
    column.header:SetJustifyH("CENTER")
    column.header:SetJustifyV("MIDDLE")
    column.header:SetTextColor(0.72, 0.82, 0.86)

    column.value = column:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    column.value:SetPoint("TOPLEFT", column, "TOPLEFT", 2, -(columnHeaderHeight + 3))
    column.value:SetPoint("BOTTOMRIGHT", column, "BOTTOMRIGHT", -2, -4)
    column.value:SetJustifyH("CENTER")
    column.value:SetJustifyV("MIDDLE")

    column.icon = column:CreateTexture(nil, "OVERLAY")
    column.icon:SetSize(booleanIconSize, booleanIconSize)
    column.icon:SetPoint("CENTER", column.value, "CENTER", 0, 0)
    column.icon:Hide()

    column:SetScript("OnEnter", ShowColumnTooltip)
    column:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    toast.columns[index] = column

    return column
end

local function EnsureToast(self)
    if self.choresToast then
        return self.choresToast
    end

    local toast = CreateFrame("Frame", "AngusUIChoresToast", UIParent)
    toast:SetSize(toastMinWidth, toastBaseHeight)
    toast:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    toast:SetFrameStrata("DIALOG")
    toast:SetClampedToScreen(true)
    toast:EnableMouse(true)
    toast:Hide()
    EnsureToastStyle(toast)

    toast.closeButton = CreateFrame("Button", nil, toast, "UIPanelCloseButton")
    toast.closeButton:SetPoint("TOPLEFT", toast, "TOPRIGHT", -8, -6)
    toast.closeButton:SetScript("OnClick", function()
        FadeOutToast(toast)
    end)
    toast.closeButton:HookScript("OnEnter", function()
        StopToastHideCountdown(toast)
    end)
    toast.closeButton:HookScript("OnLeave", function()
        StartToastHideCountdown(toast)
    end)

    toast.grid = CreateFrame("Frame", nil, toast)
    toast.grid:SetPoint("TOPLEFT", toast, "TOPLEFT", toastSidePadding, -gridTopOffset)

    toast.grid.topBorder = toast.grid:CreateTexture(nil, "ARTWORK")
    toast.grid.topBorder:SetColorTexture(1, 1, 1, 0.09)

    toast.grid.middleBorder = toast.grid:CreateTexture(nil, "ARTWORK")
    toast.grid.middleBorder:SetColorTexture(1, 1, 1, 0.07)

    toast.grid.bottomBorder = toast.grid:CreateTexture(nil, "ARTWORK")
    toast.grid.bottomBorder:SetColorTexture(1, 1, 1, 0.09)

    toast.groupLabels = {}
    toast.columns = {}
    toast.dividers = {}
    toast.FadeOut = FadeOutToast

    toast:SetScript("OnEnter", function(frame)
        StopToastHideCountdown(frame)
    end)
    toast:SetScript("OnLeave", function(frame)
        StartToastHideCountdown(frame)
    end)
    toast:SetScript("OnHide", function(frame)
        StopToastHideCountdown(frame)
        frame.pendingHideAfterFadeOut = false
        if frame.fadeInAnimation then
            frame.fadeInAnimation:Stop()
        end
        if frame.fadeOutAnimation then
            frame.fadeOutAnimation:Stop()
        end
        frame:SetAlpha(1)
        GameTooltip:Hide()
    end)

    self.choresToast = toast

    return toast
end

local function BuildProfessionGroups(self, professionSnapshot)
    local groups = {}
    local professionDefinitions = self.GetCurrentProfessionSyncData and self:GetCurrentProfessionSyncData() or {}

    for _, profession in ipairs(professionDefinitions) do
        local professionData = professionSnapshot[profession.name]
        if professionData then
            local treasuresRemaining = math.max(0, professionData.treasuresRemaining or 0)
            local treasuresComplete = treasuresRemaining <= 0
            table.insert(groups, {
                label = strupper(profession.name),
                columns = {
                    CreateBooleanCell(
                        "TRT",
                        narrowColumnWidth,
                        professionData.treatise == true,
                        profession.name .. " Treatise",
                        (professionData.treatise == true and "Completed" or "Incomplete") .. "."
                    ),
                    CreateBooleanCell(
                        "WKLY",
                        narrowColumnWidth,
                        professionData.weekly == true,
                        profession.name .. " Weekly",
                        (professionData.weekly == true and "Completed" or "Incomplete") .. "."
                    ),
                    CreateBooleanCell(
                        "TREAS",
                        narrowColumnWidth,
                        treasuresComplete,
                        profession.name .. " Treasures",
                        treasuresComplete and "All profession treasures collected." or (treasuresRemaining .. " treasures remaining.")
                    ),
                },
            })
        end
    end

    if #groups == 0 then
        table.insert(groups, {
            label = "PROFESSIONS",
            columns = {
                CreatePlaceholderCell("TRT", narrowColumnWidth, "Treatise", "No tracked professions learned."),
                CreatePlaceholderCell("WKLY", narrowColumnWidth, "Weekly", "No tracked professions learned."),
                CreatePlaceholderCell("TREAS", narrowColumnWidth, "Treasures", "No tracked professions learned."),
            },
        })
    end

    return groups
end

function AngusUI:BuildChoresGridData()
    local characterData = self.GetSyncCharacterData and self:GetSyncCharacterData() or nil
    local preyData = characterData and characterData.prey or {}
    local delveData = characterData and characterData.delves or {}
    local professionSnapshot = characterData and characterData.professions or {}

    local gildedStashesLooted = math.max(0, math.min(delveData.gildedStashesLooted or 0, 4))
    local trovehuntersBounty = delveData.trovehuntersBounty == true
    local cofferKeyShardsRemaining = math.max(0, delveData.cofferKeyShardsRemaining or cofferKeyShardsWeeklyMaximum)
    local nightmareHuntsCompleted = math.max(0, math.min(preyData.nightmare or 0, 4))
    local preyWeeklyComplete = preyData.weekly == true

    local groups = {
        {
            label = "DELVES",
            columns = {
                CreateFractionCell("STASH", wideColumnWidth, gildedStashesLooted, 4, "Delves: Gilded Stashes", gildedStashesLooted .. "/4 gilded stashes looted this week."),
                CreateBooleanCell("BOUNTY", wideColumnWidth, trovehuntersBounty, "Delves: Trovehunter's Bounty", trovehuntersBounty and "Trovehunter's Bounty is active." or "Trovehunter's Bounty is missing."),
                CreateRemainingCell("SHARDS", wideColumnWidth, cofferKeyShardsRemaining, "Delves: Coffer Key Shards", cofferKeyShardsRemaining <= 0 and "Weekly shard cap reached." or (cofferKeyShardsRemaining .. " shards remaining until the weekly cap.")),
            },
        },
        {
            label = "PREY",
            columns = {
                CreateBooleanCell("WKLY", wideColumnWidth, preyWeeklyComplete, "Prey: Weekly", preyWeeklyComplete and "Nightmare weekly completed." or "Nightmare weekly still available."),
                CreateFractionCell("NM", wideColumnWidth, nightmareHuntsCompleted, 4, "Prey: Nightmare Hunts", nightmareHuntsCompleted .. "/4 nightmare hunts completed."),
            },
        },
    }

    local professionGroups = BuildProfessionGroups(self, professionSnapshot)
    for _, group in ipairs(professionGroups) do
        table.insert(groups, group)
    end

    return groups
end

function AngusUI:BuildChoresCompletionSnapshot(characterData)
    local delvesData = characterData and characterData.delves or {}
    local preyData = characterData and characterData.prey or {}
    local professionSnapshot = characterData and characterData.professions or {}
    local professions = {}

    for _, profession in ipairs(self.GetCurrentProfessionSyncData and self:GetCurrentProfessionSyncData() or {}) do
        local professionData = professionSnapshot[profession.name]
        if professionData then
            professions[profession.name] = {
                treatise = professionData.treatise == true,
                weekly = professionData.weekly == true,
                treasures = math.max(0, professionData.treasuresRemaining or 0) <= 0,
            }
        end
    end

    return {
        delves = {
            stashes = math.max(0, math.min(delvesData.gildedStashesLooted or 0, 4)) >= 4,
            bounty = delvesData.trovehuntersBounty == true,
            shards = math.max(0, delvesData.cofferKeyShardsRemaining or cofferKeyShardsWeeklyMaximum) <= 0,
        },
        prey = {
            weekly = preyData.weekly == true,
            nightmare = math.max(0, math.min(preyData.nightmare or 0, 4)) >= 4,
        },
        professions = professions,
    }
end

function AngusUI:DidAnyChoreComplete(previousSnapshot, currentSnapshot)
    if not previousSnapshot or not currentSnapshot then
        return false
    end

    if previousSnapshot.delves.stashes ~= true and currentSnapshot.delves.stashes == true then
        return true
    end

    if previousSnapshot.delves.bounty ~= true and currentSnapshot.delves.bounty == true then
        return true
    end

    if previousSnapshot.delves.shards ~= true and currentSnapshot.delves.shards == true then
        return true
    end

    if previousSnapshot.prey.weekly ~= true and currentSnapshot.prey.weekly == true then
        return true
    end

    if previousSnapshot.prey.nightmare ~= true and currentSnapshot.prey.nightmare == true then
        return true
    end

    for professionName, currentProfessionData in pairs(currentSnapshot.professions) do
        local previousProfessionData = previousSnapshot.professions[professionName] or {}

        if previousProfessionData.treatise ~= true and currentProfessionData.treatise == true then
            return true
        end

        if previousProfessionData.weekly ~= true and currentProfessionData.weekly == true then
            return true
        end

        if previousProfessionData.treasures ~= true and currentProfessionData.treasures == true then
            return true
        end
    end

    return false
end

local function UpdateToastLayout(toast, groups)
    local gridHeight = groupHeaderHeight + columnHeaderHeight + valueRowHeight
    local totalWidth = 0
    local totalColumns = 0

    for _, group in ipairs(groups) do
        for _, column in ipairs(group.columns) do
            if totalColumns > 0 then
                totalWidth = totalWidth + columnDividerWidth
            end
            totalWidth = totalWidth + column.width
            totalColumns = totalColumns + 1
        end
    end

    local toastWidth = math.max(toastMinWidth, totalWidth + (toastSidePadding * 2))
    local toastHeight = math.max(toastBaseHeight, gridTopOffset + gridHeight + toastBottomPadding + toastHeightAdjustment)
    toast:SetSize(toastWidth, toastHeight)
    toast.grid:SetSize(totalWidth, gridHeight)

    toast.grid.topBorder:ClearAllPoints()
    toast.grid.topBorder:SetPoint("TOPLEFT", toast.grid, "TOPLEFT", 0, 0)
    toast.grid.topBorder:SetPoint("TOPRIGHT", toast.grid, "TOPRIGHT", 0, 0)
    toast.grid.topBorder:SetHeight(1)

    toast.grid.middleBorder:ClearAllPoints()
    toast.grid.middleBorder:SetPoint("TOPLEFT", toast.grid, "TOPLEFT", 0, -(groupHeaderHeight + columnHeaderHeight))
    toast.grid.middleBorder:SetPoint("TOPRIGHT", toast.grid, "TOPRIGHT", 0, -(groupHeaderHeight + columnHeaderHeight))
    toast.grid.middleBorder:SetHeight(1)

    toast.grid.bottomBorder:ClearAllPoints()
    toast.grid.bottomBorder:SetPoint("BOTTOMLEFT", toast.grid, "BOTTOMLEFT", 0, 0)
    toast.grid.bottomBorder:SetPoint("BOTTOMRIGHT", toast.grid, "BOTTOMRIGHT", 0, 0)
    toast.grid.bottomBorder:SetHeight(1)

    local groupIndex = 0
    local columnIndex = 0
    local dividerIndex = 0
    local xOffset = 0

    for currentGroupIndex, group in ipairs(groups) do
        groupIndex = groupIndex + 1
        local groupStartX = xOffset

        for currentColumnIndex, columnData in ipairs(group.columns) do
            columnIndex = columnIndex + 1
            local column = EnsureColumn(toast, columnIndex)
            column:ClearAllPoints()
            column:SetPoint("TOPLEFT", toast.grid, "TOPLEFT", xOffset, -groupHeaderHeight)
            column:SetSize(columnData.width, columnHeaderHeight + valueRowHeight)
            column.header:SetText(columnData.header)

            if columnData.iconTexture then
                column.value:SetText(nil)
                column.icon:SetTexture(columnData.iconTexture)
                column.icon:SetVertexColor(columnData.r, columnData.g, columnData.b)
                column.icon:Show()
            else
                column.value:SetText(columnData.valueText)
                column.value:SetTextColor(columnData.r, columnData.g, columnData.b)
                column.icon:Hide()
            end

            column.tooltipTitle = columnData.tooltipTitle
            column.tooltipText = columnData.tooltipText
            column:Show()

            xOffset = xOffset + columnData.width

            local isLastColumnOverall = currentGroupIndex == #groups and currentColumnIndex == #group.columns
            if not isLastColumnOverall then
                dividerIndex = dividerIndex + 1
                local divider = EnsureDivider(toast, dividerIndex)
                divider:ClearAllPoints()
                divider:SetPoint("TOPLEFT", toast.grid, "TOPLEFT", xOffset, 0)
                divider:SetSize(columnDividerWidth, gridHeight)

                if currentColumnIndex == #group.columns then
                    divider:SetColorTexture(1, 1, 1, 0.14)
                else
                    divider:SetColorTexture(1, 1, 1, 0.06)
                end

                divider:Show()
                xOffset = xOffset + columnDividerWidth
            end
        end

        local groupEndX = xOffset
        if currentGroupIndex < #groups then
            groupEndX = groupEndX - columnDividerWidth
        end

        local groupLabel = EnsureGroupLabel(toast, groupIndex)
        groupLabel:ClearAllPoints()
        groupLabel:SetPoint("TOPLEFT", toast.grid, "TOPLEFT", groupStartX + 4, -1)
        groupLabel:SetWidth(math.max(groupEndX - groupStartX - 8, 1))
        groupLabel:SetHeight(groupHeaderHeight)
        groupLabel:SetText(group.label)
        groupLabel:Show()
    end

    for index = groupIndex + 1, #toast.groupLabels do
        toast.groupLabels[index]:Hide()
    end

    for index = columnIndex + 1, #toast.columns do
        toast.columns[index]:Hide()
        toast.columns[index].icon:Hide()
        toast.columns[index].tooltipTitle = nil
        toast.columns[index].tooltipText = nil
    end

    for index = dividerIndex + 1, #toast.dividers do
        toast.dividers[index]:Hide()
    end
end

function AngusUI:RefreshChoresToast()
    if not self.choresToast then
        return
    end

    UpdateToastLayout(self.choresToast, self:BuildChoresGridData())
end

function AngusUI:ShowChoresToast(force, durationSeconds)
    if not force and self.choresToastShown then
        return
    end

    if self.SyncRefresh then
        self:SyncRefresh()
    end

    local toast = EnsureToast(self)
    self:RefreshChoresToast()
    toast:Show()
    PlayToastFadeIn(toast)
    StartToastHideCountdown(toast, durationSeconds)

    if not force then
        self.choresToastShown = true
    end
end

function AngusUI:ShowCompletedChoreToast()
    self:ShowChoresToast(true, toastCompletionDurationSeconds)
end

function AngusUI:ShowInitialChoresToast()
    self:ShowChoresToast(false, toastInitialDurationSeconds)
end

function AngusUI:ChoresInit()
    if self.choresInitialized then
        return
    end

    self.choresInitialized = true
    self.choresToastShown = false
    self.choresInitialToastPending = false
end
