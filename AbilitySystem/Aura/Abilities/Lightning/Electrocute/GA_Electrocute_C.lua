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
    self.bCleaned = false
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
    
    self.DamageDeltaTime = 0.1
    self.DamageAndCostTimer = UE.UKismetSystemLibrary.K2_SetTimer(self, "DamageAndCost", self.DamageDeltaTime, true)
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
        CueTarget:SetIsBeingShocked(true)
        self.AdditionalTargets = UE.TArray(UE.AActor)
        self.AdditionalTargets = self:StoreAdditionalTargets()
        for i = 1, self.AdditionalTargets:Length() do
            local Element = self.AdditionalTargets:Get(i)
            Element:SetIsBeingShocked(true)
            self:AddShockLoopCueToAdditionalTarget(Element)
        end
    end
end

function M:AddShockLoopCueToAdditionalTarget(AdditionalTarget)
    local Params = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, AdditionalTarget:K2_GetActorLocation(), nil, nil, nil, AdditionalTarget, nil, 1, 1, self.MouseHitActor.RootComponent, false)
    UE.UGameplayCueFunctionLibrary.AddGameplayCueOnActor(AdditionalTarget, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), Params)
end

function M:DamageAndCost()
    if self:K2_CommitAbilityCost() then
        self:ApplyDamage()
    else
        self:ClearTimerAndEndAbility()
    end
end

function M:ApplyDamage()
    self:ApplyDamageSingleTarget(self.MouseHitActor)

    if self.AdditionalTargets then
        for i = 1, self.AdditionalTargets:Length() do
            local Element = self.AdditionalTargets:Get(i)
            self:ApplyDamageSingleTarget(Element)
        end
    end
end

function M:ApplyDamageSingleTarget(TargetActor)
    local SourceASC = self:GetAbilitySystemComponentFromActorInfo()
    local EffectContext = SourceASC:MakeEffectContext()
    local SpecHandle = SourceASC:MakeOutgoingSpec(self.DamageEffectClass, self:GetAbilityLevel(), EffectContext)

    UE.UAbilitySystemBlueprintLibrary.AssignTagSetByCallerMagnitude(SpecHandle, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Damage.Lightning"), self:GetDamageAtLevel())
    local TargetASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(TargetActor)
    if TargetASC then
        TargetASC:BP_ApplyGameplayEffectSpecToSelf(SpecHandle)
    end
end

function M:ClearTimerAndEndAbility()
    if self.bCleaned then
        return
    end
    self.bCleaned = true
    
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.DamageAndCostTimer)
    self:PrepareToEndAbility()
    self:K2_CommitAbilityCooldown()
    self:K2_EndAbility()
end

function M:PrimaryTargetDied(DeadActor)
    UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(DeadActor, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)
    self:ClearTimerAndEndAbility()
end

function M:AdditionalTargetDied(DeadActor)
    self:RemoveShockLoopCueFromAdditionalTarget(DeadActor)
    if self.AdditionalTargets then
        self.AdditionalTargets:RemoveItem(DeadActor)
    end
end

function M:OnInputRelease(TimeHeld)
    self.TimeHeld = TimeHeld
    self.MinSpellTime = 0.5

    if self.TimeHeld < self.MinSpellTime then
        if self:K2_HasAuthority() then
            local Duration = self.MinSpellTime - self.TimeHeld
            self.DelayTask = UE.UAbilityTask_WaitDelay.WaitDelay(self, Duration)
            self.DelayTask.OnFinish:Add(self, self.ClearTimerAndEndAbility)
            self.DelayTask:ReadyForActivation()
        else
            self:PrepareToEndAbility()
        end
    else
        self:ClearTimerAndEndAbility()
    end
end

function M:PrepareToEndAbility()
    self.OwnerPlayerController.bShowMouseCursor = true
    self.AvatarActor:SetInShockLoop(false)
    self.AvatarActor.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Walking, 0)

    if self.ImplementsInterface then
        self.MouseHitActor:SetIsBeingShocked(false)
        UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(self.MouseHitActor, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)
        if self:K2_HasAuthority() then
            UE.UAuraAbilitySystemLibrary.ApplyDamageEffect(self:MakeDamageEffectParamsFromClassDefaults(self.MouseHitActor))
        end
        
        for i = 1, self.AdditionalTargets:Length() do
            local Element = self.AdditionalTargets:Get(i)
            Element:SetIsBeingShocked(false)
            self:RemoveShockLoopCueFromAdditionalTarget(Element)
            if self:K2_HasAuthority() then
                UE.UAuraAbilitySystemLibrary.ApplyDamageEffect(self:MakeDamageEffectParamsFromClassDefaults(Element))
            end
        end
    else
        UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(self.AvatarActor, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), self.FirstTargetCueParams)
    end
end

function M:RemoveShockLoopCueFromAdditionalTarget(AdditionalTarget)
    if AdditionalTarget and self.MouseHitActor then
        local Params = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, AdditionalTarget:K2_GetActorLocation(), nil, nil, nil, AdditionalTarget, nil, 1, 1, self.MouseHitActor.RootComponent, false)
        UE.UGameplayCueFunctionLibrary.RemoveGameplayCueOnActor(AdditionalTarget, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ShockLoop"), Params)
    end
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

    if self.DelayTask then
        self.DelayTask.OnFinish:Remove(self, self.ClearTimerAndEndAbility)
        self.DelayTask:EndTask()
        self.DelayTask = nil
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

function M:K2_OnEndAbility(bWasCancelled)
    self:Cleanup()
    self.TimeHeld = 0
    self.Overridden.K2_OnEndAbility(self, bWasCancelled)
end

return M