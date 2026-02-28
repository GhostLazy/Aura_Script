--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_LoadMenu_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.Button_Quit.Button.OnClicked:Add(self, self.OnQuitClicked)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnQuitClicked()
    UE.UGameplayStatics.OpenLevel(self, "MainMenu")
end

function M:BlueprintInitializeWidget()
    self.Switcher_0:InitializeSlot(0)
    self.Switcher_1:InitializeSlot(1)
    self.Switcher_2:InitializeSlot(2)
end

return M
