local _, AngusUI = ...

local lootSpecToastWidth = 280
local lootSpecToastMinHeight = 84
local lootSpecToastPadding = 16

local function EnsureBackdrop(frame)
    if frame.backdrop then
        return
    end

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:SetAllPoints()
    backdrop:SetFrameLevel(math.max(frame:GetFrameLevel() - 1, 0))
    backdrop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    backdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
    backdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
    frame.backdrop = backdrop
end

local function GetCurrentLootSpecializationName()
    local lootSpecializationID = GetLootSpecialization and GetLootSpecialization() or 0
    if lootSpecializationID > 0 and GetSpecializationInfoByID then
        local _, specializationName = GetSpecializationInfoByID(lootSpecializationID)
        if specializationName then
            return specializationName
        end
    end

    local specialization = GetSpecialization and GetSpecialization()
    if specialization and GetSpecializationInfo then
        local _, specializationName = GetSpecializationInfo(specialization)
        return specializationName
    end

    return nil
end

local function NormalizeTooltipTitle(text)
    if type(text) ~= "string" then
        return nil
    end

    text = gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = gsub(text, "|r", "")
    return strlower(text)
end

local greatVaultTooltipTitles = {
    ["the great vault"] = true,
}

if type(WEEKLY_REWARDS_TITLE) == "string" then
    greatVaultTooltipTitles[NormalizeTooltipTitle(WEEKLY_REWARDS_TITLE)] = true
end

local function IsHoveringGreatVault()
    if not GameTooltip or not GameTooltip:IsShown() then
        return false
    end

    local tooltipName = GameTooltip:GetName()
    if not tooltipName then
        return false
    end

    local title = _G[tooltipName .. "TextLeft1"]
    local titleText = title and title:GetText() or nil
    return greatVaultTooltipTitles[NormalizeTooltipTitle(titleText)] == true
end

local function EnsureLootSpecToast(self)
    if self.greatVaultLootSpecToast then
        return self.greatVaultLootSpecToast
    end

    local toast = CreateFrame("Frame", "AngusUIGreatVaultLootSpecToast", UIParent, "BackdropTemplate")
    toast:SetSize(lootSpecToastWidth, lootSpecToastMinHeight)
    toast:SetPoint("CENTER", UIParent, "CENTER", 0, 220)
    toast:SetFrameStrata("DIALOG")
    toast:SetClampedToScreen(true)
    toast:EnableMouse(false)
    toast:Hide()
    EnsureBackdrop(toast)

    toast.title = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    toast.title:SetPoint("TOPLEFT", toast, "TOPLEFT", lootSpecToastPadding, -lootSpecToastPadding)
    toast.title:SetJustifyH("LEFT")
    toast.title:SetText("The Great Vault")

    toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    toast.text:SetPoint("TOPLEFT", toast.title, "BOTTOMLEFT", 0, -8)
    toast.text:SetPoint("BOTTOMRIGHT", toast, "BOTTOMRIGHT", -lootSpecToastPadding, lootSpecToastPadding)
    toast.text:SetJustifyH("LEFT")
    toast.text:SetJustifyV("TOP")

    self.greatVaultLootSpecToast = toast

    return toast
end

local function EnsureGreatVaultHoverWatcher(self)
    if self.greatVaultHoverWatcher then
        return
    end

    local elapsedSinceUpdate = 0
    local watcher = CreateFrame("Frame")
    watcher:SetScript("OnUpdate", function(_, elapsed)
        elapsedSinceUpdate = elapsedSinceUpdate + elapsed
        if elapsedSinceUpdate < 0.1 then
            return
        end

        elapsedSinceUpdate = 0
        local hoveringGreatVault = IsHoveringGreatVault()
        if hoveringGreatVault then
            local lootSpecName = GetCurrentLootSpecializationName()
            if lootSpecName then
                if lootSpecName ~= self.greatVaultLootSpecName or not self.greatVaultLootSpecToastShown then
                    self.greatVaultLootSpecName = lootSpecName
                    self:ShowGreatVaultLootSpecToast()
                end
                return
            end
        end

        if self.greatVaultLootSpecToastShown then
            self.greatVaultLootSpecName = nil
            self:HideGreatVaultLootSpecToast()
        end
    end)

    self.greatVaultHoverWatcher = watcher
end

function AngusUI:ShowGreatVaultLootSpecToast()
    local lootSpecName = GetCurrentLootSpecializationName()
    if not lootSpecName then
        return
    end

    local toast = EnsureLootSpecToast(self)
    toast.text:SetText("Loot Spec: |cff58c4dd" .. lootSpecName .. "|r")
    toast:Show()
    self.greatVaultLootSpecToastShown = true
end

function AngusUI:HideGreatVaultLootSpecToast()
    if self.greatVaultLootSpecToast then
        self.greatVaultLootSpecToast:Hide()
    end

    self.greatVaultLootSpecToastShown = false
end

function AngusUI:GreatVaultInit()
    if self.greatVaultInitialized then
        return
    end

    self.greatVaultInitialized = true
    self.greatVaultLootSpecToastShown = false
    EnsureGreatVaultHoverWatcher(self)
end
