local _, AngusUI = ...

function AngusUI:UI()
    local layouts = C_EditMode.GetLayouts();
    local screenWidth, screenHeight = GetPhysicalScreenSize()

    if (layouts.activeLayout < 3) then
        return
    end

    local actualActiveLayout = layouts.activeLayout - 2
    local activeLayout = layouts.layouts[actualActiveLayout]
    local activeLayoutName = activeLayout.layoutName:lower()

    if not activeLayoutName:find("angusui") then
        return
    end

    local layoutToUse

    if (screenWidth == 3840 or screenWidth == 2560) and (screenHeight == 2160 or screenHeight == 1440) then
        layoutToUse = "angusui 4k"
    else
        local shouldUseWideLayout = (screenWidth / screenHeight) > 2

        layoutToUse = shouldUseWideLayout and "angusui wide" or "angusui"
    end

    for i, layout in ipairs(layouts.layouts) do
        local layoutName = layout.layoutName:lower()
        local isAngusUI = layoutName:find("angusui") ~= nil

        if not isAngusUI then
            return
        end

        if (layoutName == layoutToUse) then
            C_EditMode.SetActiveLayout(i + 2)
            return
        end
    end
end
