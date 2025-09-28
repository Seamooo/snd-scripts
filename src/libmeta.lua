---@meta
--- type declarations for snd builtins as well as useful apis that could be imported
--- TODO(seamooo) codegen this from NLua / snd
--- The below is not exhaustive but aims to be added to whenever type
--- definitions are required

--- @param content string
--- @diagnostic disable-next-line: lowercase-global
function yield(content) end

--- @param path string
--- @diagnostic disable-next-line: lowercase-global
function import(path) end

---@class System_Numerics_Vector3
---@field X number
---@field Y number
---@field Z number
---@overload fun(x:number, y:number, z:number):System_Numerics_Vector3
Vector3 = {}

---@class System_Numerics_Vector2
---@field X number
---@field Y number
---@overload fun(x:number, y:number):System_Numerics_Vector2
Vector2 = {}

---@class IEnumerable<T>: { [integer]: T}
---@field Count number

---@class AtkValueWrapper
---@field ValueString string
local AtkValueWrapper = {}

---@class NodeWrapper
---@field Id number
---@field IsVisible boolean
---@field Text string
---@field NodeType number
local NodeWrapper = {}

---@class AddonWrapper
---@field Exists boolean
---@field Ready boolean
---@field AtkValues IEnumerable<AtkValueWrapper>
---@field Nodes IEnumerable<NodeWrapper>
--- TODO(seamooo) investigate below type
local AddonWrapper = {}

---@param ... number 
---@return NodeWrapper
function AddonWrapper.GetNode(...) end

---@class Addons
---@field GetAddon fun(name: string): AddonWrapper
Addons = {}

---@class Config
---@field Get fun(varName: string): any?
Config = {}


---@class Dalamud
---@field Log fun(message: any)
---@field LogDebug fun(message: any)
---@field LogVerbose fun(message: any)
Dalamud = {}

---@class Entity
---@field GetPartyMember fun(index: number): EntityWrapper
---@field GetAllianceMember fun(index: number): EntityWrapper
---@field GetEntityByName fun(name: string): EntityWrapper
---@field Player EntityWrapper
---@field Target EntityWrapper?
---@field FocusTargetTarget EntityWrapper?
---@field NearestDeadCharacter EntityWrapper?
Entity = {}

---@class FateWrapper
---@field Id number
---@field Exists boolean
---@field InFate boolean
---@field State number
---@field StartTimeEpoch number
---@field Duration number
---@field Name string
---@field HandInCount number
---@field Location System_Numerics_Vector3
---@field Progress number
---@field IsBonus boolean 
---@field Radius number
---technically a fate rule field here but omitted until enums are more concrete
---@field Level number
---@field MaxLevel number
---@field FATEChain number
---@field EventItem number
---@field IconId number
---@field DistanceToPlayer number
local FateWrapper = {}

---@class Fates
---@field GetFateById fun(fateId: number): FateWrapper
---@field GetNearestFate fun(): FateWrapper
---@field GetActiveFates fun(): IEnumerable<FateWrapper> 
---@field CurrentFate fun(): FateWrapper
Fates = {}

---@class PublicInstanceWrapper
---@field TerritoryTypeId number
---@field InstanceId number
---@field IsInstancedArea boolean
local PublicInstanceWrapper = {}

---@class InstancedContent
---@field PublicInstance PublicInstanceWrapper
InstancedContent = {}

---@class FrameworkWrapper
---@field EorzeaTime number
---@field ClientLanguage number
---@field Region number
local FrameworkWrapper = {}

---@class BuddyMemberWrapper
---@field EntityId number
---@field CurrentHealth number
---@field MaxHealth number
---@field DataId number
---@field Synced number
---@field Status StatusWrapper[]
local BuddyMemberWrapper = {}

---@class CompanionInfoWrapper
---@field TimeLeft number
---@field BardingHead number
---@field BardingChest number
---@field BardingFeet number
---@field CurrentXp number
---@field Rank number
---@field Stars number
---@field SkillPoints number
---@field DefenderLevel number
---@field AttackerLevel number
---@field HealerLevel number
---@field ActiveCommand number
---@field FavoriteFeed number
---@field CurrentColorStainId number
---@field Mounted boolean
---@field Name string
local CompanionInfoWrapper = {}

---@class BuddyWrapper
---@field BuddyMember BuddyMemberWrapper[]
---@field CompanionInfo CompanionInfoWrapper
local BuddyWrapper = {}

---@class FlagWrapper
---@field TerritoryId number
---@field MapId number
---@field XFloat number
---@field YFloat number
---@field Vector2 System_Numerics_Vector2
---@field Vector3 System_Numerics_Vector3
local FlagWrapper = {}

---@param territoryId number
---@param mapId number
---@param x number
---@param y number
function FlagWrapper:SetFlagMapMarker(territoryId, mapId, x, y) end

---@param territoryId number
---@param x number
---@param y number
function FlagWrapper:SetFlagMapMarker(territoryId, x, y) end

---@class MapWrapper
---@field IsFlagMarkerSet boolean
---@field Flag FlagWrapper
local MapWrapper = {}

---@class TelepoWrapper
---@field Teleport fun(aetheryte: any)
---@field Teleport fun(aetheryteId: number, subIndex: number)
---@field GetAetherytePosition fun(aetheryteId: number): System_Numerics_Vector3
---@field IsAetheryteUnlocked fun(aetheryteId: number): boolean 
local TelepoWrapper = {}

---@class Instances
---@field Framework FrameworkWrapper
---@field Buddy BuddyWrapper
---@field Map MapWrapper
---@field Telepo TelepoWrapper
Instances = {}

---@class InventoryItemWrapper
---@field ItemId number
---@field BaseItemId number
---@field Count number
---@field SpiritbondOrCollectability number
---@field Condition number
---@field GlamourId number
---@field IsHighQuality boolean
local InventoryItemWrapper = {}

---@class Inventory
---@field GetItemCount fun(itemId: number): number
---@field GetItemsInNeedOfRepairs fun(durability: number?): IEnumerable<InventoryItemWrapper>
---@field GetSpiritbondedItems fun(): IEnumerable<InventoryItemWrapper>
---@field GetFreeInventorySlots fun(): number
Inventory = {}

---@class OfflineRetainerDataWrapper
---@field Name string
---@field VentureEndsAt number
---@field HasVenture boolean
---@field Level number
---@field VentureBeginsAt number
---@field Job number
---@field VentureID number
---@field Gil number
---@field RetainerID number
---@field MBItems number
local OfflineRetainerDataWrapper = {}

---@class OfflineCharacterDataWrapper
---@field CID number
---@field Name string
---@field World string
---@field Enabled boolean
---@field WorkshopEnabled boolean
---@field RetainerData IEnumerable<OfflineRetainerDataWrapper>
local OfflineCharacterDataWrapper = {}

---@class AutoRetainerIPC
---@field EnqueueInitiation fun(): boolean
---@field GetOfflineCharacterData fun(cid: number): OfflineCharacterDataWrapper
local AutoRetainerIPC = {}

---@class LifeStreamIPC
---@field ExecuteCommand fun(command: string)
---@field IsBusy fun(): boolean
---@field Abort fun()
local LifeStreamIPC = {}

---@class TextAdvanceIPC
---@field Stop fun()
---@field IsBusy fun(): boolean
---@field IsInExternalControl fun(): boolean
---@field IsEnabled fun(): boolean
---@field IsPaused fun(): boolean
---@field GetEnableQuestAccept fun(): boolean
---@field GetEnableQuestComplete fun(): boolean
---@field GetEnableRewardPick fun(): boolean
---@field GetEnableCutsceneEsc fun(): boolean
---@field GetEnableCutsceneSkipConfirm fun(): boolean
---@field GetEnableRequestHandin fun(): boolean
---@field GetEnableRequestFill fun(): boolean
---@field GetEnableTalkSkip fun(): boolean
---@field GetEnableAutoInteract fun(): boolean
local TextAdvanceIPC = {}

---@class VnavmeshIPC
---@field IsReady fun(): boolean
---@field BuildProgress fun(): number 
---@field Reload fun(): boolean
---@field Rebuild fun(): boolean
---@field PathfindAndMoveTo fun(dest: System_Numerics_Vector3, fly: boolean): boolean
---@field PathfindInProgress fun(): boolean
---@field Stop fun()
---@field IsRunning fun(): boolean
---@field PointOnFloor fun(p: System_Numerics_Vector3, allowUnlandable: boolean, halfExtentXZ: number): System_Numerics_Vector3?
local VnavmeshIPC = {}

---@class BossModIPC
---@field Get fun(name: string): string
---@field Create fun(name: string, overwrite: boolean): boolean
---@field Delete fun(name: string): boolean
---@field GetActive fun(): string
---@field SetActive fun(name: string)
---@field ClearActive fun(): boolean
---@field GetForceDisabled fun(): boolean
---@field SetForceDisabled fun(): boolean
local BossmodIPC = {}

---@class IPC
---@field IsInstalled fun(name: string): boolean
---@field GetAvailablePlugins fun(): any
---@field AutoRetainer AutoRetainerIPC?
---@field Lifestream LifeStreamIPC?
---@field TextAdvance TextAdvanceIPC?
---@field vnavmesh VnavmeshIPC?
---@field BossMod BossModIPC?
IPC = {}

---@class StatusWrapper
---@field StatusId number
---@field Param number
---@field RemainingTime number
---@field SourceObject EntityWrapper
local StatusWrapper = {}

---@class EntityWrapper
---@field Type number
---@field Name string
---@field Position System_Numerics_Vector3
---@field DistanceTo number
---@field ContentId number
---@field AccountId number
---@field CurrentWorld number
---@field HomeWorld number
---@field CurrentHp number
---@field MaxHp number
---@field HealthPercent number
---@field CurrentMp number
---@field MaxMp number
---@field Target EntityWrapper?
---@field IsCasting boolean
---@field IsCastInterruptable boolean
---@field IsInCombat boolean
---@field HuntRank number
---@field IsMounted boolean
---@field Status StatusWrapper[]
---@field FateId number
---@field SetAsTarget fun()
---@field SetAsFocusTarget fun()
---@field ClearTarget fun()
---@field Interact fun()
local EntityWrapper = {}

---@class JobWrapper
---@field Id number
---@field Name string
---@field Abbreviation string
---@field IsCrafter boolean
---@field IsGatherer boolean
---@field IsMeleeDPS boolean
---@field IsRangedDPS boolean
---@field IsMagicDPS boolean
---@field IsHealer boolean
---@field IsTank boolean
---@field IsDPS boolean
---@field IsDiscipleOfWar boolean
---@field IsDiscipleOfMagic boolean
---@field IsBlu boolean
---@field IsLimited boolean
---@field Level number
local JobWrapper = {}

---@class Player
---@field GetJob fun(classJobId: number): JobWrapper
---@field Entity EntityWrapper
---@field Job JobWrapper
---@field IsMoving boolean
---@field IsInDuty boolean
---@field IsOnIsland boolean
---@field IsBusy boolean
---@field CanFly boolean
---@field CanMount boolean
---@field Revivable boolean
---@field Available boolean
---@field IsLevelSynced boolean
Player = {}

---@class IExposedPlugin
---@field Name string
---@field InternalName string
---@field IsLoaded boolean
local IExposedPlugin = {}

---@class IDalamudPluginInterface
---@field InstalledPlugins IExposedPlugin[]
local IDalamudPluginInterface = {}

---@class ICondition: { [number]: boolean }
local ICondition = {}

---@class SeString
---@field TextValue string
local SeString = {}

---@enum ObjectKind
local ObjectKind = {
    None = 0,
    Player = 1,
    BattleNpc = 2,
    EventNpc = 3,
    Treasure = 4,
    Aetheryte = 5,
    GatheringPoint = 6,
    EventObj = 7,
    MountType = 8,
    Companion = 9,
    Retainer = 10,
    Area = 11,
    Housing = 12,
    Cutscene = 13,
    CardStand = 14,
    Ornament = 15
}

---@class ObjectKindEnum
---@field None ObjectKind.None
---@field Player ObjectKind.Player
---@field BattleNpc ObjectKind.BattleNpc
---@field EventNpc ObjectKind.EventNpc
---@field Treasure ObjectKind.Treasure
---@field Aetheryte ObjectKind.Aetheryte
---@field GatheringPoint ObjectKind.GatheringPoint
---@field EventObj ObjectKind.EventObj
---@field MountType ObjectKind.MountType
---@field Companion ObjectKind.Companion
---@field Retainer ObjectKind.Retainer
---@field Area ObjectKind.Area
---@field Housing ObjectKind.Housing
---@field Cutscene ObjectKind.Cutscene
---@field CardStand ObjectKind.CardStand
---@field Ornament ObjectKind.Ornament

---@class IGameObject
---@field Name SeString
---@field GameObjectId number
---@field Position System_Numerics_Vector3
---@field HitboxRadius number
---@field IsTargetable boolean
---@field IsDead boolean
---@field ObjectKind ObjectKind
local IGameObject = {}

---@return boolean
function IGameObject:IsHostile() end

---NOTE This is for typing only, using the literal
---integer values will result in unexpected behaviour
---@enum NameplateKind
local NameplateKind = {
    PlayerCharacterSelf = 1,
    InDutyPartyMember = 2,
    InDutyNpcNotInParty = 3,
    EnemyMalestromPvPPC = 4,
    EnemyAdderPvPPC = 5,
    EnemyFlamesPvPPC = 6,
    HostileNotEngaged = 7,
    Dead = 8,
    HostileEngagedSelfDamaged = 9,
    HostileEngagedOther = 10,
    HostileEngagedSelfUndamaged = 11,
    FriendlyBattleNPC = 12,
    PlayerCharacterChocobo = 15,
    OtherPlayerCharacterChocobo = 17,
    OtherAlliancePlayerCharacter = 20,
    AnyPlayerCharacterDead = 21,
    OutOfDutyPartyPC = 22,
    InDutyPCInPartyTank = 27,
    InDutyPcInPartyHealer = 28,
    InDutyPCInPartyDPS = 29
}

---Used for typing the loaded enum type
---@class NameplateKindEnum
---@field PlayerCharacterSelf NameplateKind.PlayerCharacterSelf
---@field InDutyPartyMember NameplateKind.InDutyPartyMember
---@field InDutyNpcNotInParty NameplateKind.InDutyNpcNotInParty
---@field EnemyMalestromPvPPC NameplateKind.EnemyMalestromPvPPC
---@field EnemyAdderPvPPC NameplateKind.EnemyAdderPvPPC
---@field EnemyFlamesPvPPC NameplateKind.EnemyFlamesPvPPC
---@field HostileNotEngaged NameplateKind.HostileNotEngaged
---@field Dead NameplateKind.Dead
---@field HostileEngagedSelfDamaged NameplateKind.HostileEngagedSelfDamaged
---@field HostileEngagedOther NameplateKind.HostileEngagedOther
---@field HostileEngagedSelfUndamaged NameplateKind.HostileEngagedSelfUndamaged
---@field FriendlyBattleNPC NameplateKind.FriendlyBattleNPC
---@field PlayerCharacterChocobo NameplateKind.PlayerCharacterChocobo
---@field OtherPlayerCharacterChocobo NameplateKind.OtherPlayerCharacterChocobo
---@field OtherAlliancePlayerCharacter NameplateKind.OtherAlliancePlayerCharacter
---@field AnyPlayerCharacterDead NameplateKind.AnyPlayerCharacterDead
---@field OutOfDutyPartyPC NameplateKind.OutOfDutyPartyPC
---@field InDutyPCInPartyTank NameplateKind.InDutyPCInPartyTank
---@field InDutyPcInPartyHealer NameplateKind.InDutyPcInPartyHealer
---@field InDutyPCInPartyDPS NameplateKind.InDutyPCInPartyDPS

---@return NameplateKind
function IGameObject:GetNameplateKind() end

---@class ITargetManager
---@field Target IGameObject?
local ITargetManager = {}

---@class ICharacter: IGameObject
local ICharacter = {}

---@class Status
---@field StatusId number
local Status = {}

---@class StatusList: { [number]: Status }
---@field Length number
local StatusList = {}

---@class IBattleCharacter: ICharacter
---@field Position System_Numerics_Vector3
---@field StatusList StatusList
local IBattleCharacter = {}

---@class IPlayerCharacter: IBattleCharacter
---todo(seamooo) represent RowRef properly here
---@field CurrentWorld any
---@field HomeWorld any
local IPlayerCharacter = {}

---@class IClientState
---@field LocalPlayer IPlayerCharacter?
---@field TerritoryType number
---@field LocalContentId number
local IClientState = {}

---@class ObjectTable: { [number]: IGameObject }
---@field Length number
local ObjectTable = {}

---@class IAetheryteEntry
---@field TerritoryId number
local IAetheryteEntry = {}

---@class IAetheryteList: { [number]: IAetheryteEntry? }
---@field Length number
local IAetheryteList = {}

--- this is just so insanely huge it has to be done on case by case
--- below is the Svc interface provided by ecommons
--- @class Svc
--- @field PluginInterface IDalamudPluginInterface
--- @field Condition ICondition
--- @field Targets ITargetManager
--- @field ClientState IClientState
--- @field Objects ObjectTable
--- @field AetheryteList IAetheryteList
Svc = {}

---@class luanet
---@field load_assembly fun(assembly: string): any
---@field import_type fun(type: string): any
luanet = {}

-- TODO(seamooo) investigate below
---@generic T
---@param enumerable IEnumerable<T>
---@return T[]
function luanet.each(enumerable) end