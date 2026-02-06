--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_FireBolt_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

-- function M:ReceiveBeginPlay()
-- end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    if self.LocationThisFrame then
        self.LocationLastFrame = self.LocationThisFrame
    end
    self.LocationThisFrame = self:K2_GetActorLocation()
    if self.LocationLastFrame then
        local Distance = UE.UKismetMathLibrary.VSize(self.LocationThisFrame - self.LocationLastFrame)
        if Distance <= 10 then
            UE.UGameplayStatics.SpawnSoundAtLocation(self, self.ImpactSound, self.LocationThisFrame)
            UE.UNiagaraFunctionLibrary.SpawnSystemAtLocation(self, self.ImpactEffect, self.LocationThisFrame)
            self:K2_DestroyActor()
        end
    end
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return M
