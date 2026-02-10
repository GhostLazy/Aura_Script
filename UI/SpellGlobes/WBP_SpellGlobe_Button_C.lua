--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_SpellGlobe_Button_C
local M = UnLua.Class()

function M:PreConstruct(IsDesignTime)
    self:UpdateBoxSize()
    self:UpdateGlobePadding()
    self:UpdateBackground()
end

--function M:WidgetControllerSet()
--    local TargetClass = UE.UClass.Load("/Game/BluePrints/UI/WidgetController/BP_SpellMenuWidgetController.BP_SpellMenuWidgetController_C")
--    local castedController = TargetClass.Cast(self.WidgetController, TargetClass.StaticClass())
--    if castedController then
--        self.BP_SpellMenuWidgetController = castedController
--    end
--
--    self.BP_SpellMenuWidgetController.AbilityInfoDelegate:Add(self.BP_SpellMenuWidgetController, self.ReceiveAbilityInfo)
--    self.BP_SpellMenuWidgetController.SpellGlobeReassignedDelegate:Add(self.BP_SpellMenuWidgetController, self.OnSpellGlobeSelected)
--end

--function M:Construct()
--    
--end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:UpdateBoxSize()
    self.SizeBox_Root:SetWidthOverride(self.BoxWidth)
    self.SizeBox_Root:SetHeightOverride(self.BoxHeight)
end

function M:UpdateGlobePadding()
    local GlassSlot = UE.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Image_Glass)
    local BackgroundSlot = UE.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Image_Background)
    local Margin = UE.FMargin(self.GlassPadding, self.GlassPadding, self.GlassPadding, self.GlassPadding)
    GlassSlot:SetPadding(Margin)
    BackgroundSlot:SetPadding(Margin)
end

function M:UpdateBackground()
    self.Image_Background:SetBrush(self.BackgroundBrush)
end

function M:ReceiveAbilityInfo(Info)
    self.Overridden.ReceiveAbilityInfo(self, Info)
end

function M:OnSpellGlobeSelected(AbilityTag)
    self.Overridden.OnSpellGlobeSelected(self, AbilityTag)
end

return M
