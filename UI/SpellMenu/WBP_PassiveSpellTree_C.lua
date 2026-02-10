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
--
--function M:Construct()
--    self.Button_HaloOfProtection.OnSpellGlobeSelectedDelegate:Add(self.Button_HaloOfProtection, self.SpellGlobeSelectedCallback)
--    self.Button_LifeSiphon.OnSpellGlobeSelectedDelegate:Add(self.Button_LifeSiphon, self.SpellGlobeSelectedCallback)
--    self.Button_ManaSiphon.OnSpellGlobeSelectedDelegate:Add(self.Button_ManaSiphon, self.SpellGlobeSelectedCallback)
--end
--
function M:SetWidgetControllers()
    self.Button_HaloOfProtection:SetWidgetController(self.WidgetController)
    self.Button_LifeSiphon:SetWidgetController(self.WidgetController)
    self.Button_ManaSiphon:SetWidgetController(self.WidgetController)
end

function M:UpdateBoxSize()
    self.SizeBox_Root:SetWidthOverride(self.BoxWidth)
    self.SizeBox_Root:SetHeightOverride(self.BoxHeight)
end
--
--function M:SpellGlobeSelectedCallback(SelectedGlobe)
--    self.Button_HaloOfProtection:Deselect()
--    self.Button_LifeSiphon:Deselect()
--    self.Button_ManaSiphon:Deselect()
--    
--    SelectedGlobe:Select()
--    self.OnPassiveSpellGlobeSelected:Broadcast()
--end

return M
