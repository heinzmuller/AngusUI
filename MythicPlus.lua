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
    frame:SetPoint("RIGHT", ChallengesFrame.WeeklyInfo, "RIGHT", 0, -110)

    local text = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Small")
    text:SetFont(Inconsolata, 10)
    text:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

    local endOfDungeon = {
        champion(597),
        champion(597),
        champion(600),
        champion(603),
        champion(606),
        hero(610),
        hero(610),
        hero(613),
        hero(613)
    }

    local vault = {
        champion(606),
        hero(610),
        hero(610),
        hero(613),
        hero(613),
        hero(616),
        hero(619),
        hero(619),
        mythic(623)
    }

    local mythicItemLevels = ""
    mythicItemLevels = mythicItemLevels .. "2    3    4    5    6    7    8    9   10\n"

    for _, v in ipairs(endOfDungeon) do
        mythicItemLevels = mythicItemLevels .. v .. "  "
    end

    mythicItemLevels = mythicItemLevels .. "\n"

    for _, v in ipairs(vault) do
        mythicItemLevels = mythicItemLevels .. v .. "  "
    end

    text:SetText(mythicItemLevels)
    frame:Show()
end
