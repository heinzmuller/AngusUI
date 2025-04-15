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
local backs = Set(backIds)

function AngusUI:TeleportBack()
    local equippedItemId = GetInventoryItemID("player", 15)

    function EquipTeleportBack()
        for _, backId in ipairs(backIds) do
            if C_Item.GetItemCount(backId, false) == 1 and C_Container.GetItemCooldown(backId) == 0 then
                C_Item.EquipItemByName(backId)
                break
            end
        end
    end

    if backs[equippedItemId] then
        local cooldown = C_Item.GetItemCooldown(equippedItemId)

        if cooldown > 0 then
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
