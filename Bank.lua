local _, AngusUI = ...

local function SelectWarbandBankTab(bankFrame)
    if
        not bankFrame or
        not bankFrame.accountBankTabID or
        not bankFrame.SetTab or
        not C_Bank or
        not C_Bank.CanViewBank or
        not C_Bank.CanViewBank(Enum.BankType.Account)
    then
        return
    end

    if bankFrame.GetTab and bankFrame:GetTab() == bankFrame.accountBankTabID then
        return
    end

    bankFrame:SetTab(bankFrame.accountBankTabID)
end

function AngusUI:BankInit()
    if self.bankDefaultTabHooked or not BankFrame then
        return
    end

    BankFrame:HookScript("OnShow", function(bankFrame)
        SelectWarbandBankTab(bankFrame)
    end)

    self.bankDefaultTabHooked = true
end
