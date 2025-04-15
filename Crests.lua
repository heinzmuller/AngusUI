local _, AngusUI = ...

local crestQuests = {
    ["Nerub-ar Palace"] = 82141,
    ["Hallowfall"] = 82407,
    ["Isle of Dorn"] = 82365,
    ["The Ringing Deeps"] = 82384,
    ["Azj-Kahet"] = 82446,
    ["Undermine"] = 85827,
    ["Liberation of Undermine"] = 86204,
}

local achievements = { 40942, 40943, 40944, 40945 }

local iLvls = {
    [40942] = 631,
    [40943] = 644,
    [40944] = 657,
    [40945] = 674,
}

function AngusUI:Crests()
    for zone, questId in pairs(crestQuests) do
        local completed = C_QuestLog.IsQuestFlaggedCompleted(questId)
        local color = completed and "\124cff00FF00" or "\124cffFF0000"
        print(color .. zone .. "\124r")
    end

    for _, achievementId in ipairs(achievements) do
        local id, name, points, completed, month, day, year, description, flags,
        icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementId)
        local color = wasEarnedByMe and "\124cff00FF00" or "\124cffFF0000"
        print(color .. name .. " (" .. (iLvls[achievementId] + 1) .. ")\124r")

        if wasEarnedByMe == false then
            local x = {}

            for n, i in next, Enum.ItemRedundancySlot do
                local w = C_ItemUpgrade.GetHighWatermarkForSlot(i)
                x[i] = { w > iLvls[achievementId], w, n }
            end

            for i, v in next, x do
                if i < 12 and not v[1] or i > 11 and not (x[12][1] or x[13][1] and x[16][1] or x[14][1] and x[15][1]) then
                    print(v[2], v[3])
                end
            end

            return
        end
    end
end
