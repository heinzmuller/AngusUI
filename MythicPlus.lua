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

function AngusUI:MythicPlus()
    local frame = CreateFrame("Frame", "AngusUIMythicPlusRewards", ChallengesFrame.WeeklyInfo)
    frame:SetSize(1, 1)
    frame:SetPoint("RIGHT", ChallengesFrame.WeeklyInfo, "RIGHT", 0, -100)

    local text = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    text:SetFont(Inconsolata, 10)
    text:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

    local endOfDungeon = {
        champion(639),
        champion(639),
        champion(642),
        champion(645),
        hero(649),
        hero(649),
        hero(652),
        hero(652),
        hero(655),
        hero(655),
        hero(655),
    }

    local vault = {
        hero(649),
        hero(649),
        hero(652),
        hero(652),
        hero(655),
        hero(658),
        hero(658),
        hero(658),
        mythic(662),
        mythic(662),
        mythic(662),
    }

    local crests = {
        hero(10),
        hero(12),
        hero(14),
        hero(16),
        hero(18),
        mythic(10),
        mythic(12),
        mythic(14),
        mythic(16),
        mythic(18),
        mythic(20),
    }

    local mythicItemLevels = ""
    mythicItemLevels = mythicItemLevels .. "2    3    4    5    6    7    8    9   10   11   12\n"

    for _, v in ipairs(endOfDungeon) do
        mythicItemLevels = mythicItemLevels .. v .. "  "
    end

    mythicItemLevels = mythicItemLevels .. "\n"

    for _, v in ipairs(vault) do
        mythicItemLevels = mythicItemLevels .. v .. "  "
    end

    mythicItemLevels = mythicItemLevels .. "\n"

    for _, v in ipairs(crests) do
        mythicItemLevels = mythicItemLevels .. v .. "   "
    end

    text:SetText(mythicItemLevels)
    frame:Show()
end
