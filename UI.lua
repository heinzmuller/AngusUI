local _, AngusUI = ...

function AngusUI:UI()
    local layouts = C_EditMode.GetLayouts();
    if not layouts or not layouts.layouts then
        return
    end

    local screenWidth, screenHeight = GetPhysicalScreenSize()
    if not screenWidth or not screenHeight or screenHeight == 0 then
        return
    end

    if (layouts.activeLayout < 3) then
        return
    end

    local actualActiveLayout = layouts.activeLayout - 2
    local activeLayout = layouts.layouts[actualActiveLayout]
    if not activeLayout or not activeLayout.layoutName then
        return
    end

    local activeLayoutName = strlower(activeLayout.layoutName)

    if not strfind(activeLayoutName, "angusui") then
        return
    end

    local screenRatio = screenWidth / screenHeight
    local epsilon = 0.0001
    local bestLayoutIndex
    local bestLayoutName
    local bestDistance
    local bestRatioCount
    local bestMatchedRatio

    for i, layout in ipairs(layouts.layouts) do
        local layoutName = strlower(layout.layoutName)
        local layoutRatioCount = 0
        local layoutBestDistance
        local layoutBestRatio

        if strfind(layoutName, "angusui") then
            for width, height in gmatch(layoutName, "(%d+):(%d+)") do
                local ratioWidth = tonumber(width)
                local ratioHeight = tonumber(height)

                if ratioWidth and ratioHeight and ratioHeight ~= 0 then
                    local distance = math.abs((ratioWidth / ratioHeight) - screenRatio)

                    layoutRatioCount = layoutRatioCount + 1

                    if not layoutBestDistance or distance < layoutBestDistance then
                        layoutBestDistance = distance
                        layoutBestRatio = width .. ":" .. height
                    end
                end
            end
        end

        if layoutBestDistance then
            local isBetterMatch = not bestDistance or (layoutBestDistance < (bestDistance - epsilon))
            local isEquallyClose = bestDistance and math.abs(layoutBestDistance - bestDistance) <= epsilon
            local isMoreSpecific = isEquallyClose and layoutRatioCount < bestRatioCount

            if isBetterMatch or isMoreSpecific then
                bestLayoutIndex = i
                bestLayoutName = layout.layoutName
                bestDistance = layoutBestDistance
                bestRatioCount = layoutRatioCount
                bestMatchedRatio = layoutBestRatio
            end
        end
    end

    if not bestLayoutIndex then
        return
    end

    local selectionKey = bestLayoutName .. "@" .. screenWidth .. "x" .. screenHeight

    if (bestLayoutIndex + 2) ~= layouts.activeLayout then
        C_EditMode.SetActiveLayout(bestLayoutIndex + 2)
    end

    if AngusUI.lastAutoSelectedLayout ~= selectionKey then
        AngusUI:Print("Selected layout \"" .. bestLayoutName .. "\" for " .. screenWidth .. "x" .. screenHeight .. " (matched " .. bestMatchedRatio .. ")")
        AngusUI.lastAutoSelectedLayout = selectionKey
    end
end
