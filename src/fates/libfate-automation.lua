---@alias ChocoboStance
---| '"Follow"'
---| '"Free"'
---| '"Defender"'
---| '"Healer"'
---| '"Attacker"'
---| '"None"'

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

---@class FateAutomationConfig
---@field Food string?
---@field Potion string?
---@field ResummonChocoboTimeLeft number
---@field ChocoboStance ChocoboStance
---@field EnableAutoBuyGysahlGreens boolean
---@field MountToUse string
---@field CompletionToIgnoreFate number?
---@field MainJob JobWrapper
---@field BossFatesJob JobWrapper?
---@field RotationPlugin RotationPlugin
---@field DodgingPlugin DodgingPlugin?
---@field MinWait number
---@field MaxWait number
---@field EnableDowntimeWaitAtNearestAetheryte boolean
---@field EnableMoveToRandomSpot boolean
---@field GcTurnIn GcTurnIn
---@field EnableWaitIfBonusBuff boolean
---@field EnableAutoExtractMateria boolean
---@field EnableAutoBuyDarkMatter boolean
---@field EnableChangeInstace boolean
---@field EnableReturnOnDeath boolean
---@field EnableRetainers boolean
local FateAutomationConfig = {}
FateAutomationConfig.__index = FateAutomationConfig

---@return FateAutomationConfig
function FateAutomationConfig.default()
    return {
        Food = nil,
        Potion = nil,
        ResummonChocoboTimeLeft = 3 * 60,
        ChocoboStance = "Healer",
        MountTuUse = "mount roulette",
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
        EnableDowntimeWaitAtNearestAetheryte = false,
        EnableMoveToRandomSpot = false,
        GcTurnIn = { Enabled = false },
        EnableWaitIfBonusBuff = true,
        EnableAutoExtractMateria = true,
        EnableAutoBuyDarkMatter = true,
        EnableChangeInstance = true,
        EnableReturnOnDeath = true,
        EnableRetainers = false,
    }
end

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
---@field isCollectionsFate boolean
---@field isBossFate boolean
---@field isSpecialFate boolean
---@field isBlacklistedFate boolean

---@class FateAutomation
---@field Config FateAutomationConfig
---@field private CurrentFate FateWrapper?
local FateAutomation = {}
FateAutomation.__index = FateAutomation

---@return FateAutomation
function FateAutomation.new()
    local rv = setmetatable({}, FateAutomation)
    return rv 
end