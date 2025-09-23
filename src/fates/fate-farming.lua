--[=====[
[[SND Metadata]]
author: seamooo || forked from baanderson40 || orginially pot0to
version: 3.1.5
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
  Companion Script Mode:
    description: Enable to use companison scripts with main Fate Farming script.
    default: false
[[End Metadata]]
--]=====]
--[[

********************************************************************************
*                                  Changelog                                   *
********************************************************************************
    -> 3.1.5    WIP modularised rewrite
    -> 3.1.4    Modified VBM/BMR combat commands to use IPCs
    -> 3.1.3    Companion script echo logic changed to true only
    -> 3.1.2    Fix VBM/BMR hold buff rotation setting issue
    -> 3.1.1    Reverted RSR auto to just 'on'
    -> 3.1.0    Updated to support companion scripts by Minnu

********************************************************************************
    -> 3.0.21   Updated meta data config settings
    -> 3.0.20   Fixed unexptected combat while moving
    -> 3.0.19   Fixed random pathing to mob target
    -> 3.0.18   Fixed Mender and Darkmatter npc positions
    -> 3.0.17   Removed types from config settings
    -> 3.0.16   Corrected Bossmod Reborn spelling for dodging plugin
    -> 3.0.15   Added none as a purchase option to disable purchases
    -> 3.0.14   Fixed setting issue with Percentage to hold buff
    -> 3.0.13   Added list for settings
    -> 3.0.12   Fixed TextAdvance enabling
    -> 3.0.11   Revision rollup
                Fixed Gysahl Greens purchases
                Blacklisted "Plumbers Don't Fear Slimes" due to script crashing
    -> 3.0.10   By baanderson40
            a   Max melee distance fix.
            b   WaitingForFateRewards fix.
            c   Removed HasPlugin and implemented IPC.IsInstalled from SND **reversed**.
            d   Removed Deliveroo and implemented AutoReainter GC Delievery.
            e   Swapped echo yields for yield.
            f   Added settions to config settings.
            g   Fixed unexpected Combat.
            h   Removed the remaining yields except for waits.
            i   Ready function optimized and refactord.
            j   Reworked Rotation and Dodging pluings.
            k   Fixed Materia Extraction
            l   Updated Config settings for BMR/VMR rotations
            m   Added option to move to random location after fate if none are eligible.
            n   Actually fixed WaitingForFateRewards & instance hopping.
    -> 3.0.9    By Allison.
                Fix standing in place after fate finishes bug.
                Add config options for Rotation Plugin and Dodging Plugin (Fixed bug when multiple solvers present at once)
                Update description to more accurately reflect script.
                Cleaned up metadata + changed description to more accurately reflect script.
                Small change to combat related distance to target checks to more accurately reflect how FFXIV determines if abilities are usable (no height). Hopefully fixes some max distance checks during combat.
                Small Bugfixes.
    -> 3.0.6    Adding metadata
    -> 3.0.5    Fixed repair function
    -> 3.0.4    Remove noisy logging
    -> 3.0.2    Fixed HasPlugin check
    -> 3.0.1    Fixed typo causing it to crash
    -> 3.0.0    Updated for SND2

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

require('libfate-utils')

--#region Main

CharacterState = {
    ready                   = Ready,
    dead                    = HandleDeath,
    unexpectedCombat        = HandleUnexpectedCombat,
    mounting                = MountState,
    npcDismount             = NpcDismount,
    MiddleOfFateDismount    = MiddleOfFateDismount,
    moveToFate              = MoveToFate,
    interactWithNpc         = InteractWithFateNpc,
    collectionsFateTurnIn   = CollectionsFateTurnIn,
    doFate                  = DoFate,
    waitForContinuation     = WaitForContinuation,
    changingInstances       = ChangeInstance,
    changeInstanceDismount  = ChangeInstanceDismount,
    flyBackToAetheryte      = FlyBackToAetheryte,
    extractMateria          = ExtractMateria,
    repair                  = Repair,
    exchangingVouchers      = ExecuteBicolorExchange,
    processRetainers        = ProcessRetainers,
    gcTurnIn                = GrandCompanyTurnIn,
    summonChocobo           = SummonChocobo,
    autoBuyGysahlGreens     = AutoBuyGysahlGreens
}

--- Fate state enum mapping (values confirmed from FFXIV SND)
FateState = {
    None       = 0,  -- no state / unknown
    Preparing  = 1,  -- fate is setting up
    Waiting    = 2,  -- waiting before spawn
    Spawning   = 3,  -- mobs/NPCs spawning
    Running    = 4,  -- fate active and in progress
    Ending     = 5,  -- fate nearing completion
    Ended      = 6,  -- fate finished successfully
    Failed     = 7   -- fate failed
}

-- Settings Area
-- Buffs
Food                            = Config.Get("Food")
Potion                          = Config.Get("Potion")

-- Chocobo
ResummonChocoboTimeLeft            = 3 * 60        --Resummons chocobo if there's less than this many seconds left on the timer, so it doesn't disappear on you in the middle of a fate.
ChocoboStance                   = Config.Get("Chocobo Companion Stance") -- Options: Follow, Free, Defender, Healer, Attacker, None. Do not summon if None.
ShouldSummonChocobo =  ChocoboStance == "Follow"
                    or ChocoboStance == "Free"
                    or ChocoboStance == "Defender"
                    or ChocoboStance == "Healer"
                    or ChocoboStance == "Attacker"
ShouldAutoBuyGysahlGreens       = Config.Get("Buy Gysahl Greens?")
MountToUse                      = "mount roulette"       --The mount youd like to use when flying between fates

-- Retainer




--Fate Combat
CompletionToIgnoreFate          = Config.Get("Ignore FATE if progress is over (%)")
MinTimeLeftToIgnoreFate         = Config.Get("Ignore FATE if duration is less than (mins)") * 60
CompletionToJoinBossFate        = Config.Get("Ignore boss FATEs until progress is at least (%)")
CompletionToJoinSpecialBossFates = Config.Get("Ignore Special FATEs until progress is at least (%)")
JoinCollectionsFates            = Config.Get("Do collection FATEs?")
BonusFatesOnly                  = Config.Get("Do only bonus FATEs?") --If true, will only do bonus fates and ignore everything else
FatePriority                    = {"DistanceTeleport", "Progress", "Bonus", "TimeLeft", "Distance" }
MeleeDist                       = Config.Get("Max melee distance")
RangedDist                      = Config.Get("Max ranged distance")
HitboxBuffer                    = 0.5
--ClassForBossFates                = ""            --If you want to use a different class for boss fates, set this to the 3 letter abbreviation

-- Variable initialzization
StopScript                      = false
DidFate                         = false
GemAnnouncementLock             = false
DeathAnnouncementLock           = false
MovingAnnouncementLock          = false
SuccessiveInstanceChanges       = 0
LastInstanceChangeTimestamp     = 0
LastTeleportTimeStamp           = 0
GotCollectionsFullCredit        = false
WaitingForFateRewards           = nil
LastFateEndTime                 = os.clock()
LastStuckCheckTime              = os.clock()
LastStuckCheckPosition          = Player.Entity.Position
MainClass                       = Player.Job
BossFatesClass                  = nil

--Forlorns
IgnoreForlorns = false
IgnoreBigForlornOnly = false
Forlorns = string.lower(Config.Get("Forlorns"))
if Forlorns == "none" then
    IgnoreForlorns = true
elseif Forlorns == "small" then
    IgnoreBigForlornOnly = true
end

-- Rotation plugin
local configRotationPlugin = string.lower(Config.Get("Rotation Plugin"))
if configRotationPlugin == "any" then
    if HasPlugin("WrathCombo") then
        RotationPlugin = "Wrath"
    elseif HasPlugin("RotationSolver") then
        RotationPlugin = "RSR"
    elseif HasPlugin("BossModReborn") then
        RotationPlugin = "BMR"
    elseif HasPlugin("BossMod") then
        RotationPlugin = "VBM"
    end
elseif configRotationPlugin == "wrath" and HasPlugin("WrathCombo") then
    RotationPlugin = "Wrath"
elseif configRotationPlugin == "rotationsolver" and HasPlugin("RotationSolver") then
    RotationPlugin = "RSR"
elseif configRotationPlugin == "bossmodreborn" and HasPlugin("BossModReborn") then
    RotationPlugin = "BMR"
elseif configRotationPlugin == "bossmod" and HasPlugin("BossMod") then
    RotationPlugin = "VBM"
else
    StopScript = true
end
RSRAoeType                 = "Full"      --Options: Cleave/Full/Off

-- For BMR/VBM/Wrath rotation plugins
RotationSingleTargetPreset      = Config.Get("Single Target Rotation") --Preset name with single target strategies (for forlorns). TURN OFF AUTOMATIC TARGETING FOR THIS PRESET
RotationAoePreset               = Config.Get("AoE Rotation")           --Preset with AOE + Buff strategies.
RotationHoldBuffPreset          = Config.Get("Hold Buff Rotation")     --Preset to hold 2min burst when progress gets to seleted %
PercentageToHoldBuff            = Config.Get("Percentage to Hold Buff")--Ideally youll want to make full use of your buffs, higher than 70% will still waste a few seconds if progress is too fast.

-- Dodge plugin
local dodgeConfig = string.lower(Config.Get("Dodging Plugin"))  -- Options: Any / BossModReborn / BossMod / None

-- Resolve "any" or specific plugin if available
if dodgeConfig == "any" then
    if HasPlugin("BossModReborn") then
        DodgingPlugin = "BMR"
    elseif HasPlugin("BossMod") then
        DodgingPlugin = "VBM"
    else
        DodgingPlugin = "None"
    end
elseif dodgeConfig == "bossmodreborn" and HasPlugin("BossModReborn") then
    DodgingPlugin = "BMR"
elseif dodgeConfig == "bossmod" and HasPlugin("BossMod") then
    DodgingPlugin = "VBM"
else
    DodgingPlugin = "None"
end

-- Override if RotationPlugin already uses a dodging plugin
if RotationPlugin == "BMR" then
    DodgingPlugin = "BMR"
elseif RotationPlugin == "VBM" then
    DodgingPlugin = "VBM"
end

-- Final warning if no dodging plugin is active
if DodgingPlugin == "None" then
    yield(
    "/echo [FATE] Warning: you do not have an AI dodging plugin configured, so your character will stand in AOEs. Please install either Veyn's BossMod or BossMod Reborn")
end

--Post Fate Settings
MinWait                        = 3          --Min number of seconds it should wait until mounting up for next fate.
MaxWait                        = 10         --Max number of seconds it should wait until mounting up for next fate.
    --Actual wait time will be a randomly generated number between MinWait and MaxWait.
DownTimeWaitAtNearestAetheryte = false      --When waiting for fates to pop, should you fly to the nearest Aetheryte and wait there?
MoveToRandomSpot               = false      --Randomly fly to spot while waiting on fate.
InventorySlotsLeft             = 5          --how much inventory space before turning in
WaitIfBonusBuff                = true       --Dont change instances if you have the Twist of Fate bonus buff
NumberOfInstances              = 2
RemainingDurabilityToRepair    = 10         --the amount it needs to drop before Repairing (set it to 0 if you don't want it to repair)
ShouldAutoBuyDarkMatter        = true       --Automatically buys a 99 stack of Grade 8 Dark Matter from the Limsa gil vendor if you're out
ShouldExtractMateria           = true       --should it Extract Materia

-- Config settings
EnableChangeInstance           = Config.Get("Change instances if no FATEs?")
ShouldExchangeBicolorGemstones = Config.Get("Exchange bicolor gemstones?")
ItemToPurchase                 = Config.Get("Exchange bicolor gemstones for")
if ItemToPurchase == "None" then
    ShouldExchangeBicolorGemstones = false
end
ReturnOnDeath                   = Config.Get("Return on death?")
SelfRepair                      = Config.Get("Self repair?")
Retainers                       = Config.Get("Pause for retainers?")
ShouldGrandCompanyTurnIn        = Config.Get("Dump extra gear at GC?")
Echo                            = string.lower(Config.Get("Echo logs"))
CompanionScriptMode             = Config.Get("Companion Script Mode")

-- Plugin warnings
if Retainers and not HasPlugin("AutoRetainer") then
    Retainers = false
    yield("/echo [FATE] Warning: you have enabled the feature to process retainers, but you do not have AutoRetainer installed.")
end

if ShouldGrandCompanyTurnIn and not HasPlugin("AutoRetainer") then
    ShouldGrandCompanyTurnIn = false
    yield("/echo [FATE] Warning: you have enabled the feature to process GC turn ins, but you do not have AutoRetainer installed.")
end

-- Enable Auto Advance plugin
yield("/at y")

-- Functions
--Set combat max distance
SetMaxDistance()

--Set selected zone
SelectedZone = SelectNextZone()
if SelectedZone.zoneName ~= "" and Echo == "all" then
    yield("/echo [FATE] Farming "..SelectedZone.zoneName)
end
Dalamud.Log("[FATE] Farming Start for "..SelectedZone.zoneName)

if ShouldExchangeBicolorGemstones ~= false then
    for _, shop in ipairs(BicolorExchangeData) do
        for _, item in ipairs(shop.shopItems) do
            if item.itemName == ItemToPurchase then
                SelectedBicolorExchangeData = {
                    shopKeepName = shop.shopKeepName,
                    zoneId = shop.zoneId,
                    aetheryteName = shop.aetheryteName,
                    miniAethernet = shop.miniAethernet,
                    position = shop.position,
                    item = item
                }
            end
        end
    end
    if SelectedBicolorExchangeData == nil then
        yield("/echo [FATE] Cannot recognize bicolor shop item "..ItemToPurchase.."! Please make sure it's in the BicolorExchangeData table!")
        StopScript = true
    end
end

if InActiveFate() then
    CurrentFate = BuildFateTable(Fates.GetNearestFate())
end

if ShouldSummonChocobo and GetBuddyTimeRemaining() > 0 then
    yield('/cac "'..ChocoboStance..' stance"')
end

Dalamud.Log("[FATE] Starting fate farming script.")

State = CharacterState.ready
CurrentFate = nil

if CompanionScriptMode then
    yield("/echo The companion script will overwrite changing instances.")
    EnableChangeInstance = false
end

while not StopScript do
    local nearestFate = Fates.GetNearestFate()
    if not IPC.vnavmesh.IsReady() then
        yield("/echo [FATE] Waiting for vnavmesh to build...")
        Dalamud.Log("[FATE] Waiting for vnavmesh to build...")
        repeat
            yield("/wait 1")
        until IPC.vnavmesh.IsReady()
    end
    if State ~= CharacterState.dead and Svc.Condition[CharacterCondition.dead] then
        State = CharacterState.dead
        Dalamud.Log("[FATE] State Change: Dead")
    elseif not Player.IsMoving then
        if State ~= CharacterState.unexpectedCombat
        and State ~= CharacterState.doFate
        and State ~= CharacterState.waitForContinuation
        and State ~= CharacterState.collectionsFateTurnIn
        and Svc.Condition[CharacterCondition.inCombat]
        and (
            not InActiveFate()
            or (InActiveFate() and IsCollectionsFate(nearestFate.Name) and nearestFate.Progress == 100)
            )
        then
            State = CharacterState.unexpectedCombat
            Dalamud.Log("[FATE] State Change: UnexpectedCombat")
        end
    end

    BicolorGemCount = Inventory.GetItemCount(26807)

    if WaitingForFateRewards ~= nil then
        local state = WaitingForFateRewards.fateObject and WaitingForFateRewards.fateObject.State or nil
        if WaitingForFateRewards.fateObject == nil
            or state == nil
            or state == FateState.Ended
            or state == FateState.Failed
        then
            local msg = "[FATE] WaitingForFateRewards.fateObject is nil or fate state ("..tostring(state)..") indicates fate is finished for fateId: "..tostring(WaitingForFateRewards.fateId)..". Clearing it."
            Dalamud.Log(msg)
            if Echo == "all" then
                yield("/echo "..msg)
            end
            WaitingForFateRewards = nil
        else
            local msg = "[FATE] Not clearing WaitingForFateRewards: fate state="..tostring(state)..", expected one of [Ended: "..tostring(FateState.Ended)..", Failed: "..tostring(FateState.Failed).."] or nil."
            Dalamud.Log(msg)
            if Echo == "all" then
                yield("/echo "..msg)
            end
        end
    end
    if not (Svc.Condition[CharacterCondition.betweenAreas]
        or Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair]
        or IPC.Lifestream.IsBusy())
        then
            State()
    end
    yield("/wait 0.25")
end
yield("/vnav stop")

if Player.Job.Id ~= MainClass.Id then
    yield("/gs change "..MainClass.Name)
end

yield("/echo [Fate] Loop Ended !!")
--#endregion Main
