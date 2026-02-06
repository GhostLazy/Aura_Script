--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_HealthManaSpells_C
local M = UnLua.Class()

function M:WidgetControllerSet()
    self.WBP_HealthGlobe:SetWidgetController(self.WidgetController)
    self.WBP_ManaGlobe:SetWidgetController(self.WidgetController)
    
    self:SetGlobeWidgetControllers()
end

function M:PreConstruct(IsDesignTime)
    self:SetSpellGlobeInputTag()
end

function M:SetGlobeWidgetControllers()
    self.SpellGlobe_LMB:SetWidgetController(self.WidgetController)
    self.SpellGlobe_RMB:SetWidgetController(self.WidgetController)
    self.SpellGlobe_1:SetWidgetController(self.WidgetController)
    self.SpellGlobe_2:SetWidgetController(self.WidgetController)
    self.SpellGlobe_3:SetWidgetController(self.WidgetController)
    self.SpellGlobe_4:SetWidgetController(self.WidgetController)
    self.SpellGlobe_Passive_1:SetWidgetController(self.WidgetController)
    self.SpellGlobe_Passive_2:SetWidgetController(self.WidgetController)
end

function M:SetSpellGlobeInputTag()
    self.SpellGlobe_LMB.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.LMB")
    self.SpellGlobe_RMB.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.RMB")
    self.SpellGlobe_1.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.1")
    self.SpellGlobe_2.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.2")
    self.SpellGlobe_3.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.3")
    self.SpellGlobe_4.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.4")
    self.SpellGlobe_Passive_1.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.Passive.1")
    self.SpellGlobe_Passive_2.InputTag = UE.UAuraAbilitySystemLibrary.RequestGameplayTag("InputTag.Passive.2")
end

return M
