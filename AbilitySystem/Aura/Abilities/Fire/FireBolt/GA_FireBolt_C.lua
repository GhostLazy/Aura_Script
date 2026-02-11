--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type GA_FireBolt_C
local M = UnLua.Class()

function M:K2_ActivateAbility()
    self:K2_CommitAbility()
    self.bCleaned = false
    
    self.TargetData = UE.UTargetDataUnderMouse.CreateTargetDataUnderMouse(self)
    self.TargetData.ValidData:Add(self, self.OnValidData)
    self.TargetData:ReadyForActivation()
end

function M:OnValidData(DataHandle)
    local HitResult = UE.UAbilitySystemBlueprintLibrary.GetHitResultFromTargetData(DataHandle, 0)
    self.TargetLocation = HitResult.Location
    self.HitActor = UE.UAuraAbilitySystemLibrary.FetchActor(HitResult.HitObjectHandle)

    local AvatarActor = self:GetAvatarActorFromActorInfo()
    local CombatInterface = UE.UCombatInterface.Cast(AvatarActor, UE.UCombatInterface.StaticClass())
    if CombatInterface then
        CombatInterface:UpdateFacingTarget(self.TargetLocation)
    end

    self.Overridden.PlayFireBoltMontage(self)
    self.Event = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("Event.Montage.FireBolt"), nil, false, true)
    self.Event.EventReceived:Add(self, self.OnEventReceived)
    self.Event:ReadyForActivation()
end

function M:OnEventReceived(Payload)
    if self.bCleaned then
        return
    end
    
    self.SpawnProjectiles(self, self.TargetLocation, UE.UAuraAbilitySystemLibrary.RequestGameplayTag("CombatSocket.Weapon"), true, 45, self.HitActor)
end

function M:Cleanup()
    if self.bCleaned then
        return
    end
    self.bCleaned = true

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
    
    self.TargetLocation = nil
    self.HitActor = nil
end

function M:K2_OnEndAbility(bWasCancelled)
    self:Cleanup()
    self.Overridden.K2_OnEndAbility(self, bWasCancelled)
end

return M