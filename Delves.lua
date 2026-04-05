local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"

local TROVEHUNTER_RECEIVED_QUEST_ID = 86371
local TROVEHUNTER_USED_QUEST_ID = 92887
local GILDED_STASH_SPELL_ID = 1216211
local MYTH_CREST_CURRENCY_ID = 3347
local GILDED_STASH_WIDGET_IDS = {
    6659,
    6718,
    6719,
    6720,
    6721,
    6722,
    6723,
    6724,
    6725,
    6726,
    6727,
    6728,
    6729,
    6794,
    7193,
}

local lastAnnouncedGildedStash
local lastMythCrestQuantity
local pendingRefreshes = {}

local knownGildedStashWidgets = {}
for _, widgetID in ipairs(GILDED_STASH_WIDGET_IDS) do
    knownGildedStashWidgets[widgetID] = true
end

local function statusText(completed, trueText, falseText)
    trueText = trueText or "Yes"
    falseText = falseText or "No"

    return completed and GREEN_FONT_COLOR:WrapTextInColorCode(trueText) or RED_FONT_COLOR:WrapTextInColorCode(falseText)
end

local function debugPrint(message)
    print("AngusUI: " .. message)
end

local function trovehunterBountyStatus()
    if not C_QuestLog or not C_QuestLog.IsQuestFlaggedCompleted then
        return false, false
    end

    return C_QuestLog.IsQuestFlaggedCompleted(TROVEHUNTER_RECEIVED_QUEST_ID),
        C_QuestLog.IsQuestFlaggedCompleted(TROVEHUNTER_USED_QUEST_ID)
end

function AngusUI:DelvesCommand()
    local received, used = trovehunterBountyStatus()

    debugPrint("Trovehunter's Bounty looted this week: " .. statusText(received))
    debugPrint("Trovehunter's Bounty used this week: " .. statusText(used, "Used", "Not used"))
end

local function mythCrestQuantity()
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(MYTH_CREST_CURRENCY_ID)
    return info and info.quantity
end

local function parseGildedStashTooltip(text)
    if not text or text == "" then
        return
    end

    local current, max = string.match(text, "Gilded Stash looted:%s*(%d+)%s*/%s*(%d+)")
    if current and max then
        return tonumber(current), tonumber(max)
    end

    if string.find(text, "Gilded Stash", 1, true) then
        current, max = string.match(text, "(%d+)%s*/%s*(%d+)")
        if current and max then
            return tonumber(current), tonumber(max)
        end
    end
end

local function isInDelve()
    if not C_ScenarioInfo or not C_ScenarioInfo.GetScenarioInfo then
        return false
    end

    local scenarioInfo = C_ScenarioInfo.GetScenarioInfo()
    return scenarioInfo and scenarioInfo.name == "Delves"
end

local function selectedDelveWidgetSets()
    if not DelvesDifficultyPickerFrame or not DelvesDifficultyPickerFrame.GetSelectedOption then
        return
    end

    if not C_GossipInfo or not C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID then
        return
    end

    local selectedOption = DelvesDifficultyPickerFrame:GetSelectedOption()
    if not selectedOption or not selectedOption.gossipOptionID then
        return
    end

    return C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID(selectedOption.gossipOptionID)
end

local function inspectSpellInfo(spellInfo, widgetID)
    if not spellInfo then
        return
    end

    local current, max = parseGildedStashTooltip(spellInfo.tooltip)
    local matchesSpell = spellInfo.spellID == GILDED_STASH_SPELL_ID
    local matchesTooltip = current and max

    if (matchesSpell or matchesTooltip) and matchesTooltip then
        return current, max, widgetID
    end
end

local function scanScenarioHeaderDelvesWidget(widgetID)
    if not C_UIWidgetManager or not C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo then
        return
    end

    local info = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(widgetID)
    if not info then
        return
    end

    if info.tooltip then
        local current, max = parseGildedStashTooltip(info.tooltip)
        if current and max then
            return current, max, widgetID
        end
    end

    if info.spells then
        for _, spellInfo in ipairs(info.spells) do
            local current, max = inspectSpellInfo(spellInfo, widgetID)
            if current and max then
                return current, max, widgetID
            end
        end
    end
end

local function scanSpellDisplayWidget(widgetID)
    local info = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(widgetID)
    local spellInfo = info and info.spellInfo

    if not spellInfo then
        return info and true or false
    end

    local current, max = inspectSpellInfo(spellInfo, widgetID)
    if current and max then
        return true, current, max, widgetID
    end

    return true
end

local function scanWidgetSetForGildedStash(widgetSetID)
    if not C_UIWidgetManager or not C_UIWidgetManager.GetAllWidgetsBySetID then
        return
    end

    local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID)
    if not widgets or #widgets == 0 then
        return false
    end

    local sawAnyWidgetInfo = false

    for _, widget in ipairs(widgets) do
        if widget.widgetType == Enum.UIWidgetVisualizationType.ScenarioHeaderDelves then
            sawAnyWidgetInfo = true
            local current, max, widgetID = scanScenarioHeaderDelvesWidget(widget.widgetID)
            if current and max then
                return true, current, max, widgetID
            end
        elseif widget.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay then
            local sawInfo, current, max, widgetID = scanSpellDisplayWidget(widget.widgetID)
            if sawInfo then
                sawAnyWidgetInfo = true
            end
            if current and max then
                return true, current, max, widgetID
            end
        end
    end

    return sawAnyWidgetInfo
end

local function gildedStashProgress()
    if not C_UIWidgetManager or not C_UIWidgetManager.GetSpellDisplayVisualizationInfo then
        return
    end

    local widgetSets = selectedDelveWidgetSets()

    if widgetSets then
        for _, widgetSetInfo in ipairs(widgetSets) do
            local _, current, max, widgetID = scanWidgetSetForGildedStash(widgetSetInfo.uiWidgetSetID)
            if current and max then
                return current, max, widgetID
            end
        end
    end

    for _, widgetID in ipairs(GILDED_STASH_WIDGET_IDS) do
        local _, current, max, foundWidgetID = scanSpellDisplayWidget(widgetID)

        if current and max then
            return current, max, foundWidgetID
        end
    end
end

local function requestGildedStashRefresh(delay, reason)
    if not C_Timer or not C_Timer.After then
        return
    end

    delay = delay or 0
    local key = tostring(delay) .. ":" .. tostring(reason or "")

    if pendingRefreshes[key] then
        return
    end

    pendingRefreshes[key] = true
    C_Timer.After(delay, function()
        pendingRefreshes[key] = nil
        AngusUI:Delves("GILDED_STASH_REFRESH", reason)
    end)
end

local function cacheGildedStashProgress(current, max, widgetID)
    if not current or not max then
        return
    end

    AngusUIDB = AngusUIDB or {}

    local seenAt = GetServerTime and GetServerTime() or time()
    local resetAt

    if C_DateAndTime and C_DateAndTime.GetSecondsUntilWeeklyReset then
        local secondsUntilWeeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset()

        if secondsUntilWeeklyReset and secondsUntilWeeklyReset > 0 then
            resetAt = seenAt + secondsUntilWeeklyReset
        end
    end

    AngusUIDB.delvesGildedStash = {
        current = current,
        max = max,
        widgetID = widgetID,
        seenAt = seenAt,
        resetAt = resetAt,
        inferred = false,
        source = "widget",
    }

    local progress = current .. "/" .. max

    if lastAnnouncedGildedStash ~= progress then
        lastAnnouncedGildedStash = progress
        debugPrint("Gilded Stash looted " .. progress)
    end
end

local function pseudoIncrementGildedStashFromMythCrests()
    local quantity = mythCrestQuantity()

    if not quantity then
        return
    end

    if lastMythCrestQuantity == nil then
        lastMythCrestQuantity = quantity
        return
    end

    local delta = quantity - lastMythCrestQuantity
    lastMythCrestQuantity = quantity

    if delta ~= 5 or not isInDelve() then
        return
    end

    AngusUIDB = AngusUIDB or {}

    local cache = AngusUIDB.delvesGildedStash
    if not cache or not cache.current or not cache.max then
        return
    end

    local previous = cache.current
    if previous >= cache.max then
        return
    end

    cache.current = math.min(previous + 1, cache.max)
    cache.seenAt = GetServerTime and GetServerTime() or time()
    cache.inferred = true
    cache.source = "myth-crest-delta"
    cache.lastMythCrestDelta = delta
    lastAnnouncedGildedStash = cache.current .. "/" .. cache.max
end

function AngusUI:Delves(event, ...)
    if not DelvesDifficultyPickerFrame then
        return
    end

    if not DelvesDifficultyPickerFrame.AngusUITrovehunterStatus then
        local frame = CreateFrame("Frame", nil, DelvesDifficultyPickerFrame)
        frame:SetSize(180, 40)
        frame:SetPoint("TOP", DelvesDifficultyPickerFrame.EnterDelveButton, "BOTTOM", 0, -10)

        local text = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
        text:SetFont(Inconsolata, 11)
        text:SetJustifyH("CENTER")
        text:SetJustifyV("TOP")
        text:SetPoint("TOP", frame, "TOP")

        frame.Text = text
        DelvesDifficultyPickerFrame.AngusUITrovehunterStatus = frame

        local eventFrame = CreateFrame("Frame", nil, DelvesDifficultyPickerFrame)
        eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
        eventFrame:RegisterEvent("UPDATE_UI_WIDGET")
        eventFrame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
        eventFrame:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE")
        eventFrame:SetScript("OnEvent", function(_, innerEvent, ...)
            AngusUI:Delves(innerEvent, ...)
        end)
        DelvesDifficultyPickerFrame.AngusUIDelvesEventFrame = eventFrame

        DelvesDifficultyPickerFrame:HookScript("OnShow", function()
            AngusUI:Delves("ONSHOW")
            requestGildedStashRefresh(0, "OnShow immediate")
            requestGildedStashRefresh(0.25, "OnShow +0.25")
            requestGildedStashRefresh(0.75, "OnShow +0.75")
        end)
    end

    if event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID = ...

        if currencyID == MYTH_CREST_CURRENCY_ID then
            pseudoIncrementGildedStashFromMythCrests()
        end
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...

        if widgetInfo and widgetInfo.widgetID and DelvesDifficultyPickerFrame:IsShown() then
            if knownGildedStashWidgets[widgetInfo.widgetID]
                or widgetInfo.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay
                or widgetInfo.widgetType == Enum.UIWidgetVisualizationType.ScenarioHeaderDelves then
                requestGildedStashRefresh(0.1, "UPDATE_UI_WIDGET " .. widgetInfo.widgetID)
            end
        end
    elseif event == "UPDATE_ALL_UI_WIDGETS" or event == "ACTIVE_DELVE_DATA_UPDATE" then
        requestGildedStashRefresh(0.1, event)
    end

    local current, max, widgetID = gildedStashProgress()
    cacheGildedStashProgress(current, max, widgetID)
    lastMythCrestQuantity = mythCrestQuantity() or lastMythCrestQuantity

    local received = trovehunterBountyStatus()
    DelvesDifficultyPickerFrame.AngusUITrovehunterStatus.Text:SetText(table.concat({
        "Trovehunter's Bounty",
        "Completed this week: " .. statusText(received),
    }, "\n"))
end
