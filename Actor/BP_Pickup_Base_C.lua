--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Pickup_Base_C
local M = UnLua.Class()

function M:ReceiveBeginPlay()
    UE.UGameplayStatics.PlaySoundAtLocation(self, self.SpawnSound, self:K2_GetActorLocation(), self:K2_GetActorRotation())
    self.PickupElevationTimeline:Play()
    self.bHitGround = false
end

function M:ReceiveTick(DeltaSeconds)
    self:K2_SetActorLocation(self.CalculatedLocation, false, nil, false)
    self:K2_SetActorRotation(self.CalculatedRotation, false)
end

function M:OnPickupElevationTimelineUpdate(Elevation, Scale)
    self.CalculatedLocation = self.InitialLocation + UE.FVector(0, 0, Elevation * 100)
    self:SetActorScale3D(UE.FVector(Scale, Scale, Scale))

    if (not self.bHitGround and Elevation < 0) then
        self.bHitGround = true
        UE.UGameplayStatics.PlaySoundAtLocation(self, self.GroundImpactSound, self:K2_GetActorLocation(), self:K2_GetActorRotation())
    end
end

function M:OnPickupElevationTimelineFinished()
    self:StartSinusoidalMovement()
    self:StartRotation()
end

function M:ReceiveDestroyed()
    UE.UGameplayStatics.PlaySoundAtLocation(self, self.ConsumedSound, self:K2_GetActorLocation(), self:K2_GetActorRotation())
end

return M
