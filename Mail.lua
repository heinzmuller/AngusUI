-- Speeds up mailing by letting the player bulk-attach matching bag items from the mail UI.
local _, AngusUI = ...

local hookedMailButtons = setmetatable({}, { __mode = "k" })

local mailEnhancementTooltipLines = {
    "Alt-click a bag item to attach all matching copies."
}

-- Checks whether bulk mail attachment actions are currently possible.
local function IsSendMailFrameOpen()
    return SendMailFrame and SendMailFrame:IsShown()
end

-- Finds the next free outgoing mail attachment slot.
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

-- Attaches one bag item to the current mail draft.
local function AttachContainerItemToSendMail(containerID, slotID)
    local attachmentSlot = GetFirstEmptySendMailAttachmentSlot()
    if not attachmentSlot or not C_Container or not C_Container.PickupContainerItem or not ClickSendMailItemButton then
        return false
    end

    C_Container.PickupContainerItem(containerID, slotID)
    ClickSendMailItemButton(attachmentSlot)
    return true
end

-- Lets Alt-click attach as many matching items as the mail allows.
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

-- Adds the Alt-click bulk-attach shortcut to an item button.
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

-- Applies the mail shortcut hook to every button in a bag frame.
local function HookBagFrameButtons(frame)
    if not frame or not frame.EnumerateValidItems then
        return
    end

    for _, itemButton in frame:EnumerateValidItems() do
        HookMailAttachmentClick(itemButton)
    end
end

-- Applies the mail shortcut hook to older bag frame buttons.
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

-- Ensures all currently active bag buttons support bulk attaching.
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

-- Shrinks the send-money display slightly to make room for the helper button.
local function AdjustSendMailMoneyLayout()
    if not SendMailMoneyInset or not SendMailMoneyBg or not SendMailMoneyFrame then
        return
    end

    if SendMailMoneyInset.angusHelperAdjusted then
        return
    end

    SendMailMoneyInset:ClearAllPoints()
    SendMailMoneyInset:SetPoint("BOTTOMLEFT", 4, 92)
    SendMailMoneyInset:SetPoint("TOPRIGHT", SendMailFrame, "BOTTOMLEFT", 144, 115)

    SendMailMoneyBg:ClearAllPoints()
    SendMailMoneyBg:SetPoint("BOTTOMLEFT", 7, 94)
    SendMailMoneyBg:SetPoint("TOPRIGHT", SendMailFrame, "BOTTOMLEFT", 140, 113)

    SendMailMoneyFrame:ClearAllPoints()
    SendMailMoneyFrame:SetPoint("BOTTOMRIGHT", SendMailFrame, "BOTTOMLEFT", 149, 96)

    SendMailMoneyInset.angusHelperAdjusted = true
end

-- Creates the helper button that explains the mail enhancements.
local function EnsureMailHelperButton()
    if not SendMailFrame or not SendMailMailButton then
        return
    end

    if SendMailFrame.angusMailHelperButton then
        return SendMailFrame.angusMailHelperButton
    end

    AdjustSendMailMoneyLayout()

    local button = CreateFrame("Button", nil, SendMailFrame)
    button:SetSize(24, 24)
    button:SetPoint("RIGHT", SendMailMailButton, "LEFT", -4, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\common\\help-i")
    button.icon = icon

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\common\\help-i")
    highlight:SetAlpha(0.2)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("AngusUI Mail Enhancements")
        for _, line in ipairs(mailEnhancementTooltipLines) do
            GameTooltip:AddLine(line, 0.85, 0.85, 0.85, true)
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", GameTooltip_Hide)

    SendMailFrame.angusMailHelperButton = button
    return button
end

-- Initializes bag hooks for the mail attachment shortcut.
function AngusUI:MailInit()
    if self.mailHooked then
        EnsureMailHelperButton()
        HookCurrentBagButtons()
        return
    end

    EnsureMailHelperButton()

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
