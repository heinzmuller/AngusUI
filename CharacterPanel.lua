local _, AngusUI = ...

local Inconsolata = "Interface\\AddOns\\AngusUI\\Inconsolata.ttf"

local slotFrames = {
    { slotId = INVSLOT_HEAD,     frameName = "CharacterHeadSlot" },
    { slotId = INVSLOT_NECK,     frameName = "CharacterNeckSlot" },
    { slotId = INVSLOT_SHOULDER, frameName = "CharacterShoulderSlot" },
    { slotId = INVSLOT_BACK,     frameName = "CharacterBackSlot" },
    { slotId = INVSLOT_CHEST,    frameName = "CharacterChestSlot" },
    { slotId = INVSLOT_BODY,     frameName = "CharacterShirtSlot" },
    { slotId = INVSLOT_TABARD,   frameName = "CharacterTabardSlot" },
    { slotId = INVSLOT_WRIST,    frameName = "CharacterWristSlot" },
    { slotId = INVSLOT_HAND,     frameName = "CharacterHandsSlot" },
    { slotId = INVSLOT_WAIST,    frameName = "CharacterWaistSlot" },
    { slotId = INVSLOT_LEGS,     frameName = "CharacterLegsSlot" },
    { slotId = INVSLOT_FEET,     frameName = "CharacterFeetSlot" },
    { slotId = INVSLOT_FINGER1,  frameName = "CharacterFinger0Slot" },
    { slotId = INVSLOT_FINGER2,  frameName = "CharacterFinger1Slot" },
    { slotId = INVSLOT_TRINKET1, frameName = "CharacterTrinket0Slot" },
    { slotId = INVSLOT_TRINKET2, frameName = "CharacterTrinket1Slot" },
    { slotId = INVSLOT_MAINHAND, frameName = "CharacterMainHandSlot" },
    { slotId = INVSLOT_OFFHAND,  frameName = "CharacterSecondaryHandSlot" },
}

local function GetSlotButton(frameName)
    return _G[frameName]
end

local function GetOverlay(slotButton)
    if slotButton.AngusUIItemLevelText then
        return slotButton.AngusUIItemLevelText
    end

    local text = slotButton:CreateFontString(nil, "OVERLAY")
    text:SetFont(Inconsolata, 10, "OUTLINE")
    text:SetPoint("BOTTOM", slotButton, "BOTTOM", 0, 2)
    text:SetJustifyH("CENTER")
    text:SetShadowOffset(1, -1)
    text:SetShadowColor(0, 0, 0, 1)
    slotButton.AngusUIItemLevelText = text

    return text
end

local function QueueRefresh(itemLocation, slotButton)
    if slotButton.AngusUIItemLevelPending then
        return
    end

    if not Item or not Item.CreateFromItemLocation then
        return
    end

    local item = Item:CreateFromItemLocation(itemLocation)

    if not item then
        return
    end

    slotButton.AngusUIItemLevelPending = true
    item:ContinueOnItemLoad(function()
        slotButton.AngusUIItemLevelPending = nil
        AngusUI:CharacterPanel()
    end)
end

local function GetItemLevel(slotId, slotButton)
    local itemLink = GetInventoryItemLink("player", slotId)

    if not itemLink then
        slotButton.AngusUIItemLevelPending = nil
        return nil
    end

    local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)

    if not itemLocation or not itemLocation:IsValid() then
        slotButton.AngusUIItemLevelPending = nil
        return nil
    end

    local currentItemLevel = C_Item.GetCurrentItemLevel and C_Item.GetCurrentItemLevel(itemLocation)
    if currentItemLevel and currentItemLevel > 0 then
        slotButton.AngusUIItemLevelPending = nil
        return currentItemLevel
    end

    QueueRefresh(itemLocation, slotButton)
    return nil
end

function AngusUI:CharacterPanel()
    if not CharacterFrame then
        return
    end

    if not self.characterPanelHooked then
        CharacterFrame:HookScript("OnShow", function()
            AngusUI:CharacterPanel()
        end)

        self.characterPanelHooked = true
    end

    for _, slotInfo in ipairs(slotFrames) do
        local slotButton = GetSlotButton(slotInfo.frameName)

        if slotButton then
            local text = GetOverlay(slotButton)
            local itemLevel = GetItemLevel(slotInfo.slotId, slotButton)

            if itemLevel then
                text:SetText(itemLevel)
                text:Show()
            else
                text:SetText("")
                text:Hide()
            end
        end
    end
end
