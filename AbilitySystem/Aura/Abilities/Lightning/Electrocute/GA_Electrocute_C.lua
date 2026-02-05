--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type GA_Electrocute_C
local M = UnLua.Class()

function M:K2_ActivateAbility()
    self:EnforceImplementsCombatInterface()

    self.TargetData = UE.UTargetDataUnderMouse.CreateTargetDataUnderMouse(self)
    self.TargetData.ValidData:Add(self, self.OnValidData)
    self.TargetData:ReadyForActivation()
end

function M:EnforceImplementsCombatInterface()
    self.AvatarActor = self:GetAvatarActorFromActorInfo()
    if not UE.UKismetSystemLibrary.DoesImplementInterface(self.AvatarActor, UE.UCombatInterface.StaticClass()) then
        self:K2_EndAbility()
    end
end

function M:OnValidData(DataHandle)
    local HitResult = UE.UAbilitySystemBlueprintLibrary.GetHitResultFromTargetData(DataHandle, 0)
    self:StoreMouseDataInfo(HitResult)
    self:StoreOwnerVariables()
    
    self.OwnerPlayerController.bShowMouseCursor = false
    self.AvatarActor:UpdateFacingTarget(self.MouseHitLocation)
    self:K2_ExecuteGameplayCue(UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockBurst"), nil)
    self.Overridden.PlayElectrocuteMontage(self)

    self.Event = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Event.Montage.Electrocute"), nil, true, true)
    self.Event.EventReceived:Add(self, self.OnEventReceived)
    self.Event:ReadyForActivation()

    self.WaitRelease = UE.UAbilityTask_WaitInputRelease.WaitInputRelease(self)
    self.WaitRelease.OnRelease:Add(self, self.OnInputRelease)
    self.WaitRelease:ReadyForActivation()
end

function M:OnEventReceived(Payload)
    self:InShockLoop()
    self:SpawnElectricBeam()
end

function M:InShockLoop()
    self.AvatarActor:SetInShockLoop(true)
    self.AvatarActor.CharacterMovement:DisableMovement()
end

function M:SpawnElectricBeam()
    self:TraceFirstTarget(self.MouseHitLocation)

    self.FirstTargetCueParams = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, self.MouseHitLocation, nil, nil, nil, self.MouseHitActor, nil, 1, 1, self.OwnerCharacter:GetWeapon(), false)

    self.ImplementsInterface = UE.UKismetSystemLibrary.DoesImplementInterface(self.MouseHitActor, UE.UCombatInterface.StaticClass())
    local CueTarget
    if self.ImplementsInterface then
        CueTarget = self.MouseHitActor
    else
        CueTarget = self.AvatarActor
    end
    UE.UGameplayCueFunctionLibrary.AddGameplayCueOnActor(CueTarget, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)

    if self.ImplementsInterface then
        self.AdditionalTargets = UE.TArray(UE.AActor)
        self.AdditionalTargets = self:StoreAdditionalTargets()
        for i = 1, self.AdditionalTargets:Length() do
            local Element = self.AdditionalTargets:Get(i)
            self:AddShockLoopCueToAdditionalTarget(Element)
        end
    end
end

function M:AddShockLoopCueToAdditionalTarget(AdditionalTarget)
    local Params = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, AdditionalTarget:K2_GetActorLocation(), nil, nil, nil, AdditionalTarget, nil, 1, 1, self.MouseHitActor.RootComponent, false)
    UE.UGameplayCueFunctionLibrary.AddGameplayCueOnActor(AdditionalTarget, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), Params)
end

function M:OnInputRelease(TimeHeld)
    self:PrepareToEndAbility()
    self:Cleanup()
    self:K2_EndAbility()
end

function M:PrepareToEndAbility()
    self.OwnerPlayerController.bShowMouseCursor = true
    self.AvatarActor:SetInShockLoop(false)
    self.AvatarActor.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Walking, 0)

    if self.ImplementsInterface then
        UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(self.MouseHitActor, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)
        for i = 1, self.AdditionalTargets:Length() do
            local Element = self.AdditionalTargets:Get(i)
            self:RemoveShockLoopCueFromAdditionalTarget(Element)
        end
    else
        UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(self.AvatarActor, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)
    end
end

function M:RemoveShockLoopCueFromAdditionalTarget(AdditionalTarget)
    local Params = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, AdditionalTarget:K2_GetActorLocation(), nil, nil, nil, AdditionalTarget, nil, 1, 1, self.MouseHitActor.RootComponent, false)
    UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(AdditionalTarget, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), Params)
end

function M:Cleanup()
    if self.TargetData then
        self.TargetData.ValidData:Remove(self, self.OnValidData)
        self.TargetData:EndTask()
        self.TargetData = nil
    end
    
    if self.Event then
        self.Event.EventReceived:Remove(self, self.OnEventReceived)
        self.Event:EndTask()
        self.Event = nil
    end

    if self.WaitRelease then
        self.WaitRelease.OnRelease:Remove(self, self.OnInputRelease)
        self.WaitRelease:EndTask()
        self.WaitRelease = nil
    end

    self.MouseHitActor = nil
    self.MouseHitLocation = nil
    self.OwnerPlayerController = nil
    self.OwnerCharacter = nil
    
    self.FirstTargetCueParams = nil
    self.AvatarActor = nil
    self.ImplementsInterface = nil
    self.AdditionalTargets = nil
end

return M