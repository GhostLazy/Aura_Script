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
    self.PickupElevationTimeline:Play()
end

function M:ReceiveTick(DeltaSeconds)
    self:K2_SetActorLocation(self.CalculatedLocation, false, nil, false)
    self:K2_SetActorRotation(self.CalculatedRotation, false)
end

function M:OnPickupElevationTimelineUpdate(Elevation, Scale)
    self.CalculatedLocation = self.InitialLocation + UE.FVector(0, 0, Elevation * 100)
    self:SetActorScale3D(UE.FVector(Scale, Scale, Scale))
end

function M:OnPickupElevationTimelineFinished()
    self:StartSinusoidalMovement()
    self:StartRotation()
end

return M
