local _, AngusUI = ...

local achievements = {
    { id = 61809, display = 237, mode = "watermark" },
    { id = 42767, display = 250, mode = "watermark" },
    { id = 42768, display = 263, mode = "watermark" },
    { id = 42769, display = 276, mode = "watermark" },
    { id = 42770, display = 285, mode = "average" },
}

local trackedQuests = {
    { id = 95245, fallbackName = "Midnight: World Tour" },
}

local CREST_COST_PER_STEP = 20

local COMPLETED_COLOR = "\124cff00FF00"
local INCOMPLETE_COLOR = "\124cffFF0000"
local COLOR_RESET = "\124r"

local crestSteps = {
    { itemLevel = 224, crest = "Adventurer Dawncrest" },
    { itemLevel = 227, crest = "Adventurer Dawncrest" },
    { itemLevel = 230, crest = "Adventurer Dawncrest" },
    { itemLevel = 233, crest = "Adventurer Dawncrest" },
    { itemLevel = 237, crest = "Adventurer Dawncrest" },
    { itemLevel = 240, crest = "Veteran Dawncrest" },
    { itemLevel = 243, crest = "Veteran Dawncrest" },
    { itemLevel = 246, crest = "Veteran Dawncrest" },
    { itemLevel = 250, crest = "Veteran Dawncrest" },
    { itemLevel = 253, crest = "Champion Dawncrest" },
    { itemLevel = 256, crest = "Champion Dawncrest" },
    { itemLevel = 259, crest = "Champion Dawncrest" },
    { itemLevel = 263, crest = "Champion Dawncrest" },
    { itemLevel = 266, crest = "Hero Dawncrest" },
    { itemLevel = 269, crest = "Hero Dawncrest" },
    { itemLevel = 272, crest = "Hero Dawncrest" },
    { itemLevel = 276, crest = "Hero Dawncrest" },
}

local crestOrder = {
    "Adventurer Dawncrest",
    "Veteran Dawncrest",
    "Champion Dawncrest",
    "Hero Dawncrest",
}

local redundancySlots = {
    Twohand = 12,
    MainhandWeapon = 13,
    OnehandWeapon = 14,
    OnehandWeaponSecond = 15,
    Offhand = 16,
}

local function calculateCrestCosts(currentItemLevel, targetItemLevel, discountItemLevel)
    local costs = {}
    local total = 0

    for _, step in ipairs(crestSteps) do
        if step.itemLevel > currentItemLevel and step.itemLevel <= targetItemLevel then
            local stepCost = CREST_COST_PER_STEP

            if discountItemLevel and step.itemLevel <= discountItemLevel then
                stepCost = stepCost / 2
            end

            costs[step.crest] = (costs[step.crest] or 0) + stepCost
            total = total + stepCost
        end
    end

    return costs, total
end

local function mergeCrestCosts(target, source)
    for crestName, amount in next, source do
        target[crestName] = (target[crestName] or 0) + amount
    end
end

local function formatCrestCosts(costs, total)
    local parts = {}

    for _, crestName in ipairs(crestOrder) do
        local amount = costs[crestName]

        if amount and amount > 0 then
            table.insert(parts, amount .. " " .. crestName)
        end
    end

    if #parts == 0 then
        return nil
    end

    return table.concat(parts, ", ") .. " (total " .. total .. ")"
end

local function colorizeCompletion(name, completed)
    local color = completed and COMPLETED_COLOR or INCOMPLETE_COLOR
    return color .. name .. COLOR_RESET
end

local function printTrackedQuests()
    for _, quest in ipairs(trackedQuests) do
        local completed = C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(quest.id) or false
        local title = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(quest.id)

        print(colorizeCompletion((title or quest.fallbackName) .. " (Quest)", completed))
    end
end

function AngusUI:Crests()
    local achievementState = {}
    local highestAccountAchievementDisplay = 0

    for _, achievement in ipairs(achievements) do
        local achievementId = achievement.id
        local id, name, points, completed, month, day, year, description, flags,
        icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementId)

        achievementState[achievementId] = {
            name = name,
            completed = completed,
            wasEarnedByMe = wasEarnedByMe,
        }

        if completed and achievement.display > highestAccountAchievementDisplay then
            highestAccountAchievementDisplay = achievement.display
        end
    end

    printTrackedQuests()

    for _, achievement in ipairs(achievements) do
        local achievementId = achievement.id
        local achievementInfo = achievementState[achievementId]
        local name = achievementInfo.name
        local wasEarnedByMe = achievementInfo.wasEarnedByMe
        
        if not name then
            print("AngusUI: Warning - Achievement " .. achievementId .. " not found")
            return
        end
        
        print(colorizeCompletion(name .. " (" .. achievement.display .. ")", wasEarnedByMe))

        if wasEarnedByMe == false then
            if highestAccountAchievementDisplay > 0 then
                print("Account crest discount through " .. highestAccountAchievementDisplay .. " (50%)")
            end

            if achievement.mode == "average" then
                local overallItemLevel, equippedItemLevel = GetAverageItemLevel()
                local currentItemLevel = equippedItemLevel or overallItemLevel or 0
                print(string.format("%.1f / %d average item level", currentItemLevel, achievement.display))
                return
            end

            local slotInfo = {}

            for slotName, slotId in next, Enum.ItemRedundancySlot do
                local characterHighWatermark, accountHighWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(slotId)
                slotInfo[slotId] = { 
                    meetsRequirement = characterHighWatermark >= achievement.display,
                    itemLevel = characterHighWatermark, 
                    name = slotName 
                }
            end

            local requirements = {}
            local totalCosts = {}
            local totalCrests = 0

            for slotId = 0, 11 do
                local info = slotInfo[slotId]

                if info and not info.meetsRequirement then
                    local costs, costTotal = calculateCrestCosts(info.itemLevel, achievement.display, highestAccountAchievementDisplay)

                    table.insert(requirements, {
                        sortId = slotId,
                        label = info.name,
                        itemLevel = info.itemLevel,
                        costs = costs,
                        total = costTotal,
                    })

                    mergeCrestCosts(totalCosts, costs)
                    totalCrests = totalCrests + costTotal
                end
            end

            local singleHandSlotIds = {
                redundancySlots.MainhandWeapon,
                redundancySlots.OnehandWeapon,
                redundancySlots.OnehandWeaponSecond,
                redundancySlots.Offhand,
            }
            local hasTwoHandWeapon = slotInfo[redundancySlots.Twohand] and slotInfo[redundancySlots.Twohand].itemLevel >= achievement.display
            local hasSingleHandSet = false

            for firstIndex = 1, #singleHandSlotIds - 1 do
                local firstSlot = slotInfo[singleHandSlotIds[firstIndex]]

                if firstSlot and firstSlot.itemLevel >= achievement.display then
                    for secondIndex = firstIndex + 1, #singleHandSlotIds do
                        local secondSlot = slotInfo[singleHandSlotIds[secondIndex]]

                        if secondSlot and secondSlot.itemLevel >= achievement.display then
                            hasSingleHandSet = true
                            break
                        end
                    end
                end

                if hasSingleHandSet then
                    break
                end
            end

            if not (hasTwoHandWeapon or hasSingleHandSet) then
                local weaponOptions = {}

                if slotInfo[redundancySlots.Twohand] then
                    local costs, costTotal = calculateCrestCosts(slotInfo[redundancySlots.Twohand].itemLevel, achievement.display, highestAccountAchievementDisplay)
                    table.insert(weaponOptions, {
                        label = slotInfo[redundancySlots.Twohand].name,
                        itemLevel = slotInfo[redundancySlots.Twohand].itemLevel,
                        costs = costs,
                        total = costTotal,
                        isTwoHand = true,
                    })
                end

                for firstIndex = 1, #singleHandSlotIds - 1 do
                    local firstSlotId = singleHandSlotIds[firstIndex]
                    local firstSlot = slotInfo[firstSlotId]

                    if firstSlot then
                        for secondIndex = firstIndex + 1, #singleHandSlotIds do
                            local secondSlotId = singleHandSlotIds[secondIndex]
                            local secondSlot = slotInfo[secondSlotId]

                            if secondSlot then
                                local firstCosts, firstTotal = calculateCrestCosts(firstSlot.itemLevel, achievement.display, highestAccountAchievementDisplay)
                                local secondCosts, secondTotal = calculateCrestCosts(secondSlot.itemLevel, achievement.display, highestAccountAchievementDisplay)
                                local combinedCosts = {}
                                mergeCrestCosts(combinedCosts, firstCosts)
                                mergeCrestCosts(combinedCosts, secondCosts)

                                table.insert(weaponOptions, {
                                    label = firstSlot.name .. " + " .. secondSlot.name,
                                    costs = combinedCosts,
                                    total = firstTotal + secondTotal,
                                    isTwoHand = false,
                                })
                            end
                        end
                    end
                end

                table.sort(weaponOptions, function(a, b)
                    if a.total == b.total then
                        if a.isTwoHand ~= b.isTwoHand then
                            return a.isTwoHand
                        end

                        return a.label < b.label
                    end

                    return a.total < b.total
                end)

                if weaponOptions[1] then
                    table.insert(requirements, {
                        sortId = 12,
                        label = weaponOptions[1].label,
                        itemLevel = weaponOptions[1].itemLevel,
                        costs = weaponOptions[1].costs,
                        total = weaponOptions[1].total,
                    })

                    mergeCrestCosts(totalCosts, weaponOptions[1].costs)
                    totalCrests = totalCrests + weaponOptions[1].total
                end
            end

            table.sort(requirements, function(a, b)
                return a.sortId < b.sortId
            end)

            for _, requirement in ipairs(requirements) do
                local crestText = formatCrestCosts(requirement.costs, requirement.total)

                if requirement.itemLevel then
                    print(requirement.itemLevel, requirement.label, "-", crestText)
                else
                    print(requirement.label, "-", crestText)
                end
            end

            if totalCrests > 0 then
                print("Total - " .. formatCrestCosts(totalCosts, totalCrests))
            end

            return
        end
    end
end
