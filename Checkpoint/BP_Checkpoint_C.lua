--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Checkpoint_C
local M = UnLua.Class()

function M:CheckpointReached(DynamicMaterialInstance)
    self.DynamicMaterialInstance = DynamicMaterialInstance;
    self.GlowTimeline:Play()
end

function M:OnGlowTimelineUpdate(Value)
    self.DynamicMaterialInstance:SetScalarParameterValue("Glow", Value * 100)
end

return M
