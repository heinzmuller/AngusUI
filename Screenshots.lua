local _, AngusUI = ...

local levelUpScreenshotDelay = 1
local achievementScreenshotDelay = 1
local collectionScreenshotDelay = 1

local function QueueScreenshot(delay)
    C_Timer.After(delay, function()
        Screenshot()
    end)
end

function AngusUI:TakeLevelUpScreenshot(newLevel)
    if type(newLevel) ~= "number" or newLevel <= 0 then
        return
    end

    QueueScreenshot(levelUpScreenshotDelay)
end

function AngusUI:TakeAchievementScreenshot(achievementID)
    if type(achievementID) ~= "number" or achievementID <= 0 then
        return
    end

    QueueScreenshot(achievementScreenshotDelay)
end

function AngusUI:TakeMountScreenshot(mountID)
    if type(mountID) ~= "number" or mountID <= 0 then
        return
    end

    QueueScreenshot(collectionScreenshotDelay)
end

function AngusUI:TakePetScreenshot(petID)
    if petID == nil or petID == "" then
        return
    end

    QueueScreenshot(collectionScreenshotDelay)
end
