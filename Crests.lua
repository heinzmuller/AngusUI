local _, AngusUI = ...

local crestQuests = {
    ["Nerub-ar Palace"] = 82141,
    ["Hallowfall"] = 82407,
    ["Isle of Dorn"] = 82365,
    ["The Ringing Deeps"] = 82384,
    ["Azj-Kahet"] = 82446,
    ["Undermine"] = 86204,
}

function AngusUI:Crests()
    for zone, questId in pairs(crestQuests) do
        local completed = C_QuestLog.IsQuestFlaggedCompleted(questId)
        C_TooltipInfo.GetBagItem(bagIndex, slotIndex)

        if (completed == true) then
            print("\124cff00FF00" .. zone .. "\124r")
        end

        if (completed == false) then
            print("\124cffFF0000" .. zone .. "\124r")
        end
    end
end
