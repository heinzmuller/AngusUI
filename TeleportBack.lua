local _, AngusUI = ...

local nonTeleportBack
local backIds = {
    65274,
    63207,
    63353,
    65360,
    63206,
    63352,
}

-- Create a set from backIds for quick lookup
local backs = {}
for _, id in ipairs(backIds) do
    backs[id] = true
end

function AngusUI:TeleportBack()
    local equippedItemId = GetInventoryItemID("player", 15)
    
    if not equippedItemId then
        print("AngusUI: No back item equipped")
        return
    end

    function EquipTeleportBack()
        for _, backId in ipairs(backIds) do
            local startTime, duration, enable = C_Container.GetItemCooldown(backId)
            if C_Item.GetItemCount(backId, false) == 1 and startTime == 0 then
                C_Item.EquipItemByName(backId)
                break
            end
        end
    end

    if backs[equippedItemId] then
        local startTime, duration, enableCooldownTimer = C_Item.GetItemCooldown(equippedItemId)

        if startTime > 0 and duration > 0 then
            C_Item.EquipItemByName(nonTeleportBack)
        end
    else
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(INVSLOT_BACK)

        if itemLoc:IsValid() then
            nonTeleportBack = C_Item.GetItemGUID(itemLoc)
        end

        EquipTeleportBack()
    end
end
