--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_LoadSlot_WidgetSwitcher_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

-- function M:Construct()
-- end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:InitializeSlot(InSlot)
    self.SlotIndex = InSlot
    local LoadSlotViewModel = self:FindLoadScreenViewModel():GetLoadSlotViewModelByIndex(self.SlotIndex)
    local TargetClass = UE.UClass.Load("/Game/BluePrints/UI/ViewModel/BP_LoadSlotViewModel.BP_LoadSlotViewModel_C")
    self.BP_LoadSlotViewModel = TargetClass.Cast(LoadSlotViewModel, TargetClass.StaticClass())
    
    self.WBP_LoadSlot_EnterName.SlotIndex = self.SlotIndex
    self.WBP_LoadSlot_EnterName:SetBP_LoadSlotViewModel(self.BP_LoadSlotViewModel)
    self.WBP_LoadSlot_EnterName:BlueprintInitializeWidget()

    self.WBP_LoadSlot_Taken.SlotIndex = self.SlotIndex
    self.WBP_LoadSlot_Taken:SetBP_LoadSlotViewModel(self.BP_LoadSlotViewModel)
    self.WBP_LoadSlot_Taken:BlueprintInitializeWidget()

    self.WBP_LoadSlot_Vacant.SlotIndex = self.SlotIndex
    self.WBP_LoadSlot_Vacant:SetBP_LoadSlotViewModel(self.BP_LoadSlotViewModel)
    self.WBP_LoadSlot_Vacant:BlueprintInitializeWidget()
    
    self:BlueprintInitializeWidget()
end

function M:BlueprintInitializeWidget()
    self.BP_LoadSlotViewModel.SetWidgetSwitcherIndex:Add(self, self.OnIndexSet)
end

function M:OnIndexSet(Index)
    self.WidgetSwitcher_Root:SetActiveWidgetIndex(Index)
end

return M
