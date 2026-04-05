local _, AngusUI = ...

local OVERLAY_ALPHA = 0.42
local registeredButtons = {}

local function ActionHasRangeRequirements(action)
    if C_ActionBar and C_ActionBar.HasRangeRequirements then
        return C_ActionBar.HasRangeRequirements(action)
    end

    return ActionHasRange and ActionHasRange(action)
end

local function IsActionOutOfRange(action)
    if C_ActionBar and C_ActionBar.IsActionInRange then
        return C_ActionBar.IsActionInRange(action) == false
    end

    return IsActionInRange(action) == false
end

local function GetButtonIcon(button)
    return button and (button.icon or button.Icon or (button.GetName and _G[button:GetName() .. "Icon"]))
end

local function GetRangeOverlay(button)
    local icon = GetButtonIcon(button)
    if not icon then
        return nil
    end

    local overlay = button.AngusUIRangeOverlay
    if not overlay then
        overlay = button:CreateTexture(nil, "ARTWORK", nil, 1)
        overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
        overlay:SetPoint("TOPLEFT", icon, 2, -2)
        overlay:SetPoint("BOTTOMRIGHT", icon, -2, 2)
        overlay:SetVertexColor(1, 0, 0, OVERLAY_ALPHA)
        overlay:Hide()
        button.AngusUIRangeOverlay = overlay
    end

    return overlay
end

local function ApplyRangeVisual(button)
    local outOfRange = button.AngusUIRangeChecks and button.AngusUIOutOfRange
    local overlay = GetRangeOverlay(button)
    if not overlay then
        return
    end

    if outOfRange then
        overlay:Show()
    else
        overlay:Hide()
    end

    local icon = GetButtonIcon(button)
    if not icon or not icon.SetDesaturated then
        return
    end

    if outOfRange then
        icon:SetDesaturated(true)
        button.AngusUIRangeDesaturated = true
    elseif button.AngusUIRangeDesaturated then
        icon:SetDesaturated(false)
        button.AngusUIRangeDesaturated = nil
    end
end

local function ResetRangeState(button)
    if not button then
        return
    end

    button.AngusUIRangeChecks = false
    button.AngusUIOutOfRange = false
end

local function RefreshRangeOverlay(button)
    if not registeredButtons[button] then
        return
    end

    if not button or not button:IsShown() then
        return
    end

    local action = button.action
    if not action or action <= 0 or not HasAction(action) then
        ResetRangeState(button)
        ApplyRangeVisual(button)
        return
    end

    local checksRange = ActionHasRangeRequirements(action)
    button.AngusUIRangeChecks = checksRange
    button.AngusUIOutOfRange = checksRange and IsActionOutOfRange(action)
    ApplyRangeVisual(button)
end

local function UpdateRangeOverlay(button, checksRange, inRange)
    if not registeredButtons[button] then
        return
    end

    if checksRange == nil or inRange == nil then
        RefreshRangeOverlay(button)
        return
    end

    button.AngusUIRangeChecks = checksRange
    button.AngusUIOutOfRange = checksRange and not inRange
    ApplyRangeVisual(button)
end

local function RegisterButton(button)
    if registeredButtons[button] then
        return
    end

    button:HookScript("OnShow", RefreshRangeOverlay)
    hooksecurefunc(button, "UpdateAction", RefreshRangeOverlay)

    registeredButtons[button] = true
    RefreshRangeOverlay(button)
end

function AngusUI:EnableActionRangeOverlay()
    if self.actionRangeOverlayEnabled then
        return
    end

    if not ActionBarButtonEventsFrame or not ActionBarButtonEventsFrame.ForEachFrame then
        return
    end

    self.actionRangeOverlayEnabled = true

    ActionBarButtonEventsFrame:ForEachFrame(RegisterButton)
    hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
        RegisterButton(button)
    end)

    if type(ActionButton_UpdateRangeIndicator) == "function" then
        hooksecurefunc("ActionButton_UpdateRangeIndicator", UpdateRangeOverlay)
    end

    C_Timer.After(0, function()
        if not ActionBarButtonEventsFrame or not ActionBarButtonEventsFrame.ForEachFrame then
            return
        end

        ActionBarButtonEventsFrame:ForEachFrame(RefreshRangeOverlay)
    end)
end
