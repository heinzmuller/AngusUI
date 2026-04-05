local _, AngusUI = ...

local toastWidth = 420
local toastMinHeight = 120
local toastRowHeight = 18
local toastRowSpacing = 0
local toastGroupSpacing = 2
local toastPadding = 16
local toastDurationSeconds = 5
local gildedStashWidgetID = 7591
local gildedStashCurrencyID = 3290
local cofferKeyShardsCurrencyID = 3310
local cofferKeyShardsWeeklyMaximum = 600
local firstWorldBossQuestIDs = { 92127, 92128, 92129, 92130 }
local nightmareTaskQuestID = 94446
local trovehunterBountyAuraSpellID = 1254631
local professionChoreData = {
    [Enum.ExpansionLevel.WarWithin] = {
        { name = "Alchemy", spellID = 423321, treatise = { 83725 }, weekly = { 84133 }, treasures = { { 83253 }, { 83255 } } },
        { name = "Blacksmithing", spellID = 423332, treatise = { 83726 }, weekly = { 84127 }, treasures = { { 83256 }, { 83257 } } },
        { name = "Enchanting", spellID = 423334, treatise = { 83727 }, weekly = { 84084, 84085, 84086 }, treasures = { { 84290, 84291, 84292, 84293, 84294 }, { 84295 }, { 83258 }, { 83259 } } },
        { name = "Engineering", spellID = 423335, treatise = { 83728 }, weekly = { 84128 }, treasures = { { 83260 }, { 83261 } } },
        { name = "Herbalism", spellID = 441327, treatise = { 83729 }, weekly = { 82970, 82958, 82965, 82916, 82962 }, treasures = { { 81416, 81417, 81418, 81419, 81420 }, { 81421 } } },
        { name = "Inscription", spellID = 423338, treatise = { 83730 }, weekly = { 84129 }, treasures = { { 83262 }, { 83264 } } },
        { name = "Jewelcrafting", spellID = 423339, treatise = { 83731 }, weekly = { 84130 }, treasures = { { 83265 }, { 83266 } } },
        { name = "Leatherworking", spellID = 423340, treatise = { 83732 }, weekly = { 84131 }, treasures = { { 83267 }, { 83268 } } },
        { name = "Mining", spellID = 423341, treatise = { 83733 }, weekly = { 83104, 83105, 83103, 83106, 83102 }, treasures = { { 83050, 83051, 83052, 83053, 83054 }, { 83049 } } },
        { name = "Skinning", spellID = 423342, treatise = { 83735 }, weekly = { 83097, 83098, 83100, 82992, 82993 }, treasures = { { 81459, 81460, 81461, 81462, 81463 }, { 81464 } } },
        { name = "Tailoring", spellID = 423343, treatise = { 83734 }, weekly = { 84132 }, treasures = { { 83269 }, { 83270 } } },
    },
    [Enum.ExpansionLevel.Midnight] = {
        { name = "Alchemy", spellID = 471003, treatise = { 95127 }, weekly = { 93690 }, treasures = { { 93528 }, { 93529 } } },
        { name = "Blacksmithing", spellID = 471004, treatise = { 95128 }, weekly = { 93691 }, treasures = { { 93530 }, { 93531 } } },
        { name = "Enchanting", spellID = 471006, treatise = { 95129 }, weekly = { 93699, 93698, 93697 }, treasures = { { 95048, 95049, 95050, 95051, 95052 }, { 95053 }, { 93532 }, { 93533 } } },
        { name = "Engineering", spellID = 471007, treatise = { 95138 }, weekly = { 93692 }, treasures = { { 93534 }, { 93535 } } },
        { name = "Herbalism", spellID = 471009, treatise = { 95130 }, weekly = { 93700, 93701, 93702, 93703, 93704 }, treasures = { { 81425, 81426, 81427, 81428, 81429 }, { 81430 } } },
        { name = "Inscription", spellID = 471010, treatise = { 95131 }, weekly = { 93693 }, treasures = { { 93536 }, { 93537 } } },
        { name = "Jewelcrafting", spellID = 471011, treatise = { 95133 }, weekly = { 93694 }, treasures = { { 93539 }, { 93538 } } },
        { name = "Leatherworking", spellID = 471012, treatise = { 95134 }, weekly = { 93695 }, treasures = { { 93540 }, { 93541 } } },
        { name = "Mining", spellID = 471013, treatise = { 95135 }, weekly = { 93705, 93706, 93707, 93708, 93709 }, treasures = { { 88673, 88674, 88675, 88676, 88677 }, { 88678 } } },
        { name = "Skinning", spellID = 471014, treatise = { 95136 }, weekly = { 93710, 93711, 93712, 93713, 93714 }, treasures = { { 88534, 88549, 88536, 88537, 88530 }, { 88529 } } },
        { name = "Tailoring", spellID = 471015, treatise = { 95137 }, weekly = { 93696 }, treasures = { { 93542 }, { 93543 } } },
    },
}
local nightmarePreyQuestIDs = {
    91211, 91213, 91215, 91217, 91219,
    91221, 91223, 91225, 91227, 91229,
    91231, 91233, 91235, 91237, 91239,
    91241, 91256, 91257, 91258, 91259,
    91260, 91261, 91262, 91263, 91264,
    91265, 91266, 91267, 91268, 91269,
}

local function IsQuestComplete(questID)
    if not questID or questID <= 0 then
        return false
    end

    return C_QuestLog.IsQuestFlaggedCompleted(questID) == true
end

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

local function IsAnyQuestComplete(questIDs)
    if not questIDs then
        return false
    end

    for _, questID in ipairs(questIDs) do
        if IsQuestComplete(questID) then
            return true
        end
    end

    return false
end

local function CountCompletedQuests(questIDs)
    local count = 0

    for _, questID in ipairs(questIDs or {}) do
        if IsQuestComplete(questID) then
            count = count + 1
        end
    end

    return count
end

local function IsProfessionLearned(spellID)
    return C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID) == true
end

local function CountCompletedSources(sourceList)
    local completed = 0
    local total = 0

    for _, questIDs in ipairs(sourceList or {}) do
        total = total + 1
        if IsAnyQuestComplete(questIDs) then
            completed = completed + 1
        end
    end

    return completed, total
end

local function GetCurrentProfessionChoreData()
    local expansionLevel = GetExpansionLevel()
    if professionChoreData[expansionLevel] then
        return professionChoreData[expansionLevel]
    end

    if expansionLevel and expansionLevel > Enum.ExpansionLevel.Midnight then
        return professionChoreData[Enum.ExpansionLevel.Midnight]
    end

    return professionChoreData[Enum.ExpansionLevel.WarWithin]
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

local function GetGildedStashCountFromWidget()
    if not C_UIWidgetManager or not C_UIWidgetManager.GetSpellDisplayVisualizationInfo then
        return nil
    end

    local visInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(gildedStashWidgetID)
    local tooltip = visInfo and visInfo.spellInfo and visInfo.spellInfo.tooltip
    if not tooltip then
        return nil
    end

    local count = string.match(tooltip, "(%d)/4")
    if not count then
        return nil
    end

    return tonumber(count)
end

local function GetCharacterKey()
    return UnitGUID("player") or UnitName("player")
end

local function GetCharacterStorageKey()
    local name, realm = UnitFullName("player")
    if not name then
        return GetCharacterKey()
    end

    realm = realm or GetRealmName()
    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

local function GetCurrentDateTag()
    return date("%Y-%m-%d")
end

local function GetCurrencyInfoByID(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil
    end

    return C_CurrencyInfo.GetCurrencyInfo(currencyID)
end

local function GetProfessionConcentrationCurrencyID(info)
    if not C_TradeSkillUI or not C_TradeSkillUI.GetConcentrationCurrencyID or not info then
        return nil
    end

    local candidateIDs = {
        info.professionID,
        info.parentProfessionID,
    }

    for _, candidateID in ipairs(candidateIDs) do
        if candidateID then
            local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(candidateID)
            if currencyID then
                return currencyID
            end
        end
    end

    return nil
end

local function SetValue(target, key, value)
    if target[key] ~= value then
        target[key] = value
        return true
    end

    return false
end

local function AreTablesEqual(left, right)
    if left == right then
        return true
    end

    if type(left) ~= type(right) then
        return false
    end

    if type(left) ~= "table" then
        return false
    end

    for key, value in pairs(left) do
        if not AreTablesEqual(value, right[key]) then
            return false
        end
    end

    for key, value in pairs(right) do
        if left[key] == nil and value ~= nil then
            return false
        end
    end

    return true
end

local function GetWeeklyResetKey()
    if not C_DateAndTime or not C_DateAndTime.GetSecondsUntilWeeklyReset then
        return nil
    end

    local secondsUntilReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
    if not secondsUntilReset then
        return nil
    end

    return floor((time() + secondsUntilReset) / 3600)
end

local function HasTrovehunterAura()
    return C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and C_UnitAuras.GetPlayerAuraBySpellID(trovehunterBountyAuraSpellID) ~= nil
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

    local accountData = self:GetChoresAccountData()
    local characterData = self:GetChoresCharacterData()
    local worldBossComplete = accountData and accountData.firstWorldBoss == true
    table.insert(rows, CreateRowData("worldBoss", "World Boss", worldBossComplete, worldBossComplete and "Done" or "Pending", 10, { groupStart = true }))

    local preyData = characterData and characterData.prey or {}
    local nightmareHuntsCompleted = math.max(0, math.min(preyData.nightmare or 0, 4))
    local preyWeeklyComplete = preyData.weekly == true
    local preyComplete = nightmareHuntsCompleted >= 4 and preyWeeklyComplete
    table.insert(rows, CreateRowData("prey-nightmare", "Prey", nightmareHuntsCompleted >= 4, nightmareHuntsCompleted .. "/4 Nightmare Hunts", 20, { groupStart = true, sortComplete = preyComplete }))
    table.insert(rows, CreateRowData("prey-weekly", "", preyWeeklyComplete, "Weekly", 21, { hideBullet = true, sortComplete = preyComplete }))

    local hasProfessionRows = false
    local professionSnapshot = characterData and characterData.professions or {}
    for index, profession in ipairs(GetCurrentProfessionChoreData()) do
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

    table.insert(rows, CreateRowData("delve-gildedStashesLooted", "Delve", gildedComplete, "Gilded Stashes looted: " .. gildedStashesLooted, 300, { groupStart = true, sortComplete = delveComplete }))
    table.insert(rows, CreateRowData("delve-trovehuntersBounty", "", trovehuntersBounty, "Trovehunter's Bounty: " .. tostring(trovehuntersBounty), 301, { hideBullet = true, sortComplete = delveComplete }))
    table.insert(rows, CreateRowData("delve-cofferKeyShardsRemaining", "", cofferKeysComplete, "Coffer Key Shards remaining until weekly limit: " .. cofferKeyShardsRemaining, 302, { hideBullet = true, sortComplete = delveComplete }))

    table.sort(rows, CompareRows)

    return rows
end

function AngusUI:ShowChoresToast(force)
    if not force and self.choresToastShown then
        return
    end

    self:ChoresRefresh()

    local toast = EnsureToast(self)
    local rows = self:BuildChoresRows()
    UpdateToastLayout(toast, rows)
    toast:Show()
    StartToastHideCountdown(toast)

    if not force then
        self.choresToastShown = true
    end
end

function AngusUI:GetChoresDB()
    AngusUIDB = AngusUIDB or {}
    AngusUIDB.chores = AngusUIDB.chores or {}
    AngusUIDB.chores.characters = AngusUIDB.chores.characters or {}
    AngusUIDB.chores.account = AngusUIDB.chores.account or {}

    return AngusUIDB.chores
end

function AngusUI:GetChoresCharacterData()
    local choresDB = self:GetChoresDB()
    local characterKey = GetCharacterStorageKey()
    if not characterKey then
        return nil
    end

    local characterData = choresDB.characters[characterKey]
    if not characterData then
        characterData = {}
        choresDB.characters[characterKey] = characterData
    end

    characterData.delves = characterData.delves or {}
    characterData.prey = characterData.prey or {}
    characterData.professions = characterData.professions or {}

    return characterData
end

function AngusUI:GetChoresAccountData()
    local choresDB = self:GetChoresDB()
    choresDB.account.firstWorldBoss = choresDB.account.firstWorldBoss == true

    return choresDB.account
end

function AngusUI:BuildProfessionSnapshot(existingProfessions)
    local professions = {}

    for _, profession in ipairs(GetCurrentProfessionChoreData()) do
        if IsProfessionLearned(profession.spellID) then
            local treatiseComplete = profession.treatise and IsAnyQuestComplete(profession.treatise) or true
            local weeklyComplete = profession.weekly and IsAnyQuestComplete(profession.weekly) or true
            local treasureCompleted, treasureTotal = CountCompletedSources(profession.treasures)
            local previousProfessionData = existingProfessions and existingProfessions[profession.name]

            professions[profession.name] = {
                treatise = treatiseComplete,
                weekly = weeklyComplete,
                treasuresRemaining = math.max(treasureTotal - treasureCompleted, 0),
                concentration = previousProfessionData and previousProfessionData.concentration or nil,
            }
        end
    end

    return professions
end

function AngusUI:GetProfessionConcentrationSnapshot()
    if not C_TradeSkillUI or not C_TradeSkillUI.GetChildProfessionInfos then
        return nil
    end

    local professionInfos = C_TradeSkillUI.GetChildProfessionInfos()
    if not professionInfos then
        return nil
    end

    local concentrationSnapshot = {}
    local timestamp = time()

    for _, professionInfo in ipairs(professionInfos) do
        local professionName = professionInfo and professionInfo.professionName
        local currencyID = GetProfessionConcentrationCurrencyID(professionInfo)
        local currencyInfo = currencyID and GetCurrencyInfoByID(currencyID)
        if professionName and currencyInfo then
            concentrationSnapshot[professionName] = {
                current = currencyInfo.quantity or 0,
                timestamp = timestamp,
            }
        end
    end

    local skillLineID, skillLineDisplayName, _, _, _, parentSkillLineID, parentSkillLineDisplayName = C_TradeSkillUI.GetTradeSkillLine and C_TradeSkillUI.GetTradeSkillLine() or nil
    local currentProfessionName = parentSkillLineDisplayName or skillLineDisplayName
    if currentProfessionName then
        local fallbackCurrencyID = nil
        if C_TradeSkillUI.GetConcentrationCurrencyID then
            fallbackCurrencyID = skillLineID and C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID) or nil
            if not fallbackCurrencyID and parentSkillLineID then
                fallbackCurrencyID = C_TradeSkillUI.GetConcentrationCurrencyID(parentSkillLineID)
            end
        end

        local fallbackCurrencyInfo = fallbackCurrencyID and GetCurrencyInfoByID(fallbackCurrencyID)
        if fallbackCurrencyInfo then
            concentrationSnapshot[currentProfessionName] = {
                current = fallbackCurrencyInfo.quantity or 0,
                timestamp = timestamp,
            }
        end
    end

    return next(concentrationSnapshot) and concentrationSnapshot or nil
end

function AngusUI:UpdateCharacterDelvesData(characterData)
    local existingDelvesData = characterData.delves or {}
    local gildedStashesLooted = GetGildedStashCountFromWidget()
    if gildedStashesLooted == nil then
        gildedStashesLooted = existingDelvesData.gildedStashesLooted or 0
    end

    local trovehuntersBounty = HasTrovehunterAura() or existingDelvesData.trovehuntersBounty == true
    local cofferKeyShardsRemaining = existingDelvesData.cofferKeyShardsRemaining
    if cofferKeyShardsRemaining == nil then
        cofferKeyShardsRemaining = cofferKeyShardsWeeklyMaximum
    end

    local shardInfo = GetCurrencyInfoByID(cofferKeyShardsCurrencyID)
    if shardInfo then
        local weeklyMaximum = shardInfo.maxWeeklyQuantity or 0
        if weeklyMaximum <= 0 then
            weeklyMaximum = cofferKeyShardsWeeklyMaximum
        end

        cofferKeyShardsRemaining = math.max(weeklyMaximum - (shardInfo.quantityEarnedThisWeek or 0), 0)
    end

    local delvesData = {
        gildedStashesLooted = math.max(0, math.min(gildedStashesLooted, 4)),
        trovehuntersBounty = trovehuntersBounty,
        cofferKeyShardsRemaining = cofferKeyShardsRemaining,
    }

    if AreTablesEqual(existingDelvesData, delvesData) then
        return false
    end

    characterData.delves = delvesData
    return true
end

function AngusUI:UpdateCharacterPreyData(characterData)
    local existingPreyData = characterData.prey or {}
    local nightmare = math.min(CountCompletedQuests(nightmarePreyQuestIDs), 4)
    local weekly = IsQuestComplete(nightmareTaskQuestID) or nightmare >= 3
    local preyData = {
        nightmare = nightmare,
        weekly = weekly,
        hard = existingPreyData.hard or 0,
        normal = existingPreyData.normal or 0,
    }

    if AreTablesEqual(existingPreyData, preyData) then
        return false
    end

    characterData.prey = preyData
    return true
end

function AngusUI:UpdateCharacterProfessionsData(characterData)
    local professions = self:BuildProfessionSnapshot(characterData.professions)
    if AreTablesEqual(characterData.professions, professions) then
        return false
    end

    characterData.professions = professions
    return true
end

function AngusUI:UpdateCharacterProfessionConcentrationData(characterData)
    local concentrationSnapshot = self:GetProfessionConcentrationSnapshot()
    if not concentrationSnapshot then
        return false
    end

    local updated = false

    for professionName, concentrationData in pairs(concentrationSnapshot) do
        local professionData = characterData.professions[professionName]
        if professionData then
            local existingConcentration = professionData.concentration
            if
                type(existingConcentration) ~= "table" or
                existingConcentration.current ~= concentrationData.current or
                existingConcentration.timestamp ~= concentrationData.timestamp
            then
                professionData.concentration = {
                    current = concentrationData.current,
                    timestamp = concentrationData.timestamp,
                }
                updated = true
            end
        end
    end

    return updated
end

function AngusUI:UpdateChoresCharacterData(includeProfessionConcentration)
    local characterData = self:GetChoresCharacterData()
    local weeklyResetKey = GetWeeklyResetKey()
    local changed = false
    if not characterData then
        return nil
    end

    if weeklyResetKey and characterData.weeklyResetKey ~= weeklyResetKey then
        characterData.weeklyResetKey = weeklyResetKey
        characterData.delves = {}
        changed = true
    end

    characterData.delves = characterData.delves or {}
    characterData.prey = characterData.prey or {}
    characterData.professions = characterData.professions or {}

    changed = self:UpdateCharacterDelvesData(characterData) or changed
    changed = self:UpdateCharacterPreyData(characterData) or changed
    changed = self:UpdateCharacterProfessionsData(characterData) or changed

    if includeProfessionConcentration then
        changed = self:UpdateCharacterProfessionConcentrationData(characterData) or changed
    end

    if changed or not characterData.lastChanged then
        characterData.lastChanged = GetCurrentDateTag()
        characterData.lastChangedResetKey = weeklyResetKey
    end

    return characterData
end

function AngusUI:UpdateChoresAccountData()
    local accountData = self:GetChoresAccountData()
    local weeklyResetKey = GetWeeklyResetKey()
    if not accountData then
        return nil
    end

    if weeklyResetKey and accountData.weeklyResetKey ~= weeklyResetKey then
        accountData.weeklyResetKey = weeklyResetKey
        accountData.firstWorldBoss = false
    end

    if IsAnyQuestComplete(firstWorldBossQuestIDs) then
        accountData.firstWorldBoss = true
    elseif accountData.firstWorldBoss == nil then
        accountData.firstWorldBoss = false
    end

    return accountData
end

function AngusUI:QueueChoresGildedRefresh()
    if self.choresGildedRefreshQueued then
        return
    end

    self.choresGildedRefreshQueued = true
    C_Timer.After(2, function()
        self.choresGildedRefreshQueued = false
        self:ChoresRefresh()
    end)
end

function AngusUI:ChoresHandleCurrencyUpdate(currencyID)
    if currencyID == gildedStashCurrencyID then
        self:QueueChoresGildedRefresh()
        return
    end

    if currencyID == nil or currencyID == cofferKeyShardsCurrencyID then
        self:ChoresRefresh()
    end
end

function AngusUI:ChoresRefresh(includeProfessionConcentration)
    self:UpdateChoresAccountData()
    self:UpdateChoresCharacterData(includeProfessionConcentration == true)

    if self.choresToast and self.choresToast:IsShown() then
        UpdateToastLayout(self.choresToast, self:BuildChoresRows())
    end
end

function AngusUI:ChoresInit()
    if self.choresInitialized then
        return
    end

    self.choresInitialized = true
    self.choresToastShown = false
    self.choresGildedRefreshQueued = false
    self:GetChoresDB()
end
