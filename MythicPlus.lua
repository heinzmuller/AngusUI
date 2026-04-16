local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"

local function champion(itemLevel)
    return RARE_BLUE_COLOR:WrapTextInColorCode(itemLevel)
end

local function hero(itemLevel)
    return ITEM_EPIC_COLOR:WrapTextInColorCode(itemLevel)
end

local function mythic(itemLevel)
    return ITEM_LEGENDARY_COLOR:WrapTextInColorCode(itemLevel)
end

local function cell(value)
    return string.format("%-4s", tostring(value))
end

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
