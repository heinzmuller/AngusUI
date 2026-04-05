local _, AngusUI = ...

local gildedStashWidgetID = 7591
local gildedStashCurrencyID = 3290
local cofferKeyShardsCurrencyID = 3310
local cofferKeyShardsWeeklyMaximum = 600
local restoredCofferKeyCurrencyID = 3028
local firstWorldBossQuestIDs = { 92127, 92128, 92129, 92130 }
local nightmareTaskQuestID = 94446
local trovehunterBountyAuraSpellID = 1254631
local trackedCurrencyIDs = {
    3383,
    3341,
    3343,
    3345,
    3347,
    3378,
    3212,
    cofferKeyShardsCurrencyID,
    restoredCofferKeyCurrencyID,
}
local weeklyRewardTrackTypes = {
    raid = Enum.WeeklyRewardChestThresholdType and Enum.WeeklyRewardChestThresholdType.Raid,
    dungeons = Enum.WeeklyRewardChestThresholdType and Enum.WeeklyRewardChestThresholdType.Activities,
    delves = Enum.WeeklyRewardChestThresholdType and Enum.WeeklyRewardChestThresholdType.World,
}
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

local function GetCharacterStorageKey()
    local name, realm = UnitFullName("player")
    if not name then
        return UnitGUID("player") or UnitName("player")
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

local function GetGreatVaultItemLevel(activity)
    if not activity or not activity.id or not C_WeeklyRewards or not C_WeeklyRewards.GetExampleRewardItemHyperlinks then
        return nil
    end

    local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
    if not C_Item or not C_Item.GetDetailedItemLevelInfo then
        return nil
    end

    return (itemLink and C_Item.GetDetailedItemLevelInfo(itemLink)) or
        (upgradeItemLink and C_Item.GetDetailedItemLevelInfo(upgradeItemLink)) or
        nil
end

local function GetGreatVaultTrackData(trackType)
    if not trackType or not C_WeeklyRewards or not C_WeeklyRewards.GetActivities then
        return {}
    end

    local trackData = {}
    local activities = C_WeeklyRewards.GetActivities(trackType) or {}

    for _, activity in ipairs(activities) do
        local unlocked = activity.progress and activity.threshold and activity.progress >= activity.threshold
        if unlocked then
            local itemLevel = GetGreatVaultItemLevel(activity)
            if itemLevel then
                table.insert(trackData, itemLevel)
            end
        end
    end

    return trackData
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

function AngusUI:GetCurrentProfessionSyncData()
    local expansionLevel = GetExpansionLevel()
    if professionChoreData[expansionLevel] then
        return professionChoreData[expansionLevel]
    end

    if expansionLevel and expansionLevel > Enum.ExpansionLevel.Midnight then
        return professionChoreData[Enum.ExpansionLevel.Midnight]
    end

    return professionChoreData[Enum.ExpansionLevel.WarWithin]
end

function AngusUI:GetSyncDB()
    AngusUIDB = AngusUIDB or {}
    AngusUIDB.sync = AngusUIDB.sync or {}
    AngusUIDB.sync.characters = AngusUIDB.sync.characters or {}
    AngusUIDB.sync.account = AngusUIDB.sync.account or {}

    return AngusUIDB.sync
end

function AngusUI:GetSyncCharacterData()
    local syncDB = self:GetSyncDB()
    local characterKey = GetCharacterStorageKey()
    if not characterKey then
        return nil
    end

    local characterData = syncDB.characters[characterKey]
    if not characterData then
        characterData = {}
        syncDB.characters[characterKey] = characterData
    end

    characterData.delves = characterData.delves or {}
    characterData.prey = characterData.prey or {}
    characterData.professions = characterData.professions or {}
    characterData.greatVault = characterData.greatVault or {}
    characterData.currencies = characterData.currencies or {}

    return characterData
end

function AngusUI:GetSyncAccountData()
    local syncDB = self:GetSyncDB()
    syncDB.account.firstWorldBoss = syncDB.account.firstWorldBoss == true

    return syncDB.account
end

function AngusUI:BuildProfessionSyncSnapshot(existingProfessions)
    local professions = {}

    for _, profession in ipairs(self:GetCurrentProfessionSyncData()) do
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

function AngusUI:UpdateSyncCharacterDelvesData(characterData)
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

function AngusUI:UpdateSyncCharacterPreyData(characterData)
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

function AngusUI:UpdateSyncCharacterProfessionsData(characterData)
    local professions = self:BuildProfessionSyncSnapshot(characterData.professions)
    if AreTablesEqual(characterData.professions, professions) then
        return false
    end

    characterData.professions = professions
    return true
end

function AngusUI:UpdateSyncCharacterGreatVaultData(characterData)
    local greatVaultData = {
        raid = GetGreatVaultTrackData(weeklyRewardTrackTypes.raid),
        dungeons = GetGreatVaultTrackData(weeklyRewardTrackTypes.dungeons),
        delves = GetGreatVaultTrackData(weeklyRewardTrackTypes.delves),
    }

    if AreTablesEqual(characterData.greatVault, greatVaultData) then
        return false
    end

    characterData.greatVault = greatVaultData
    return true
end

function AngusUI:UpdateSyncCharacterCurrenciesData(characterData)
    local currenciesData = {}

    for _, currencyID in ipairs(trackedCurrencyIDs) do
        local currencyInfo = GetCurrencyInfoByID(currencyID)
        currenciesData[currencyID] = currencyInfo and currencyInfo.quantity or 0
    end

    if AreTablesEqual(characterData.currencies, currenciesData) then
        return false
    end

    characterData.currencies = currenciesData
    return true
end

function AngusUI:UpdateSyncCharacterProfessionConcentrationData(characterData)
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

function AngusUI:UpdateSyncCharacterData(includeProfessionConcentration)
    local characterData = self:GetSyncCharacterData()
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
    characterData.greatVault = characterData.greatVault or {}
    characterData.currencies = characterData.currencies or {}

    changed = self:UpdateSyncCharacterDelvesData(characterData) or changed
    changed = self:UpdateSyncCharacterPreyData(characterData) or changed
    changed = self:UpdateSyncCharacterProfessionsData(characterData) or changed
    changed = self:UpdateSyncCharacterGreatVaultData(characterData) or changed
    changed = self:UpdateSyncCharacterCurrenciesData(characterData) or changed

    if includeProfessionConcentration then
        changed = self:UpdateSyncCharacterProfessionConcentrationData(characterData) or changed
    end

    if changed or not characterData.lastChanged then
        characterData.lastChanged = GetCurrentDateTag()
        characterData.lastChangedResetKey = weeklyResetKey
    end

    return characterData
end

function AngusUI:UpdateSyncAccountData()
    local accountData = self:GetSyncAccountData()
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

function AngusUI:QueueSyncGildedRefresh()
    if self.syncGildedRefreshQueued then
        return
    end

    self.syncGildedRefreshQueued = true
    C_Timer.After(2, function()
        self.syncGildedRefreshQueued = false
        self:SyncRefresh()
    end)
end

function AngusUI:SyncHandleCurrencyUpdate(currencyID)
    if currencyID == gildedStashCurrencyID then
        self:QueueSyncGildedRefresh()
        return
    end

    if currencyID == nil or currencyID == cofferKeyShardsCurrencyID then
        self:SyncRefresh()
    end
end

function AngusUI:SyncRefresh(includeProfessionConcentration)
    self:UpdateSyncAccountData()
    self:UpdateSyncCharacterData(includeProfessionConcentration == true)

    if self.RefreshChoresToast then
        self:RefreshChoresToast()
    end
end

function AngusUI:SyncInit()
    if self.syncInitialized then
        return
    end

    self.syncInitialized = true
    self.syncGildedRefreshQueued = false
    self:GetSyncDB()
end
