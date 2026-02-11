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
    self.TargetData = UE.UTargetDataUnderMouse.CreateTargetDataUnderMouse(self)
    self.TargetData.ValidData:Add(self, self.OnValidData)
    self.TargetData:ReadyForActivation()
end

function M:OnValidData(DataHandle)
    local HitResult = UE.UAbilitySystemBlueprintLibrary.GetHitResultFromTargetData(DataHandle, 0)
    self.SpawnLocation = HitResult.ImpactPoint
    self.Overridden.SpawnPointCollection(self)  --self.PointCollection = self.Overridden.SpawnPointCollection(self)
    
    self.YawOverride = UE.UKismetMathLibrary.RandomFloatInRange(0, 360)
    self.NumPoints = 11
    self.Count = 0
    self.GroundPoints = self.PointCollection:GetGroundPoints(self.SpawnLocation, self.NumPoints, self.YawOverride)
    
    self.ShardSpawnTimer = UE.UKismetSystemLibrary.K2_SetTimer(self, "SpawnShard", 0.2, true)
    self:SpawnShard()
    self.AvatarActor:HideMagicCircle()
end

function M:SpawnShard()
    if self.Count < self.NumPoints then
        local Element = self.GroundPoints:Get(self.Count + 1)
        local ElementLocation = Element:K2_GetComponentLocation()
        self.Count = self.Count + 1
        
        local CueParams = UE.UAbilitySystemBlueprintLibrary.MakeGameplayCueParameters(0, 0, nil, nil, nil, nil, nil, ElementLocation, nil, nil, nil, nil, nil, 1, 1, nil, false)
        self:K2_ExecuteGameplayCueWithParams(UE.UAuraAbilitySystemLibrary.RequestGameplayTag("GameplayCue.ArcaneShards"), CueParams)
    else
        coroutine.resume(coroutine.create(self.Delay), self)
    end
end

function M:Delay()
    UE.UKismetSystemLibrary.Delay(self, 0.2)
    self.PointCollection:K2_DestroyActor()
    self:Cleanup()
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
    
    if self.WaitPress then
        self.WaitPress.OnPress:Remove(self, self.OnInputPress)
        self.WaitPress:EndTask()
        self.WaitPress = nil
    end
    
    if self.TargetData then
        self.TargetData.ValidData:Remove(self, self.OnValidData)
        self.TargetData:EndTask()
        self.TargetData = nil
    end

    self.AvatarActor = nil
    self.SpawnLocation = nil
    self.PointCollection = nil
    self.GroundPoints = nil
end

function M:K2_OnEndAbility(bWasCancelled)
    self:Cleanup()
    self.Overridden.K2_OnEndAbility(self, bWasCancelled)
end

return M