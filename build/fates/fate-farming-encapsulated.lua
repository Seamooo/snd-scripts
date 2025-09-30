-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
--[=====[
[[SND Metadata]]
author: seamooo || forked from baanderson40 || orginially pot0to
version: 0.0.1
description: |
  Fate farming script with the following features:
  - Can purchase Bicolor Gemstone Vouchers (both old and new) when your gemstones are almost capped
  - Priority system for Fate selection: distance w/ teleport > most progress > is bonus fate > least time left > distance
  - Will prioritize Forlorns when they show up during Fate
  - Can do all fates, including NPC collection fates
  - Revives upon death and gets back to fate farming
  - Attempts to change instances when there are no fates left in the zone
  - Can process your retainers and Grand Company turn ins, then get back to fate farming
  - Autobuys gysahl greens and grade 8 dark matter when you run out
plugin_dependencies:
- Lifestream
- vnavmesh
- TextAdvance
configs:
  Rotation Plugin:
    description: What roation plugin to use?
    default: "Any"
    is_choice: true
    choices: ["Any", "Wrath", "RotationSolver","BossMod", "BossModReborn"]
  Dodging Plugin:
    description: What dodging plugin to use. If your Rotation plugin is BMR or VBM, this will be overriden.
    default: "Any"
    is_choice: true
    choices: ["Any", "BossMod", "BossModReborn", "None"]
  BMR/VBM Specific settings:
    description: "--- BMR/VBM Specific settings if you are using one of them as your rotation plugin ---"
    default: false
  Single Target Rotation:
    description: Preset name with single strategies (for forlorns). TURN OFF AUTOMATIC TARGETING FOR THIS PRESET
    default: ""
  AoE Rotation:
    description: Preset with AoE and Buff Strategies.
    default: ""
  Hold Buff Rotation:
    description: Preset to hold 2min burst when progress gets to select percent
    default: ""
  Percentage to Hold Buff:
    description: Ideally you want to make full use of your buffs, higher then 70% will still waste a few seconds if progress is too fast.
    default: 65
  Food:
    description: Leave blank if you dont want to use any food. If its HQ include <hq> next to the name "Baked Eggplant <hq>"
    default: ""
  Potion:
    description: Leave blank if you dont want to use any potions. If its HQ include <hq> next to the name "Superior Spiritbond Potion <hq>"
    default: ""
  Max melee distance:
    default: 2.5
    min: 0
    max: 30
  Max ranged distance:
    default: 20
    min: 0
    max: 30
  Ignore FATE if progress is over (%):
    default: 80
    min: 0
    max: 100
  Ignore FATE if duration is less than (mins):
    default: 3
    min: 0
    max: 100
  Ignore boss FATEs until progress is at least (%):
    default: 0
    min: 0
    max: 100
  Ignore Special FATEs until progress is at least (%):
    default: 20
    min: 0
    max: 100
  Do collection FATEs?:
    default: true
  Do only bonus FATEs?:
    default: false
  Forlorns:
    description: Forlorns to attack.
    default: "All"
    is_choice: true
    choices: ["All", "Small", "None"]
  Change instances if no FATEs?:
    default: false
  Exchange bicolor gemstones for:
    description: Choose none if you dont want to spend your bicolors.
    default: "Turali Bicolor Gemstone Voucher"
    is_choice: true
    choices: ["None",
        "Alexandrian Axe Beak Wing",
        "Alpaca Fillet",
        "Almasty Fur",
        "Amra",
        "Berkanan Sap",
        "Bicolor Gemstone Voucher",
        "Bird of Elpis Breast",
        "Branchbearer Fruit",
        "Br'aax Hide",
        "Dynamis Crystal",
        "Dynamite Ash",
        "Egg of Elpis",
        "Gaja Hide",
        "Gargantua Hide",
        "Gomphotherium Skin",
        "Hammerhead Crocodile Skin",
        "Hamsa Tenderloin",
        "Kumbhira Skin",
        "Lesser Apollyon Shell",
        "Lunatender Blossom",
        "Luncheon Toad Skin",
        "Megamaguey Pineapple",
        "Mousse Flesh",
        "Nopalitender Tuna",
        "Ovibos Milk",
        "Ophiotauros Hide",
        "Petalouda Scales",
        "Poison Frog Secretions",
        "Rroneek Chuck",
        "Rroneek Fleece",
        "Saiga Hide",
        "Silver Lobo Hide",
        "Swampmonk Thigh",
        "Tumbleclaw Weeds",
        "Turali Bicolor Gemstone Voucher",
        "Ty'aitya Wingblade",
        "Ut'ohmu Siderite"]
  Chocobo Companion Stance:
    description: Will not summon chocobo if set to "None"
    default: "Healer"
    is_choice: true
    choices: ["Follow", "Free", "Defender", "Healer", "Attacker", "None"]
  Buy Gysahl Greens?:
    description: Automatically buys a 99 stack of Gysahl Greens from the Limsa gil vendor if none in inventory.
    default: true
  Self repair?:
    description: If checked, will attempt to repair your gear. If not checked, will go to Limsa mender.
    default: true
  Pause for retainers?:
    default: true
  Dump extra gear at GC?:
    description: Used with retainers, in case they come back with too much stuff and clog your inventory.
    default: true
  Return on death?:
    description: Auto accept the box to return to home aetheryte when you die.
    default: true
  Echo logs:
    description: Debug level of logs.
    default: "Gems"
    is_choice: true
    choices: ["All", "Gems", "None"]
[[End Metadata]]
--]=====]
--[[

********************************************************************************
*                                  Changelog                                   *
********************************************************************************
    -> 0.0.1 Encapsulation rewrite
********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    -> VNavmesh :   (for Pathing/Moving)    https://puni.sh/api/repository/veyn
    -> Some form of rotation plugin for attacking enemies. Options are:
        -> RotationSolver Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyns BossMod: https://puni.sh/api/repository/veyn
        -> Wrath Combo: https://love.puni.sh/ment.json
    -> Some form of AI dodging. Options are:
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyns BossMod: https://puni.sh/api/repository/veyn
    -> TextAdvance: (for interacting with Fate NPCs) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
    -> Lifestream :  (for changing Instances [ChangeInstance][Exchange]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

********************************************************************************
*                                Optional Plugins                              *
********************************************************************************

This Plugins are Optional and not needed unless you have it enabled in the settings:

    -> AutoRetainer : (for Retainers [Retainers])   https://love.puni.sh/ment.json
    -> YesAlready : (for extracting materia)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]
require("libfate-automation")

local function main()
    local config = FateAutomationConfig.default()
    local automator = FateAutomation.new(config)
    repeat
        automator:run()
    until false
end

main()

end)
__bundle_register("libfate-automation", function(require, _LOADED, __bundle_register, __bundle_modules)
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
    Init = 0,
    Ready = 1,
    Dead = 2,
    UnexpectedCombat = 3,
    Mounting = 4,
    NpcDismount = 5,
    MiddleOfFateDismount = 6,
    MoveToFate = 7,
    InteractWithNpc = 8,
    CollectionsFateTurnIn = 9,
    DoFate = 10,
    WaitForContinuation = 11,
    ChangingInstances = 12,
    ChangeInstanceDismount = 13,
    FlyBackToAetheryte = 14,
    ExtractMateria = 15,
    Repair = 16,
    ExchangingVouchers = 17,
    ProcessRetainers = 18,
    GcTurnIn = 19,
    SummonChocobo = 20,
    AutoBuyGysahlGreens = 21,
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
    rv:updateState(AutomationState.Init)
    return rv
end

---@private
function FateAutomation:foodCheck()
    if not HasStatusId(48) and self.Config.Food ~= nil and self.Config.Food ~= "" then
        yield("/item " .. self.Config.Food)
    end
end

---@private
function FateAutomation:potCheck()
    if not HasStatusId(49) and self.Config.Potion ~= nil and self.Config.Potion ~= "" then
        yield("/item " .. self.Config.Potion)
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
            yield("/bmrai maxdistancetarget " .. MAX_DISTANCE)
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
        if self.Config.DodgingPlugin == nil then
            return
        end
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
                "Lifestream",
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
                yield(
                    "/echo BossMod and BossModReborn are incompatible, ensure your configuration only uses at most one"
                )
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
            self:log("configuration requires " .. StringifyArray(requiredPlugins))
            local missingPlugins = false
            for _, plugin in ipairs(requiredPlugins) do
                if not HasPlugin(plugin) then
                    missingPlugins = true
                    yield("/echo missing " .. plugin)
                    self:log("missing " .. plugin)
                end
            end
            if missingPlugins then
                error("some required plugins were missing, check logs for details")
            end
            TurnOnTextAdvance()
            self.turnOffCombatMods(self, true)
            self.currentZone = GetCurrentZone()
            self.teleportManager = NewTeleportManager(60, function(message)
                self:logDebug(message)
            end)
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end,
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
                and (HasStatusId(TWISTOFFATE_FORLORN_STATUS_ID) or HasStatusId(TWISTOFFATE_MAIDEN_STATUS_ID))
            )
            local needsRepair = self.Config.RepairPercent ~= nil
                and Inventory.GetItemsInNeedOfRepairs(self.Config.RepairPercent).Count > 0
            local needsMateriaExtract = self.Config.EnableAutoExtractMateria
                and Inventory.GetSpiritbondedItems().Count > 0

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

            if
                self.Config.ChocoboStance ~= nil
                and GetBuddyTimeRemaining() <= self.Config.ResummonChocoboTimeLeft
                and (
                    (not shouldWaitForBonusBuff and self.Config.EnableAutoBuyGysahlGreens)
                    or Inventory.GetItemCount(GYSAHLGREENS_ITEMID) > 0
                )
            then
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
        Dispose = function() end,
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
        Dispose = function() end,
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
            yield("/ac dismount")
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
        Dispose = function() end,
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
        yield('/mount "' .. self.Config.MountToUse .. '"')
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
        Dispose = function() end,
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
        Dispose = function() end,
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
        Dispose = function() end,
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
local function cmpNumber(a, b)
    if a < b then
        return Cmp.Lt
    end
    if a > b then
        return Cmp.Gt
    end
    return Cmp.Eq
end

--- definition of cmp is false is less than true
---@param a boolean
---@param b boolean
---@return Cmp
local function cmpBoolean(a, b)
    if ~a and b then
        return Cmp.Lt
    end
    if a and ~b then
        return Cmp.Gt
    end
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
        local cmpFn = comparisons[criteria]
        if cmpFn ~= nil then
            local cmpResult = cmpFn()
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
    for i = 0, fates.Count - 1 do
        local tpFate = BuildFateTable(fates[i], self.currentZone)
        if tpFate.position.X == 0 and tpFate.position.Z == 0 then
            self:logDebug("Found fate with zero coords (" .. tpFate.fateName .. "). Skipping..")
        elseif tpFate.isBlacklistedFate then
            self:logDebug("found blacklisted fate (" .. tpFate.fateName .. "). Skipping..")
        elseif
            tpFate:isBossFate()
            and (
                (tpFate:isSpecialFate() and tpFate.fateObject.Progress < self.Config.CompletionToJoinSpecialBossFate)
                or (not tpFate:isSpecialFate() and tpFate.fateObject.Progress < self.Config.CompletionToJoinBossFate)
            )
        then
            self:logDebug("Boss fate is not at required completion percent (" .. tpFate.fateName .. "). Skipping..")
        elseif
            tpFate.duration == 0
            and not ((tpFate.isOtherNpcFate or tpFate.isCollectionsFate) and tpFate.startTime == 0)
        then
            self:logDebug("Found fate with duration zero (" .. tpFate.fateName .. "). Skipping..")
        else
            -- filtered elements here
            table.insert(filteredFates, tpFate)
        end
    end
    ---@type FateTable?
    local rv = nil
    for _, fateTable in pairs(filteredFates) do
        if rv == nil or self:fateCmp(rv, fateTable) == Cmp.Lt then
            rv = fateTable
        end
    end
    if rv ~= nil then
        self:logDebug("selected fate: " .. rv.fateName)
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
                local newPos = Svc.ClientState.LocalPlayer.Position + Vector3(0, 10, 0)
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
    if aetheryteForClosestFate ~= nil then
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
                    yield("/gs change" .. self.Config.BossFatesJob.Name)
                    return
                elseif not self.currentFate:isBossFate() and currentJob ~= self.Config.MainJob.Id then
                    yield("/gs change" .. self.Config.MainJob.Name)
                    return
                end
            end

            -- target an npc/enemy when close to fate and path to them
            if GetDistanceToPoint(self.currentFate.position) < 60 then
                if Svc.Targets.Target == nil then
                    if
                        (self.currentFate:isOtherNpcFate() or self.currentFate:isCollectionsFate())
                        and not InActiveFate()
                    then
                        yield("/target " .. self.currentFate.npcName)
                    else
                        AttemptToTargetClosestFateEnemy()
                    end
                    -- TODO(seamooo) may need a wait here for stability
                    return
                else
                    if
                        (self.currentFate:isOtherNpcFate() or self.currentFate:isCollectionsFate())
                        and not InActiveFate()
                    then
                        self:updateState(AutomationState.InteractWithNpc)
                        return
                    else
                        self:updateState(AutomationState.MiddleOfFateDismount)
                        return
                    end
                end
            end

            -- antistuck
            if
                (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress())
                and Svc.Condition[CharacterCondition.mounted]
            then
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
        Dispose = function() end,
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
                if Svc.Targets.Target == nil or GetTargetName() ~= self.currentFate.npcName then
                    yield("/target " .. self.currentFate.npcName)
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
        Dispose = function() end,
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
            if Svc.Targets.Target == nil or GetTargetName() ~= currentFate.npcName then
                self:turnOffCombatMods()
                yield("/target " .. currentFate.npcName)
                -- potential wait here for stability
                if Svc.Targets.Target == nil or GetTargetName() ~= currentFate.npcName then
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
        Dispose = function() end,
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
    if distance == 0 then
        return
    end
    local desiredRange = math.max(0.1, GetTargetHitboxRadius() + GetPlayerHitboxRadius() + MAX_DISTANCE)
    local STOP_EPS = 0.15
    if distance <= (desiredRange + STOP_EPS) then
        return
    end
    local dir = Normalize(playerPos - targetPos)
    if dir:Length() == 0 then
        return
    end
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
        [FateTargetEntity.IdleFateMob] = function()
            return TargetIdleFateMob(self.currentFate.fateObject)
        end,
        [FateTargetEntity.Gatherables] = function()
            return TargetFateGatherable(self.currentFate.fateObject)
        end,
        [FateTargetEntity.Adds] = function()
            return TargetFateAdds(self.currentFate.fateObject)
        end,
        [FateTargetEntity.Boss] = function()
            return TargetFateBoss(self.currentFate.fateObject)
        end,
        [FateTargetEntity.ForlornMaiden] = TargetForlornMaiden,
        [FateTargetEntity.Forlorn] = TargetForlorn,
        [FateTargetEntity.ClosestFateMob] = function()
            return TargetClosestFateMob(self.currentFate.fateObject)
        end,
    }
    return {
        Exec = function()
            if self.currentFate == nil then
                self:log("internal error: unset current fate inside doFate, check code path")
                self:updateState(AutomationState.Ready)
            end
            local currentJob = Player.Job
            if
                self.currentFate:isBossFate()
                and self.Config.BossFatesJob ~= nil
                and currentJob.Id ~= self.Config.BossFatesJob.Id
            then
                self:turnOffCombatMods()
                yield("/gs change " .. self.Config.BossFatesJob.Name)
                return
            elseif not self.currentFate:isBossFate() and self.Config.MainJob.Id ~= currentJob.Id then
                self:turnOffCombatMods()
                yield("/gs change " .. self.Config.MainJob.Name)
                return
                -- XXX(seamooo) known that below comparison had failures previously
                -- uncertain if due to self.currentFate being nil or self.currentFate.fateObject.MaxLevel being nil
            elseif
                InActiveFate()
                and (self.currentFate.fateObject.MaxLevel < Player.Job.Level)
                and not Player.IsLevelSynced
            then
                yield("/lsync")
                -- potential wait here for stability
            elseif
                IsFateActive(self.currentFate.fateObject)
                and not InActiveFate()
                and self.currentFate.fateObject.Progress ~= nil
                and self.currentFate.fateObject.Progress < 100
                and (GetDistanceToPoint(self.currentFate.position) < self.currentFate.fateObject.Radius + 10)
                and not Svc.Condition[CharacterCondition.mounted]
                and not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress())
            then -- got pushed out of fate. go back
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
                if
                    (
                        self.currentFate.fateObject.EventItem ~= 0
                        and Inventory.GetItemCount(self.currentFate.fateObject.EventItem) >= FULL_CREDIT_MIN_ITEMS
                    )
                    or (
                        self.currentFate.collectionsFateCtx.haveMaxCredit
                        and self.currentFate.fateObject.Progress == 100
                    )
                then
                    yield("/vnav stop")
                    self:updateState(AutomationState.CollectionsFateTurnIn)
                end
            end
            -- clear fatenpc if targeted
            if
                self.currentFate.npcName ~= nil
                and self.currentFate.npcName ~= ""
                and GetTargetName() == self.currentFate.npcName
            then
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
            elseif
                not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning())
                and not Svc.Condition[CharacterCondition.casting]
            then
                self:moveToTargetHitbox()
                return
            end
        end,
        Dispose = function() end,
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
                        if
                            self.currentFate ~= nil
                            and self.currentFate.continuationIsBoss
                            and currentJob ~= self.Config.BossFatesJob.Id
                        then
                            yield("/gs change " .. self.Config.BossFatesJob.Name)
                        elseif
                            self.currentFate ~= nil
                            and not self.currentFate.continuationIsBoss
                            and currentJob ~= self.Config.BossFatesJob.Id
                        then
                            yield("/gs change " .. self.Config.MainJob.Name)
                        end
                    end
                end
            end
        end,
        Dispose = function() end,
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
        Dispose = function() end,
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
        Dispose = function() end,
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
            local closestAetheryte =
                GetClosestAetheryteToPoint(Svc.ClientState.LocalPlayer.Position, 200, self.currentZone)
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
        Dispose = function() end,
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
                    yield('/generalaction "Materia Extraction"')
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
        Dispose = function() end,
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
            local hawkersAlleyAethernetShard = { position = Vector3(-213.95, 15.99, 49.35) }
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
                    local darkMatterVendor =
                        { npcName = "Unsynrael", position = Vector3(-257.71, 16.19, 50.11), wait = 0.08 }
                    if
                        GetDistanceToPoint(darkMatterVendor.position)
                        > (DistanceBetween(hawkersAlleyAethernetShard.position, darkMatterVendor.position) + 10)
                    then
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
                            yield("/target " .. darkMatterVendor.npcName)
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
                    local mender = { npcName = "Alistair", position = Vector3(-246.87, 16.19, 49.83) }
                    if
                        GetDistanceToPoint(mender.position)
                        > (DistanceBetween(hawkersAlleyAethernetShard.position, mender.position) + 10)
                    then
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
                            yield("/target " .. mender.npcName)
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
        Dispose = function() end,
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
        Dispose = function() end,
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
        Dispose = function() end,
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
        Dispose = function() end,
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
                    yield('/cac "' .. StringifyChocoboStance(self.Config.ChocoboStance) .. ' stance"')
                elseif self.Config.EnableAutoBuyGysahlGreens then
                    self:logDebug("needs to get gysahl greens")
                    self:updateState(AutomationState.AutoBuyGysahlGreens)
                    return
                end
            end
            self:updateState(AutomationState.Ready)
        end,
        Dispose = function() end,
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
            local gysahlGreensVendor = { position = Vector3(-62.1, 18.0, 9.4), npcName = "Bango Zango" }
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
                yield("/target " .. gysahlGreensVendor.npcName)
            end
        end,
        Dispose = function() end,
    }
end

---@private
---This method should be used in place of Dalamud.LogDebug
---such that the logging mechanism may be hooked into with
---configuration
---TODO(seamooo) make the logging configurable
---@param message string
function FateAutomation:logDebug(message)
    Dalamud.LogDebug("[FATE] " .. message)
end

---@private
---This method should be used in place of Dalamud.LogVerbose
---such that the logging mechanism may be hooked into with
---configuration
---TODO(seamooo) make the logging configurable
---@param message string
function FateAutomation:log(message)
    Dalamud.Log("[FATE] " .. message)
end

---@private
---This method is the expected setter for state
---state should not be mutated outside of this method
---@param newState AutomationState
function FateAutomation:updateState(newState)
    self:logDebug("update state to " .. newState)
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
        [AutomationState.AutoBuyGysahlGreens] = self.autoBuyGysahlGreens,
    }
    ---@type fun(FateAutomation): StateFunction
    local initFn = jTable[newState]
    self.currentState.Dispose()
    self.currentState = initFn(self)
end

---@private
function FateAutomation:handleEvents()
    if Svc.Condition[CharacterCondition.dead] and self.currentState ~= AutomationState.Dead then
        self:updateState(AutomationState.Dead)
    end
end

---@param zoneId number
function FateAutomation:setCurrentZone(zoneId)
    self.currentFate = nil
    self.currentZone = GetZoneFromId(zoneId)
    self:updateState(AutomationState.Ready)
end

function FateAutomation:run()
    self:handleEvents()
    self.currentState.Exec()
    -- release control for 0.1 to allow game state to update in between calls
    yield("/wait 0.1")
end

end)
__bundle_register("libfate-utils-v2", function(require, _LOADED, __bundle_register, __bundle_modules)
require("libfate-data")

---logs source line number
---@return integer line number
function __LINE__()
    return debug.getinfo(2, "l").currentline
end

---@generic T: {[string]: any}
---@param val T
function DbgTable(val)
    local rv = "{"
    local firstElem = true
    for k, v in pairs(val) do
        if not firstElem then
            rv = rv .. ", "
        end
        firstElem = false
        rv = rv .. '{"' .. k .. '": ' .. tostring(v) .. "}"
    end
    rv = rv .. "}"
    return rv
end

---@generic T
---@param val T[]
---@return string
function StringifyArray(val)
    local rv = "{"
    for idx, x in ipairs(val) do
        if idx ~= 1 then
            rv = rv .. ", "
        end
        rv = rv .. tostring(x)
    end
    rv = rv .. "}"
    return rv
end

---@param name string
---@returns boolean
function HasPlugin(name)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == name and plugin.IsLoaded then
            return true
        end
    end
    return false
end

---@enum ChocoboStance
ChocoboStance = {
    Follow = 0,
    Free = 1,
    Defender = 2,
    Healer = 3,
    Attacker = 4,
}

---@return string
---@params stance ChocoboStance
function StringifyChocoboStance(stance)
    local stringsTable = {
        [ChocoboStance.Follow] = "Follow",
        [ChocoboStance.Free] = "Free",
        [ChocoboStance.Defender] = "Defender",
        [ChocoboStance.Healer] = "Healer",
        [ChocoboStance.Attacker] = "Attacker",
    }
    local rv = stringsTable[stance]
    if rv == nil then
        return ""
    end
    return rv
end

---@param pos1 System_Numerics_Vector3
---@param pos2 System_Numerics_Vector3
---@return number
function DistanceBetween(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

---@param vec3 System_Numerics_Vector3
---@return number
function GetDistanceToPoint(vec3)
    return DistanceBetween(Svc.ClientState.LocalPlayer.Position, vec3)
end

---@return number
function GetDistanceToTarget()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPoint(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end

---@return number
function GetDistanceToTargetFlat()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPointFlat(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end

---@param vec3 System_Numerics_Vector3
---@return number
function GetDistanceToPointFlat(vec3)
    return DistanceBetweenFlat(Svc.ClientState.LocalPlayer.Position, vec3)
end

---@param pos1 System_Numerics_Vector3
---@param pos2 System_Numerics_Vector3
---@return number
function DistanceBetweenFlat(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dz * dz)
end

---@param position System_Numerics_Vector3
---@param maxDistance number
---@return System_Numerics_Vector3
function RandomAdjustCoordinates(position, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = position.X + (x_adjust * math.cos(angle))
    local randomY = position.Y + maxDistance
    local randomZ = position.Z + (z_adjust * math.sin(angle))

    return Vector3(randomX, randomY, randomZ)
end

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime / (144 / 7) -- 24h Eorzea Time equals 70min IRL
end

---@param zoneId number
---@returns IAetheryteEntry[]
function GetAetherytesInZone(zoneId)
    local aetherytesInZone = {}
    for _, aetheryte in ipairs(Svc.AetheryteList) do
        if aetheryte.TerritoryId == zoneId then
            table.insert(aetherytesInZone, aetheryte)
        end
    end
    return aetherytesInZone
end

---@param aetheryte IAetheryteEntry
---@return string
function GetAetheryteName(aetheryte)
    local name = aetheryte.AetheryteData.Value.PlaceName.Value.Name:GetText()
    if name ~= nil then
        return name
    end
    return ""
end

---@param fate FateWrapper
---@return boolean
function IsFateActive(fate)
    if fate.State == nil then
        return false
    else
        return fate.State ~= FateState.Ending and fate.State ~= FateState.Ended and fate.State ~= FateState.Failed
    end
end

---@return boolean
function InActiveFate()
    local activeFates = Fates.GetActiveFates()
    for i = 0, activeFates.Count - 1 do
        if activeFates[i].InFate == true and IsFateActive(activeFates[i]) then
            return true
        end
    end
    return false
end

---@param vec3 System_Numerics_Vector3
---@param teleportTimePenalty number
---@param zone ZoneFateInfoExt
function DistanceFromClosestAetheryteToPoint(vec3, teleportTimePenalty, zone)
    local rv = math.maxinteger
    for _, aetheryte in ipairs(zone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, vec3)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        if comparisonDistance < rv then
            rv = comparisonDistance
        end
    end
    return rv
end

---TODO(seamooo) this can be made much more precise
---@param vec3 System_Numerics_Vector3
---@param zone ZoneFateInfoExt
---@return number
function GetDistanceToPointWithAetheryteTravel(vec3, zone)
    -- Get the direct flight distance (no aetheryte)
    local directFlightDistance = GetDistanceToPoint(vec3)
    -- Get the distance to the closest aetheryte, including teleportation penalty
    local distanceToAetheryte = DistanceFromClosestAetheryteToPoint(vec3, 200, zone)

    -- Return the minimum distance, either via direct flight or via the closest aetheryte travel
    if distanceToAetheryte == nil then
        return directFlightDistance
    else
        return math.min(directFlightDistance, distanceToAetheryte)
    end
end

---@param zoneId number
---@param position System_Numerics_Vector3
function SetMapFlag(zoneId, position)
    Instances.Map.Flag:SetFlagMapMarker(zoneId, position.X, position.Z)
end

local function mysplit(inputstr)
    for str in string.gmatch(inputstr, "[^%.]+") do
        return str
    end
end

local function load_type(type_path)
    local assembly = mysplit(type_path)
    luanet.load_assembly(assembly)
    local type_var = luanet.import_type(type_path)
    return type_var
end

-- TODO(seamooo) should make a preamble that loads below

---@type fun(obj: IGameObject):EntityWrapper
EntityWrapper = load_type("SomethingNeedDoing.LuaMacro.Wrappers.EntityWrapper")

---@type ObjectKindEnum
ObjectKind = load_type("Dalamud.Game.ClientState.Objects.Enums.ObjectKind")

---@type NameplateKindEnum
NameplateKind = load_type("ECommons.GameFunctions.NameplateKind")

function AttemptToTargetClosestFateEnemy()
    local closestTarget = nil
    local closestTargetDistance = math.maxinteger
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and obj:IsHostile() and not obj.IsDead and EntityWrapper(obj).FateId > 0 then
            local dist = GetDistanceToPoint(obj.Position)
            if dist < closestTargetDistance then
                closestTargetDistance = dist
                closestTarget = obj
            end
        end
    end
    if closestTarget ~= nil then
        Svc.Targets.Target = closestTarget
    end
end

---XXX(seamooo) make non-blocking version of this
---@param addonName string
---@param nodePath number
---@param ... number
function GetNodeText(addonName, nodePath, ...)
    local addon = Addons.GetAddon(addonName)
    while not addon.Ready do
        yield("/wait 0.25")
    end
    return addon:GetNode(nodePath, ...).Text
end

---@param destinationAetheryte string
function AcceptTeleportOfferLocation(destinationAetheryte)
    if Addons.GetAddon("_NotificationTelepo").Ready then
        local location = GetNodeText("_NotificationTelepo", 3, 4)
        yield("/callback _Notification true 0 16 " .. location)
        yield("/wait 1")
    end

    if Addons.GetAddon("SelectYesno").Ready then
        local teleportOfferMessage = GetNodeText("SelectYesno", 1, 2)
        if type(teleportOfferMessage) == "string" then
            local teleportOfferLocation = teleportOfferMessage:match("Accept Teleport to (.+)%?")
            if
                teleportOfferLocation ~= nil
                and string.lower(teleportOfferLocation) == string.lower(destinationAetheryte)
            then
                yield("/callback SelectYesno true 0") -- accept teleport
                return
            end
            yield("/callback SelectYesno true 2") -- decline teleport
            return
        end
    end
end

---@param timeout number?
---@param logHook (fun(message: string))?
---@return fun(aetheryteName: string): boolean
function NewTeleportManager(timeout, logHook)
    local timeoutConcrete = 60
    if timeout ~= nil then
        timeoutConcrete = timeout
    end
    local logger = Dalamud.LogDebug
    if logHook ~= nil then
        logger = logHook
    end

    ---@type number?
    local lastTeleportTimestamp = nil

    ---@param aetheryteName string
    ---@return boolean
    local rv = function(aetheryteName)
        local now = os.clock()
        if lastTeleportTimestamp == nil or now - lastTeleportTimestamp > 2 then
            -- below executes teleport and blocks until finished or timeout
            yield("/li tp " .. aetheryteName)
            yield("/wait 1")
            while Svc.Condition[CharacterCondition.casting] do
                if os.clock() - now > timeoutConcrete then
                    logger("TeleportManager timeout reached while waiting for cast")
                    return false
                end
                yield("/wait 0.1")
            end
            local castFinishedTime = os.clock()
            yield("/wait 1")
            while Svc.Condition[CharacterCondition.betweenAreas] do
                if os.clock() - castFinishedTime > timeoutConcrete then
                    logger("TeleportManager timeout reached while waiting for cast")
                    return false
                end
                yield("/wait 0.1")
            end
        end
        lastTeleportTimestamp = now
        return true
    end
    return rv
end

---@return number
function GetTargetHitboxRadius()
    if Svc.Targets.Target ~= nil then
        return Svc.Targets.Target.HitboxRadius
    end
    return 0
end

---@return number
function GetPlayerHitboxRadius()
    if Svc.ClientState.LocalPlayer ~= nil then
        return Svc.ClientState.LocalPlayer.HitboxRadius
    end
    return 0
end

---@param v System_Numerics_Vector2
function Normalize(v)
    local len = v:Length()
    if len == 0 then
        return v
    end
    return v / len
end

---@class AetheryteTable
---@field name string
---@field id string
---@field position System_Numerics_Vector3
---@field aetheryteObj IAetheryteEntry

---@class ZoneFateInfoExt: ZoneFateInfo
---@field aetheryteList AetheryteTable[]
---@field flying boolean

---@param zoneId number
---@return ZoneFateInfoExt
function GetZoneFromId(zoneId)
    local zoneInfo = nil

    for _, zone in ipairs(FatesData) do
        if zoneId == zone.zoneId then
            zoneInfo = zone
        end
    end
    if zoneInfo == nil then
        yield("/echo [FATE] Current zone is only partially supported. No data on npc fates.")
        zoneInfo = {
            zoneName = "",
            zoneId = zoneId,
            fatesList = {
                collectionsFates = {},
                otherNpcFates = {},
                bossFates = {},
                blacklistedFates = {},
                fatesWithContinuations = {},
            },
        }
    end
    local flying = zoneInfo.flying
    ---@type ZoneFateInfoExt
    local rv = {
        zoneName = zoneInfo.zoneName,
        zoneId = zoneInfo.zoneId,
        fatesList = zoneInfo.fatesList,
        flying = flying == nil or flying,
        aetheryteList = {},
    }
    local aetherytes = GetAetherytesInZone(zoneInfo.zoneId)
    for _, aetheryte in ipairs(aetherytes) do
        local aetherytePos = Instances.Telepo:GetAetherytePosition(aetheryte.AetheryteId)
        local aetheryteTable = {
            name = GetAetheryteName(aetheryte),
            id = aetheryte.AetheryteId,
            position = aetherytePos,
            aetheryteObj = aetheryte,
        }
        table.insert(rv.aetheryteList, aetheryteTable)
    end
    return rv
end

---@return ZoneFateInfoExt
function GetCurrentZone()
    return GetZoneFromId(Svc.ClientState.TerritoryType)
end

---Returns the closest aetheryte if a teleport would be faster else nil
---@param position System_Numerics_Vector3
---@param teleportTimePenalty number yalms travelled during teleport cast
---@param zone ZoneFateInfoExt current zone
---@return AetheryteTable?
function GetClosestAetheryte(position, teleportTimePenalty, zone)
    ---@type AetheryteTable?
    local rv = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(zone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, position)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        if comparisonDistance < closestTravelDistance then
            closestTravelDistance = comparisonDistance
            rv = aetheryte
        end
    end
    return rv
end

---Returns the closest aetheryte if a teleport would be faster else nil
---@param position System_Numerics_Vector3
---@param teleportTimePenalty number yalms travelled during teleport cast
---@param zone ZoneFateInfoExt current zone
---@return AetheryteTable?
function GetClosestAetheryteToPoint(position, teleportTimePenalty, zone)
    local directFlightDistance = GetDistanceToPoint(position)
    local closestAetheryte = GetClosestAetheryte(position, teleportTimePenalty, zone)
    if closestAetheryte ~= nil then
        local closestAetheryteDistance = DistanceBetween(position, closestAetheryte.position) + teleportTimePenalty

        if closestAetheryteDistance < directFlightDistance then
            return closestAetheryte
        end
    end
    return nil
end

---@return boolean
function AttemptToTargetClosestFateEnemy()
    local closestTarget = nil
    local closestTargetDistance = math.maxinteger
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and obj:IsHostile() and not obj.IsDead and EntityWrapper(obj).FateId > 0 then
            local dist = GetDistanceToPoint(obj.Position)
            if dist < closestTargetDistance then
                closestTargetDistance = dist
                closestTarget = obj
            end
        end
    end
    if closestTarget ~= nil then
        Svc.Targets.Target = closestTarget
        return true
    end
    return false
end

---@return string
function GetTargetName()
    if Svc.Targets.Target ~= nil then
        return Svc.Targets.Target.Name.TextValue
    end
    return ""
end

function AcceptNPCFateOrRejectOtherYesno()
    if Addons.GetAddon("SelectYesno").Ready then
        local dialogBox = GetNodeText("SelectYesno", 1, 2)
        if type(dialogBox) == "string" and dialogBox:find("The recommended level for this FATE is") then
            yield("/callback SelectYesno true 0") --accept fate
        else
            yield("/callback SelectYesno true 1") --decline all other boxes
        end
    end
end

---@return number
function GetBuddyTimeRemaining()
    return Instances.Buddy.CompanionInfo.TimeLeft
end

---Unselects current target
function ClearTarget()
    Svc.Targets.Target = nil
end

---@param fateName string
---@param zone ZoneFateInfoExt
---@return boolean
function IsCollectionsFate(fateName, zone)
    for _, collectionsFate in ipairs(zone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

---@param fate FateWrapper
---@return boolean
function IsBossFate(fate)
    return fate.IconId == 60722
end

---@param fateName string
---@param zone ZoneFateInfoExt
---@return boolean
function IsOtherNpcFate(fateName, zone)
    for _, otherNpcFate in ipairs(zone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

---@param fateName string
---@param zone ZoneFateInfoExt
---@return boolean
function IsSpecialFate(fateName, zone)
    if zone.fatesList.specialFates == nil then
        return false
    end
    for _, specialFate in ipairs(zone.fatesList.specialFates) do
        if specialFate == fateName then
            return true
        end
    end
    return false
end

---@param fateName string
---@param zone ZoneFateInfoExt
---@return boolean
function IsBlacklistedFate(fateName, zone)
    for _, blacklistedFate in ipairs(zone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
        end
    end
    return false
end

---@param fateName string
---@param zone ZoneFateInfoExt
---@return string
function GetFateNpcName(fateName, zone)
    for i, fate in ipairs(zone.fatesList.otherNpcFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    for i, fate in ipairs(zone.fatesList.collectionsFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    return ""
end

---@return boolean
function TargetBattle()
    yield("/battletarget")
    yield("/wait 0.1")
    return Svc.Targets.Target ~= nil and Svc.Targets.Target:IsHostile()
end

---@class FateObjInfo
---@field obj IGameObject
---@field nameplateKind NameplateKind
---@field distance number
---@field maxHp number
---@field currHp number
---@field kind ObjectKind
---@field name string

---@return FateObjInfo
---@param obj IGameObject
function BuildFateObjInfo(obj)
    local tpEntity = EntityWrapper(obj)
    return {
        obj = obj,
        nameplateKind = obj:GetNameplateKind(),
        distance = GetDistanceToPoint(obj.Position),
        maxHp = tpEntity.MaxHp,
        currHp = tpEntity.CurrentHp,
        kind = obj.ObjectKind,
        name = tpEntity.Name,
    }
end

---Target an idle fate mob if one exists. Priority
---will be current target -> closest target
---excludes forlorns
---returns true if an entity to target was found
---@param fate FateWrapper
---@boolean
function TargetIdleFateMob(fate)
    local currTarget = Svc.Targets.Target
    if currTarget ~= nil then
        local currTargetInfo = BuildFateObjInfo(currTarget)
        if currTargetInfo.nameplateKind == NameplateKind.HostileNotEngaged then
            -- current target is still deaggroed, no need to find a new target
            return true
        end
    end
    ---@type FateObjInfo?
    local bestObjInfo = nil
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and EntityWrapper(obj).FateId == fate.Id then
            local info = BuildFateObjInfo(obj)
            if info.nameplateKind == NameplateKind.HostileNotEngaged and not string.find(info.name, "Forlorn") then
                if bestObjInfo == nil or bestObjInfo.distance > info.distance then
                    bestObjInfo = info
                end
            end
        end
    end
    if bestObjInfo ~= nil then
        Svc.Targets.Target = bestObjInfo.obj
        return true
    end
    return false
end

---@param fate FateWrapper
---@return boolean
function TargetFateGatherable(fate)
    local currTarget = Svc.Targets.Target
    if currTarget ~= nil then
        local currTargetInfo = BuildFateObjInfo(currTarget)
        if currTargetInfo.kind == ObjectKind.EventObj then
            -- current target is still a gatherable, no need to find a new target
            return true
        end
    end
    ---@type FateObjInfo?
    local bestObjInfo = nil
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable then
            local info = BuildFateObjInfo(obj)
            if info.kind == ObjectKind.EventObj then
                if bestObjInfo == nil or bestObjInfo.distance > info.distance then
                    bestObjInfo = info
                end
            end
        end
    end
    if bestObjInfo ~= nil then
        Svc.Targets.Target = bestObjInfo.obj
        return true
    end
    return false
end

---@param fate FateWrapper
function TargetFateAdds(fate)
    local currTarget = Svc.Targets.Target
    ---@type FateObjInfo?
    local bestObjInfo = nil
    if currTarget ~= nil then
        bestObjInfo = BuildFateObjInfo(currTarget)
    end
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and EntityWrapper(obj).FateId == fate.Id and obj:IsHostile() then
            local info = BuildFateObjInfo(obj)
            if info.maxHp > 1 and not string.find(info.name, "Forlorn") then
                if bestObjInfo == nil or bestObjInfo.maxHp > info.maxHp then
                    bestObjInfo = info
                end
            end
        end
    end
    if bestObjInfo ~= nil then
        if currTarget == bestObjInfo.obj then
            -- do nothing
            return true
        end
        Svc.Targets.Target = bestObjInfo.obj
        return true
    end
    return false
end

---@param fate FateWrapper
function TargetFateBoss(fate)
    local currTarget = Svc.Targets.Target
    ---@type FateObjInfo?
    local bestObjInfo = nil
    if currTarget ~= nil then
        bestObjInfo = BuildFateObjInfo(currTarget)
    end
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and EntityWrapper(obj).FateId == fate.Id and obj:IsHostile() then
            local info = BuildFateObjInfo(obj)
            if info.maxHp > 1 and not string.find(info.name, "Forlorn") then
                if bestObjInfo == nil or bestObjInfo.maxHp < info.maxHp then
                    bestObjInfo = info
                end
            end
        end
    end
    if bestObjInfo ~= nil then
        if currTarget == bestObjInfo.obj then
            -- do nothing
            return true
        end
        Svc.Targets.Target = bestObjInfo.obj
        return true
    end
    return false
end

---@return boolean
function TargetForlornMaiden()
    yield("/target Forlorn Maiden")
    -- really don't like not just returning a truthy statement but type system
    -- didn't think it reduced to a boolean
    if Svc.Targets.Target ~= nil and string.find(tostring(Svc.Targets.Target.Name), "Forlorn") then
        return true
    end
    return false
end

---@return boolean
function TargetForlorn()
    yield("/target The Forlorn")
    if Svc.Targets.Target ~= nil and string.find(tostring(Svc.Targets.Target.Name), "Forlorn") then
        return true
    end
    return false
end

---Targets the closest fate mob indiscriminant of any
---other properties
---@param fate FateWrapper
---@return boolean
function TargetClosestFateMob(fate)
    ---@type FateObjInfo?
    local bestObjInfo = nil
    for i = 0, Svc.Objects.Length - 1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and EntityWrapper(obj).FateId == fate.Id and obj:IsHostile() then
            local info = BuildFateObjInfo(obj)
            if bestObjInfo == nil or bestObjInfo.distance > info.distance then
                bestObjInfo = info
            end
        end
    end
    if bestObjInfo ~= nil then
        Svc.Targets.Target = bestObjInfo.obj
        return true
    end
    return false
end

---@param statusId number
---@return boolean
function HasStatusId(statusId)
    local statusList = Svc.ClientState.LocalPlayer.StatusList
    if statusList == nil then
        return false
    end
    for i = 0, statusList.Length - 1 do
        if statusList[i].StatusId == statusId then
            return true
        end
    end
    return false
end

---@return boolean
function TurnOnTextAdvance()
    if IPC.TextAdvance == nil then
        return false
    end
    if IPC.TextAdvance.IsEnabled() then
        return true
    end
    yield("/at y")
    return true
end

end)
__bundle_register("libfate-data", function(require, _LOADED, __bundle_register, __bundle_modules)
import("System.Numerics")
CharacterCondition = {
    dead = 2,
    mounted = 4,
    inCombat = 26,
    casting = 27,
    occupiedInEvent = 31,
    occupiedInQuestEvent = 32,
    occupied = 33,
    boundByDuty34 = 34,
    occupiedMateriaExtractionAndRepair = 39,
    betweenAreas = 45,
    jumping48 = 48,
    jumping61 = 61,
    occupiedSummoningBell = 50,
    betweenAreasForDuty = 51,
    boundByDuty56 = 56,
    mounting57 = 57,
    mounting64 = 64,
    beingMoved = 70,
    flying = 77,
}

-- TODO(seamooo) investigate if below is dead code
-- ClassList =
-- {
--     gla = { classId=1, className="Gladiator", isMelee=true, isTank=true },
--     pgl = { classId=2, className="Pugilist", isMelee=true, isTank=false },
--     mrd = { classId=3, className="Marauder", isMelee=true, isTank=true },
--     lnc = { classId=4, className="Lancer", isMelee=true, isTank=false },
--     arc = { classId=5, className="Archer", isMelee=false, isTank=false },
--     cnj = { classId=6, className="Conjurer", isMelee=false, isTank=false },
--     thm = { classId=7, className="Thaumaturge", isMelee=false, isTank=false },
--     pld = { classId=19, className="Paladin", isMelee=true, isTank=true },
--     mnk = { classId=20, className="Monk", isMelee=true, isTank=false },
--     war = { classId=21, className="Warrior", isMelee=true, isTank=true },
--     drg = { classId=22, className="Dragoon", isMelee=true, isTank=false },
--     brd = { classId=23, className="Bard", isMelee=false, isTank=false },
--     whm = { classId=24, className="White Mage", isMelee=false, isTank=false },
--     blm = { classId=25, className="Black Mage", isMelee=false, isTank=false },
--     acn = { classId=26, className="Arcanist", isMelee=false, isTank=false },
--     smn = { classId=27, className="Summoner", isMelee=false, isTank=false },
--     sch = { classId=28, className="Scholar", isMelee=false, isTank=false },
--     rog = { classId=29, className="Rogue", isMelee=false, isTank=false },
--     nin = { classId=30, className="Ninja", isMelee=true, isTank=false },
--     mch = { classId=31, className="Machinist", isMelee=false, isTank=false},
--     drk = { classId=32, className="Dark Knight", isMelee=true, isTank=true },
--     ast = { classId=33, className="Astrologian", isMelee=false, isTank=false },
--     sam = { classId=34, className="Samurai", isMelee=true, isTank=false },
--     rdm = { classId=35, className="Red Mage", isMelee=false, isTank=false },
--     blu = { classId=36, className="Blue Mage", isMelee=false, isTank=false },
--     gnb = { classId=37, className="Gunbreaker", isMelee=true, isTank=true },
--     dnc = { classId=38, className="Dancer", isMelee=false, isTank=false },
--     rpr = { classId=39, className="Reaper", isMelee=true, isTank=false },
--     sge = { classId=40, className="Sage", isMelee=false, isTank=false },
--     vpr = { classId=41, className="Viper", isMelee=true, isTank=false },
--     pct = { classId=42, className="Pictomancer", isMelee=false, isTank=false }
-- }

BicolorExchangeData = {
    {
        shopKeepName = "Gadfrid",
        zoneName = "Old Sharlayan",
        zoneId = 962,
        aetheryteName = "Old Sharlayan",
        position = Vector3(78, 5, -37),
        shopItems = {
            { itemName = "Bicolor Gemstone Voucher", itemIndex = 8, price = 100 },
            { itemName = "Ovibos Milk", itemIndex = 9, price = 2 },
            { itemName = "Hamsa Tenderloin", itemIndex = 10, price = 2 },
            { itemName = "Yakow Chuck", itemIndex = 11, price = 2 },
            { itemName = "Bird of Elpis Breast", itemIndex = 12, price = 2 },
            { itemName = "Egg of Elpis", itemIndex = 13, price = 2 },
            { itemName = "Amra", itemIndex = 14, price = 2 },
            { itemName = "Dynamis Crystal", itemIndex = 15, price = 2 },
            { itemName = "Almasty Fur", itemIndex = 16, price = 2 },
            { itemName = "Gaja Hide", itemIndex = 17, price = 2 },
            { itemName = "Luncheon Toad Skin", itemIndex = 18, price = 2 },
            { itemName = "Saiga Hide", itemIndex = 19, price = 2 },
            { itemName = "Kumbhira Skin", itemIndex = 20, price = 2 },
            { itemName = "Ophiotauros Hide", itemIndex = 21, price = 2 },
            { itemName = "Berkanan Sap", itemIndex = 22, price = 2 },
            { itemName = "Dynamite Ash", itemIndex = 23, price = 2 },
            { itemName = "Lunatender Blossom", itemIndex = 24, price = 2 },
            { itemName = "Mousse Flesh", itemIndex = 25, price = 2 },
            { itemName = "Petalouda Scales", itemIndex = 26, price = 2 },
        },
    },
    {
        shopKeepName = "Beryl",
        zoneName = "Solution Nine",
        zoneId = 1186,
        aetheryteName = "Solution Nine",
        position = Vector3(-198.47, 0.92, -6.95),
        miniAethernet = {
            name = "Nexus Arcade",
            position = Vector3(-157.74, 0.29, 17.43),
        },
        shopItems = {
            { itemName = "Turali Bicolor Gemstone Voucher", itemIndex = 6, price = 100 },
            { itemName = "Alpaca Fillet", itemIndex = 7, price = 3 },
            { itemName = "Swampmonk Thigh", itemIndex = 8, price = 3 },
            { itemName = "Rroneek Chuck", itemIndex = 9, price = 3 },
            { itemName = "Megamaguey Pineapple", itemIndex = 10, price = 3 },
            { itemName = "Branchbearer Fruit", itemIndex = 11, price = 3 },
            { itemName = "Nopalitender Tuna", itemIndex = 12, price = 3 },
            { itemName = "Rroneek Fleece", itemIndex = 13, price = 3 },
            { itemName = "Silver Lobo Hide", itemIndex = 14, price = 3 },
            { itemName = "Hammerhead Crocodile Skin", itemIndex = 15, price = 3 },
            { itemName = "Br'aax Hide", itemIndex = 16, price = 3 },
            { itemName = "Gomphotherium Skin", itemIndex = 17, price = 3 },
            { itemName = "Gargantua Hide", itemIndex = 18, price = 3 },
            { itemName = "Ty'aitya Wingblade", itemIndex = 19, price = 3 },
            { itemName = "Poison Frog Secretions", itemIndex = 20, price = 3 },
            { itemName = "Alexandrian Axe Beak Wing", itemIndex = 21, price = 3 },
            { itemName = "Lesser Apollyon Shell", itemIndex = 22, price = 3 },
            { itemName = "Tumbleclaw Weeds", itemIndex = 23, price = 3 },
        },
    },
    {
        shopKeepName = "Rral Wuruq",
        zoneName = "Yak T'el",
        zoneId = 1189,
        aetheryteName = "Iq Br'aax",
        position = Vector3(-381, 23, -436),
        shopItems = {
            { itemName = "Ut'ohmu Siderite", itemIndex = 8, price = 600 },
        },
    },
}

---@class FateInfo
---@field fateName string
---@field npcName string

---@class ContinuationFateInfo
---@field fateName string
---@field continuationIsBoss boolean

---@class FatesList
---@field collectionsFates FateInfo[]
---@field otherNpcFates FateInfo[]
---@field fatesWithContinuations (ContinuationFateInfo|string)[]
---@field specialFates string[]?
---@field blacklistedFates string[]

---@class ZoneFateInfo
---@field zoneName string
---@field zoneId number
---@field fatesList FatesList
---@field flying boolean?

---@type ZoneFateInfo[]
FatesData = {
    {
        zoneName = "Middle La Noscea",
        zoneId = 134,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {
                { fateName = "Thwack-a-Mole", npcName = "Troubled Tiller" },
                { fateName = "Yellow-bellied Greenbacks", npcName = "Yellowjacket Drill Sergeant" },
                { fateName = "The Orange Boxes", npcName = "Farmer in Need" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Lower La Noscea",
        zoneId = 135,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {
                { fateName = "Away in a Bilge Hold", npcName = "Yellowjacket Veteran" },
                { fateName = "Fight the Flower", npcName = "Furious Farmer" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Central Thanalan",
        zoneId = 141,
        fatesList = {
            collectionsFates = {
                { fateName = "Let them Eat Cactus", npcName = "Hungry Hobbledehoy" },
            },
            otherNpcFates = {
                { fateName = "A Few Arrows Short of a Quiver", npcName = "Crestfallen Merchant" },
                { fateName = "Wrecked Rats", npcName = "Coffer & Coffin Heavy" },
                { fateName = "Something to Prove", npcName = "Cowardly Challenger" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Eastern Thanalan",
        zoneId = 145,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {
                { fateName = "Attack on Highbridge: Denouement", npcName = "Brass Blade" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Southern Thanalan",
        zoneId = 146,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
        flying = false,
    },
    {
        zoneName = "Outer La Noscea",
        zoneId = 180,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
        flying = false,
    },
    {
        zoneName = "Coerthas Central Highlands",
        zoneId = 155,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            specialFates = {
                "He Taketh It with His Eyes", --behemoth
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Coerthas Western Highlands",
        zoneId = 397,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Mor Dhona",
        zoneId = 156,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Sea of Clouds",
        zoneId = 401,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Azys Lla",
        zoneId = 402,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Dravanian Forelands",
        zoneId = 398,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            specialFates = {
                "Coeurls Chase Boys Chase Coeurls", --coeurlregina
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Dravanian Hinterlands",
        zoneId = 399,
        tpZoneId = 478,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Churning Mists",
        zoneId = 400,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Fringes",
        zoneId = 612,
        fatesList = {
            collectionsFates = {
                { fateName = "Showing The Recruits What For", npcName = "Storm Commander Bharbennsyn" },
                { fateName = "Get Sharp", npcName = "M Tribe Youth" },
            },
            otherNpcFates = {
                { fateName = "The Mail Must Get Through", npcName = "Storm Herald" },
                { fateName = "The Antlion's Share", npcName = "M Tribe Ranger" },
                { fateName = "Double Dhara", npcName = "Resistence Fighter" },
                { fateName = "Keeping the Peace", npcName = "Resistence Fighter" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Peaks",
        zoneId = 620,
        fatesList = {
            collectionsFates = {
                { fateName = "Fletching Returns", npcName = "Sorry Sutler" },
            },
            otherNpcFates = {
                { fateName = "Resist, Die, Repeat", npcName = "Wounded Fighter" },
                { fateName = "And the Bandits Played On", npcName = "Frightened Villager" },
                { fateName = "Forget-me-not", npcName = "Coldhearth Resident" },
                { fateName = "Of Mice and Men", npcName = "Furious Farmer" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {
                "The Magitek Is Back", --escort
                "A New Leaf", --escort
            },
        },
    },
    {
        zoneName = "The Lochs",
        zoneId = 621,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            specialFates = {
                "A Horse Outside", --ixion
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Ruby Sea",
        zoneId = 613,
        fatesList = {
            collectionsFates = {
                { fateName = "Treasure Island", npcName = "Blue Avenger" },
                { fateName = "The Coral High Ground", npcName = "Busy Beachcomber" },
            },
            otherNpcFates = {
                { fateName = "Another One Bites The Dust", npcName = "Pirate Youth" },
                { fateName = "Ray Band", npcName = "Wounded Confederate" },
                { fateName = "Bilge-hold Jin", npcName = "Green Confederate" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Yanxia",
        zoneId = 614,
        fatesList = {
            collectionsFates = {
                { fateName = "Rice and Shine", npcName = "Flabbergasted Farmwife" },
                { fateName = "More to Offer", npcName = "Ginko" },
            },
            otherNpcFates = {
                { fateName = "Freedom Flies", npcName = "Kinko" },
                { fateName = "A Tisket, a Tasket", npcName = "Gyogun of the Most Bountiful Catch" },
            },
            specialFates = {
                "Foxy Lady", --foxyyy
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Azim Steppe",
        zoneId = 622,
        fatesList = {
            collectionsFates = {
                { fateName = "The Dataqi Chronicles: Duty", npcName = "Altani" },
            },
            otherNpcFates = {
                { fateName = "Rock for Food", npcName = "Oroniri Youth" },
                { fateName = "Killing Dzo", npcName = "Olkund Dzotamer" },
                { fateName = "They Shall Not Want", npcName = "Mol Shepherd" },
                { fateName = "A Good Day to Die", npcName = "Qestiri Merchant" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Lakeland",
        zoneId = 813,
        fatesList = {
            collectionsFates = {
                { fateName = "Pick-up Sticks", npcName = "Crystarium Botanist" },
            },
            otherNpcFates = {
                { fateName = "Subtle Nightshade", npcName = "Artless Dodger" },
                { fateName = "Economic Peril", npcName = "Jobb Guard" },
            },
            fatesWithContinuations = {
                "Behind Anemone Lines",
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Kholusia",
        zoneId = 814,
        fatesList = {
            collectionsFates = {
                { fateName = "Ironbeard Builders - Rebuilt", npcName = "Tholl Engineer" },
            },
            otherNpcFates = {},
            fatesWithContinuations = {},
            specialFates = {
                "A Finale Most Formidable", --formidable
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Amh Araeng",
        zoneId = 815,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {
                "Tolba No. 1", -- pathing is really bad to enemies
            },
        },
    },
    {
        zoneName = "Il Mheg",
        zoneId = 816,
        fatesList = {
            collectionsFates = {
                { fateName = "Twice Upon a Time", npcName = "Nectar-seeking Pixie" },
            },
            otherNpcFates = {
                { fateName = "Once Upon a Time", npcName = "Nectar-seeking Pixie" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Rak'tika Greatwood",
        zoneId = 817,
        fatesList = {
            collectionsFates = {
                { fateName = "Picking up the Pieces", npcName = "Night's Blessed Missionary" },
                { fateName = "Pluck of the Draw", npcName = "Myalna Bowsing" },
                { fateName = "Monkeying Around", npcName = "Fanow Warder" },
            },
            otherNpcFates = {
                { fateName = "Queen of the Harpies", npcName = "Fanow Huntress" },
                { fateName = "Shot Through the Hart", npcName = "Qilmet Redspear" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "The Tempest",
        zoneId = 818,
        fatesList = {
            collectionsFates = {
                { fateName = "Low Coral Fiber", npcName = "Teushs Ooan" },
                { fateName = "Pearls Apart", npcName = "Ondo Spearfisher" },
            },
            otherNpcFates = {
                { fateName = "Where has the Dagon", npcName = "Teushs Ooan" },
                { fateName = "Ondo of Blood", npcName = "Teushs Ooan" },
                { fateName = "Lookin' Back on the Track", npcName = "Teushs Ooan" },
            },
            fatesWithContinuations = {},
            specialFates = {
                "The Head, the Tail, the Whole Damned Thing", --archaeotania
            },
            blacklistedFates = {
                "Coral Support", -- escort fate
                "The Seashells He Sells", -- escort fate
            },
        },
    },
    {
        zoneName = "Labyrinthos",
        zoneId = 956,
        fatesList = {
            collectionsFates = {
                { fateName = "Sheaves on the Wind", npcName = "Vexed Researcher" },
                { fateName = "Moisture Farming", npcName = "Well-moisturized Researcher" },
            },
            otherNpcFates = {},
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Thavnair",
        zoneId = 957,
        fatesList = {
            collectionsFates = {
                { fateName = "Full Petal Alchemist: Perilous Pickings", npcName = "Sajabaht" },
            },
            otherNpcFates = {},
            specialFates = {
                "Devout Pilgrims vs. Daivadipa", --daveeeeee
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Garlemald",
        zoneId = 958,
        fatesList = {
            collectionsFates = {
                { fateName = "Parts Unknown", npcName = "Displaced Engineer" },
            },
            otherNpcFates = {
                { fateName = "Artificial Malevolence: 15 Minutes to Comply", npcName = "Keltlona" },
                { fateName = "Artificial Malevolence: The Drone Army", npcName = "Ebrelnaux" },
                { fateName = "Artificial Malevolence: Unmanned Aerial Villains", npcName = "Keltlona" },
                { fateName = "Amazing Crates", npcName = "Hardy Refugee" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Mare Lamentorum",
        zoneId = 959,
        fatesList = {
            collectionsFates = {
                { fateName = "What a Thrill", npcName = "Thrillingway" },
            },
            otherNpcFates = {
                { fateName = "Lepus Lamentorum: Dynamite Disaster", npcName = "Warringway" },
                { fateName = "Lepus Lamentorum: Cleaner Catastrophe", npcName = "Fallingway" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {
                "Hunger Strikes", --really bad line of sight with rocks, get stuck not doing anything quite often
            },
        },
    },
    {
        zoneName = "Ultima Thule",
        zoneId = 960,
        fatesList = {
            collectionsFates = {
                { fateName = "Omicron Recall: Comms Expansion", npcName = "N-6205" },
            },
            otherNpcFates = {
                { fateName = "Wings of Glory", npcName = "Ahl Ein's Kin" },
                { fateName = "Omicron Recall: Secure Connection", npcName = "N-6205" },
                { fateName = "Only Just Begun", npcName = "Myhk Nehr" },
            },
            specialFates = {
                "Omicron Recall: Killing Order", --chi
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Elpis",
        zoneId = 961,
        fatesList = {
            collectionsFates = {
                { fateName = "So Sorry, Sokles", npcName = "Flora Overseer" },
            },
            otherNpcFates = {
                { fateName = "Grand Designs: Unknown Execution", npcName = "Meletos the Inscrutable" },
                { fateName = "Grand Designs: Aigokeros", npcName = "Meletos the Inscrutable" },
                { fateName = "Nature's Staunch Protector", npcName = "Monoceros Monitor" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Urqopacha",
        zoneId = 1187,
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {
                { fateName = "Pasture Expiration Date", npcName = "Tsivli Stoutstrider" },
                { fateName = "Gust Stop Already", npcName = "Mourning Yok Huy" },
                { fateName = "Lay Off the Horns", npcName = "Yok Huy Vigilkeeper" },
                { fateName = "Birds Up", npcName = "Coffee Farmer" },
                { fateName = "Salty Showdown", npcName = "Chirwagur Sabreur" },
                { fateName = "Fire Suppression", npcName = "Tsivli Stoutstrider" },
                { fateName = "Panaq Attack", npcName = "Pelupelu Peddler" },
            },
            fatesWithContinuations = {
                { fateName = "Salty Showdown", continuationIsBoss = true },
            },
            blacklistedFates = {
                "Young Volcanoes",
                "Wolf Parade", -- multiple Pelupelu Peddler npcs, rng whether it tries to talk to the right one
                "Panaq Attack", -- multiple Pelupleu Peddler npcs
            },
        },
    },
    {
        zoneName = "Kozama'uka",
        zoneId = 1188,
        fatesList = {
            collectionsFates = {
                { fateName = "Borne on the Backs of Burrowers", npcName = "Moblin Forager" },
                { fateName = "Combing the Area", npcName = "Hanuhanu Combmaker" },
            },
            otherNpcFates = {
                { fateName = "There's Always a Bigger Beast", npcName = "Hanuhanu Angler" },
                { fateName = "Toucalibri at That Game", npcName = "Hanuhanu Windscryer" },
                { fateName = "Putting the Fun in Fungicide", npcName = "Bagnobrok Craftythoughts" },
                { fateName = "Reeds in Need", npcName = "Hanuhanu Farmer" },
                { fateName = "Tax Dodging", npcName = "Pelupelu Peddler" },
            },
            fatesWithContinuations = {},
            blacklistedFates = {
                "Mole Patrol",
                "Tax Dodging", -- multiple Pelupelu Peddlers
            },
        },
    },
    {
        zoneName = "Yak T'el",
        zoneId = 1189,
        fatesList = {
            collectionsFates = {
                { fateName = "Escape Shroom", npcName = "Hoobigo Forager" },
            },
            otherNpcFates = {
                { fateName = "Could've Found Something Bigger", npcName = "Xbr'aal Hunter" },
                { fateName = "La Selva se lo Llevó", npcName = "Xbr'aal Hunter" },
                { fateName = "Stabbing Gutward", npcName = "Doppro Spearbrother" },
                { fateName = "Porting is Such Sweet Sorrow", npcName = "Hoobigo Porter" },
                { fateName = "Stick it to the Mantis", npcName = "Xbr'aal Sentry" },
            },
            fatesWithContinuations = {
                "Stabbing Gutward",
            },
            blacklistedFates = {
                "The Departed",
                "Could've Found Something Bigger", -- 2 npcs named the same thing
                "Stick it to the Mantis", -- 2 npcs named the same thing
                "La Selva se lo Llevó", -- 2 pncs named the same thing
            },
        },
    },
    {
        zoneName = "Shaaloani",
        zoneId = 1190,
        fatesList = {
            collectionsFates = {
                { fateName = "Gonna Have Me Some Fur", npcName = "Tonawawtan Trapper" },
                { fateName = "The Serpentlord Sires", npcName = "Br'uk Vaw of the Setting Sun" },
            },
            otherNpcFates = {
                { fateName = "The Dead Never Die", npcName = "Tonawawtan Worker" }, --22 boss
                { fateName = "Ain't What I Herd", npcName = "Hhetsarro Herder" }, --23 normal
                { fateName = "Helms off to the Bull", npcName = "Hhetsarro Herder" }, --22 boss
                { fateName = "A Raptor Runs Through It", npcName = "Hhetsarro Angler" }, --24 tower defense
                { fateName = "The Serpentlord Suffers", npcName = "Br'uk Vaw of the Setting Sun" },
                { fateName = "That's Me and the Porter", npcName = "Pelupelu Peddler" },
            },
            fatesWithContinuations = {
                "The Serpentlord Sires",
            },
            specialFates = {
                "The Serpentlord Seethes", -- big snake fate
            },
            blacklistedFates = {},
        },
    },
    {
        zoneName = "Heritage Found",
        zoneId = 1191,
        fatesList = {
            collectionsFates = {
                { fateName = "License to Dill", npcName = "Tonawawtan Provider" },
                { fateName = "When It's So Salvage", npcName = "Refined Reforger" },
            },
            otherNpcFates = {
                { fateName = "It's Super Defective", npcName = "Novice Hunter" },
                { fateName = "Running of the Katobleps", npcName = "Novice Hunter" },
                { fateName = "Ware the Wolves", npcName = "Imperiled Hunter" },
                { fateName = "Domo Arigato", npcName = "Perplexed Reforger" },
                { fateName = "Old Stampeding Grounds", npcName = "Driftdowns Reforger" },
                { fateName = "Pulling the Wool", npcName = "Panicked Courier" },
            },
            fatesWithContinuations = {
                { fateName = "Domo Arigato", continuationIsBoss = false },
            },
            blacklistedFates = {
                "When It's So Salvage", -- terrain is terrible
                "print('I hate snakes')",
            },
        },
    },
    {
        zoneName = "Living Memory",
        zoneId = 1192,
        fatesList = {
            collectionsFates = {
                { fateName = "Seeds of Tomorrow", npcName = "Unlost Sentry GX" },
                { fateName = "Scattered Memories", npcName = "Unlost Sentry GX" },
            },
            otherNpcFates = {
                { fateName = "Canal Carnage", npcName = "Unlost Sentry GX" },
                { fateName = "Mascot March", npcName = "The Grand Marshal" },
            },
            fatesWithContinuations = {
                { fateName = "Plumbers Don't Fear Slimes", continuationIsBoss = true },
                { fateName = "Mascot March", continuationIsBoss = true },
            },
            specialFates = {
                "Mascot Murder",
            },
            blacklistedFates = {
                "Plumbers Don't Fear Slimes", --Causing Script to crash
            },
        },
    },
}

end)
return __bundle_require("__root")