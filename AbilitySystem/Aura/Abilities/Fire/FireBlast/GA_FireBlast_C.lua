--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type GA_FireBlast_C
local M = UnLua.Class()

function M:K2_ActivateAbility()
    self:K2_CommitAbility()
    self:SpawnFireBalls()
    self:K2_EndAbility()
end

return M