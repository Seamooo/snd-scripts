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
