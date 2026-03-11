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
    self.DynamicMaterialInstance:SetScalarParameterValue("Glow", Value * 20)
end

function M:HighlightActor()
    self.CheckpointMesh:SetRenderCustomDepth(true)
    self.CheckpointMesh:SetCustomDepthStencilValue(252);
end

function M:UnHighlightActor()
    self.CheckpointMesh:SetRenderCustomDepth(false)
end

return M
