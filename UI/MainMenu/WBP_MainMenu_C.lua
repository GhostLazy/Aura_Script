--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_MainMenu_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.Button_Quit.Button.OnClicked:Add(self.Button_Quit.Button, self.OnQuitClicked)
    self.Button_Play.Button.OnClicked:Add(self.Button_Play.Button, self.OnPlayClicked)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnQuitClicked()
    UE.UKismetSystemLibrary.QuitGame(self, nil, UE.EQuitPreference.Quit, false)
end

function M:OnPlayClicked()
    UE.UGameplayStatics.OpenLevel(self, "LoadMenu")
end

return M
