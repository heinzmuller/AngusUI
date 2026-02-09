local _, AngusUI = ...

local defaultThemeEnabled = true
local defaultThemeDarkness = 0.4
local defaultThemeButtonDarkness = 0.4

function AngusUI:Theme(forceReset)
    local enabled = defaultThemeEnabled
    local darkness = defaultThemeDarkness
    local buttonDarkness = defaultThemeButtonDarkness
    local desaturateEnabled = true

    if AngusUIDB then
        if AngusUIDB.themeEnabled ~= nil then
            enabled = AngusUIDB.themeEnabled
        end

        darkness = AngusUIDB.themeDarkness or darkness
        buttonDarkness = AngusUIDB.themeButtonDarkness or buttonDarkness
        if AngusUIDB.themeDesaturate ~= nil then
            desaturateEnabled = AngusUIDB.themeDesaturate
        end
    end

    if not enabled and not forceReset then
        return
    end

    local textureValue = forceReset and 1 or darkness
    local buttonValue = forceReset and 1 or buttonDarkness
    local desaturate = (not forceReset) and desaturateEnabled
    -- Darken menu bar end caps
    local endCaps = MainActionBar and MainActionBar.EndCaps
    if not endCaps and MainMenuBar then
        endCaps = MainMenuBar.EndCaps
    end

    if endCaps then
        for _, v in pairs(
            {
                endCaps.LeftEndCap,
                endCaps.RightEndCap,
            }
        ) do
            if v then
                if v.SetDesaturation then
                    v:SetDesaturation(desaturate and 1 or 0)
                end
                v:SetVertexColor(textureValue, textureValue, textureValue)
            end
        end
    end

    -- Darken various UI textures
    for _, v in pairs(
        {
            MainActionBar and MainActionBar.BorderArt,
            MainMenuBar and MainMenuBar.BorderArt,
            MinimapCompassTexture,
            PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.FrameTexture,
            PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
            TargetFrame and TargetFrame.TargetFrameContainer and TargetFrame.TargetFrameContainer.FrameTexture,
        }
    ) do
        if v then
            if v.SetDesaturation then
                v:SetDesaturation(desaturate and 1 or 0)
            end
            v:SetVertexColor(textureValue, textureValue, textureValue)
        end
    end

    -- Darken action button textures
    for _, v in pairs(
        {
            "MultiBarBottomLeftButton",
            "MultiBarBottomRightButton",
            "ActionButton",
        }
    ) do
        for i = 1, 12 do
            local frame = _G[v .. i .. "NormalTexture"]

            if frame then
                if frame.SetDesaturation then
                    frame:SetDesaturation(desaturate and 1 or 0)
                end
                frame:SetVertexColor(buttonValue, buttonValue, buttonValue)
            end
        end
    end
end

function AngusUI:ApplyTheme()
    if not self.Theme then
        return
    end

    local enabled = AngusUIDB and AngusUIDB.themeEnabled
    if enabled == false and self.themeWasEnabled == nil then
        return
    end

    if enabled == false and self.themeWasEnabled == true then
        self:Theme(true)
        self.themeWasEnabled = false
        return
    end

    if enabled == true then
        self.themeWasEnabled = true
    end

    self:Theme(false)
end
