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

local function FindItemInBags(matchFunc)
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bag)

        for slot = 1, numSlots do
            local itemId = C_Container.GetContainerItemID(bag, slot)

            if itemId and matchFunc(bag, slot, itemId) then
                return bag, slot
            end
        end
    end
end

local function FindTeleportBack()
    return FindItemInBags(function(bag, slot, itemId)
        if not backs[itemId] then
            return false
        end

        local startTime = C_Container.GetContainerItemCooldown(bag, slot)
        return startTime == 0
    end)
end

local function FindItemByGuid(targetGuid)
    if not targetGuid then
        return
    end

    return FindItemInBags(function(bag, slot)
        local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)

        if not itemLoc or not itemLoc:IsValid() then
            return false
        end

        return C_Item.GetItemGUID(itemLoc) == targetGuid
    end)
end

local function EquipBackFromBag(bag, slot)
    if not bag or not slot then
        return false
    end

    C_Container.PickupContainerItem(bag, slot)
    EquipCursorItem(INVSLOT_BACK)
    return true
end

function AngusUI:TeleportBack()
    local equippedItemId = GetInventoryItemID("player", 15)

    if not equippedItemId then
        print("AngusUI: No back item equipped")
        return
    end

    if backs[equippedItemId] then
        local startTime, duration = C_Item.GetItemCooldown(equippedItemId)

        if startTime > 0 and duration > 0 then
            local bag, slot = FindItemByGuid(nonTeleportBack)

            if not EquipBackFromBag(bag, slot) then
                print("AngusUI: Original back item not found")
            end
        end
    else
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(INVSLOT_BACK)

        if itemLoc:IsValid() then
            nonTeleportBack = C_Item.GetItemGUID(itemLoc)
        end

        local bag, slot = FindTeleportBack()

        if not EquipBackFromBag(bag, slot) then
            print("AngusUI: No available teleport back found")
        end
    end
end
