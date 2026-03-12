--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Beacon_C
local M = UnLua.Class()

function M:CheckpointReached(DynamicMaterialInstance)
    self.DynamicMaterialInstance = DynamicMaterialInstance;
    self.BeaconTimeline:Play()
end

function M:OnBeaconTimelineUpdate(Value)
    self.DynamicMaterialInstance:SetScalarParameterValue("Glow", Value * 20)
end

function M:ReceiveBeginPlay()
    if self.Sphere then
        self.Sphere.OnComponentBeginOverlap:Add(self, self.OnSphereBeginOverlap)
    end
end

function M:OnSphereBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if UE.UKismetSystemLibrary.DoesImplementInterface(OtherActor, UE.UPlayerInterface.StaticClass()) then
        self:HandleGlowEffects()
        self.bReached = true
    end
end

return M
