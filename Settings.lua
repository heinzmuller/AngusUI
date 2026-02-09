local _, AngusUI = ...

local defaultFriendsExtraWidth = 50
local defaultFriendsExtraHeight = 300
local defaultThemeEnabled = true
local defaultThemeDarkness = 0.25
local defaultThemeButtonDarkness = 0.5
local defaultThemeDesaturate = true

function AngusUI:SettingsInit()
    if self.settingsInitialized then
        return
    end

    self.settingsInitialized = true

    AngusUIDB = AngusUIDB or {}
    AngusUIDB.friendsFrameExtraWidth = AngusUIDB.friendsFrameExtraWidth or defaultFriendsExtraWidth
    AngusUIDB.friendsFrameExtraHeight = AngusUIDB.friendsFrameExtraHeight or defaultFriendsExtraHeight
    if AngusUIDB.themeEnabled == nil then
        AngusUIDB.themeEnabled = defaultThemeEnabled
    end
    AngusUIDB.themeDarkness = AngusUIDB.themeDarkness or defaultThemeDarkness
    AngusUIDB.themeButtonDarkness = AngusUIDB.themeButtonDarkness or defaultThemeButtonDarkness
    if AngusUIDB.themeDesaturate == nil then
        AngusUIDB.themeDesaturate = defaultThemeDesaturate
    end

    local category = Settings.RegisterVerticalLayoutCategory("AngusUI")

    local themeEnabledSetting = Settings.RegisterAddOnSetting(
        category,
        "themeEnabled",
        "themeEnabled",
        AngusUIDB,
        "boolean",
        "Theme Tinting",
        AngusUIDB.themeEnabled
    )

    local themeEnabledControl = Settings.CreateCheckbox(category, themeEnabledSetting, "Enable UI tinting")

    local themeDarknessSetting = Settings.RegisterAddOnSetting(
        category,
        "themeDarkness",
        "themeDarkness",
        AngusUIDB,
        "number",
        "Theme Darkness",
        AngusUIDB.themeDarkness
    )

    local themeButtonDarknessSetting = Settings.RegisterAddOnSetting(
        category,
        "themeButtonDarkness",
        "themeButtonDarkness",
        AngusUIDB,
        "number",
        "Action Button Darkness",
        AngusUIDB.themeButtonDarkness
    )

    local themeDesaturateSetting = Settings.RegisterAddOnSetting(
        category,
        "themeDesaturate",
        "themeDesaturate",
        AngusUIDB,
        "boolean",
        "Theme Desaturate",
        AngusUIDB.themeDesaturate
    )

    Settings.CreateCheckbox(category, themeDesaturateSetting, "Grayscale textures")

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

    UpdateThemeEnabled()

    local widthSetting = Settings.RegisterAddOnSetting(
        category,
        "friendsFrameExtraWidth",
        "friendsFrameExtraWidth",
        AngusUIDB,
        "number",
        "Friends Frame Extra Width",
        AngusUIDB.friendsFrameExtraWidth
    )

    local heightSetting = Settings.RegisterAddOnSetting(
        category,
        "friendsFrameExtraHeight",
        "friendsFrameExtraHeight",
        AngusUIDB,
        "number",
        "Friends Frame Extra Height",
        AngusUIDB.friendsFrameExtraHeight
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
    AngusUI:ApplyTheme()
end
