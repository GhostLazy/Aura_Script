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
    self:StartSinusoidalMovement()
    self:StartRotation()
end

function M:ReceiveTick(DeltaSeconds)
    self:K2_SetActorLocation(self.CalculatedLocation, false, nil, false)
    self:K2_SetActorRotation(self.CalculatedRotation, false)
end

return M
