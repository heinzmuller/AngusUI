local _, AngusUI = ...

local undermineSearchURL = "https://undermine.exchange/#%s-%s/search/%s"
local recipePrefixesByProfession = {
    [Enum.Profession.Alchemy] = "Recipe: ",
    [Enum.Profession.Blacksmithing] = "Plans: ",
    [Enum.Profession.Cooking] = "Recipe: ",
    [Enum.Profession.Enchanting] = "Formula: ",
    [Enum.Profession.Engineering] = "Schematic: ",
    [Enum.Profession.Inscription] = "Technique: ",
    [Enum.Profession.Jewelcrafting] = "Design: ",
    [Enum.Profession.Leatherworking] = "Pattern: ",
    [Enum.Profession.Tailoring] = "Pattern: ",
}

local function UrlEncode(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end

    return (gsub(text, "([^%w%-_%.~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end))
end

local function GetRegionSlug()
    local regionName = GetCurrentRegionName and GetCurrentRegionName() or nil
    if type(regionName) ~= "string" or regionName == "" then
        return nil
    end

    return strlower(regionName)
end

local function GetRealmSlug()
    local realmName = GetNormalizedRealmName and GetNormalizedRealmName() or nil
    if type(realmName) ~= "string" or realmName == "" then
        realmName = GetRealmName and GetRealmName() or nil
    end

    if type(realmName) ~= "string" or realmName == "" then
        return nil
    end

    realmName = gsub(realmName, "%s+", "")
    realmName = gsub(realmName, "'", "")
    return strlower(realmName)
end

local function BuildRecipeSearchText(recipeInfo)
    if not recipeInfo or type(recipeInfo.name) ~= "string" or recipeInfo.name == "" then
        return nil
    end

    local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID and C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
    local prefix = professionInfo and professionInfo.profession and recipePrefixesByProfession[professionInfo.profession] or nil
    if prefix then
        return prefix .. recipeInfo.name
    end

    return recipeInfo.name
end

local function BuildUndermineSearchURL(recipeInfo)
    local searchText = BuildRecipeSearchText(recipeInfo)
    local encodedRecipeName = UrlEncode(searchText)
    local regionSlug = GetRegionSlug()
    local realmSlug = GetRealmSlug()
    if not encodedRecipeName or not regionSlug or not realmSlug then
        return nil
    end

    return string.format(undermineSearchURL, regionSlug, realmSlug, encodedRecipeName)
end

local function ShowCopyDialog(dialog, title, url)
    if not dialog or type(url) ~= "string" or url == "" then
        return
    end

    dialog.url = url
    dialog.title:SetText(title or "Undermine Search URL")
    dialog.urlBox:SetText(url)
    dialog:Show()
    dialog.urlBox:SetFocus()
    dialog.urlBox:HighlightText()
end

local function CreateCopyDialog(parent)
    local dialog = CreateFrame("Frame", "AngusUIProfessionRecipeURLDialog", parent, "BasicFrameTemplateWithInset")
    dialog:SetSize(560, 120)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetToplevel(true)
    dialog:SetClampedToScreen(true)
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
    dialog:Hide()

    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog.title:SetPoint("TOP", dialog, "TOP", 0, -10)
    dialog.title:SetText("Undermine Search URL")

    dialog.urlBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    dialog.urlBox:SetAutoFocus(false)
    dialog.urlBox:SetSize(490, 20)
    dialog.urlBox:SetPoint("TOP", dialog, "TOP", 0, -42)
    dialog.urlBox:SetFontObject("GameFontHighlightSmall")
    dialog.urlBox:SetTextInsets(4, 4, 0, 0)
    dialog.urlBox:SetMaxLetters(2048)
    dialog.urlBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:GetParent():Hide()
    end)
    dialog.urlBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput and dialog.url then
            self:SetText(dialog.url)
            self:HighlightText()
        end
    end)

    dialog.hint = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dialog.hint:SetPoint("TOP", dialog.urlBox, "BOTTOM", 0, -10)
    dialog.hint:SetText("Press Ctrl-C to copy, then Escape to close")
    dialog.hint:SetTextColor(0.8, 0.8, 0.8)

    dialog:SetScript("OnShow", function(self)
        self.urlBox:SetFocus()
        self.urlBox:HighlightText()
    end)

    return dialog
end

local function EnsureCopyButton(schematicForm)
    if schematicForm.angusRecipeSearchButton then
        return schematicForm.angusRecipeSearchButton
    end

    local button = CreateFrame("Button", nil, schematicForm, "UIPanelButtonTemplate")
    button:SetSize(84, 20)
    button:SetPoint("LEFT", schematicForm.RecipeSourceButton, "RIGHT", 8, 0)
    button:SetText("Copy URL")
    button:Hide()

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_AddNormalLine(GameTooltip, "Copy Undermine Exchange search URL")
        GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText or "Uses the current recipe name and realm")
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetScript("OnClick", function(self)
        if not self.url then
            return
        end

        ShowCopyDialog(AngusUI.professionRecipeURLDialog, "Undermine Search URL", self.url)
    end)

    schematicForm.angusRecipeSearchButton = button
    return button
end

local function RefreshCopyButton(schematicForm, recipeInfo, isRecraftOverride)
    if not schematicForm or not schematicForm.RecipeSourceButton then
        return
    end

    local button = EnsureCopyButton(schematicForm)
    button:Hide()
    button.url = nil
    button.tooltipText = nil

    if not recipeInfo or recipeInfo.learned or isRecraftOverride or schematicForm.isInspection then
        return
    end

    if not schematicForm.RecipeSourceButton:IsShown() then
        return
    end

    local url = BuildUndermineSearchURL(recipeInfo)
    if not url then
        return
    end

    button.url = url
    button.tooltipText = BuildRecipeSearchText(recipeInfo) or recipeInfo.name
    button:Show()
end

function AngusUI:ProfessionLinksInit()
    if self.professionLinksInitialized or not ProfessionsRecipeSchematicFormMixin then
        return
    end

    self.professionLinksInitialized = true
    self.professionRecipeURLDialog = self.professionRecipeURLDialog or CreateCopyDialog(UIParent)

    hooksecurefunc(ProfessionsRecipeSchematicFormMixin, "Init", function(schematicForm, recipeInfo, isRecraftOverride)
        RefreshCopyButton(schematicForm, recipeInfo, isRecraftOverride)
    end)

    if ProfessionsFrame and ProfessionsFrame.CraftingPage and ProfessionsFrame.CraftingPage.SchematicForm then
        local schematicForm = ProfessionsFrame.CraftingPage.SchematicForm
        local recipeInfo = schematicForm.GetRecipeInfo and schematicForm:GetRecipeInfo() or nil
        RefreshCopyButton(schematicForm, recipeInfo)
    end
end
