--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Aura_MainMenu_C
local M = UnLua.Class()

function M:ReceiveBeginPlay()
    self.FireballInitialLocation = self.Fireball:K2_GetComponentLocation()
    self.Time = 0
    self.Overridden.PlayMainMenuSound(self)
    
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load("/Game/BluePrints/UI/MainMenu/WBP_MainMenu.WBP_MainMenu_C"), nil)
    if Widget then
        Widget:AddToViewport()
    end
    
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    UE.UWidgetBlueprintLibrary.SetInputMode_UIOnlyEx(PC, Widget)
    PC.bShowMouseCursor = true
end

function M:ReceiveTick(DeltaSeconds)
    self:UpdateTime(DeltaSeconds)
    
    local NewLocation = self.FireballInitialLocation + UE.FVector(0, 0, 3.5 * UE.UKismetMathLibrary.Sin(self.Time))
    self.Fireball:K2_SetWorldLocation(NewLocation, false, nil, false)

    local Rotator = UE.FRotator(0, 0, -4 * DeltaSeconds)
    self.MagicCircleDecal:K2_AddLocalRotation(Rotator, false, nil, false)
end

function M:UpdateTime(DeltaSeconds)
    self.Time = self.Time + DeltaSeconds
    if (self.Time > 2 * math.pi) then
        self.Time = 0
    end
end

return M
