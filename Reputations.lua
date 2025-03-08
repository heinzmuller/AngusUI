local addonName, AngusUI = ...

local reputations = {}

reputations[2902] = { 82946, 81794, 79683, 78564, 79565, 79029, 79266, 81559, 80378, 80082, 81713, 79510, 82814, 83153, 79682, 81672, 83162, 78706, 79944, 80407, 83331, 80516, 82144, 79371 }

function AngusUI:Reputations()
    for _, questId in ipairs(reputations[2902]) do
        local completed = C_QuestLog.IsQuestFlaggedCompleted(questId)

        if (completed == false) then
            local title = C_QuestLog.GetTitleForQuestID(questId)
            if (title == nil) then
                print(questId)
            else
                print(title)
            end
        end
    end
end
