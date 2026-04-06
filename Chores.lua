local _, AngusUI = ...

local toastWidth = 420
local toastMinHeight = 120
local toastRowHeight = 18
local toastRowSpacing = 0
local toastGroupSpacing = 2
local toastPadding = 16
local toastDurationSeconds = 5
local cofferKeyShardsWeeklyMaximum = 600

local function CreateRowData(key, label, complete, statusText, sortOrder, options)
    options = options or {}

    return {
        key = key,
        label = label,
        complete = complete == true,
        sortComplete = options.sortComplete,
        hideBullet = options.hideBullet == true,
        groupStart = options.groupStart == true,
        inlineStatusColors = options.inlineStatusColors == true,
        statusText = statusText,
        sortOrder = sortOrder or 100,
    }
end

local function CompareRows(left, right)
    local leftSortComplete = left.sortComplete
    if leftSortComplete == nil then
        leftSortComplete = left.complete
    end

    local rightSortComplete = right.sortComplete
    if rightSortComplete == nil then
        rightSortComplete = right.complete
    end

    if leftSortComplete ~= rightSortComplete then
        return not leftSortComplete
    end

    if left.sortOrder ~= right.sortOrder then
        return left.sortOrder < right.sortOrder
    end

    return left.label < right.label
end

local function GetStatusColor(complete, statusText)
    if statusText == "TODO" then
        return 1, 0.82, 0.2
    end

    if complete then
        return 0.2, 0.9, 0.35
    end

    return 1, 0.35, 0.35
end

local function EnsureBackdrop(frame)
    if frame.backdrop then
        return
    end

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:SetAllPoints()
    backdrop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    backdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
    backdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
    frame.backdrop = backdrop
end

local function StartToastHideCountdown(toast)
    toast.hideAt = GetTime() + toastDurationSeconds
    toast:SetScript("OnUpdate", function(frame)
        if frame.hideAt and GetTime() >= frame.hideAt then
            frame:Hide()
        end
    end)
end

local function EnsureToast(self)
    if self.choresToast then
        return self.choresToast
    end

    local toast = CreateFrame("Frame", "AngusUIChoresToast", UIParent, "BackdropTemplate")
    toast:SetSize(toastWidth, toastMinHeight)
    toast:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    toast:SetFrameStrata("DIALOG")
    toast:SetClampedToScreen(true)
    toast:EnableMouse(true)
    toast:Hide()
    EnsureBackdrop(toast)

    toast.title = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    toast.title:SetPoint("TOPLEFT", toast, "TOPLEFT", toastPadding, -toastPadding)
    toast.title:SetJustifyH("LEFT")
    toast.title:SetText("Weekly Chores")

    toast.closeButton = CreateFrame("Button", nil, toast, "UIPanelCloseButton")
    toast.closeButton:SetPoint("TOPRIGHT", toast, "TOPRIGHT", -4, -4)
    toast.closeButton:SetScript("OnClick", function()
        toast:Hide()
    end)
    toast.closeButton:HookScript("OnEnter", function()
        toast.hideAt = nil
        toast:SetScript("OnUpdate", nil)
    end)
    toast.closeButton:HookScript("OnLeave", function()
        StartToastHideCountdown(toast)
    end)

    toast.rows = {}
    toast:SetScript("OnEnter", function(frame)
        frame.hideAt = nil
        frame:SetScript("OnUpdate", nil)
    end)
    toast:SetScript("OnLeave", function(frame)
        StartToastHideCountdown(frame)
    end)
    toast:SetScript("OnHide", function(frame)
        frame.hideAt = nil
        frame:SetScript("OnUpdate", nil)
    end)

    self.choresToast = toast

    return toast
end

local function EnsureRow(toast, index)
    if toast.rows[index] then
        return toast.rows[index]
    end

    local row = CreateFrame("Frame", nil, toast)
    row:SetSize(toastWidth - (toastPadding * 2), toastRowHeight)

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:Hide()

    row.bullet = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.bullet:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.bullet:SetText("•")

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.label:SetPoint("LEFT", row.bullet, "RIGHT", 8, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetWidth(250)

    row.status = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.status:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.status:SetJustifyH("RIGHT")
    row.status:SetWidth(120)

    toast.rows[index] = row

    return row
end

local function UpdateToastLayout(toast, rows)
    local contentTopOffset = toastPadding + 26
    local currentYOffset = contentTopOffset
    local stripeIndex = 0

    for index, rowData in ipairs(rows) do
        local row = EnsureRow(toast, index)
        if index == 1 or rowData.groupStart then
            stripeIndex = stripeIndex + 1
        end

        if index > 1 then
            currentYOffset = currentYOffset + toastRowHeight + toastRowSpacing
            if rowData.groupStart then
                currentYOffset = currentYOffset + toastGroupSpacing
            end
        end

        local yOffset = -currentYOffset
        local r, g, b = GetStatusColor(rowData.complete, rowData.statusText)
        local backgroundTopPadding = 0
        if index > 1 and rowData.groupStart then
            backgroundTopPadding = toastGroupSpacing
        end

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", toast, "TOPLEFT", toastPadding, yOffset)
        row.background:ClearAllPoints()
        row.background:SetPoint("TOPLEFT", row, "TOPLEFT", 0, backgroundTopPadding)
        row.background:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        if math.fmod(stripeIndex, 2) == 1 then
            row.background:SetColorTexture(1, 1, 1, 0.04)
        else
            row.background:SetColorTexture(1, 1, 1, 0.08)
        end
        row.background:Show()
        row.bullet:Hide()
        if rowData.hideBullet then
            row.label:SetPoint("LEFT", row, "LEFT", 24, 0)
        else
            row.label:SetPoint("LEFT", row, "LEFT", 4, 0)
        end
        row.label:SetText(rowData.label)
        row.status:SetText(rowData.statusText)
        if rowData.inlineStatusColors then
            row.status:SetTextColor(1, 1, 1)
        else
            row.status:SetTextColor(r, g, b)
        end
        row.status:Show()
        row:Show()
    end

    for index = #rows + 1, #toast.rows do
        toast.rows[index].background:Hide()
        toast.rows[index]:Hide()
    end

    local rowCount = math.max(#rows, 1)
    local groupSpacingTotal = 0
    for index = 2, #rows do
        if rows[index].groupStart then
            groupSpacingTotal = groupSpacingTotal + toastGroupSpacing
        end
    end
    local height = (toastPadding * 2) + 28 + (rowCount * toastRowHeight) + ((rowCount - 1) * toastRowSpacing) + groupSpacingTotal
    toast:SetHeight(math.max(height, toastMinHeight))
end

function AngusUI:BuildChoresRows()
    local rows = {}

    local accountData = self.GetSyncAccountData and self:GetSyncAccountData() or nil
    local characterData = self.GetSyncCharacterData and self:GetSyncCharacterData() or nil
    local worldBossComplete = accountData and accountData.firstWorldBoss == true
    table.insert(rows, CreateRowData("worldBoss", "World Boss", worldBossComplete, worldBossComplete and "Done" or "Pending", 10, { groupStart = true }))

    local preyData = characterData and characterData.prey or {}
    local nightmareHuntsCompleted = math.max(0, math.min(preyData.nightmare or 0, 4))
    local preyWeeklyComplete = preyData.weekly == true
    local preyComplete = nightmareHuntsCompleted >= 4 and preyWeeklyComplete
    local nightmareStatusText = nightmareHuntsCompleted .. "/4 Nightmare Hunts"
    local nightmareUsesInlineStatusColor = false
    if nightmareHuntsCompleted == 3 then
        nightmareStatusText = "|cffffd133" .. nightmareStatusText .. "|r"
        nightmareUsesInlineStatusColor = true
    end
    table.insert(rows, CreateRowData("prey-nightmare", "Prey", nightmareHuntsCompleted >= 4, nightmareStatusText, 20, {
        groupStart = true,
        inlineStatusColors = nightmareUsesInlineStatusColor,
        sortComplete = preyComplete,
    }))
    table.insert(rows, CreateRowData("prey-weekly", "", preyWeeklyComplete, "Weekly", 21, { hideBullet = true, sortComplete = preyComplete }))

    local hasProfessionRows = false
    local professionSnapshot = characterData and characterData.professions or {}
    local professionDefinitions = self.GetCurrentProfessionSyncData and self:GetCurrentProfessionSyncData() or {}
    for index, profession in ipairs(professionDefinitions) do
        local professionData = professionSnapshot[profession.name]
        if professionData then
            hasProfessionRows = true
            local treatiseComplete = professionData.treatise == true
            local weeklyComplete = professionData.weekly == true
            local treasuresRemaining = math.max(0, professionData.treasuresRemaining or 0)
            local treasureComplete = treasuresRemaining <= 0
            local professionComplete = treatiseComplete and weeklyComplete and treasureComplete
            local baseSortOrder = 100 + (index * 10)

            if profession.treatise then
                table.insert(rows, CreateRowData(
                    "profession-" .. profession.name .. "-treatise",
                    profession.name,
                    treatiseComplete,
                    "Treatise",
                    baseSortOrder,
                    { sortComplete = professionComplete, groupStart = true }
                ))
            end

            if profession.weekly then
                table.insert(rows, CreateRowData(
                    "profession-" .. profession.name .. "-weekly",
                    "",
                    weeklyComplete,
                    "Weekly",
                    baseSortOrder + 1,
                    { sortComplete = professionComplete, hideBullet = true }
                ))
            end

            table.insert(rows, CreateRowData(
                "profession-" .. profession.name .. "-treasures",
                "",
                treasureComplete,
                "Treasures Remaining: " .. treasuresRemaining,
                baseSortOrder + 2,
                { sortComplete = professionComplete, hideBullet = true }
            ))
        end
    end

    if not hasProfessionRows then
        table.insert(rows, CreateRowData("professions", "Professions", false, "Not Learned", 100, { groupStart = true }))
    end

    local delveData = characterData and characterData.delves or {}
    local gildedStashesLooted = math.max(0, math.min(delveData.gildedStashesLooted or 0, 4))
    local trovehuntersBounty = delveData.trovehuntersBounty == true
    local cofferKeyShardsRemaining = math.max(0, delveData.cofferKeyShardsRemaining or cofferKeyShardsWeeklyMaximum)
    local gildedComplete = gildedStashesLooted >= 4
    local cofferKeysComplete = cofferKeyShardsRemaining <= 0
    local delveComplete = gildedComplete and trovehuntersBounty and cofferKeysComplete
    local trovehuntersBountyStatus = "Trovehunter's Bounty: " .. tostring(trovehuntersBounty)
    if self.IsTrovehunterBountyStatusUnknown and self:IsTrovehunterBountyStatusUnknown(characterData) then
        trovehuntersBountyStatus = "Trovehunter's Bounty: Unknown"
    end

    table.insert(rows, CreateRowData("delve-gildedStashesLooted", "Delve", gildedComplete, "Gilded Stashes looted: " .. gildedStashesLooted, 300, { groupStart = true, sortComplete = delveComplete }))
    table.insert(rows, CreateRowData("delve-trovehuntersBounty", "", trovehuntersBounty, trovehuntersBountyStatus, 301, { hideBullet = true, sortComplete = delveComplete }))
    table.insert(rows, CreateRowData("delve-cofferKeyShardsRemaining", "", cofferKeysComplete, "Coffer Key Shards remaining until weekly limit: " .. cofferKeyShardsRemaining, 302, { hideBullet = true, sortComplete = delveComplete }))

    table.sort(rows, CompareRows)

    return rows
end

function AngusUI:RefreshChoresToast()
    if not self.choresToast then
        return
    end

    UpdateToastLayout(self.choresToast, self:BuildChoresRows())
end

function AngusUI:ShowChoresToast(force)
    if not force and self.choresToastShown then
        return
    end

    if self.SyncRefresh then
        self:SyncRefresh()
    end

    local toast = EnsureToast(self)
    self:RefreshChoresToast()
    toast:Show()
    StartToastHideCountdown(toast)

    if not force then
        self.choresToastShown = true
    end
end

function AngusUI:ChoresInit()
    if self.choresInitialized then
        return
    end

    self.choresInitialized = true
    self.choresToastShown = false
end
