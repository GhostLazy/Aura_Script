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
        self:K2_DestroyActor()
    end
end

return M
