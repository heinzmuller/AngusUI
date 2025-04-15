local _, AngusUI = ...

local delveIsActive = nil
local delveControl = nil

function AngusUI:StartDelveSpeedrun()
    if (delveIsActive ~= nil) then
        return
    end

    print("Starting the delve speedrun =]")
    delveIsActive = time()
end

function AngusUI:StopDelveSpeedrun()
    if (delveIsActive == nil) then
        return
    end

    print("Stopping the delve speedrun =]")

    local elapsed = time() - delveIsActive

    print("You completed the delve speedrun in " .. elapsed .. " seconds")
    delveIsActive = false
end

function AngusUI:Delves()
    if (delveControl ~= nil) then
        return
    end

    -- Create the frame
    local frame = CreateFrame("Frame", "DelveSpeedrunFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 100)  -- Width, Height
    frame:SetPoint("CENTER") -- Position in the center of the screen
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", function()
        delveControl = nil
    end)

    delveControl = frame

    -- Title text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    title:SetText("Delve Speedrun")

    -- Button to hide the frame
    local cancelButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    cancelButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    cancelButton:SetSize(120, 30) -- Width, Height
    cancelButton:SetText("Stop")
    cancelButton:SetNormalFontObject("GameFontNormal")
    cancelButton:SetHighlightFontObject("GameFontHighlight")
    cancelButton:SetScript("OnClick", function()
        frame:Hide()
        AngusUI:StopDelveSpeedrun()
    end)

    -- Button to hide the frame and start the speedrun
    local startButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    startButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    startButton:SetSize(120, 30) -- Width, Height
    startButton:SetText("Start")
    startButton:SetNormalFontObject("GameFontNormal")
    startButton:SetHighlightFontObject("GameFontHighlight")
    startButton:SetScript("OnClick", function()
        AngusUI:StartDelveSpeedrun()
        startButton:Hide()
        cancelButton:Show()
    end)

    -- Show the frame
    cancelButton:Hide()
    frame:Show()
end

local frame = CreateFrame("FRAME", "AngusUIDelveSpeedrunning");
frame:RegisterEvent("CHAT_MSG_MONSTER_SAY");
local function eventHandler(self, event, text, playerName, ...)
    -- event is CHAT_MSG_MONSTER_SAY
    -- make event typed please
    if (playerName == "Brann Bronzebeard") then
        -- AngusUI:Delve()
    end
end
frame:SetScript("OnEvent", eventHandler);
