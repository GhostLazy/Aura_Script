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
    self.Button_Play.Button:SetIsEnabled(false)
    self.Button_Delete.Button:SetIsEnabled(false)
    
    self.Button_Delete.Button.OnClicked:Add(self, self.OnDeleteClicked)
    self.Button_Quit.Button.OnClicked:Add(self, self.OnQuitClicked)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnDeleteClicked()
    self.Button_Play.Button:SetIsEnabled(false)
    self.Button_Delete.Button:SetIsEnabled(false)
    
    local WidgetClass = UE.UClass.Load("/Game/BluePrints/UI/AreYouSure/WBP_AreYouSure.WBP_AreYouSure_C")
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass, nil)
    Widget:AddToViewport()
    
    local ViewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
    local ViewportScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
    local WidgetWidth = Widget.SizeBox_Root.WidthOverride
    local PositionX = (ViewportSize.X - WidgetWidth * ViewportScale) / 2
    Widget:SetPositionInViewport(UE.FVector2D(PositionX, 100), true)

    Widget.CancelClickedDelegate:Add(self, self.EnablePlayDeleteButton)
    Widget.DeleteClickedDelegate:Add(self, self.OnSlotDeleted)
end

function M:OnQuitClicked()
    UE.UGameplayStatics.OpenLevel(self, "MainMenu")
end

function M:OnSlotDeleted()
    self.BP_LoadScreenViewModel:DeleteButtonPressed()
    self:EnablePlayDeleteButton()
end

function M:BlueprintInitializeWidget()
    self.Switcher_0:InitializeSlot(0)
    self.Switcher_1:InitializeSlot(1)
    self.Switcher_2:InitializeSlot(2)
    
    self.BP_LoadScreenViewModel.SlotSelected:Add(self, self.EnablePlayDeleteButton)
    self.Button_Play.Button.OnClicked:Add(self, self.OnPlayPressed)
end

function M:EnablePlayDeleteButton()
    self.Button_Play.Button:SetIsEnabled(true)
    self.Button_Delete.Button:SetIsEnabled(true)
end

function M:OnPlayPressed()
    self.BP_LoadScreenViewModel:PlayButtonPressed()
end

return M
