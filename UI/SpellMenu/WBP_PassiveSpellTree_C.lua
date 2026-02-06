--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_PassiveSpellTree_C
local M = UnLua.Class()

function M:WidgetControllerSet()
    self:SetWidgetControllers()
end

function M:PreConstruct(IsDesignTime)
    self:UpdateBoxSize()
    
    self.Button_HaloOfProtection.AbilityTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Abilities.Passive.HaloOfProtection")
    self.Button_LifeSiphon.AbilityTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Abilities.Passive.LifeSiphon")
    self.Button_ManaSiphon.AbilityTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Abilities.Passive.ManaSiphon")
end

-- function M:Construct()
-- end

function M:SetWidgetControllers()
    self.Button_HaloOfProtection:SetWidgetController(self.WidgetController)
    self.Button_LifeSiphon:SetWidgetController(self.WidgetController)
    self.Button_ManaSiphon:SetWidgetController(self.WidgetController)
end

function M:UpdateBoxSize()
    self.SizeBox_Root:SetWidthOverride(self.BoxWidth)
    self.SizeBox_Root:SetHeightOverride(self.BoxHeight)
end

return M
