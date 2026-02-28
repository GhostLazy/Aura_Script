--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_LoadSlot_EnterName_C
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
    self.Button_NewSlot.Button.OnClicked:Add(self, self.OnNewSlotClicked)
end

function M:OnNewSlotClicked()
    local EnteredName = UE.UKismetTextLibrary.Conv_TextToString(self.EditableText_EnterName:GetText())
    self.BP_LoadScreenViewModel:NewSlotButtonPressed(self.SlotIndex, EnteredName)
end

return M
