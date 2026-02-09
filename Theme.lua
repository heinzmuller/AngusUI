local _, AngusUI = ...

local defaultThemeEnabled = true
local defaultThemeDarkness = 0.5
local defaultThemeButtonDarkness = 0.25

function AngusUI:Theme()
    local enabled = defaultThemeEnabled
    local darkness = defaultThemeDarkness
    local buttonDarkness = defaultThemeButtonDarkness

    if AngusUIDB then
        if AngusUIDB.themeEnabled ~= nil then
            enabled = AngusUIDB.themeEnabled
        end

        darkness = AngusUIDB.themeDarkness or darkness
        buttonDarkness = AngusUIDB.themeButtonDarkness or buttonDarkness
    end

    if not enabled then
        return
    end
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
                v:SetVertexColor(darkness, darkness, darkness)
            end
        end
    end

    -- Darken various UI textures
    for _, v in pairs(
        {
            MainMenuBar and MainMenuBar.BorderArt,
            MinimapCompassTexture,
            PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.FrameTexture,
            PlayerFrame and PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
            TargetFrame and TargetFrame.TargetFrameContainer and TargetFrame.TargetFrameContainer.FrameTexture,
        }
    ) do
        if v then
            v:SetVertexColor(darkness, darkness, darkness)
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
                frame:SetVertexColor(buttonDarkness, buttonDarkness, buttonDarkness)
            end
        end
    end
end

function AngusUI:ApplyTheme()
    if self.Theme then
        self:Theme()
    end
end
