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
        
        if not name then
            print("AngusUI: Warning - Achievement " .. achievementId .. " not found")
            return
        end
        
        local color = wasEarnedByMe and "\124cff00FF00" or "\124cffFF0000"
        print(color .. name .. " (" .. (iLvls[achievementId] + 1) .. ")\124r")

        if wasEarnedByMe == false then
            local slotInfo = {}

            -- Gather high watermark info for all equipment slots
            for slotName, slotId in next, Enum.ItemRedundancySlot do
                local highWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(slotId)
                slotInfo[slotId] = { 
                    meetsRequirement = highWatermark > iLvls[achievementId], 
                    itemLevel = highWatermark, 
                    name = slotName 
                }
            end

            -- Check which slots need upgrading
            for slotId, info in next, slotInfo do
                local needsUpgrade = false
                
                if slotId < 12 then
                    -- Regular slots (head, neck, shoulders, etc.)
                    needsUpgrade = not info.meetsRequirement
                elseif slotId > 11 then
                    -- Special slots (weapons and rings require both slots)
                    local hasWeapons = slotInfo[12].meetsRequirement or 
                                     (slotInfo[13].meetsRequirement and slotInfo[16].meetsRequirement)
                    local hasRings = slotInfo[14].meetsRequirement and slotInfo[15].meetsRequirement
                    needsUpgrade = not (hasWeapons or hasRings)
                end
                
                if needsUpgrade then
                    print(info.itemLevel, info.name)
                end
            end

            return
        end
    end
end
