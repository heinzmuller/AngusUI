local _, AngusUI = ...

local harandarTreasureNames = {
    ["budding barrel"] = true,
    ["dead drop"] = true,
    ["fungalcap crock"] = true,
    ["forgotten amani cache"] = true,
    ["giant grab bag"] = true,
    ["leaf-wrapped package"] = true,
    ["maisara vilevessel"] = true,
    ["mysterious domanaar vessel"] = true,
    ["shabby stockpile"] = true,
    ["stashed singularity supplies"] = true,
    ["stonewash supplies"] = true,
    ["spiritpaw satchel"] = true,
    ["twilight ordinance"] = true,
}

local harandarTreasureNameFragments = {
}

local trackedPinMixins = setmetatable({}, { __mode = "k" })
local commonTextureFields = {
    "Texture",
    "texture",
    "Icon",
    "icon",
}
local tintColor = {
    r = 0.15,
    g = 0.95,
    b = 1,
    a = 1,
}
local areaPoiSources = {
    "GetAreaPOIForMap",
    "GetDelvesForMap",
    "GetEventsForMap",
    "GetQuestHubsForMap",
}
local debugPrintedVignettes = {}
local debugPrintedAreaPois = {}
local seenTrackedTreasurePins = {}

local treasuresFrame
local refreshQueued = false

local function IsTexture(object)
    return object and object.GetObjectType and object:GetObjectType() == "Texture"
end

local function NormalizeName(name)
    if type(name) ~= "string" then
        return nil
    end

    name = strtrim(strlower(name))
    if name == "" then
        return nil
    end

    return name
end

local function ShouldTintTreasureName(name)
    local normalizedName = NormalizeName(name)
    if not normalizedName then
        return false
    end

    if harandarTreasureNames[normalizedName] then
        return true
    end

    for _, fragment in ipairs(harandarTreasureNameFragments) do
        if strfind(normalizedName, fragment, 1, true) then
            return true
        end
    end

    return false
end

local function GetTrackedTreasureName(name)
    local normalizedName = NormalizeName(name)
    if not normalizedName then
        return nil
    end

    if harandarTreasureNames[normalizedName] then
        return normalizedName
    end

    for _, fragment in ipairs(harandarTreasureNameFragments) do
        if strfind(normalizedName, fragment, 1, true) then
            return normalizedName
        end
    end

    return nil
end

local function IsMinimapDescendant(frame)
    while frame do
        if frame == Minimap then
            return true
        end

        frame = frame.GetParent and frame:GetParent() or nil
    end

    return false
end

local function GetPlayerMapID()
    if not C_Map or not C_Map.GetBestMapForUnit then
        return nil
    end

    return C_Map.GetBestMapForUnit("player")
end

local function GetPinVignetteInfo(pin)
    if not pin then
        return nil
    end

    if pin.vignetteInfo then
        return pin.vignetteInfo
    end

    local vignetteGUID = pin.vignetteGUID
    if not vignetteGUID and pin.GetVignetteGUID then
        vignetteGUID = pin:GetVignetteGUID()
    end

    if not vignetteGUID or not C_VignetteInfo or not C_VignetteInfo.GetVignetteInfo then
        return nil
    end

    return C_VignetteInfo.GetVignetteInfo(vignetteGUID)
end

local function GetPinAreaPoiInfo(pin)
    if not pin or not C_AreaPoiInfo or not C_AreaPoiInfo.GetAreaPOIInfo then
        return nil
    end

    if pin.poiInfo and pin.poiInfo.areaPoiID then
        return pin.poiInfo, pin.poiInfo.areaPoiID, pin.poiInfo.uiMapID or GetPlayerMapID()
    end

    local data = pin.data
    local poiID
    local uiMapID

    if type(data) == "table" then
        poiID = data.poiID or data.areaPoiID
        uiMapID = data.uiMapID or data.mapID
    end

    poiID = poiID or pin.poiID or pin.areaPoiID
    uiMapID = uiMapID or GetPlayerMapID()

    if not poiID then
        return nil
    end

    return C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, poiID), poiID, uiMapID
end

local function ShouldTintVignetteInfo(vignetteInfo)
    if not vignetteInfo or not vignetteInfo.name then
        return false
    end

    if Enum and Enum.VignetteType and vignetteInfo.type ~= nil and vignetteInfo.type ~= Enum.VignetteType.Treasure then
        return false
    end

    return GetTrackedTreasureName(vignetteInfo.name) ~= nil
end

local function ShouldTintAreaPoiInfo(poiInfo)
    return poiInfo and GetTrackedTreasureName(poiInfo.name) ~= nil
end

local function GetTrackedPinKey(kind, id, name)
    return table.concat({ tostring(kind), tostring(id), tostring(name) }, "|")
end

local function ReportTrackedTreasureSeen(kind, id, name, source, extra)
    local trackedName = GetTrackedTreasureName(name)
    if not trackedName then
        return
    end

    local key = GetTrackedPinKey(kind, id, trackedName)
    if seenTrackedTreasurePins[key] then
        return
    end

    seenTrackedTreasurePins[key] = true
    AngusUI:Print(
        "Tracked treasure seen:",
        "name=" .. trackedName,
        "kind=" .. tostring(kind),
        "id=" .. tostring(id),
        "source=" .. tostring(source),
        extra or ""
    )
end

local function IsTreasureDebugCandidate(vignetteInfo)
    if not vignetteInfo or not vignetteInfo.onMinimap then
        return false
    end

    return true
end

local function GetVignetteDebugSignature(vignetteInfo)
    if not vignetteInfo then
        return nil
    end

    return table.concat({
        tostring(vignetteInfo.name),
        tostring(vignetteInfo.vignetteID),
        tostring(vignetteInfo.rewardQuestID),
        tostring(vignetteInfo.objectGUID),
        tostring(vignetteInfo.type),
        tostring(vignetteInfo.atlasName),
        tostring(vignetteInfo.onMinimap),
    }, "|")
end

local function GetDebugPositionText(instanceID)
    if not C_Map or not C_Map.GetBestMapForUnit or not C_VignetteInfo or not C_VignetteInfo.GetVignettePosition then
        return ""
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return ""
    end

    local position = C_VignetteInfo.GetVignettePosition(instanceID, mapID)
    if not position then
        return " map=" .. tostring(mapID)
    end

    local x, y = position:GetXY()
    return format(" map=%s x=%.4f y=%.4f", tostring(mapID), x or 0, y or 0)
end

local function GetAreaPoiPositionText(mapID, poiInfo)
    if not poiInfo then
        return ""
    end

    local position = poiInfo.position
    if not position or not position.GetXY then
        return " map=" .. tostring(mapID)
    end

    local x, y = position:GetXY()
    return format(" map=%s x=%.4f y=%.4f", tostring(mapID), x or 0, y or 0)
end

local function PrintVignetteDebug(instanceID, vignetteInfo)
    if not vignetteInfo then
        return
    end

    AngusUI:Print(
        "Treasure vignette:",
        "instanceID=" .. tostring(instanceID),
        "name=" .. tostring(vignetteInfo.name),
        "vignetteID=" .. tostring(vignetteInfo.vignetteID),
        "rewardQuestID=" .. tostring(vignetteInfo.rewardQuestID),
        "objectGUID=" .. tostring(vignetteInfo.objectGUID),
        "type=" .. tostring(vignetteInfo.type),
        "atlas=" .. tostring(vignetteInfo.atlasName),
        GetDebugPositionText(instanceID)
    )
end

local function GetAreaPoiDebugSignature(poiInfo)
    if not poiInfo then
        return nil
    end

    return table.concat({
        tostring(poiInfo.name),
        tostring(poiInfo.areaPoiID),
        tostring(poiInfo.atlasName),
        tostring(poiInfo.textureIndex),
        tostring(poiInfo.tooltipWidgetSet),
        tostring(poiInfo.iconWidgetSet),
    }, "|")
end

local function PrintAreaPoiDebug(mapID, poiID, poiInfo, source)
    if not poiInfo then
        return
    end

    AngusUI:Print(
        "Treasure areaPOI:",
        "map=" .. tostring(mapID),
        "poiID=" .. tostring(poiID),
        "name=" .. tostring(poiInfo.name),
        "atlas=" .. tostring(poiInfo.atlasName),
        "textureIndex=" .. tostring(poiInfo.textureIndex),
        "tooltipWidgetSet=" .. tostring(poiInfo.tooltipWidgetSet),
        "iconWidgetSet=" .. tostring(poiInfo.iconWidgetSet),
        "source=" .. tostring(source),
        GetAreaPoiPositionText(mapID, poiInfo)
    )
end

local function CollectAreaPoiIDs(mapID)
    local orderedPoiIDs = {}
    local poiSources = {}

    if not mapID or not C_AreaPoiInfo then
        return orderedPoiIDs, poiSources
    end

    for _, methodName in ipairs(areaPoiSources) do
        local method = C_AreaPoiInfo[methodName]
        if method then
            local poiIDs = method(mapID)
            if poiIDs then
                for _, poiID in ipairs(poiIDs) do
                    if poiID and not poiSources[poiID] then
                        poiSources[poiID] = methodName
                        table.insert(orderedPoiIDs, poiID)
                    end
                end
            end
        end
    end

    return orderedPoiIDs, poiSources
end

local function RefreshAreaPoiDebug()
    if not AngusUI.treasureDebugEnabled or not C_AreaPoiInfo or not C_AreaPoiInfo.GetAreaPOIInfo then
        return
    end

    local mapID = GetPlayerMapID()
    local poiIDs, poiSources = CollectAreaPoiIDs(mapID)
    local activePois = {}

    for _, poiID in ipairs(poiIDs) do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
        if poiInfo and ShouldTintTreasureName(poiInfo.name) then
            activePois[poiID] = true

            local signature = GetAreaPoiDebugSignature(poiInfo)
            if debugPrintedAreaPois[poiID] ~= signature then
                debugPrintedAreaPois[poiID] = signature
                PrintAreaPoiDebug(mapID, poiID, poiInfo, poiSources[poiID])
            end
        end
    end

    for poiID in pairs(debugPrintedAreaPois) do
        if not activePois[poiID] then
            debugPrintedAreaPois[poiID] = nil
        end
    end
end

local function RefreshTreasureDebug()
    if not AngusUI.treasureDebugEnabled or not C_VignetteInfo or not C_VignetteInfo.GetVignettes or not C_VignetteInfo.GetVignetteInfo then
        return
    end

    local activeVignettes = {}
    for _, instanceID in pairs(C_VignetteInfo.GetVignettes()) do
        local vignetteInfo = C_VignetteInfo.GetVignetteInfo(instanceID)
        if IsTreasureDebugCandidate(vignetteInfo) then
            activeVignettes[instanceID] = true

            local signature = GetVignetteDebugSignature(vignetteInfo)
            if debugPrintedVignettes[instanceID] ~= signature then
                debugPrintedVignettes[instanceID] = signature
                PrintVignetteDebug(instanceID, vignetteInfo)
            end
        end
    end

    for instanceID in pairs(debugPrintedVignettes) do
        if not activeVignettes[instanceID] then
            debugPrintedVignettes[instanceID] = nil
        end
    end
end

local function ScoreTexture(texture)
    if not IsTexture(texture) then
        return -1
    end

    local score = 0
    local atlas = texture.GetAtlas and texture:GetAtlas() or nil
    local asset = texture.GetTexture and texture:GetTexture() or nil
    local width = texture.GetWidth and texture:GetWidth() or 0
    local height = texture.GetHeight and texture:GetHeight() or 0

    if atlas and atlas ~= "" then
        score = score + 6
    end

    if asset then
        score = score + 4
    end

    if width > 4 and height > 4 then
        score = score + 2
    end

    if texture.IsShown and texture:IsShown() then
        score = score + 1
    end

    return score
end

local function FindPinTexture(frame, depth)
    if not frame or depth < 0 then
        return nil
    end

    for _, fieldName in ipairs(commonTextureFields) do
        local texture = frame[fieldName]
        if IsTexture(texture) then
            return texture
        end
    end

    local bestTexture
    local bestScore = -1
    for _, region in ipairs({ frame:GetRegions() }) do
        local score = ScoreTexture(region)
        if score > bestScore then
            bestTexture = region
            bestScore = score
        end
    end

    if bestTexture then
        return bestTexture
    end

    if depth == 0 then
        return nil
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        local texture = FindPinTexture(child, depth - 1)
        if texture then
            return texture
        end
    end

    return nil
end

local function ClearPinTint(pin)
    if not pin or not pin.AngusUITreasureTexture then
        return
    end

    local texture = pin.AngusUITreasureTexture
    if IsTexture(texture) and pin.AngusUITreasureOriginalVertexColor then
        texture:SetVertexColor(unpack(pin.AngusUITreasureOriginalVertexColor))
    end

    pin.AngusUITreasureTexture = nil
    pin.AngusUITreasureOriginalVertexColor = nil
end

local function ApplyTintToPin(pin)
    if not pin or not IsMinimapDescendant(pin) then
        return
    end

    local vignetteInfo = GetPinVignetteInfo(pin)
    local poiInfo = nil

    if vignetteInfo then
        ReportTrackedTreasureSeen(
            "vignette",
            vignetteInfo.vignetteID or pin.vignetteGUID,
            vignetteInfo.name,
            "pin-scan",
            "instance=" .. tostring(pin.vignetteGUID or (pin.GetVignetteGUID and pin:GetVignetteGUID()) or nil)
        )

        if not ShouldTintVignetteInfo(vignetteInfo) then
            ClearPinTint(pin)
            return
        end
    else
        local areaPoiID
        local uiMapID
        poiInfo, areaPoiID, uiMapID = GetPinAreaPoiInfo(pin)
        if poiInfo then
            ReportTrackedTreasureSeen(
                "areaPOI",
                areaPoiID,
                poiInfo.name,
                "pin-scan",
                "map=" .. tostring(uiMapID)
            )
        end

        if not ShouldTintAreaPoiInfo(poiInfo) then
            ClearPinTint(pin)
            return
        end
    end

    local texture = FindPinTexture(pin, 2)
    if not texture then
        ClearPinTint(pin)
        return
    end

    if pin.AngusUITreasureTexture ~= texture then
        ClearPinTint(pin)
        pin.AngusUITreasureTexture = texture
        pin.AngusUITreasureOriginalVertexColor = { texture:GetVertexColor() }
    end

    texture:SetVertexColor(tintColor.r, tintColor.g, tintColor.b, tintColor.a)
end

local function RefreshVisiblePins()
    if not Minimap then
        return
    end

    local visited = {}
    local function VisitFrame(frame)
        if not frame or visited[frame] then
            return
        end

        visited[frame] = true

        ApplyTintToPin(frame)

        for _, child in ipairs({ frame:GetChildren() }) do
            VisitFrame(child)
        end
    end

    VisitFrame(Minimap)
end

local function QueueRefresh()
    if refreshQueued then
        return
    end

    refreshQueued = true
    C_Timer.After(0, function()
        refreshQueued = false
        RefreshVisiblePins()
        RefreshTreasureDebug()
        RefreshAreaPoiDebug()
    end)
end

local function DumpCurrentVignettes()
    local count = 0

    if not C_VignetteInfo or not C_VignetteInfo.GetVignettes or not C_VignetteInfo.GetVignetteInfo then
        AngusUI:Print("Treasure debug: vignette API unavailable")
        return
    end

    for _, instanceID in pairs(C_VignetteInfo.GetVignettes()) do
        local vignetteInfo = C_VignetteInfo.GetVignetteInfo(instanceID)
        if vignetteInfo then
            count = count + 1
            PrintVignetteDebug(instanceID, vignetteInfo)
        end
    end

    if count == 0 then
        AngusUI:Print("Treasure debug: no current vignettes")
    end
end

local function DumpCurrentAreaPois()
    local mapID = GetPlayerMapID()
    local count = 0

    if not mapID then
        AngusUI:Print("Treasure debug: no player map id")
        return
    end

    if not C_AreaPoiInfo or not C_AreaPoiInfo.GetAreaPOIInfo then
        AngusUI:Print("Treasure debug: areaPOI API unavailable")
        return
    end

    local poiIDs, poiSources = CollectAreaPoiIDs(mapID)
    for _, poiID in ipairs(poiIDs) do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
        if poiInfo then
            count = count + 1
            PrintAreaPoiDebug(mapID, poiID, poiInfo, poiSources[poiID])
        end
    end

    if count == 0 then
        AngusUI:Print("Treasure debug: no current areaPOIs on map", tostring(mapID))
    end
end

local function DumpVisibleMinimapPins()
    if not Minimap then
        AngusUI:Print("Treasure debug: minimap unavailable")
        return
    end

    local count = 0
    local visited = {}

    local function VisitFrame(frame)
        if not frame or visited[frame] then
            return
        end

        visited[frame] = true

        local vignetteInfo = GetPinVignetteInfo(frame)
        local poiInfo, poiID, uiMapID = GetPinAreaPoiInfo(frame)
        local data = frame.data
        local hasDebugData = vignetteInfo or poiInfo or frame.pinTemplate or frame.GetVignetteGUID or frame.GetVignetteID or frame.areaPoiID or frame.poiID or (type(data) == "table" and (data.poiID or data.areaPoiID or data.questID))

        if hasDebugData and frame.IsVisible and frame:IsVisible() and IsMinimapDescendant(frame) then
            count = count + 1

            local texture = FindPinTexture(frame, 1)
            AngusUI:Print(
                "Minimap pin:",
                "frame=" .. tostring(frame.GetName and frame:GetName() or "<anonymous>"),
                "template=" .. tostring(frame.pinTemplate),
                "vignetteName=" .. tostring(vignetteInfo and vignetteInfo.name or nil),
                "vignetteID=" .. tostring(vignetteInfo and vignetteInfo.vignetteID or nil),
                "poiName=" .. tostring(poiInfo and poiInfo.name or nil),
                "poiID=" .. tostring(poiID),
                "poiMap=" .. tostring(uiMapID),
                "questID=" .. tostring(type(data) == "table" and data.questID or nil),
                "atlas=" .. tostring(texture and texture.GetAtlas and texture:GetAtlas() or nil),
                "texture=" .. tostring(texture and texture.GetTexture and texture:GetTexture() or nil)
            )
        end

        for _, child in ipairs({ frame:GetChildren() }) do
            VisitFrame(child)
        end
    end

    VisitFrame(Minimap)

    if count == 0 then
        AngusUI:Print("Treasure debug: no visible minimap pin frames found")
    end
end

local function HookPinMixin(mixin)
    if not mixin or trackedPinMixins[mixin] then
        return
    end

    trackedPinMixins[mixin] = true

    if type(mixin.OnAcquired) == "function" then
        hooksecurefunc(mixin, "OnAcquired", function(self)
            QueueRefresh()
            ApplyTintToPin(self)
        end)
    end

    if type(mixin.UpdateAppearance) == "function" then
        hooksecurefunc(mixin, "UpdateAppearance", function(self)
            ApplyTintToPin(self)
        end)
    end

    if type(mixin.OnReleased) == "function" then
        hooksecurefunc(mixin, "OnReleased", function(self)
            ClearPinTint(self)
        end)
    end
end

function AngusUI:TreasuresInit()
    if self.treasuresInitialized then
        return
    end

    self.treasuresInitialized = true

    HookPinMixin(VignettePinBaseMixin)
    HookPinMixin(VignettePinMixin)

    treasuresFrame = CreateFrame("Frame")
    treasuresFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    treasuresFrame:RegisterEvent("VIGNETTES_UPDATED")
    if not C_EventUtils or not C_EventUtils.IsEventValid or C_EventUtils.IsEventValid("VIGNETTE_MINIMAP_UPDATED") then
        treasuresFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
    end

    treasuresFrame:SetScript("OnEvent", function()
        wipe(seenTrackedTreasurePins)
        QueueRefresh()
    end)

    QueueRefresh()
end

function AngusUI:ToggleTreasureDebug()
    self.treasureDebugEnabled = not self.treasureDebugEnabled
    wipe(debugPrintedVignettes)
    wipe(debugPrintedAreaPois)
    wipe(seenTrackedTreasurePins)

    if self.treasureDebugEnabled then
        self:Print("Treasure debug enabled", "use /aui treasuredump near the treasure")
        RefreshTreasureDebug()
        RefreshAreaPoiDebug()
        QueueRefresh()
    else
        self:Print("Treasure debug disabled")
    end
end

function AngusUI:DumpTreasureDebug()
    self:Print(
        "Treasure debug dump",
        "zone=" .. tostring(GetRealZoneText and GetRealZoneText() or nil),
        "map=" .. tostring(GetPlayerMapID())
    )
    DumpCurrentVignettes()
    DumpCurrentAreaPois()
    DumpVisibleMinimapPins()
end
