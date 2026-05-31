-- Adds a compact Mythic+ reward reference so weekly upgrade decisions are easier to make in-game.
local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"
local mythicPlusWatcher = CreateFrame("Frame")

mythicPlusWatcher:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
mythicPlusWatcher:SetScript("OnEvent", function(self)
    if ChallengesFrame == nil then
        return
    end

    AngusUI:MythicPlus()
    self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
end)

-- Colors reward values to identify Champion-track rewards.
local function champion(itemLevel)
    return RARE_BLUE_COLOR:WrapTextInColorCode(itemLevel)
end

-- Colors reward values to identify Hero-track rewards.
local function hero(itemLevel)
    return ITEM_EPIC_COLOR:WrapTextInColorCode(itemLevel)
end

-- Colors reward values to identify Myth-track rewards.
local function mythic(itemLevel)
    return ITEM_LEGENDARY_COLOR:WrapTextInColorCode(itemLevel)
end

-- Keeps the Mythic+ reward table aligned and readable.
local function cell(value)
    return string.format("%-4s", tostring(value))
end

-- Adds a quick-reference Mythic+ reward chart to the weekly panel.
function AngusUI:MythicPlus()
    local frame = CreateFrame("Frame", "AngusUIMythicPlusRewards", ChallengesFrame.WeeklyInfo)
    frame:SetSize(1, 1)
    frame:SetPoint("RIGHT", ChallengesFrame.WeeklyInfo, "RIGHT", 0, -100)

    local text = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    text:SetFont(Inconsolata, 10)
    text:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

    local endOfDungeon = {
        champion(cell(250)),
        champion(cell(250)),
        champion(cell(253)),
        champion(cell(256)),
        hero(cell(259)),
        hero(cell(259)),
        hero(cell(263)),
        hero(cell(263)),
        hero(cell(266)),
    }

    local vault = {
        hero(cell(259)),
        hero(cell(259)),
        hero(cell(263)),
        hero(cell(263)),
        hero(cell(266)),
        hero(cell(269)),
        hero(cell(269)),
        hero(cell(269)),
        mythic(cell(272)),
    }

    local crests = {
        champion(cell(10)),
        champion(cell(12)),
        hero(cell(10)),
        hero(cell(10)),
        hero(cell(12)),
        hero(cell(14)),
        hero(cell(18)),
        mythic(cell(10)),
        mythic(cell("12+")),
    }

    local mythicItemLevels = ""
    mythicItemLevels = mythicItemLevels .. table.concat({
        cell(2),
        cell(3),
        cell(4),
        cell(5),
        cell(6),
        cell(7),
        cell(8),
        cell(9),
        cell("10+"),
    }) .. "\n"

    mythicItemLevels = mythicItemLevels .. table.concat(endOfDungeon) .. "\n"
    mythicItemLevels = mythicItemLevels .. table.concat(vault) .. "\n"
    mythicItemLevels = mythicItemLevels .. table.concat(crests)

    text:SetText(mythicItemLevels)
    frame:Show()
end
