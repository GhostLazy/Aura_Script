--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_EnemyBase_C
local M = UnLua.Class()

function M:SpawnLoot()
    self.LootTiers = UE.UAuraAbilitySystemLibrary.GetLootTiers(self)
    if UE.UKismetSystemLibrary.IsValid(self.LootTiers) then
        self.LootItems = self.LootTiers:GetLootItems()
        self.LootRotations = UE.UAuraAbilitySystemLibrary.EvenlySpreadRotators(
                self:GetActorForwardVector(), UE.UKismetMathLibrary.Vector_Up(), 360, self.LootItems:Length())
        
        self.SpawnLoopCount = 1
        self.LootTimer = UE.UKismetSystemLibrary.K2_SetTimer(self, "SpawnLootItem", 0.1, true)
        self:SpawnLootItem()
    end
end

function M:SpawnLootItem()
    if self.SpawnLoopCount <= self.LootItems:Length() then
        local LootItem = self.LootItems:Get(self.SpawnLoopCount)
        local Rotation = self.LootRotations:Get(self.SpawnLoopCount)
        local SpawnDistance = UE.UKismetMathLibrary.RandomFloatInRange(25, 150)
        local Location = UE.UKismetMathLibrary.GetForwardVector(Rotation) * SpawnDistance + self:K2_GetActorLocation()
        local Transform = UE.UKismetMathLibrary.MakeTransform(Location, Rotation)

        self.Overridden.SpawnLootActor(self, LootItem.LootClass, Transform)   -- self.LootActor = self.Overridden.SpawnLootActor(LootItem.LootClass, Transform)
        self.SpawnLoopCount = self.SpawnLoopCount + 1;
        local LootEffectActor = UE.AAuraEffectActor.Cast(self.LootActor, UE.AAuraEffectActor.StaticClass())
        LootEffectActor.ActorLevel = self.Level
    else
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.LootTimer)
    end
end

return M
