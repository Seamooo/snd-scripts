require("libfate-data")
require("libfate-utils-v2")

-- TODO(seamooo) this is a placeholder
local MAX_DISTANCE = 2.1
local FULL_CREDIT_MIN_ITEMS = 7
local GYSAHLGREENS_ITEMID = 4868
local DARKMATTER_ITEMID = 33916
local MIN_DARKMATTER = 8
local LIMSA_LOWERDOCKS_ZONEID = 129
-- unsure which is which of below as both
-- are named "Twist of Fate" in Status.csv
local TWISTOFFATE_MAIDEN_STATUS_ID = 1288
local TWISTOFFATE_FORLORN_STATUS_ID = 1289

---@class WrathRotationPlugin
---@field RotationPluginKind "Wrath"
---@field SingleTargetPreset string?
---@field AoePreset string?
---@field HoldBuffPreset string?
---@field PercentageToHoldBuff number?

---@class BossModRotationPlugin
---@field RotationPluginKind "BossMod"
---@field SingleTargetPreset string?
---@field AoePreset string?
---@field HoldBuffPreset string?
---@field PercentageToHoldBuff number?

---@class BossModRebornRotationPlugin
---@field RotationPluginKind "BossModReborn"
---@field SingleTargetPreset string?
---@field AoePreset string?
---@field HoldBuffPreset string?
---@field PercentageToHoldBuff number?

---@alias RotationSolverAoeType
---| "Cleave"
---| "Full"
---| "Off"

---@class RotationSolverRotationPlugin
---@field RotationPluginKind "RotationSolver"
---@field AoeType RotationSolverAoeType

---@alias RotationPlugin
---| WrathRotationPlugin
---| RotationSolverRotationPlugin
---| BossModRotationPlugin
---| BossModRebornRotationPlugin

---@class BossModDodgingPlugin
---@field DodgingPluginKind "BossMod"
---@field SingleTargetPreset string?
---@field AoePreset string?
---@field HoldBuffPreset string?
---@field PercentageToHoldBuff number?

---@class BossModRebornDodgingPlugin
---@field DodgingPluginKind "BossModReborn"
---@field SingleTargetPreset string?
---@field AoePreset string?
---@field HoldBuffPreset string?
---@field PercentageToHoldBuff number?

---@alias DodgingPlugin
---| BossModDodgingPlugin
---| BossModRebornDodgingPlugin

---@class GcTurnInOn
---@field Enabled true
---@field InventorySlotsLeft number

---@class GcTurnInOff
---@field Enabled false

---@alias GcTurnIn
---| GcTurnInOn
---| GcTurnInOff

---@class BicolorExchangeOn
---@field Enabled true
--- TODO(seamooo) should make this an enum type from the data
---@field ItemToPurchase string

---@class BicolorExchangeOff
---@field Enabled false
--- TODO(seamooo) should make this an enum type from the data
---@field ItemToPurchase string

---@alias BicolorExchange
---| BicolorExchangeOn
---| BicolorExchangeOff

---@enum ForlornOpt
local ForlornOpt = {
    None = 0,
    Small = 1,
    All = 2,
}

---@class FateAutomationConfig
---@field Food string?
---@field Potion string?
---@field ResummonChocoboTimeLeft number
---@field ChocoboStance ChocoboStance?
---@field ForlornCfg ForlornOpt
---@field EnableAutoBuyGysahlGreens boolean
---@field MountToUse string
---@field CompletionToIgnoreFate number?
---@field MinTimeLeftToIgnoreFate number
---@field CompletionToJoinBossFate number
---@field CompletionToJoinSpecialBossFate number
---@field MainJob JobWrapper
---@field BossFatesJob JobWrapper?
---@field RotationPlugin RotationPlugin
---@field DodgingPlugin DodgingPlugin?
---@field MinWait number
---@field MaxWait number
---@field RepairPercent number?
---@field EnableDowntimeWaitAtNearestAetheryte boolean
---@field EnableMoveToRandomSpot boolean
---@field GcTurnIn GcTurnIn
---@field EnableWaitIfBonusBuff boolean
---@field EnableSelfRepair boolean
---@field EnableAutoExtractMateria boolean
---@field EnableAutoBuyDarkMatter boolean
---@field EnableChangeInstace boolean
---@field EnableReturnOnDeath boolean
---@field EnableRetainers boolean
FateAutomationConfig = {}
FateAutomationConfig.__index = FateAutomationConfig

---@return FateAutomationConfig
function FateAutomationConfig.default()
    return {
        Food = nil,
        Potion = nil,
        ResummonChocoboTimeLeft = 3 * 60,
        ChocoboStance = ChocoboStance.Healer,
        ForlornCfg = ForlornOpt.None,
        EnableAutoBuyGysahlGreens = true,
        MountToUse = "mount roulette",
        CompletionToIgnoreFate = 80,
        MinTimeLeftToIgnoreFate = 180,
        CompletionToJoinBossFate = 0,
        CompletionToJoinSpecialBossFate = 20,
        MainJob = Player.Job,
        BossFatesJob = nil,
        -- TODO(seamooo) make this more robust by checking
        -- what rotation plugins are installed
        RotationPlugin = {
            RotationPluginKind = "Wrath",
        },
        DodgingPlugin = {
            DodgingPluginKind = "BossMod",
        },
        MinWait = 1,
        MaxWait = 3,
        RepairPercent = 30,
        EnableDowntimeWaitAtNearestAetheryte = false,
        EnableMoveToRandomSpot = false,
        GcTurnIn = { Enabled = false },
        EnableWaitIfBonusBuff = true,
        EnableSelfRepair = true,
        EnableAutoExtractMateria = true,
        EnableAutoBuyDarkMatter = true,
        EnableChangeInstance = true,
        EnableReturnOnDeath = true,
        EnableRetainers = false,
    }
end

--TODO(seamooo) investigate whether fate types are mutually exclusive
-- if they are, change to be a union type with discriminator, else
-- add types until mutual exclusivity is met (hopefully very limited subset
-- of the powerset in the worst case)


---@class CollectionsFateCtx
---@field haveMaxCredit boolean

---@class FateTable 
---@field fateObject FateWrapper
---@field fateId number
---@field fateName string
---@field duration number
---@field startTime number
---@field position System_Numerics_Vector3
---@field isBonusFate boolean
---@field npcName string
---@field currentTime number
---@field timeLeft number
---@field timeElapsed number?
---@field isBlacklistedFate boolean
---@field hasContinuation boolean
---@field continuationIsBoss boolean
---@field collectionsFateCtx CollectionsFateCtx?
---@field bossFateCtx boolean
---@field otherNpcFateCtx boolean
---@field specialFateCtx boolean
local FateTable = {}
FateTable.__index = FateTable

---@return boolean
function FateTable:isCollectionsFate()
    return self.collectionsFateCtx ~= nil
end

---@return boolean
function FateTable:isBossFate()
    return self.bossFateCtx
end

---@return boolean
function FateTable:isOtherNpcFate()
    return self.otherNpcFateCtx
end

---@return boolean
function FateTable:isSpecialFate()
    return self.specialFateCtx
end

---@param fateObj FateWrapper
---@param zone ZoneFateInfoExt
---@return FateTable
function BuildFateTable(fateObj, zone)
    local fateTable = {
        fateObject = fateObj,
        fateId = fateObj.Id,
        fateName = fateObj.Name,
        duration = fateObj.Duration,
        startTime = fateObj.StartTimeEpoch,
        position = fateObj.Location,
        isBonusFate = fateObj.IsBonus,
    }

    fateTable.npcName = GetFateNpcName(fateTable.fateName, zone)

    local currentTime = EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime)
    if fateTable.startTime == 0 then
        fateTable.timeLeft = 900
    else
        fateTable.timeElapsed = currentTime - fateTable.startTime
        fateTable.timeLeft = fateTable.duration - fateTable.timeElapsed
    end

    fateTable.collectionsFateCtx = nil
    if IsCollectionsFate(fateTable.fateName, zone) then
        fateTable.collectionsFateCtx = { haveMaxCredit = false }
    end
    fateTable.bossFateCtx = IsBossFate(fateTable.fateObject)
    fateTable.otherNpcFateCtx = IsOtherNpcFate(fateTable.fateName, zone)
    fateTable.specialFateCtx = IsSpecialFate(fateTable.fateName, zone)
    fateTable.isBlacklistedFate = IsBlacklistedFate(fateTable.fateName, zone)

    fateTable.continuationIsBoss = false
    fateTable.hasContinuation = false
    for _, continuationFate in ipairs(zone.fatesList.fatesWithContinuations) do
        if fateTable.fateName == continuationFate.fateName then
            fateTable.hasContinuation = true
            fateTable.continuationIsBoss = continuationFate.continuationIsBoss
        end
    end

    return setmetatable(fateTable, FateTable)
end

---@enum Cmp
local Cmp = {
    Lt = 0,
    Eq = 1,
    Gt = 2,
}

--TODO(seamooo) create a switch zone state to
-- enforce
---@enum AutomationState
local AutomationState = {
    Init                    = 0,
    Ready                   = 1,
    Dead                    = 2,
    UnexpectedCombat        = 3,
    Mounting                = 4,
    NpcDismount             = 5,
    MiddleOfFateDismount    = 6,
    MoveToFate              = 7,
    InteractWithNpc         = 8,
    CollectionsFateTurnIn   = 9,
    DoFate                  = 10,
    WaitForContinuation     = 11,
    ChangingInstances       = 12,
    ChangeInstanceDismount  = 13,
    FlyBackToAetheryte      = 14,
    ExtractMateria          = 15,
    Repair                  = 16,
    ExchangingVouchers      = 17,
    ProcessRetainers        = 18,
    GcTurnIn                = 19,
    SummonChocobo           = 20,
    AutoBuyGysahlGreens     = 21
}

---@class IDisposable
---@field Dispose fun()

---@class StateFunction: IDisposable
---@field Exec fun()

---@class FateAutomation
---@field Config FateAutomationConfig
---@field private currentFate FateTable?
---@field private currentState StateFunction 
---@field private currentZone ZoneFateInfoExt?
---@field private combatModsOn boolean
---@field private teleportManager (fun(aetheryteName: string): boolean)?
FateAutomation = {}
FateAutomation.__index = FateAutomation

---@return FateAutomation
---@param Config FateAutomationConfig
function FateAutomation.new(Config)
    local rv = setmetatable({
        Config = Config,
        currentFate = nil,
        currentState = { Exec = function() end, Dispose = function() end },
        currentZone = nil,
        combatModsOn = false,
        teleportManager = nil,
    }, FateAutomation)
    rv:updateState(AutomationState.Init);
    return rv
end

---@private
function FateAutomation:foodCheck()
    if not HasStatusId(48) and self.Config.Food ~= nil and self.Config.Food ~= "" then
        yield("/item "..self.Config.Food)
    end
end

---@private
function FateAutomation:potCheck()
    if not HasStatusId(49) and self.Config.Potion ~= nil and self.Config.Potion ~= "" then
        yield("/item "..self.Config.Potion)
    end
end

---@private
---@param force boolean?
function FateAutomation:turnOnCombatMods(force)
    if force or not self.combatModsOn then
        self.combatModsOn = true
        local pluginConfig = self.Config.RotationPlugin
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if pluginConfig.RotationPluginKind == "RotationSolver" then
            yield("/rotation off")
            yield("/rotation auto on")
        elseif pluginConfig.RotationPluginKind == "BossModReborn" then
            IPC.BossMod.SetActive(pluginConfig.AoePreset)
        elseif pluginConfig.RotationPluginKind == "BossMod" then
            IPC.BossMod.SetActive(pluginConfig.AoePreset)
        else
            -- TODO(seamooo) phat todo: need to implement wrath ipc so it behaves correctly
            yield("/wrath auto on")
        end
        local dodgingConfig = self.Config.DodgingPlugin
        if dodgingConfig == nil then
            return
        end
        if dodgingConfig.DodgingPluginKind == "BossModReborn" then
            yield("/bmrai on")
            yield("/bmrai followtarget on")
            yield("/bmrai followcombat on")
            yield("/bmrai maxdistancetarget "..MAX_DISTANCE)
            yield("/bmrai followoutofcombat on ")
        elseif dodgingConfig.DodgingPluginKind == "BossMod" then
            -- ensure autotargetting is off
            yield("/vbm cfg AIConfig ForbidActions True")
            yield("/vbm ai on")
        end
    end
end

---@private
---@param force boolean?
function FateAutomation:turnOffCombatMods(force)
    if force or self.combatModsOn then
        self.combatModsOn = false
        if self.Config.RotationPlugin.RotationPluginKind == "RotationSolver" then
            yield("/rotation off")
        elseif self.Config.RotationPlugin.RotationPluginKind == "BossModReborn" then
            IPC.BossMod.ClearActive()
        elseif self.Config.RotationPlugin.RotationPluginKind == "BossMod" then
            IPC.BossMod.ClearActive()
        elseif self.Config.RotationPlugin.RotationPluginKind == "Wrath" then
            yield("/wrath auto off")
        end
        if self.Config.DodgingPlugin == nil then return end
        if self.Config.DodgingPlugin.DodgingPluginKind == "BossModReborn" then
            yield("/bmrai off")
            yield("/bmrai followtarget off")
            yield("/bmrai followcombat off")
            yield("/bmrai followoutofcombat off")
        elseif self.Config.DodgingPlugin.DodgingPluginKind == "BossMod" then
            yield("/vbm ai off")
        end
    end
end

---@private
---@return StateFunction
function FateAutomation:init()
    return {
        Exec = function()
            ---@type string[]
            local requiredPlugins = {
                "TextAdvance",
                "vnavmesh",
                "Lifestream"
            }
            local needBossMod = (
                self.Config.DodgingPlugin ~= nil
                and self.Config.DodgingPlugin.DodgingPluginKind == "BossMod"
            ) or self.Config.RotationPlugin.RotationPluginKind == "BossMod"
            local needBossModReborn = (
                self.Config.DodgingPlugin ~= nil
                and self.Config.DodgingPlugin.DodgingPluginKind == "BossModReborn"
            ) or self.Config.RotationPlugin.RotationPluginKind == "BossModReborn"
            if needBossMod and needBossModReborn then
                -- TODO(seamooo) error text for this would be good
                yield("/echo BossMod and BossModReborn are incompatible, ensure your configuration only uses at most one")
                self:log(tostring(debug.traceback()))
                error("enabled both bossmod and bossmodreborn in config", 2)
            end
            if needBossMod then
                table.insert(requiredPlugins, "BossMod")
            end
            if needBossModReborn then
                table.insert(requiredPlugins, "BossModReborn")
            end
            if self.Config.RotationPlugin.RotationPluginKind == "Wrath" then
                table.insert(requiredPlugins, "WrathCombo")
            end
            if self.Config.RotationPlugin.RotationPluginKind == "RotationSolver" then
                table.insert(requiredPlugins, "RotationSolver")
            end
            self:log("configuration requires "..StringifyArray(requiredPlugins))
            local missingPlugins = false
            for _, plugin in ipairs(requiredPlugins) do
                if not HasPlugin(plugin) then
                    missingPlugins = true
                    yield("/echo missing "..plugin)
                    self:log("missing "..plugin)
                end
            end
            if(missingPlugins) then
                error("some required plugins were missing, check logs for details")
            end
            TurnOnTextAdvance()
            self.turnOffCombatMods(self, true);
            self.currentZone = GetCurrentZone();
            self.teleportManager = NewTeleportManager(
                60,
                function(message) self:logDebug(message) end
            )
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:ready()
    return {
        Exec = function()
            -- TODO(seamooo) multiple features to be implemented will need to be transitioned
            -- to here when implemented (gemstones, instance switching, process retainers,
            -- gc turnin)
            self:foodCheck()
            self:potCheck()
            self:turnOffCombatMods()

            local shouldWaitForBonusBuff = (
                self.Config.EnableWaitIfBonusBuff
                and (
                    HasStatusId(TWISTOFFATE_FORLORN_STATUS_ID)
                    or HasStatusId(TWISTOFFATE_MAIDEN_STATUS_ID)
                )
            )
            local needsRepair = self.Config.RepairPercent ~= nil and Inventory.GetItemsInNeedOfRepairs(self.Config.RepairPercent).Count > 0
            local needsMateriaExtract = self.Config.EnableAutoExtractMateria and Inventory.GetSpiritbondedItems().Count > 0

            -- TODO(seamooo) implement gem turn in here

            if needsRepair and not shouldWaitForBonusBuff then
                self:updateState(AutomationState.Repair)
                return
            end
            if needsMateriaExtract and Inventory.GetFreeInventorySlots() > 1 then
                self:updateState(AutomationState.ExtractMateria)
                return
            end

            if self.currentZone ~= nil and Svc.ClientState.TerritoryType ~= self.currentZone.zoneId then
                self.teleportManager(self.currentZone.aetheryteList[1].name)
                return
            end

            -- TODO(seamooo) implement process retainers / gc turnin here

            if self.Config.ChocoboStance ~= nil
                and GetBuddyTimeRemaining() <= self.Config.ResummonChocoboTimeLeft
                and (
                    (not shouldWaitForBonusBuff and self.Config.EnableAutoBuyGysahlGreens)
                    or Inventory.GetItemCount(GYSAHLGREENS_ITEMID) > 0
                ) then
                self:updateState(AutomationState.SummonChocobo)
                return
            end
            if self.currentFate == nil or not IsFateActive(self.currentFate.fateObject) then
                self.currentFate = self:selectNextFate()
                return
            end
            -- TODO(seamooo) implement switch instances here
            -- TODO(seamooo) implement fly to aetheryte here

            if not Player.Available then
                return
            end
            if self.currentFate ~= nil and self.currentZone ~= nil then
                SetMapFlag(self.currentZone.zoneId, self.currentFate.position)
                self:updateState(AutomationState.MoveToFate)
            end

        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:handleDeath()
    return {
        Exec = function()
            self:turnOffCombatMods()
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            end
            if Svc.Condition[CharacterCondition.dead] then
                if self.Config.EnableReturnOnDeath then
                    if Addons.GetAddon("SelectYesno").Ready then
                        yield("/callback SelectYesno true 0")
                        yield("/wait 0.25")
                    end
                end
            else
                self:updateState(AutomationState.Ready)
            end
        end,
        Dispose = function() end
    }
end

---@alias SuccessClosure fun(): boolean

--- returns true when dismounted successfully
---@param disableFly boolean?
---@return SuccessClosure
local function tryDismount(disableFly)
    ---@type number?
    local lastStuckCheckTime = nil
    return function()
        ---@type boolean
        local isFlying = Svc.Condition[CharacterCondition.flying]
        if isFlying then
            yield('/ac dismount')
            local now = os.clock()
            if lastStuckCheckTime == nil or lastStuckCheckTime - now >= 0.3 then
                local random = RandomAdjustCoordinates(Svc.ClientState.LocalPlayer.Position, 10)
                local nearestFloor = IPC.vnavmesh.PointOnFloor(random, true, 100)
                if nearestFloor ~= nil then
                    IPC.vnavmesh.PathfindAndMoveTo(nearestFloor, not disableFly)
                end
            end
        elseif Svc.Condition[CharacterCondition.mounted] then
            yield("/ac dismount")
        else
            return true
        end
        return false
    end
end

---This method is the intended way to transition into the DoFate
---state, if looking to continue the same fate use `continueDoFate
---@private
---@param fate FateWrapper
function FateAutomation:updateDoFate(fate)
    self.currentFate = BuildFateTable(fate, self.currentZone)
    self:updateState(AutomationState.DoFate)
end

---@private
function FateAutomation:continueDoFate()
    self:updateState(AutomationState.DoFate)
end

---@private
---@return StateFunction
function FateAutomation:handleUnexpectedCombat()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local tryDismountInst = tryDismount(disableFly)
    ---@type number?
    local lastMoveAttempt = nil
    return {
        Exec = function()
            if not Svc.Condition[CharacterCondition.inCombat] then
                yield("/vnav stop")
                self:turnOffCombatMods()
                ClearTarget()
                -- placeholder for random wait
                self:updateState(AutomationState.Ready)
                return
            end
            if not tryDismountInst() then
                return
            end
            self:turnOnCombatMods()
            local nearestFate = Fates.GetNearestFate()
            if InActiveFate() and nearestFate.Progress < 100 then
                self:updateDoFate(nearestFate)
                return
            end

            -- definitely need to fight what is trying to kill you from here
            if Svc.Targets.Target == nil then
                yield("/battletarget")
            end

            if Svc.Targets.Target ~= nil then
                -- TODO(seamooo) rethink how move to target should behave
                if GetDistanceToTargetFlat() > (MAX_DISTANCE + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
                    -- move to target as we've already dismounted so can't fly
                    local now = os.clock()
                    if lastMoveAttempt == nil or lastMoveAttempt - now > 0.3 then
                        lastMoveAttempt = now
                        yield("/vnav movetarget")
                    end
                end
            end
        end,
        Dispose = function() end
    }
end

---@private
function FateAutomation:mount()
    -- TODO(seamooo) rethink mount config here
    if Svc.Condition[CharacterCondition.casting] then 
        -- wait for mount cast to complete
        return
    end
    if self.Config.MountToUse == "mount roulette" then
        yield('/gaction "mount roulette"')
    else
        yield('/mount "'..self.Config.MountToUse..'"')
    end
end


---@private
---@return StateFunction
function FateAutomation:mountState()
    return {
        Exec = function()
            if Svc.Condition[CharacterCondition.mounted] then
                self:updateState(AutomationState.MoveToFate)
                return
            end
            self:mount()
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:npcDismount()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local tryDismountInst = tryDismount(disableFly)
    return {
        Exec = function()
            if not tryDismountInst() then
                return
            end
            self:updateState(AutomationState.InteractWithNpc)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:middleOfFateDismount()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local tryDismountInst = tryDismount(disableFly)
    return {
        Exec = function()
            if self.currentFate == nil or not IsFateActive(self.currentFate.fateObject) then
                self:updateState(AutomationState.Ready)
                return
            end
            if Svc.Targets.Target == nil then
                --TODO(seamooo) potentially debounce this
                if not AttemptToTargetClosestFateEnemy() then
                    -- need to move closer to the fate
                    self:updateState(AutomationState.MoveToFate)
                    return
                end
            end
            if GetDistanceToTarget() > (MAX_DISTANCE + GetTargetHitboxRadius() + 5) then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    if Svc.Condition[CharacterCondition.flying] then
                        yield("/vnav flytarget")
                    else
                        yield("/vnav movetarget")
                    end
                end
            else
                if Svc.Condition[CharacterCondition.mounted] then
                    tryDismountInst()
                else
                    yield("/vnav stop")
                    self:updateState(AutomationState.DoFate)
                end
            end
        end,
        Dispose = function() end
    }
end

-- TODO(seamooo) potentially make the comparison function a config

---@enum
local FateCriteria = {
    Progress = 0,
    Bonus = 1,
    TimeLeft = 2,
    Distance = 3,
    DistanceToTeleport = 4,
}

local FateCriteriaPrio = {
    FateCriteria.DistanceToTeleport,
    FateCriteria.Progress,
    FateCriteria.Bonus,
    FateCriteria.TimeLeft,
    FateCriteria.Distance,
}

---@param a number
---@param b number
---@return Cmp
local function cmpNumber(a,b)
    if a < b then return Cmp.Lt end
    if a > b then return Cmp.Gt end
    return Cmp.Eq
end

--- definition of cmp is false is less than true
---@param a boolean
---@param b boolean
---@return Cmp
local function cmpBoolean(a,b)
    if ~a and b then return Cmp.Lt end
    if a and ~b then return Cmp.Gt end
    return Cmp.Eq
end

---transforms progress to a comparable
---@param progress number
---@return number
local function progressTransform(progress)
    if progress >= 100 then
        return -1
    end
    return progress
end

---although this doesn't require "self", keeping it as a method
---in case it becomes configurable
---@private
---@param fateA FateTable
---@param fateB FateTable
---@return Cmp
function FateAutomation:fateCmp(fateA, fateB)
    local comparisons = {
        [FateCriteria.Progress] = function()
            return cmpNumber(progressTransform(fateA.fateObject.Progress), progressTransform(fateB.fateObject.Progress))
        end,
        [FateCriteria.Bonus] = function()
            return cmpBoolean(fateA.isBonusFate, fateB.isBonusFate)
        end,
        [FateCriteria.TimeLeft] = function()
            return cmpNumber(fateA.timeLeft, fateB.timeLeft)
        end,
        [FateCriteria.Distance] = function()
            return cmpNumber(-GetDistanceToPoint(fateA.position), -GetDistanceToPoint(fateB.position))
        end,
        [FateCriteria.DistanceToTeleport] = function()
            return cmpNumber(
                -GetDistanceToPointWithAetheryteTravel(fateA.position, self.currentZone),
                -GetDistanceToPointWithAetheryteTravel(fateB.position, self.currentZone)
            )
        end,
    }
    for _, criteria in pairs(FateCriteriaPrio) do
        local cmpFn = comparisons[criteria];
        if cmpFn ~= nil then
            local cmpResult = cmpFn();
            if cmpResult ~= Cmp.Eq then
                return cmpResult
            end
        end
    end
    return Cmp.Eq
end

---@private
---@return FateTable?
function FateAutomation:selectNextFate()
    local fates = Fates.GetActiveFates()
    if fates == nil then
        return nil
    end
    ---@type FateTable[]
    local filteredFates = {}
    for i = 0, fates.Count-1 do
        local tpFate = BuildFateTable(fates[i], self.currentZone)
        if (tpFate.position.X == 0 and tpFate.position.Z == 0) then
            self:logDebug("Found fate with zero coords ("..tpFate.fateName.."). Skipping..")
        elseif tpFate.isBlacklistedFate then
            self:logDebug("found blacklisted fate ("..tpFate.fateName.."). Skipping..")
        elseif tpFate:isBossFate() and (
                (tpFate:isSpecialFate() and tpFate.fateObject.Progress < self.Config.CompletionToJoinSpecialBossFate) or
                (not tpFate:isSpecialFate() and tpFate.fateObject.Progress < self.Config.CompletionToJoinBossFate)
            ) then
            self:logDebug("Boss fate is not at required completion percent ("..tpFate.fateName.."). Skipping..")
        elseif tpFate.duration == 0 and not (
            (
                tpFate.isOtherNpcFate or tpFate.isCollectionsFate
            ) and tpFate.startTime == 0) then
            self:logDebug("Found fate with duration zero ("..tpFate.fateName.."). Skipping..")
        else
            -- filtered elements here
            table.insert(filteredFates, tpFate)
        end
    end
    ---@type FateTable?
    local rv = nil
    for _, fateTable in pairs(filteredFates) do
        if rv == nil or self:fateCmp(rv,fateTable) == Cmp.Lt then
            rv = fateTable
        end
    end
    return rv
end

---@param disableFly boolean
local function newAntiStuckChecker(disableFly)
    ---@type number?
    local lastStuckCheckTime = nil
    ---@type System_Numerics_Vector3?
    local lastStuckCheckPosition = nil
    ---@type number?
    local lastExecAntiStuckTime = nil
    return function()
        local now = os.clock()
        if lastExecAntiStuckTime ~= nil and now - lastStuckCheckTime < 8 then
            -- give antistuck significant time to execute
            return
        end
        if lastStuckCheckTime == nil or now - lastStuckCheckTime > 3 then
            lastStuckCheckTime = now
            if lastStuckCheckPosition == nil then
                lastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
                return
            end
            if GetDistanceToPoint(lastStuckCheckPosition) < 3 then
                local newPos = Svc.ClientState.LocalPlayer.Position + Vector3(0,10,0)
                -- TODO(seamooo) debug semantics of this movement
                yield("/vnav stop")
                yield("/wait 0.5")
                IPC.vnavmesh.PathfindAndMoveTo(newPos, Svc.Condition[CharacterCondition.flying] and not disableFly)
                lastExecAntiStuckTime = os.clock()
            end
            lastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
    end
end

---@private
---@param nextFate FateTable
---@return boolean
function FateAutomation:teleportToClosestAetheryteToFate(nextFate)
    local aetheryteForClosestFate = GetClosestAetheryteToPoint(nextFate.position, 200, self.currentZone)
    if aetheryteForClosestFate ~=nil then
        yield("/vnav stop")
        return self.teleportManager(aetheryteForClosestFate.name)
    end
    return false
end

---@private
---@return StateFunction
function FateAutomation:moveToFate()
    -- TODO(seamooo) implement "successive instance changes"
    ---@type number?
    local timeSinceCheckedFate = nil
    local nextFate = nil
    ---@type System_Numerics_Vector3?
    local targetPos = nil
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local antiStuckChecker = newAntiStuckChecker(disableFly)
    return {
        Exec = function()
            if not Player.Available then
                return
            end
            if self.currentFate ~= nil and not IsFateActive(self.currentFate.fateObject) then
                -- fate is dead
                self:updateState(AutomationState.Ready)
                return
            end
            local now = os.clock()
            if timeSinceCheckedFate == nil or now - timeSinceCheckedFate > 2 then
                nextFate = self:selectNextFate()
            end
            if nextFate == nil then
                yield("/vnav stop")
                self:updateState(AutomationState.Ready)
                return
            elseif self.currentFate == nil or nextFate.fateId ~= self.currentFate.fateId then
                -- picked new fate
                yield("/vnav stop")
                self.currentFate = nextFate
                SetMapFlag(self.currentZone.zoneId, self.currentFate.position)
                return
            end

            -- swap jobs for fate
            if self.Config.BossFatesJob ~= nil then
                local currentJob = Player.Job.Id
                if self.currentFate:isBossFate() and currentJob ~= self.Config.BossFatesJob.Id then
                    yield("/gs change"..self.Config.BossFatesJob.Name)
                    return
                elseif not self.currentFate:isBossFate() and currentJob ~= self.Config.MainJob.Id then
                    yield("/gs change"..self.Config.MainJob.Name)
                    return
                end
            end

            -- target an npc/enemy when close to fate and path to them
            if GetDistanceToPoint(self.currentFate.position) < 60 then
                if Svc.Targets.Target == nil then
                    if (self.currentFate:isOtherNpcFate() or self.currentFate:isCollectionsFate()) and not InActiveFate() then
                        yield("/target "..self.currentFate.npcName)
                    else
                        AttemptToTargetClosestFateEnemy()
                    end
                    -- TODO(seamooo) may need a wait here for stability
                    return
                else
                    if (self.currentFate:isOtherNpcFate() or self.currentFate:isCollectionsFate()) and not InActiveFate() then
                        self:updateState(AutomationState.InteractWithNpc)
                        return
                    else
                        self:updateState(AutomationState.MiddleOfFateDismount)
                        return
                    end
                end
            end

            -- antistuck
            if (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) and Svc.Condition[CharacterCondition.mounted] then
                antiStuckChecker()
            end

            -- teleports if teleporting to aetheryte is faster than straight travel
            if self:teleportToClosestAetheryteToFate(self.currentFate) then
                return
            end

            -- refreshes after mounting
            if targetPos == nil then
                targetPos = nextFate.position
                if not (nextFate:isCollectionsFate() or nextFate:isOtherNpcFate()) then
                    targetPos = RandomAdjustCoordinates(targetPos, 10)
                end
            end

            -- mount and move to flag
            if GetDistanceToPoint(targetPos) > 5 then
                if not Svc.Condition[CharacterCondition.mounted] then
                    self:updateState(AutomationState.Mounting)
                    return
                elseif not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
                    if Player.CanFly and not disableFly then
                        yield("/vnav flyflag")
                    else
                        yield("/vnav moveflag")
                    end
                end
            else
                self:updateState(AutomationState.MiddleOfFateDismount)
                return
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:interactWithFateNpc()
    return {
        Exec = function()
            if self.currentFate == nil then
                self:logDebug("current fate unset, returning to ready")
                self:updateState(AutomationState.Ready)
            end
            if self.currentFate.npcName == nil then
                self:logDebug("no npc set, returning to ready")
                self:updateState(AutomationState.Ready)
            end
            if InActiveFate() or self.currentFate.startTime > 0 then
                yield("/vnav stop")
                self:updateDoFate(self.currentFate.fateObject)
                return
            elseif not IsFateActive(self.currentFate.fateObject) then
                -- fate disappeared
                self:updateState(AutomationState.Ready)
                return
            else
                -- target npc, not changing if already selected
                if(Svc.Targets.Target == nil or GetTargetName() ~= self.currentFate.npcName) then
                    yield("/target "..self.currentFate.npcName)
                end
                if Svc.Condition[CharacterCondition.mounted] then
                    self:updateState(AutomationState.NpcDismount)
                    return
                end
                -- move to npc if out of range
                if GetDistanceToPoint(Svc.Targets.Target.Position) > 5 then
                    yield("/vnav movetarget")
                    return
                end

                if Addons.GetAddon("SelectYesno").Ready then
                    -- select menu when available
                    AcceptNPCFateOrRejectOtherYesno()
                elseif not Svc.Condition[CharacterCondition.occupied] then
                    -- interact with npc
                    yield("/interact")
                    yield("/wait 0.25")
                end
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:collectionsFateTurnIn()
    -- momoise currentFate, it will be the same
    -- throughout state lifetime
    local currentFate = self.currentFate
    return {
        Exec = function()
            AcceptNPCFateOrRejectOtherYesno()
            if currentFate == nil or not IsFateActive(currentFate.fateObject) then
                self:updateState(AutomationState.Ready)
                return
            end
            local collectionsFateCtx = currentFate.collectionsFateCtx
            if collectionsFateCtx == nil then
                self:log("internal error: reached collectionsFateTurnIn without a collectionsFateCtx")
                self:updateState(AutomationState.Ready)
                return
            end
            if (Svc.Targets.Target == nil or GetTargetName() ~= currentFate.npcName) then
                self:turnOffCombatMods()
                yield("/target "..currentFate.npcName)
                -- potential wait here for stability
                if (Svc.Targets.Target == nil or GetTargetName() ~= currentFate.npcName) then
                    if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                        IPC.vnavmesh.PathfindAndMoveTo(currentFate.position, false)
                    end
                else
                    yield("/vnav stop")
                end
                return
            end

            if GetDistanceToTarget() > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    yield("/vnav movetarget")
                end
            else
                if Inventory.GetItemCount(currentFate.fateObject.EventItem) >= 7 then
                    collectionsFateCtx.haveMaxCredit = true
                end
                yield("/vnav stop")
                yield("/interact")
                yield("/wait 0.25")
                if currentFate.fateObject.Progress < 100 or not collectionsFateCtx.haveMaxCredit then
                    self:continueDoFate()
                    return
                end
                self:updateState(AutomationState.UnexpectedCombat)
            end
        end,
        Dispose = function() end
    }
end

---@enum FateTargetEntity
local FateTargetEntity = {
    Battle = 0,
    IdleFateMob = 1,
    Gatherables = 2,
    Adds = 3,
    Boss = 4,
    ForlornMaiden = 5,
    Forlorn = 6,
    ClosestFateMob = 7,
}

---@private
---@return FateTargetEntity[]
function FateAutomation:getTargetPriority()
    if self.currentFate == nil then
        return {}
    end
    ---@type JobWrapper
    local intendedJob = self.Config.MainJob
    local bossJob = self.Config.BossFatesJob
    if self.currentFate:isBossFate() and bossJob ~= nil then
        intendedJob = bossJob
    end
    ---@type FateTargetEntity[]
    local rv = {}
    ---@type { [ForlornOpt]: FateTargetEntity[] }
    local jmpTable = {
        [ForlornOpt.All] = { FateTargetEntity.ForlornMaiden, FateTargetEntity.Forlorn },
        [ForlornOpt.Small] = { FateTargetEntity.ForlornMaiden },
    }
    local forlorns = jmpTable[self.Config.ForlornCfg]
    if forlorns ~= nil then
        for _, x in ipairs(forlorns) do
            table.insert(rv, x)
        end
    end
    -- TODO(seamooo) below check can be more sophisticated
    local canPullMultiple = intendedJob.IsTank
    if self.currentFate:isBossFate() then
        local appendVals = {
            FateTargetEntity.Adds,
            FateTargetEntity.Battle,
            FateTargetEntity.Boss,
        }
        for _, x in ipairs(appendVals) do
            table.insert(rv, x)
        end
    elseif self.currentFate:isCollectionsFate() then
        local appendVals = {
            FateTargetEntity.Battle,
            FateTargetEntity.Gatherables,
            FateTargetEntity.IdleFateMob,
            FateTargetEntity.ClosestFateMob,
        }
        for _, x in ipairs(appendVals) do
            table.insert(rv, x)
        end
    elseif canPullMultiple then
        local appendVals = {
            FateTargetEntity.IdleFateMob,
            FateTargetEntity.Battle,
            FateTargetEntity.ClosestFateMob,
        }
        for _, x in ipairs(appendVals) do
            table.insert(rv, x)
        end
    else
        local appendVals = {
            FateTargetEntity.Battle,
            FateTargetEntity.IdleFateMob,
            FateTargetEntity.ClosestFateMob,
        }
        for _, x in ipairs(appendVals) do
            table.insert(rv, x)
        end
    end
    return rv
end

-- will require self when max_distance becomes config / inferred
---@private
function FateAutomation:moveToTargetHitbox()
    if Svc.Targets.Target == nil then
        return
    end
    local playerPos = Svc.ClientState.LocalPlayer.Position
    local targetPos = Svc.Targets.Target.Position
    local distance = GetDistanceToTarget()
    if distance == 0 then return end
    local desiredRange = math.max(0.1, GetTargetHitboxRadius() + GetPlayerHitboxRadius() + MAX_DISTANCE)
    local STOP_EPS = 0.15
    if distance <= (desiredRange + STOP_EPS) then return end
    local dir = Normalize(playerPos - targetPos)
    if dir:Length() == 0 then return end
    local ideal = targetPos + (dir * desiredRange)
    local newPos = IPC.vnavmesh.PointOnFloor(ideal, false, 1.5) or ideal
    IPC.vnavmesh.PathfindAndMoveTo(newPos, false)
end

---@private
---@return StateFunction
function FateAutomation:doFate()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local targetPrio = self:getTargetPriority()
    -- memoise jmpTable such that it doesn't
    -- need to be created every function call
    ---@type { [FateTargetEntity]: fun(): boolean }
    local targetJmpTable = {
        [FateTargetEntity.Battle] = TargetBattle,
        [FateTargetEntity.IdleFateMob] = function() return TargetIdleFateMob(self.currentFate.fateObject) end,
        [FateTargetEntity.Gatherables] = function() return TargetFateGatherable(self.currentFate.fateObject) end,
        [FateTargetEntity.Adds] = function() return TargetFateAdds(self.currentFate.fateObject) end,
        [FateTargetEntity.Boss] = function() return TargetFateBoss(self.currentFate.fateObject) end,
        [FateTargetEntity.ForlornMaiden] = TargetForlornMaiden,
        [FateTargetEntity.Forlorn] = TargetForlorn,
        [FateTargetEntity.ClosestFateMob] = function() return TargetClosestFateMob(self.currentFate.fateObject) end,
    }
    return {
        Exec = function()
            if self.currentFate == nil then
                self:log("internal error: unset current fate inside doFate, check code path")
                self:updateState(AutomationState.Ready)
            end
            local currentJob = Player.Job
            if self.currentFate:isBossFate() and self.Config.BossFatesJob ~= nil and currentJob.Id ~= self.Config.BossFatesJob.Id then
                self:turnOffCombatMods()
                yield("/gs change "..self.Config.BossFatesJob.Name)
                return
            elseif not self.currentFate:isBossFate() and self.Config.MainJob.Id ~= currentJob.Id then
                self:turnOffCombatMods()
                yield("/gs change "..self.Config.MainJob.Name)
                return
                -- XXX(seamooo) known that below comparison had failures previously
                -- uncertain if due to self.currentFate being nil or self.currentFate.fateObject.MaxLevel being nil
            elseif InActiveFate() and (self.currentFate.fateObject.MaxLevel < Player.Job.Level) and not Player.IsLevelSynced then
                yield("/lsync")
                -- potential wait here for stability
            elseif IsFateActive(self.currentFate.fateObject)
                and not InActiveFate()
                and self.currentFate.fateObject.Progress ~= nil
                and self.currentFate.fateObject.Progress < 100
                and (GetDistanceToPoint(self.currentFate.position) < self.currentFate.fateObject.Radius + 10)
                and not Svc.Condition[CharacterCondition.mounted]
                and not (
                    IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()
                ) then -- got pushed out of fate. go back
                yield("/vnav stop")
                self:logDebug("pushed out of fate -> pathing back")
                IPC.vnavmesh.PathfindAndMoveTo(self.currentFate.position, Player.CanFly and not disableFly)
                return
            elseif not IsFateActive(self.currentFate.fateObject) or self.currentFate.fateObject.Progress == 100 then
                yield("/vnav stop")
                ClearTarget()
                if self.currentFate.hasContinuation then
                    self:updateState(AutomationState.WaitForContinuation)
                else
                    self:turnOffCombatMods()
                    self:updateState(AutomationState.Ready)
                end
            elseif Svc.Condition[CharacterCondition.mounted] then
                self:updateState(AutomationState.MiddleOfFateDismount)
                return
            elseif self.currentFate.collectionsFateCtx ~= nil then
                if (
                    self.currentFate.fateObject.EventItem ~= 0
                    and Inventory.GetItemCount(self.currentFate.fateObject.EventItem) >= FULL_CREDIT_MIN_ITEMS
                ) or (
                    self.currentFate.collectionsFateCtx.haveMaxCredit
                    and self.currentFate.fateObject.Progress == 100
                ) then
                    yield("/vnav stop")
                    self:updateState(AutomationState.CollectionsFateTurnIn)
                end
            end
            -- clear fatenpc if targeted
            if self.currentFate.npcName ~= nil and self.currentFate.npcName ~= "" and GetTargetName() == self.currentFate.npcName then
                ClearTarget()
                return
            end
            self:turnOnCombatMods()
            -- select highest priority target available
            ---@type FateTargetEntity
            local targetTy = nil
            for _, ty in ipairs(targetPrio) do
                local targetFn = targetJmpTable[ty]
                if targetFn ~= nil then
                    if targetFn() then
                        targetTy = ty
                        break
                    end
                end
            end
            if targetTy == nil then
                -- no target found
                return
            end
            local target = Svc.Targets.Target
            if target == nil then
                -- target hasn't registered yet
                return
            end
            if targetTy == FateTargetEntity.Gatherables then
                self:logDebug("in gatherables")
                if Svc.Condition[CharacterCondition.casting] then
                    -- finish interact
                    return
                elseif GetDistanceToPoint(target.Position) > MAX_DISTANCE then
                    if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                        IPC.vnavmesh.PathfindAndMoveTo(target.Position, false)
                    end
                else
                    yield("/vnav stop")
                    yield("/interact")
                end
                return
            end
            -- TODO(seamooo) hold buff implementations as well as picking between
            -- aoe preset and single target preset need to be implemented here
            if GetDistanceToTargetFlat() < (MAX_DISTANCE + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
                if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                    yield("/vnav stop")
                end
            elseif not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) and not Svc.Condition[CharacterCondition.casting] then
                self:moveToTargetHitbox()
                return
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:waitForContinuation()
    local waitStart = os.clock()
    return {
        Exec = function()
            if InActiveFate() then
                local nextFateId = Fates.GetNearestFate()
                if self.currentFate == nil or nextFateId ~= self.currentFate.fateObject then
                    self:updateDoFate(nextFateId)
                    return
                end
            elseif os.clock() - waitStart > 30 then
                self:logDebug("expected continuation fate timed out")
                self:updateState(AutomationState.Ready)
            else
                if self.Config.BossFatesJob ~= nil then
                    local currentJob = Player.Job.Id
                    if not Player.IsBusy then
                        if self.currentFate ~= nil and self.currentFate.continuationIsBoss and currentJob ~= self.Config.BossFatesJob.Id then
                            yield("/gs change "..self.Config.BossFatesJob.Name)
                        elseif self.currentFate ~= nil and not self.currentFate.continuationIsBoss and currentJob ~= self.Config.BossFatesJob.Id then
                            yield("/gs change "..self.Config.MainJob.Name)
                        end
                    end
                end
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:changeInstance()
    --TODO(seamooo) implement this feature
    return {
        Exec = function()
            self:logDebug("feature disabled")
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:changeInstanceDismount()
    --TODO(seamooo) implement this feature
    return {
        Exec = function()
            self:logDebug("feature disabled")
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:flyBackToAetheryte()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    return {
        Exec = function()
            local nextFate = self:selectNextFate()
            if nextFate ~= nil then
                self:updateState(AutomationState.Ready)
                return
            end
            local closestAetheryte = GetClosestAetheryteToPoint(Svc.ClientState.LocalPlayer.Position, 200, self.currentZone)
            yield("/target aetheryte")
            if Svc.Targets.Target ~= nil and GetTargetName() == "aetheryte" and GetDistanceToTarget() <= 20 then
                if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                    yield("/vnav stop")
                end
                if Svc.Condition[CharacterCondition.flying] then
                    yield("/ac dismount") -- land
                elseif Svc.Condition[CharacterCondition.mounted] then
                    self:updateState(AutomationState.Ready)
                else
                    self:mount()
                end
                return
            end
            if self.currentZone == nil then
                self:log("internal error: reached flyBackToAetheryte with unset zone")
                self:updateState(AutomationState.Ready)
                return
            end

            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                if closestAetheryte ~= nil then
                    SetMapFlag(self.currentZone.zoneId, closestAetheryte.position)
                    IPC.vnavmesh.PathfindAndMoveTo(closestAetheryte.position, Player.CanFly and not disableFly)
                end
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:extractMateria()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local tryDismountInst = tryDismount(disableFly)
    return {
        Exec = function()
            if Svc.Condition[CharacterCondition.mounted] then
                tryDismountInst()
                return
            end
            if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
                return
            end
            if Inventory.GetSpiritbondedItems().Count > 0 and Inventory.GetFreeInventorySlots() > 1 then
                if not Addons.GetAddon("Materialize").Ready then
                    yield("/generalaction \"Materia Extraction\"")
                    yield("/wait 0.25")
                    return
                end
                if Addons.GetAddon("MaterializeDialog").Ready then
                    return
                --     yield("/callback MaterializeDialog true 0")
                --     yield("/wait 0.25")
                else
                    yield("/callback Materialize true 2 0")
                    yield("/wait 0.25")
                end
            else
                if Addons.GetAddon("Materialize").Ready then
                    yield("/callback Materialize true -1")
                    yield("/wait 0.25")
                else
                    self:updateState(AutomationState.Ready)
                end
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:repair()
    local disableFly = self.currentZone ~= nil and not self.currentZone.flying
    local tryDismountInst = tryDismount(disableFly)
    -- memoise to enforce immutability throughout closure lifetime
    local selectedZone = self.currentZone
    local repairPercent = self.Config.RepairPercent
    return {
        Exec = function()
            if repairPercent == nil then
                self:log("internal error: entered repair state when repair disabled")
                self:updateState(AutomationState.Ready)
                return
            end
            local needsRepair = Inventory.GetItemsInNeedOfRepairs(repairPercent)
            if Addons.GetAddon("SelectYesno").Ready then
                yield("/callback SelectYesno true 0")
                yield("/wait 0.25")
                return
            end
            if Addons.GetAddon("Repair").Ready then
                if needsRepair.Count == nil or needsRepair.Count == 0 then
                    yield("/callback Repair true -1")
                    yield("/wait 0.25")
                else
                    yield("/callback Repair true 0")
                    yield("/wait 0.25")
                end
            end
            if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
                -- block until repair finished
                return
            end
            local hawkersAlleyAethernetShard = {position = Vector3(-213.95, 15.99, 49.35)}
            if needsRepair.Count > 0 then
                if self.Config.EnableSelfRepair and Inventory.GetItemCount(DARKMATTER_ITEMID) >= MIN_DARKMATTER then
                    if Addons.GetAddon("Shop").Ready then
                        yield("/callback Shop true -1")
                        yield("/wait 0.25")
                        return
                    end
                    if Svc.Condition[CharacterCondition.mounted] then
                        tryDismountInst()
                        return
                    end
                    yield("/generalaction repair")
                    yield("/wait 0.25")
                elseif self.Config.EnableSelfRepair and self.Config.EnableAutoBuyDarkMatter then
                    if Svc.ClientState.TerritoryType ~= LIMSA_LOWERDOCKS_ZONEID then
                        if selectedZone == nil then
                            self:log("internal error: unset selected zone when attempting to teleport away")
                            self:updateState(AutomationState.Ready)
                            return
                        end
                        self.teleportManager("Limsa Lominsa Lower Decks")
                        return
                    end
                    -- TODO(seamooo) make this configurable
                    local darkMatterVendor = {npcName="Unsynrael", position = Vector3(-257.71, 16.19, 50.11), wait=0.08}
                    if GetDistanceToPoint(darkMatterVendor.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, darkMatterVendor.position) + 10) then
                        yield("/li Hawkers' Alley")
                        -- potential wait here for stability
                    elseif Addons.GetAddon("telepotTown").Ready then
                        yield("/callback TeledpotTown false -1")
                        yield("/wait 0.25")
                    elseif GetDistanceToPoint(darkMatterVendor.position) > 5 then
                        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                            IPC.vnavmesh.PathfindAndMoveTo(darkMatterVendor.position, false)
                        end
                    else
                        if Svc.Targets.Target == nil or GetTargetName() ~= darkMatterVendor.npcName then
                            yield("/target "..darkMatterVendor.npcName)
                            yield("/wait 0.25")
                        elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                            yield("/interact")
                            yield("/wait 0.25")
                        elseif Addons.GetAddon("SelectYesno").Ready then
                            yield("/callback SelectYesno true 0")
                            yield("/wait 0.25")
                        elseif Addons.GetAddon("Shop") then
                            yield("/callback Shop true 0 40 99")
                            yield("/wait 0.25")
                        end
                    end
                else
                    -- fallthrough to vendor repair
                    if Svc.ClientState.TerritoryType ~= LIMSA_LOWERDOCKS_ZONEID then
                        if selectedZone == nil then
                            self:log("internal error: unset selected zone when attempting to teleport away")
                            self:updateState(AutomationState.Ready)
                            return
                        end
                        self.teleportManager("Limsa Lominsa Lower Decks")
                        return
                    end
                    local mender = { npcName="Alistair", position = Vector3(-246.87, 16.19, 49.83)}
                    if GetDistanceToPoint(mender.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, mender.position) + 10) then
                        yield("/li Hawkers' Alley")
                        -- potential wait here for stability
                    elseif Addons.GetAddon("TelepotTown").Ready then
                        yield("/callback TelepotTown false -1")
                        yield("/wait 0.25")
                    elseif GetDistanceToPoint(mender.position) > 5 then
                        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                            IPC.vnavmesh.PathfindAndMoveTo(mender.position, false)
                        end
                    else
                        if Svc.Targets.Target == nil or GetTargetName() ~= mender.npcName then
                            yield("/target "..mender.npcName)
                        elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                            yield("/interact")
                        end
                    end
                end
            elseif selectedZone ~= nil and Svc.ClientState.TerritoryType ~= selectedZone.zoneId then
                -- tp back to zone if needed to tp away
                self.teleportManager(selectedZone.aetheryteList[1].name)
            else
                self:updateState(AutomationState.Ready)
            end
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:executeBicolorExchange()
    --TODO(seamooo) implement this feature
    return {
        Exec = function()
            self:logDebug("feature disabled")
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:processRetainers()
    --TODO(seamooo) implement this feature
    return {
        Exec = function()
            self:logDebug("feature disabled")
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:grandCompanyTurnIn()
    --TODO(seamooo) implement this feature
    return {
        Exec = function()
            self:logDebug("feature disabled")
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:summonChocobo()
    return {
        Exec = function()
            if Svc.Condition[CharacterCondition.mounted] then
                Dismount()
                return
            end
            if self.Config.ChocoboStance ~= nil and GetBuddyTimeRemaining() <= self.Config.ResummonChocoboTimeLeft then
                self:logDebug("wants to summon chocobo")
                if Inventory.GetItemCount(GYSAHLGREENS_ITEMID) > 0 then
                    yield("/item Gysahl Greens")
                    yield("/wait 3")
                    --- TODO(seamooo) any attempt to stance chocobo should be 
                    --- checked whether that stance is available to avoid error
                    --- spam
                    yield('/cac "'..StringifyChocoboStance(self.Config.ChocoboStance)..' stance"')
                elseif self.Config.EnableAutoBuyGysahlGreens then
                    self:logDebug("needs to get gysahl greens")
                    self:updateState(AutomationState.AutoBuyGysahlGreens)
                    return
                end
            end
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end
    }
end

---@private
---@return StateFunction
function FateAutomation:autoBuyGysahlGreens()
    return {
        Exec = function()
            if Inventory.GetItemCount(4868) > 0 then
                -- have gysahl greens, no need to buy, cleanup any artifacts
                if Addons.GetAddon("Shop").Ready then
                    yield("/callback Shop true -1")
                    yield("/wait 0.25")
                elseif Svc.ClientState.TerritoryType == self.currentZone.zoneId then
                    yield("/item Gysahl Greens")
                    yield("/wait 0.25")
                else
                    self:updateState(AutomationState.Ready)
                end
                return
            end
            if Svc.ClientState.TerritoryType ~= 129 then
                -- TODO(seamooo) make vendor configurable
                yield("/vnav stop")
                self.teleportManager("Limsa Lominsa Lower Decks")
                return
            end
            local gysahlGreensVendor = { position=Vector3(-62.1, 18.0, 9.4), npcName="Bango Zango" }
            if GetDistanceToPoint(gysahlGreensVendor.position) > 5 then
                if not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then
                    IPC.vnavmesh.PathfindAndMoveTo(gysahlGreensVendor.position, false)
                end
            elseif Svc.Targets.Target ~= nil and GetTargetName() == gysahlGreensVendor.npcName then
                -- npc is targeted, do interact
                yield("/vnav stop")
                if Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                    yield("/wait 0.25")
                elseif Addons.GetAddon("SelectIconString").Ready then
                    yield("/callback SelectIconString true 0")
                    yield("/wait 0.25")
                elseif Addons.GetAddon("Shop").Ready then
                    yield("/callback Shop true 0 5 99")
                    yield("/wait 0.25")
                elseif not Svc.Condition[CharacterCondition.occupied] then
                    yield("/interact")
                    yield("/wait 0.25")
                    -- potential wait here for stability
                end
            else
                yield("/vnav stop")
                yield("/target "..gysahlGreensVendor.npcName)
            end
        end,
        Dispose = function() end
    }
end

---@private
---This method should be used in place of Dalamud.LogDebug
---such that the logging mechanism may be hooked into with
---configuration
---TODO(seamooo) make the logging configurable
---@param message string
function FateAutomation:logDebug(message)
    Dalamud.LogDebug("[FATE] "..message)
end

---@private
---This method should be used in place of Dalamud.LogVerbose
---such that the logging mechanism may be hooked into with
---configuration
---TODO(seamooo) make the logging configurable
---@param message string
function FateAutomation:log(message)
    Dalamud.Log("[FATE] "..message)
end

---@private
---This method is the expected setter for state
---state should not be mutated outside of this method
---@param newState AutomationState
function FateAutomation:updateState(newState)
    self:logDebug("update state to "..newState)
    local jTable = {
        [AutomationState.Init] = self.init,
        [AutomationState.Ready] = self.ready,
        [AutomationState.Dead] = self.handleDeath,
        [AutomationState.UnexpectedCombat] = self.handleUnexpectedCombat,
        [AutomationState.Mounting] = self.mountState,
        [AutomationState.NpcDismount] = self.npcDismount,
        [AutomationState.MiddleOfFateDismount] = self.middleOfFateDismount,
        [AutomationState.MoveToFate] = self.moveToFate,
        [AutomationState.InteractWithNpc] = self.interactWithFateNpc,
        [AutomationState.CollectionsFateTurnIn] = self.collectionsFateTurnIn,
        [AutomationState.DoFate] = self.doFate,
        [AutomationState.WaitForContinuation] = self.waitForContinuation,
        [AutomationState.ChangingInstances] = self.changeInstance,
        [AutomationState.ChangeInstanceDismount] = self.changeInstanceDismount,
        [AutomationState.FlyBackToAetheryte] = self.flyBackToAetheryte,
        [AutomationState.ExtractMateria] = self.extractMateria,
        [AutomationState.Repair] = self.repair,
        [AutomationState.ExchangingVouchers] = self.executeBicolorExchange,
        [AutomationState.ProcessRetainers] = self.processRetainers,
        [AutomationState.GcTurnIn] = self.grandCompanyTurnIn,
        [AutomationState.SummonChocobo] = self.summonChocobo,
        [AutomationState.AutoBuyGysahlGreens] = self.autoBuyGysahlGreens
    }
    ---@type fun(FateAutomation): StateFunction
    local initFn = jTable[newState];
    self.currentState.Dispose()
    self.currentState = initFn(self)
end

---@private
function FateAutomation:handleEvents()
    if Svc.Condition[CharacterCondition.dead] and self.currentState ~= AutomationState.Dead then
        self:updateState(AutomationState.Dead)
    end
end

function FateAutomation:run()
    self:handleEvents()
    self.currentState.Exec()
    -- release control for 0.1 to allow game state to update in between calls
    yield("/wait 0.1")
end
