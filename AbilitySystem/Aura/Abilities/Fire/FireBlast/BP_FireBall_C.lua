--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_FireBall_C
local M = UnLua.Class()

function M:StartOutgoingTimeline()
    if not self:HasAuthority() then
        return
    end
    
    self.InitialLocation = self:K2_GetActorLocation()
    self.TravelDistance = 800
    self.ApexLocation = self.InitialLocation + self:GetActorForwardVector() * self.TravelDistance
    
    self.OutgoingTimeline:Play()
end

function M:OnOutgoingTimelineUpdate(Alpha)
    local NewLocation = UE.UKismetMathLibrary.VLerp(self.InitialLocation, self.ApexLocation, Alpha)
    self:K2_SetActorLocation(NewLocation, false, nil, false)
end

function M:OnOutgoingTimelineFinished()
    self.ReturningTimeline:Play()
end

function M:OnReturningTimelineUpdate(Alpha)
    local AvatarActorLocation = self.ReturnToActor:K2_GetActorLocation()
    local NewLocation = UE.UKismetMathLibrary.VLerp(self.ApexLocation, AvatarActorLocation, Alpha)
    self:K2_SetActorLocation(NewLocation, false, nil, false)
    
    self.ExplodeDistance = 150
    if UE.UKismetMathLibrary.VSize(self:K2_GetActorLocation() - self.ReturnToActor:K2_GetActorLocation()) <= self.ExplodeDistance then
        self:OnHit()

        local ActorsToIgnore = UE.TArray(UE.AActor)
        local OverlappingPlayers = UE.TArray(UE.AActor)
        ActorsToIgnore:Add(self:GetOwner())
        ActorsToIgnore:Add(self)
        UE.UAuraAbilitySystemLibrary.GetLivePlayersWithinRadius(self, OverlappingPlayers, ActorsToIgnore, 300, self:K2_GetActorLocation())
        UE.UAuraAbilitySystemLibrary.SetIsRadialDamageEffectParam(self.ExplosionDamageParams, true, 50, 300, self:K2_GetActorLocation())

        for i = 1, OverlappingPlayers:Length() do
            local TargetActor = OverlappingPlayers:Get(i)
            local TargetLocation = TargetActor:K2_GetActorLocation()
            local KnockbackDirection = TargetLocation - self:K2_GetActorLocation()
            local Rotator = UE.UKismetMathLibrary.MakeRotFromX(KnockbackDirection)
            
            UE.UAuraAbilitySystemLibrary.SetTargetEffectParamsASC(self.ExplosionDamageParams, UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(TargetActor))
            UE.UAuraAbilitySystemLibrary.SetKnockbackDirection(self.ExplosionDamageParams, UE.UKismetMathLibrary.GetForwardVector(UE.UKismetMathLibrary.MakeRotator(Rotator.X, 45, Rotator.Z)), 800)
            UE.UAuraAbilitySystemLibrary.SetDeathImpulseDirection(self.ExplosionDamageParams, UE.UKismetMathLibrary.GetForwardVector(UE.UKismetMathLibrary.MakeRotator(Rotator.X, 45, Rotator.Z)), 600)

            UE.UAuraAbilitySystemLibrary.ApplyDamageEffect(self.ExplosionDamageParams)
        end
        
        self:K2_DestroyActor()
    end
end

return M
