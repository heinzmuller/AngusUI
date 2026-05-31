-- Captures milestone screenshots automatically so memorable character progress is preserved.
local _, AngusUI = ...

local levelUpScreenshotDelay = 1
local achievementScreenshotDelay = 1
local collectionScreenshotDelay = 1
local mythicPlusCompletionScreenshotDelay = 2
local screenshotWatcher = CreateFrame("Frame")

-- Delays screenshots so important UI popups are captured cleanly.
local function QueueScreenshot(delay)
    C_Timer.After(delay, function()
        Screenshot()
    end)
end

screenshotWatcher:RegisterEvent("PLAYER_LEVEL_UP")
screenshotWatcher:RegisterEvent("ACHIEVEMENT_EARNED")
screenshotWatcher:RegisterEvent("NEW_MOUNT_ADDED")
screenshotWatcher:RegisterEvent("NEW_PET_ADDED")
screenshotWatcher:RegisterEvent("CHALLENGE_MODE_COMPLETED")
screenshotWatcher:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        AngusUI:TakeLevelUpScreenshot(...)
    elseif event == "ACHIEVEMENT_EARNED" then
        AngusUI:TakeAchievementScreenshot(...)
    elseif event == "NEW_MOUNT_ADDED" then
        AngusUI:TakeMountScreenshot(...)
    elseif event == "NEW_PET_ADDED" then
        AngusUI:TakePetScreenshot(...)
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        AngusUI:TakeMythicPlusCompletionScreenshot()
    end
end)

-- Takes a screenshot when the player levels up.
function AngusUI:TakeLevelUpScreenshot(newLevel)
    if type(newLevel) ~= "number" or newLevel <= 0 then
        return
    end

    QueueScreenshot(levelUpScreenshotDelay)
end

-- Takes a screenshot when an achievement is earned.
function AngusUI:TakeAchievementScreenshot(achievementID)
    if type(achievementID) ~= "number" or achievementID <= 0 then
        return
    end

    QueueScreenshot(achievementScreenshotDelay)
end

-- Takes a screenshot when a new mount is learned.
function AngusUI:TakeMountScreenshot(mountID)
    if type(mountID) ~= "number" or mountID <= 0 then
        return
    end

    QueueScreenshot(collectionScreenshotDelay)
end

-- Takes a screenshot when a new pet is learned.
function AngusUI:TakePetScreenshot(petID)
    if petID == nil or petID == "" then
        return
    end

    QueueScreenshot(collectionScreenshotDelay)
end

-- Takes a screenshot when a Mythic+ run finishes.
function AngusUI:TakeMythicPlusCompletionScreenshot()
    local info = C_ChallengeMode and C_ChallengeMode.GetChallengeCompletionInfo and C_ChallengeMode.GetChallengeCompletionInfo()
    if not info or info.practiceRun then
        return
    end

    QueueScreenshot(mythicPlusCompletionScreenshotDelay)
end
