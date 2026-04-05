local _, AngusUI = ...

local defaultFriendsExtraWidth = 50
local defaultFriendsExtraHeight = 300
local defaultThemeEnabled = true
local defaultThemeDarkness = 0.25
local defaultThemeButtonDarkness = 0.5
local defaultThemeDesaturate = true
local defaultWorldQuestRewardIcons = true
local defaultWorldQuestUpgradeArrow = true
local defaultHidePartyLabel = true

function AngusUI:GetSettingsDB()
    AngusUIDB = AngusUIDB or {}
    AngusUIDB.settings = AngusUIDB.settings or {}

    return AngusUIDB.settings
end

function AngusUI:SettingsInit()
    if self.settingsInitialized then
        return
    end

    self.settingsInitialized = true

    local settingsDB = self:GetSettingsDB()

    settingsDB.friendsFrameExtraWidth = settingsDB.friendsFrameExtraWidth or defaultFriendsExtraWidth
    settingsDB.friendsFrameExtraHeight = settingsDB.friendsFrameExtraHeight or defaultFriendsExtraHeight
    if settingsDB.themeEnabled == nil then
        settingsDB.themeEnabled = defaultThemeEnabled
    end
    settingsDB.themeDarkness = settingsDB.themeDarkness or defaultThemeDarkness
    settingsDB.themeButtonDarkness = settingsDB.themeButtonDarkness or defaultThemeButtonDarkness
    if settingsDB.themeDesaturate == nil then
        settingsDB.themeDesaturate = defaultThemeDesaturate
    end
    if settingsDB.worldQuestRewardIcons == nil then
        settingsDB.worldQuestRewardIcons = defaultWorldQuestRewardIcons
    end
    if settingsDB.worldQuestUpgradeArrow == nil then
        settingsDB.worldQuestUpgradeArrow = defaultWorldQuestUpgradeArrow
    end
    if settingsDB.hidePartyLabel == nil then
        settingsDB.hidePartyLabel = defaultHidePartyLabel
    end

    local category = Settings.RegisterVerticalLayoutCategory("AngusUI")

    local themeEnabledSetting = Settings.RegisterAddOnSetting(
        category,
        "themeEnabled",
        "themeEnabled",
        settingsDB,
        "boolean",
        "Theme Tinting",
        settingsDB.themeEnabled
    )

    local themeEnabledControl = Settings.CreateCheckbox(category, themeEnabledSetting, "Enable UI tinting")

    local themeDarknessSetting = Settings.RegisterAddOnSetting(
        category,
        "themeDarkness",
        "themeDarkness",
        settingsDB,
        "number",
        "Theme Darkness",
        settingsDB.themeDarkness
    )

    local themeButtonDarknessSetting = Settings.RegisterAddOnSetting(
        category,
        "themeButtonDarkness",
        "themeButtonDarkness",
        settingsDB,
        "number",
        "Action Button Darkness",
        settingsDB.themeButtonDarkness
    )

    local themeDesaturateSetting = Settings.RegisterAddOnSetting(
        category,
        "themeDesaturate",
        "themeDesaturate",
        settingsDB,
        "boolean",
        "Theme Desaturate",
        settingsDB.themeDesaturate
    )

    local worldQuestRewardIconsSetting = Settings.RegisterAddOnSetting(
        category,
        "worldQuestRewardIcons",
        "worldQuestRewardIcons",
        settingsDB,
        "boolean",
        "World Quest Reward Icons",
        settingsDB.worldQuestRewardIcons
    )

    local worldQuestUpgradeArrowSetting = Settings.RegisterAddOnSetting(
        category,
        "worldQuestUpgradeArrow",
        "worldQuestUpgradeArrow",
        settingsDB,
        "boolean",
        "World Quest Upgrade Arrow",
        settingsDB.worldQuestUpgradeArrow
    )

    local hidePartyLabelSetting = Settings.RegisterAddOnSetting(
        category,
        "hidePartyLabel",
        "hidePartyLabel",
        settingsDB,
        "boolean",
        "Hide Party Label",
        settingsDB.hidePartyLabel
    )

    Settings.CreateCheckbox(category, themeDesaturateSetting, "Grayscale textures")
    Settings.CreateCheckbox(category, worldQuestRewardIconsSetting, "Replace world quest icons with reward icons")
    Settings.CreateCheckbox(category, worldQuestUpgradeArrowSetting, "Show upgrade arrow for better gear rewards")
    Settings.CreateCheckbox(category, hidePartyLabelSetting, "Hide party frame label")

    local themeOptions = Settings.CreateSliderOptions and Settings.CreateSliderOptions(0, 1, 0.05)
        or { min = 0, max = 1, step = 0.05 }

    if themeOptions.SetLabelFormatter and MinimalSliderWithSteppersMixin then
        themeOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%.2f", value)
        end)
    end

    Settings.CreateSlider(category, themeDarknessSetting, themeOptions)
    Settings.CreateSlider(category, themeButtonDarknessSetting, themeOptions)

    local function UpdateThemeEnabled()
        AngusUI:ApplyTheme()
        local enabled = themeEnabledSetting:GetValue()

        if themeDarknessSetting.SetEnabled then
            themeDarknessSetting:SetEnabled(enabled)
        end

        if themeButtonDarknessSetting.SetEnabled then
            themeButtonDarknessSetting:SetEnabled(enabled)
        end

        if themeDesaturateSetting.SetEnabled then
            themeDesaturateSetting:SetEnabled(enabled)
        end
    end

    themeEnabledSetting:SetValueChangedCallback(UpdateThemeEnabled)
    themeDarknessSetting:SetValueChangedCallback(function()
        AngusUI:ApplyTheme()
    end)
    themeButtonDarknessSetting:SetValueChangedCallback(function()
        AngusUI:ApplyTheme()
    end)
    themeDesaturateSetting:SetValueChangedCallback(function()
        AngusUI:ApplyTheme()
    end)
    worldQuestRewardIconsSetting:SetValueChangedCallback(function()
        AngusUI:QueueWorldQuestIconsRefresh(true)
    end)
    worldQuestUpgradeArrowSetting:SetValueChangedCallback(function()
        AngusUI:QueueWorldQuestIconsRefresh(true)
    end)
    hidePartyLabelSetting:SetValueChangedCallback(function()
        AngusUI:PartyFrames()
    end)

    UpdateThemeEnabled()

    local widthSetting = Settings.RegisterAddOnSetting(
        category,
        "friendsFrameExtraWidth",
        "friendsFrameExtraWidth",
        settingsDB,
        "number",
        "Friends Frame Extra Width",
        settingsDB.friendsFrameExtraWidth
    )

    local heightSetting = Settings.RegisterAddOnSetting(
        category,
        "friendsFrameExtraHeight",
        "friendsFrameExtraHeight",
        settingsDB,
        "number",
        "Friends Frame Extra Height",
        settingsDB.friendsFrameExtraHeight
    )

    local widthOptions = Settings.CreateSliderOptions and Settings.CreateSliderOptions(0, 300, 1)
        or { min = 0, max = 300, step = 1 }
    local heightOptions = Settings.CreateSliderOptions and Settings.CreateSliderOptions(0, 600, 1)
        or { min = 0, max = 600, step = 1 }

    if widthOptions.SetLabelFormatter and MinimalSliderWithSteppersMixin then
        widthOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%d", value)
        end)
    end

    if heightOptions.SetLabelFormatter and MinimalSliderWithSteppersMixin then
        heightOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%d", value)
        end)
    end

    Settings.CreateSlider(category, widthSetting, widthOptions)
    Settings.CreateSlider(category, heightSetting, heightOptions)

    widthSetting:SetValueChangedCallback(function()
        AngusUI:FriendsFrame()
    end)

    heightSetting:SetValueChangedCallback(function()
        AngusUI:FriendsFrame()
    end)

    Settings.RegisterAddOnCategory(category)

    AngusUI:FriendsFrame()
    AngusUI:PartyFrames()
    AngusUI:ApplyTheme()
    AngusUI:QueueWorldQuestIconsRefresh(true)
end
