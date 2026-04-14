local _, AngusUI = ...

local gildedStashWidgetID = 7591
local gildedStashCurrencyID = 3290
local cofferKeyShardsCurrencyID = 3310
local cofferKeyShardsWeeklyMaximum = 600
local restoredCofferKeyCurrencyID = 3028
local firstWorldBossQuestIDs = {
    92034, -- Thorm'belan
    92123, -- Cragpine
    92560, -- Lu'ashal
    92636, -- Predaxas
}
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
local trackedCurrencyIDSet = {}
local warbandBankTabSize = 98
local timewalkingRaidWeeklyQuestByLfgID = {
    [744] = 47523,
    [995] = 50316,
    [1146] = 57637,
}

for _, currencyID in ipairs(trackedCurrencyIDs) do
    trackedCurrencyIDSet[currencyID] = true
end

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
local hardPreyQuestIDs = {
    91210, 91212, 91214, 91216, 91218,
    91220, 91222, 91224, 91226, 91228,
    91230, 91232, 91234, 91236, 91238,
    91240, 91242, 91243, 91244, 91245,
    91246, 91247, 91248, 91249, 91250,
    91251, 91252, 91253, 91254, 91255,
}
local normalPreyQuestIDs = {
    91095, 91096, 91097, 91098, 91099,
    91100, 91101, 91102, 91103, 91104,
    91105, 91106, 91107, 91108, 91109,
    91110, 91111, 91112, 91113, 91114,
    91115, 91116, 91117, 91118, 91119,
    91120, 91121, 91122, 91123, 91124,
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

local function GetCharacterGold()
    if not GetMoney then
        return 0
    end

    return GetMoney() or 0
end

local function GetCurrencyInfoByID(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil
    end

    return C_CurrencyInfo.GetCurrencyInfo(currencyID)
end

local function IsAccountTransferableCurrency(currencyID)
    if not currencyID then
        return false
    end

    if C_CurrencyInfo and C_CurrencyInfo.IsAccountTransferableCurrency then
        return C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) == true
    end

    local currencyInfo = GetCurrencyInfoByID(currencyID)
    return currencyInfo and currencyInfo.isAccountTransferable == true
end

local function GetContainerItemIDAndCount(containerID, slotID)
    if not C_Container or not C_Container.GetContainerItemInfo then
        return nil, 0
    end

    local itemInfo = C_Container.GetContainerItemInfo(containerID, slotID)
    if not itemInfo then
        return nil, 0
    end

    local itemID = itemInfo.itemID
    if not itemID and C_Container.GetContainerItemID then
        itemID = C_Container.GetContainerItemID(containerID, slotID)
    end

    if not itemID then
        local itemLink = itemInfo.hyperlink
        if not itemLink and C_Container.GetContainerItemLink then
            itemLink = C_Container.GetContainerItemLink(containerID, slotID)
        end

        if type(itemLink) == "string" then
            itemID = tonumber(strmatch(itemLink, "item:(%d+)"))
        end
    end

    return itemID, itemInfo.stackCount or itemInfo.quantity or 0
end

local function CanScanWarbandBank()
    if not C_Bank or not Enum or not Enum.BankType or not Enum.BankType.Account then
        return false
    end

    if C_Bank.CanUseBank then
        return C_Bank.CanUseBank(Enum.BankType.Account) == true
    end

    return false
end

local function GetQuestName(questID)
    if not questID or not C_QuestLog or not C_QuestLog.GetTitleForQuestID then
        return nil
    end

    return C_QuestLog.GetTitleForQuestID(questID)
end

local function GetActiveWeeklyQuestMap()
    if not GetNumRandomDungeons or not GetLFGRandomDungeonInfo then
        return {}
    end

    local weeklyQuests = {}

    for index = 1, GetNumRandomDungeons() do
        local lfgID = GetLFGRandomDungeonInfo(index)
        local questID = timewalkingRaidWeeklyQuestByLfgID[lfgID]
        if questID then
            local questName = GetQuestName(questID)
            if questName and questName ~= "" then
                weeklyQuests[questID] = questName
            end
        end
    end

    return weeklyQuests
end

local function BuildCompletedWeeklyQuestList(activeWeeklyQuests)
    local completedWeeklyQuestIDs = {}

    for questID, _ in pairs(activeWeeklyQuests or {}) do
        if IsQuestComplete(questID) then
            table.insert(completedWeeklyQuestIDs, questID)
        end
    end

    table.sort(completedWeeklyQuestIDs)

    return completedWeeklyQuestIDs
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
        info.skillLineID,
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

local function GetCurrentProfessionConcentrationInfo()
    if not C_TradeSkillUI or not C_TradeSkillUI.GetProfessionChildSkillLineID or not C_TradeSkillUI.GetProfessionInfoBySkillLineID then
        return nil
    end

    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    if not skillLineID or skillLineID <= 0 then
        return nil
    end

    local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    if not professionInfo then
        return nil
    end

    professionInfo.skillLineID = skillLineID
    return professionInfo
end

local function GetCurrentProfessionConcentrationCurrencyID()
    local professionInfo = GetCurrentProfessionConcentrationInfo()
    if not professionInfo then
        return nil
    end

    return GetProfessionConcentrationCurrencyID(professionInfo)
end

local function NormalizeProfessionName(name)
    if type(name) ~= "string" then
        return nil
    end

    local normalizedName = strlower(strtrim(name))
    normalizedName = gsub(normalizedName, "[%s%p]", "")
    if normalizedName == "" then
        return nil
    end

    return normalizedName
end

local function ResolveProfessionSyncName(rawName, knownProfessions)
    if type(rawName) ~= "string" or type(knownProfessions) ~= "table" then
        return nil
    end

    if knownProfessions[rawName] then
        return rawName
    end

    local normalizedRawName = NormalizeProfessionName(rawName)
    if not normalizedRawName then
        return nil
    end

    local bestMatch = nil
    local bestMatchLength = 0

    for professionName, _ in pairs(knownProfessions) do
        local normalizedProfessionName = NormalizeProfessionName(professionName)
        if normalizedProfessionName then
            if normalizedProfessionName == normalizedRawName then
                return professionName
            end

            if
                strfind(normalizedRawName, normalizedProfessionName, 1, true) or
                strfind(normalizedProfessionName, normalizedRawName, 1, true)
            then
                if #normalizedProfessionName > bestMatchLength then
                    bestMatch = professionName
                    bestMatchLength = #normalizedProfessionName
                elseif #normalizedProfessionName == bestMatchLength and bestMatch ~= professionName then
                    bestMatch = nil
                end
            end
        end
    end

    return bestMatch
end

local function BuildProfessionNameLookup(professionDefinitions)
    local professionNames = {}

    for _, profession in ipairs(professionDefinitions or {}) do
        if profession.name then
            professionNames[profession.name] = true
        end
    end

    return professionNames
end

local function GetProfessionSkillSnapshot(knownProfessions)
    if not GetProfessions or not GetProfessionInfo then
        return {}
    end

    local professionSkillLevels = {}

    for _, professionIndex in pairs({ GetProfessions() }) do
        if professionIndex then
            local professionName, _, skillLevel, _, _, _, _, _, _, _, skillLineName = GetProfessionInfo(professionIndex)
            local resolvedProfessionName = ResolveProfessionSyncName(professionName, knownProfessions)
            if not resolvedProfessionName then
                resolvedProfessionName = ResolveProfessionSyncName(skillLineName, knownProfessions)
            end

            if resolvedProfessionName then
                professionSkillLevels[resolvedProfessionName] = skillLevel or 0
            end
        end
    end

    return professionSkillLevels
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
    AngusUIDB.sync.account = AngusUIDB.sync.account or {}

    return AngusUIDB.sync
end

function AngusUI:GetSyncCharacterData()
    AngusUICharacterSyncDB = AngusUICharacterSyncDB or {}

    local characterData = AngusUICharacterSyncDB

    characterData.delves = characterData.delves or {}
    characterData.prey = characterData.prey or {}
    characterData.professions = characterData.professions or {}
    characterData.greatVault = characterData.greatVault or {}
    characterData.currencies = characterData.currencies or {}
    characterData.gold = characterData.gold or 0
    characterData.weeklies = characterData.weeklies or {}

    return characterData
end

function AngusUI:GetSyncAccountData()
    local syncDB = self:GetSyncDB()
    syncDB.account.firstWorldBoss = syncDB.account.firstWorldBoss == true
    syncDB.account.currencies = syncDB.account.currencies or {}
    syncDB.account.weeklyQuests = syncDB.account.weeklyQuests or {}
    syncDB.account.warbandBank = syncDB.account.warbandBank or {}
    syncDB.account.warbandBank.gold = syncDB.account.warbandBank.gold or 0
    syncDB.account.warbandBank.slotCount = syncDB.account.warbandBank.slotCount or warbandBankTabSize
    syncDB.account.warbandBank.items = syncDB.account.warbandBank.items or {}
    syncDB.account.warbandBank.tabs = syncDB.account.warbandBank.tabs or {}

    return syncDB.account
end

function AngusUI:UpdateSyncCharacterWeekliesData(characterData, accountData)
    local completedWeeklies = BuildCompletedWeeklyQuestList(accountData and accountData.weeklyQuests or nil)
    if AreTablesEqual(characterData.weeklies, completedWeeklies) then
        return false
    end

    characterData.weeklies = completedWeeklies
    return true
end

function AngusUI:UpdateSyncAccountWeeklyQuestsData(accountData)
    local weeklyQuests = GetActiveWeeklyQuestMap()
    if AreTablesEqual(accountData.weeklyQuests, weeklyQuests) then
        return false
    end

    accountData.weeklyQuests = weeklyQuests
    return true
end

function AngusUI:BuildProfessionSyncSnapshot(existingProfessions)
    local professionDefinitions = self:GetCurrentProfessionSyncData()
    local professionSkillLevels = GetProfessionSkillSnapshot(BuildProfessionNameLookup(professionDefinitions))
    local professions = {}

    for _, profession in ipairs(professionDefinitions) do
        if IsProfessionLearned(profession.spellID) then
            local treatiseComplete = profession.treatise == nil or IsAnyQuestComplete(profession.treatise)
            local weeklyComplete = profession.weekly == nil or IsAnyQuestComplete(profession.weekly)
            local treasureCompleted, treasureTotal = CountCompletedSources(profession.treasures)
            local previousProfessionData = existingProfessions and existingProfessions[profession.name]
            local skillLevel = professionSkillLevels[profession.name]

            if skillLevel == nil and previousProfessionData then
                skillLevel = previousProfessionData.skillLevel
            end

            if skillLevel == nil then
                skillLevel = 0
            end

            professions[profession.name] = {
                skillLevel = skillLevel,
                treatise = treatiseComplete,
                weekly = weeklyComplete,
                treasuresRemaining = math.max(treasureTotal - treasureCompleted, 0),
                concentration = previousProfessionData and previousProfessionData.concentration or nil,
            }
        end
    end

    return professions
end

function AngusUI:GetProfessionConcentrationSnapshot(knownProfessions)
    if not C_TradeSkillUI then
        return nil
    end

    local professionInfo = GetCurrentProfessionConcentrationInfo()
    if not professionInfo then
        return nil
    end

    local resolvedProfessionName = ResolveProfessionSyncName(professionInfo.professionName, knownProfessions)
    local currencyID = GetProfessionConcentrationCurrencyID(professionInfo)
    local currencyInfo = currencyID and GetCurrencyInfoByID(currencyID)
    if not resolvedProfessionName or not currencyInfo then
        return nil
    end

    return {
        [resolvedProfessionName] = {
            current = currencyInfo.quantity or 0,
            timestamp = time(),
        },
    }
end

function AngusUI:UpdateSyncCharacterDelvesData(characterData)
    local existingDelvesData = characterData.delves or {}
    local gildedStashesLooted = GetGildedStashCountFromWidget()
    if gildedStashesLooted == nil then
        gildedStashesLooted = existingDelvesData.gildedStashesLooted or 0
    end

    local trovehuntersBounty = existingDelvesData.trovehuntersBounty == true or HasTrovehunterAura()

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
    local normal = CountCompletedQuests(normalPreyQuestIDs)
    local hard = CountCompletedQuests(hardPreyQuestIDs)
    local nightmare = CountCompletedQuests(nightmarePreyQuestIDs)
    local weekly = IsQuestComplete(nightmareTaskQuestID)
    local preyData = {
        normal = normal,
        hard = hard,
        nightmare = nightmare,
        weekly = weekly,
    }

    if AreTablesEqual(existingPreyData, preyData) then
        return false
    end

    characterData.prey = preyData
    return true
end

function AngusUI:UpdateSyncCharacterProfessionsData(characterData)
    local existingProfessions = characterData.professions or {}
    local professions = self:BuildProfessionSyncSnapshot(characterData.professions)

    for professionName, professionData in pairs(existingProfessions) do
        if professions[professionName] == nil then
            professions[professionName] = professionData
        end
    end

    if AreTablesEqual(existingProfessions, professions) then
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

function AngusUI:UpdateSyncCharacterGoldData(characterData)
    local gold = GetCharacterGold()
    if characterData.gold == gold then
        return false
    end

    characterData.gold = gold
    return true
end

function AngusUI:UpdateSyncCharacterProfessionConcentrationData(characterData)
    local concentrationSnapshot = self:GetProfessionConcentrationSnapshot(characterData.professions)
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

function AngusUI:RequestSyncAccountCurrencyData()
    if not C_CurrencyInfo or not C_CurrencyInfo.RequestCurrencyDataForAccountCharacters then
        return false
    end

    if C_CurrencyInfo.IsAccountCharacterCurrencyDataReady and C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
        self.syncAccountCurrencyRequestPending = false
        return true
    end

    if not self.syncAccountCurrencyRequestPending then
        self.syncAccountCurrencyRequestPending = true
        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
    end

    return false
end

function AngusUI:BuildSyncAccountCurrenciesSnapshot()
    if not C_CurrencyInfo or not C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters then
        return nil
    end

    if not self:RequestSyncAccountCurrencyData() then
        return nil
    end

    local currenciesData = {}
    local playerGUID = UnitGUID("player")

    for _, currencyID in ipairs(trackedCurrencyIDs) do
        if IsAccountTransferableCurrency(currencyID) then
            local totalQuantity = 0
            local currentCharacterSeen = false
            local characterDatas = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID) or {}

            for _, characterData in ipairs(characterDatas) do
                totalQuantity = totalQuantity + (characterData.quantity or 0)
                if playerGUID and characterData.characterGUID == playerGUID then
                    currentCharacterSeen = true
                end
            end

            if not currentCharacterSeen then
                local currencyInfo = GetCurrencyInfoByID(currencyID)
                totalQuantity = totalQuantity + ((currencyInfo and currencyInfo.quantity) or 0)
            end

            currenciesData[currencyID] = totalQuantity
        end
    end

    return currenciesData
end

function AngusUI:UpdateSyncAccountCurrenciesData(accountData)
    local currenciesData = self:BuildSyncAccountCurrenciesSnapshot()
    if not currenciesData or AreTablesEqual(accountData.currencies, currenciesData) then
        return false
    end

    accountData.currencies = currenciesData
    return true
end

function AngusUI:BuildWarbandBankSnapshot(existingWarbandBank)
    local warbandBankData = {
        gold = existingWarbandBank and existingWarbandBank.gold or 0,
        slotCount = warbandBankTabSize,
        items = existingWarbandBank and existingWarbandBank.items or {},
        tabs = existingWarbandBank and existingWarbandBank.tabs or {},
    }

    if C_Bank and C_Bank.FetchDepositedMoney and Enum and Enum.BankType and Enum.BankType.Account then
        local depositedMoney = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
        if depositedMoney ~= nil then
            warbandBankData.gold = depositedMoney
        end
    end

    if not CanScanWarbandBank() or not C_Bank or not C_Bank.FetchPurchasedBankTabIDs then
        return warbandBankData, false
    end

    local items = {}
    local tabs = {}
    local tabIDs = C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Account) or {}
    local tabSettings = C_Bank.FetchPurchasedBankTabData and C_Bank.FetchPurchasedBankTabData(Enum.BankType.Account) or {}

    for index, tabID in ipairs(tabIDs) do
        local slots = {}

        for slotID = 1, warbandBankTabSize do
            local itemID, itemCount = GetContainerItemIDAndCount(tabID, slotID)
            if itemID and itemCount and itemCount > 0 then
                slots[slotID] = {
                    itemID = itemID,
                    count = itemCount,
                }
                items[itemID] = (items[itemID] or 0) + itemCount
            end
        end

        tabs[index] = {
            id = tabID,
            name = tabSettings[index] and tabSettings[index].name or "",
            icon = tabSettings[index] and tabSettings[index].icon or nil,
            slots = slots,
        }
    end

    warbandBankData.items = items
    warbandBankData.tabs = tabs
    return warbandBankData, true
end

function AngusUI:UpdateSyncAccountWarbandBankData(accountData)
    local warbandBankData = self:BuildWarbandBankSnapshot(accountData.warbandBank)
    if AreTablesEqual(accountData.warbandBank, warbandBankData) then
        return false
    end

    accountData.warbandBank = warbandBankData
    return true
end

function AngusUI:UpdateSyncCharacterData(includeProfessionConcentration)
    local characterData = self:GetSyncCharacterData()
    local accountData = self:GetSyncAccountData()
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
    characterData.gold = characterData.gold or 0
    characterData.weeklies = characterData.weeklies or {}

    changed = self:UpdateSyncCharacterDelvesData(characterData) or changed
    changed = self:UpdateSyncCharacterPreyData(characterData) or changed
    changed = self:UpdateSyncCharacterProfessionsData(characterData) or changed
    changed = self:UpdateSyncCharacterGreatVaultData(characterData) or changed
    changed = self:UpdateSyncCharacterCurrenciesData(characterData) or changed
    changed = self:UpdateSyncCharacterGoldData(characterData) or changed
    changed = self:UpdateSyncCharacterWeekliesData(characterData, accountData) or changed

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
        accountData.weeklyQuests = {}
    end

    -- Recompute each refresh so stale values from older quest lists do not persist until reset.
    accountData.firstWorldBoss = IsAnyQuestComplete(firstWorldBossQuestIDs)

    self:UpdateSyncAccountCurrenciesData(accountData)
    self:UpdateSyncAccountWeeklyQuestsData(accountData)
    self:UpdateSyncAccountWarbandBankData(accountData)

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

function AngusUI:QueueProfessionConcentrationRefresh(delaySeconds)
    if not GetCurrentProfessionConcentrationCurrencyID() then
        return
    end

    if self.syncProfessionConcentrationRefreshQueued then
        return
    end

    self.syncProfessionConcentrationRefreshQueued = true
    C_Timer.After(delaySeconds or 2, function()
        self.syncProfessionConcentrationRefreshQueued = false
        if GetCurrentProfessionConcentrationCurrencyID() then
            self:SyncRefresh(true)
        end
    end)
end

function AngusUI:SyncHandleCurrencyUpdate(currencyID)
    if currencyID == gildedStashCurrencyID then
        self:QueueSyncGildedRefresh()
        return
    end

    if currencyID and currencyID == GetCurrentProfessionConcentrationCurrencyID() then
        self:QueueProfessionConcentrationRefresh(0.5)
        return
    end

    if currencyID == nil or currencyID == cofferKeyShardsCurrencyID or trackedCurrencyIDSet[currencyID] then
        self:SyncRefresh()
    end
end

function AngusUI:SyncHandleAccountCurrencyDataUpdate()
    self.syncAccountCurrencyRequestPending = false
    self:SyncRefresh()
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
    self.syncAccountCurrencyRequestPending = false
    self.syncGildedRefreshQueued = false
    self.syncProfessionConcentrationRefreshQueued = false
    self:GetSyncDB()
end
