local _, AngusUI = ...

local hookedMailButtons = setmetatable({}, { __mode = "k" })

local function IsSendMailFrameOpen()
    return SendMailFrame and SendMailFrame:IsShown()
end

local function GetFirstEmptySendMailAttachmentSlot()
    if not GetSendMailItem then
        return nil
    end

    for index = 1, ATTACHMENTS_MAX_SEND or 12 do
        local name = GetSendMailItem(index)
        if not name then
            return index
        end
    end

    return nil
end

local function AttachContainerItemToSendMail(containerID, slotID)
    local attachmentSlot = GetFirstEmptySendMailAttachmentSlot()
    if not attachmentSlot or not C_Container or not C_Container.PickupContainerItem or not ClickSendMailItemButton then
        return false
    end

    C_Container.PickupContainerItem(containerID, slotID)
    ClickSendMailItemButton(attachmentSlot)
    return true
end

local function AttachMatchingBagItemsToSendMail(containerID, slotID)
    if not IsSendMailFrameOpen() or not C_Container or not C_Container.GetContainerItemID then
        return
    end

    local itemID = C_Container.GetContainerItemID(containerID, slotID)
    if not itemID then
        return
    end

    if not AttachContainerItemToSendMail(containerID, slotID) then
        return
    end

    local lastBag = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
    for bag = 0, lastBag do
        local slotCount = C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, slotCount do
            if not GetFirstEmptySendMailAttachmentSlot() then
                return
            end

            if not (bag == containerID and slot == slotID) and C_Container.GetContainerItemID(bag, slot) == itemID then
                if not AttachContainerItemToSendMail(bag, slot) then
                    return
                end
            end
        end
    end
end

local function HookMailAttachmentClick(button)
    if not button or hookedMailButtons[button] then
        return
    end

    button:HookScript("PreClick", function(self, mouseButton)
        if mouseButton ~= "LeftButton" or not IsAltKeyDown() then
            return
        end

        if not self.GetBagID or not self.GetID then
            return
        end

        AttachMatchingBagItemsToSendMail(self:GetBagID(), self:GetID())
    end)

    hookedMailButtons[button] = true
end

local function HookBagFrameButtons(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        HookMailAttachmentClick(itemButton)
    end
end

local function HookLegacyContainerFrame(container)
    if not container then
        return
    end

    local name = container:GetName()
    if not name then
        return
    end

    for index = 1, container.size or 0 do
        local button = _G[name .. "Item" .. index]
        if button then
            HookMailAttachmentClick(button)
        end
    end
end

local function HookCurrentBagButtons()
    HookBagFrameButtons(ContainerFrameCombinedBags)

    local containerFrames = (ContainerFrameContainer or UIParent).ContainerFrames
    if not containerFrames then
        return
    end

    for _, frame in ipairs(containerFrames) do
        HookBagFrameButtons(frame)
    end
end

function AngusUI:MailInit()
    if self.mailHooked then
        HookCurrentBagButtons()
        return
    end

    if ContainerFrame_Update then
        hooksecurefunc("ContainerFrame_Update", HookLegacyContainerFrame)
    end

    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.UpdateItems then
        hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", HookBagFrameButtons)
    end

    local containerFrames = (ContainerFrameContainer or UIParent).ContainerFrames
    if containerFrames then
        for _, frame in ipairs(containerFrames) do
            if frame and frame.UpdateItems then
                hooksecurefunc(frame, "UpdateItems", HookBagFrameButtons)
            end
        end
    end

    HookCurrentBagButtons()
    self.mailHooked = true
end
