--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_LoadSlot_Vacant_C
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
    self.Button_NewGame.OnClicked:Add(self, self.OnNewGameClicked)
end

function M:OnNewGameClicked()
    self.BP_LoadScreenViewModel:NewGameButtonPressed(self.SlotIndex)
end

return M
