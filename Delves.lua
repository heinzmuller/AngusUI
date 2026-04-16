local _, AngusUI = ...

local cofferKeyShardsCurrencyID = 3310
local restoredCofferKeyCurrencyID = 3028
local requiredCofferKeyShards = 100
local bountifulAtlasToken = "bountiful"
local continentMapType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
local toastWidth = 280
local toastHeight = 80
local toastPadding = 16
local entryRefreshWindowSeconds = 5

local function EnsureBackdrop(frame)
    if frame.backdrop then
        return
    end

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:SetAllPoints()
    backdrop:SetFrameLevel(math.max(frame:GetFrameLevel() - 1, 0))
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

local function GetCurrencyInfoByID(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil
    end

    return C_CurrencyInfo.GetCurrencyInfo(currencyID)
end

local function GetCurrencyQuantity(currencyID)
    local currencyInfo = GetCurrencyInfoByID(currencyID)
    return currencyInfo and currencyInfo.quantity or 0
end

local function HasBountifulDelveKeyRequirement()
    return GetCurrencyQuantity(cofferKeyShardsCurrencyID) >= requiredCofferKeyShards or GetCurrencyQuantity(restoredCofferKeyCurrencyID) >= 1
end

local function IsDelveInProgress()
    if C_PartyInfo and C_PartyInfo.IsDelveInProgress then
        return C_PartyInfo.IsDelveInProgress() == true
    end

    if C_Scenario and C_Scenario.IsInScenario then
        return C_Scenario.IsInScenario() == true
    end

    return false
end

local function GetCurrentDelveEntryKey()
    local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()
    if instanceID and instanceID > 0 then
        if instanceName and instanceName ~= "" then
            return instanceID .. ":" .. instanceName
        end

        return tostring(instanceID)
    end

    local zoneName = GetRealZoneText and GetRealZoneText() or nil
    if zoneName and zoneName ~= "" then
        return zoneName
    end

    return nil
end

local function AddCandidateName(candidates, name)
    if type(name) ~= "string" or name == "" then
        return
    end

    candidates[name] = true
end

local function GetCurrentDelveNameCandidates()
    local candidates = {}
    AddCandidateName(candidates, GetRealZoneText and GetRealZoneText() or nil)
    AddCandidateName(candidates, select(1, GetInstanceInfo()))
    return candidates
end

local function GetPlayerContinentMapID()
    if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetMapInfo then
        return nil
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    while mapID do
        local mapInfo = C_Map.GetMapInfo(mapID)
        if not mapInfo then
            return nil
        end

        if mapInfo.mapType == continentMapType then
            return mapID
        end

        mapID = mapInfo.parentMapID
    end

    return nil
end

local function CollectMapIDsRecursive(mapID, mapIDs, visited)
    if not mapID or visited[mapID] then
        return
    end

    visited[mapID] = true
    table.insert(mapIDs, mapID)

    if C_Map and C_Map.GetMapGroupID and C_Map.GetMapGroupMembersInfo then
        local groupID = C_Map.GetMapGroupID(mapID)
        if groupID then
            local groupMembers = C_Map.GetMapGroupMembersInfo(groupID)
            if groupMembers then
                for _, memberInfo in ipairs(groupMembers) do
                    CollectMapIDsRecursive(memberInfo.mapID, mapIDs, visited)
                end
            end
        end
    end

    if C_Map and C_Map.GetMapChildrenInfo then
        local children = C_Map.GetMapChildrenInfo(mapID)
        if children then
            for _, childInfo in ipairs(children) do
                CollectMapIDsRecursive(childInfo.mapID, mapIDs, visited)
            end
        end
    end
end

local function GetActiveBountifulDelveNames(self)
    if not C_AreaPoiInfo or not C_AreaPoiInfo.GetDelvesForMap or not C_AreaPoiInfo.GetAreaPOIInfo then
        return nil
    end

    local continentMapID = GetPlayerContinentMapID()
    if continentMapID then
        self.delvesLastKnownContinentMapID = continentMapID
    else
        continentMapID = self.delvesLastKnownContinentMapID
    end

    if not continentMapID then
        return nil
    end

    -- Active bountiful delves are exposed as delve POIs on the parent continent's map tree.
    local mapIDs = {}
    CollectMapIDsRecursive(continentMapID, mapIDs, {})

    local activeBountifulDelves = {}
    local foundAnyDelvePOIs = false

    for _, mapID in ipairs(mapIDs) do
        local poiIDs = C_AreaPoiInfo.GetDelvesForMap(mapID)
        if poiIDs then
            for _, poiID in ipairs(poiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
                if poiInfo then
                    foundAnyDelvePOIs = true

                    local atlasName = poiInfo.atlasName
                    local delveName = poiInfo.name
                    if
                        type(atlasName) == "string" and
                        type(delveName) == "string" and
                        delveName ~= "" and
                        strfind(strlower(atlasName), bountifulAtlasToken, 1, true)
                    then
                        activeBountifulDelves[delveName] = true
                    end
                end
            end
        end
    end

    if not foundAnyDelvePOIs then
        return nil
    end

    return activeBountifulDelves
end

local function GetCurrentDelveBountifulState(self)
    local activeBountifulDelves = GetActiveBountifulDelveNames(self)
    if not activeBountifulDelves then
        return nil
    end

    local candidates = GetCurrentDelveNameCandidates()
    if next(candidates) == nil then
        return nil
    end

    for delveName in pairs(candidates) do
        if activeBountifulDelves[delveName] then
            return true
        end
    end

    return false
end

local function EnsureMissingKeyToast(self)
    if self.delvesMissingKeyToast then
        return self.delvesMissingKeyToast
    end

    local toast = CreateFrame("Frame", "AngusUIDelvesMissingKeyToast", UIParent, "BackdropTemplate")
    toast:SetSize(toastWidth, toastHeight)
    toast:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    toast:SetFrameStrata("DIALOG")
    toast:SetClampedToScreen(true)
    toast:EnableMouse(true)
    toast:Hide()
    EnsureBackdrop(toast)

    toast.closeButton = CreateFrame("Button", nil, toast, "UIPanelCloseButton")
    toast.closeButton:SetPoint("TOPRIGHT", toast, "TOPRIGHT", -4, -4)
    toast.closeButton:SetScript("OnClick", function()
        toast:Hide()
    end)

    toast.message = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    toast.message:SetPoint("TOPLEFT", toast, "TOPLEFT", toastPadding, -toastPadding)
    toast.message:SetPoint("BOTTOMRIGHT", toast, "BOTTOMRIGHT", -toastPadding, toastPadding)
    toast.message:SetJustifyH("CENTER")
    toast.message:SetJustifyV("MIDDLE")
    toast.message:SetText("Missing Restored Key")

    self.delvesMissingKeyToast = toast

    return toast
end

function AngusUI:ShowDelvesMissingKeyToast()
    local toast = EnsureMissingKeyToast(self)
    toast:Show()
end

function AngusUI:HideDelvesMissingKeyToast()
    if self.delvesMissingKeyToast then
        self.delvesMissingKeyToast:Hide()
    end
end

function AngusUI:EvaluateDelveEntry()
    if not IsDelveInProgress() then
        self.delvesCurrentEntryKey = nil
        self.delvesEvaluatedEntryKey = nil
        self.delvesEvaluatedEntryHasRequirement = nil
        self.delvesEntryDetectedAt = nil
        self.delvesRetryCount = 0
        self:HideDelvesMissingKeyToast()
        return
    end

    local currentEntryKey = GetCurrentDelveEntryKey()
    if not currentEntryKey then
        local retryCount = self.delvesRetryCount or 0
        if retryCount < 3 then
            self.delvesRetryCount = retryCount + 1
            self:QueueDelveEntryCheck(1)
        end

        return
    end

    if currentEntryKey ~= self.delvesCurrentEntryKey then
        self.delvesCurrentEntryKey = currentEntryKey
        self.delvesEvaluatedEntryKey = nil
        self.delvesEvaluatedEntryHasRequirement = nil
        self.delvesEntryDetectedAt = GetTime()
        self.delvesRetryCount = 0
        self:HideDelvesMissingKeyToast()
    end

    if self.delvesEvaluatedEntryKey == currentEntryKey and HasBountifulDelveKeyRequirement() == self.delvesEvaluatedEntryHasRequirement then
        return
    end

    local isBountiful = GetCurrentDelveBountifulState(self)
    if isBountiful == nil then
        local retryCount = self.delvesRetryCount or 0
        if retryCount < 3 then
            self.delvesRetryCount = retryCount + 1
            self:QueueDelveEntryCheck(1)
        end

        return
    end

    self.delvesEvaluatedEntryKey = currentEntryKey
    self.delvesEvaluatedEntryHasRequirement = HasBountifulDelveKeyRequirement()
    self.delvesRetryCount = 0

    if not isBountiful then
        self:HideDelvesMissingKeyToast()
        return
    end

    if self.delvesEvaluatedEntryHasRequirement then
        self:HideDelvesMissingKeyToast()
        if self.Print then
            self:Print("Delve is good")
        end
        return
    end

    self:ShowDelvesMissingKeyToast()
end

function AngusUI:QueueDelveEntryCheck(delaySeconds)
    self.delvesCheckRevision = (self.delvesCheckRevision or 0) + 1
    local revision = self.delvesCheckRevision

    C_Timer.After(delaySeconds or 1, function()
        if self.delvesCheckRevision ~= revision then
            return
        end

        self:EvaluateDelveEntry()
    end)
end

function AngusUI:DelvesInit()
    if self.delvesInitialized then
        return
    end

    self.delvesInitialized = true
    self.delvesCheckRevision = 0
    self.delvesRetryCount = 0

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    watcher:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE")
    watcher:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    watcher:SetScript("OnEvent", function(_, event, ...)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if currencyID ~= cofferKeyShardsCurrencyID and currencyID ~= restoredCofferKeyCurrencyID then
                return
            end

            if not IsDelveInProgress() then
                return
            end

            if self.delvesEntryDetectedAt and (GetTime() - self.delvesEntryDetectedAt) > entryRefreshWindowSeconds then
                return
            end

            self:QueueDelveEntryCheck(0.25)
            return
        end

        if event == "PLAYER_ENTERING_WORLD" then
            self:QueueDelveEntryCheck(1.5)
            return
        end

        self:QueueDelveEntryCheck(0.75)
    end)

    self.delvesWatcher = watcher
end
