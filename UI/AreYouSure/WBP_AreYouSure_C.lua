--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_AreYouSure_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.Button_Cancel.Button.OnClicked:Add(self, self.OnCancelClicked)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnCancelClicked()
    self.CancelClickedDelegate:Broadcast()
    self:RemoveFromParent()
end

return M
