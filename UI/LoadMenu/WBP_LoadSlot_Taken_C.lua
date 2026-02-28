--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_LoadSlot_Taken_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

-- function M:Construct()
-- end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:BlueprintInitializeWidget()
    self.Button_SelectSlot.Button.OnClicked:Add(self, self.OnSelectSlotClicked)
end

function M:OnSelectSlotClicked()
    self:FindLoadScreenViewModel():SelectSlotButtonPressed(self.SlotIndex)
end

return M
