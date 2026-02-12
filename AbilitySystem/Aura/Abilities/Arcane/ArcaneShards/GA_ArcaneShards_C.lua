--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type GA_ArcaneShards_C
local M = UnLua.Class()

function M:K2_ActivateAbility()
    self.bCleaned = false
    
    self.AvatarActor = self:GetAvatarActorFromActorInfo()
    self.AvatarActor:ShowMagicCircle()

    self.WaitPress = UE.UAbilityTask_WaitInputPress.WaitInputPress(self)
    self.WaitPress.OnPress:Add(self, self.OnInputPress)
    self.WaitPress:ReadyForActivation()
end

function M:OnInputPress(TimeWaited)
    if self.WaitPress then
        self.WaitPress.OnPress:Remove(self, self.OnInputPress)
        self.WaitPress:EndTask()
        self.WaitPress = nil
    end
    
    self.TargetData = UE.UTargetDataUnderMouse.CreateTargetDataUnderMouse(self)
    self.TargetData.ValidData:Add(self, self.OnValidData)
    self.TargetData:ReadyForActivation()
end

function M:OnValidData(DataHandle)
    local HitResult = UE.UAbilitySystemBlueprintLibrary.GetHitResultFromTargetData(DataHandle, 0)
    self.MouseHitLocation = HitResult.ImpactPoint
    self.Overridden.SpawnPointCollection(self)  --self.PointCollection = self.Overridden.SpawnPointCollection(self)
    
    self.YawOverride = UE.UKismetMathLibrary.RandomFloatInRange(0, 360)
    self.NumPoints = 1
    self.Count = 0
    self.GroundPoints = self.PointCollection:GetGroundPoints(self.MouseHitLocation, self.NumPoints, self.YawOverride)

    self.AvatarActor:UpdateFacingTarget(self.MouseHitLocation)
    self.Overridden.PlayArcaneShardsMontage(self)
    
    self.Event = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Event.Montage.ArcaneShards"), nil, true, true)
    self.Event.EventReceived:Add(self, self.OnEventReceived)
    self.Event:ReadyForActivation()
end

function M:OnEventReceived(Payload)
    self.ShardSpawnTimer = UE.UKismetSystemLibrary.K2_SetTimer(self, "SpawnShard", 0.2, true)
    self.AvatarActor:HideMagicCircle()
    self:SpawnShard()
end

function M:SpawnShard()
    if self.Count < self.NumPoints then
        local Element = self.GroundPoints:Get(self.Count + 1)
        local ElementLocation = Element:K2_GetComponentLocation()
        --UE.UKismetSystemLibrary.DrawDebugSphere(self, ElementLocation, self.RadialDamageInnerRadius, 12, UE.FLinearColor.White, 20, 0)
        --UE.UKismetSystemLibrary.DrawDebugSphere(self, ElementLocation, self.RadialDamageOuterRadius, 12, UE.FLinearColor(0, 0, 1, 1), 20, 0)
        local ActorsToIgnore = UE.TArray(UE.AActor)
        local OverlappingPlayers = UE.TArray(UE.AActor)
        ActorsToIgnore:Add(self.AvatarActor)
        UE.UAuraAbilitySystemLibrary.GetLivePlayersWithinRadius(self.AvatarActor, OverlappingPlayers, ActorsToIgnore, self.RadialDamageOuterRadius, ElementLocation)
        for i = 1, OverlappingPlayers:Length() do
            local Target = OverlappingPlayers:Get(i)
            UE.UAuraAbilitySystemLibrary.ApplyDamageEffect(self:MakeDamageEffectParamsFromClassDefaults(Target, ElementLocation))
        end
        self.Count = self.Count + 1
        
        local CueParams = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, ElementLocation, nil, nil, nil, nil, nil, 1, 1, nil, false)
        self:K2_ExecuteGameplayCueWithParams(UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ArcaneShards"), CueParams)
    else
        coroutine.resume(coroutine.create(self.Delay), self)
    end
end

function M:Delay()
    UE.UKismetSystemLibrary.Delay(self, 0.2)
    
    if self.PointCollection then
        self.PointCollection:K2_DestroyActor()
    end
    
    self:K2_EndAbility()
end

function M:Cleanup()
    if self.bCleaned then
        return
    end
    self.bCleaned = true

    if self.ShardSpawnTimer then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ShardSpawnTimer)
        self.ShardSpawnTimer = nil
    end
    
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

    self.AvatarActor = nil
    self.MouseHitLocation = nil
    self.GroundPoints = nil
    self.Count = 0
end

function M:K2_OnEndAbility(bWasCancelled)
    self:Cleanup()
    self.Overridden.K2_OnEndAbility(self, bWasCancelled)
end

return M