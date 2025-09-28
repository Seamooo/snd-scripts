require("libfate-data")

---logs source line number
---@return integer line number
function __LINE__() return debug.getinfo(2, 'l').currentline end

---@generic T: {[string]: any}
---@param val T
function DbgTable(val)
    local rv = "{"
    local firstElem = true
    for k, v in pairs(val) do
        if not firstElem then
            rv = rv..", "
        end
        firstElem = false
        rv = rv.."{\""..k.."\": "..tostring(v).."}"
    end
    rv = rv.."}"
    return rv
end

---@generic T
---@param val T[]
---@return string
function StringifyArray(val)
    local rv = "{"
    for idx, x in ipairs(val) do
        if idx ~= 1 then
            rv = rv..", "
        end
        rv = rv..tostring(x)
    end
    rv = rv.."}"
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
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
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
    for i=0, activeFates.Count-1 do
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
    Dalamud.Log("[FATE] Setting map flag to zone #"..zoneId..", (X: "..position.X..", "..position.Z.." )")
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
EntityWrapper = load_type('SomethingNeedDoing.LuaMacro.Wrappers.EntityWrapper')

---@type ObjectKindEnum
ObjectKind = load_type('Dalamud.Game.ClientState.Objects.Enums.ObjectKind')

---@type NameplateKindEnum
NameplateKind = load_type('ECommons.GameFunctions.NameplateKind')

function AttemptToTargetClosestFateEnemy()
    local closestTarget = nil
    local closestTargetDistance = math.maxinteger
    for i=0, Svc.Objects.Length-1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and obj:IsHostile() and
            not obj.IsDead and EntityWrapper(obj).FateId > 0
        then
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
    repeat
        yield("/wait 0.1")
    until addon.Ready
    return addon.GetNode(nodePath, ...).Text
end

---@param destinationAetheryte string
function AcceptTeleportOfferLocation(destinationAetheryte)
    if Addons.GetAddon("_NotificationTelepo").Ready then
        local location = GetNodeText("_NotificationTelepo", 3, 4)
        yield("/callback _Notification true 0 16 "..location)
        yield("/wait 1")
    end

    if Addons.GetAddon("SelectYesno").Ready then
        local teleportOfferMessage = GetNodeText("SelectYesno", 1, 2)
        if type(teleportOfferMessage) == "string" then
            local teleportOfferLocation = teleportOfferMessage:match("Accept Teleport to (.+)%?")
            if teleportOfferLocation ~= nil and string.lower(teleportOfferLocation) == string.lower(destinationAetheryte) then
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
            yield("/li tp "..aetheryteName)
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
    if len == 0 then return v end
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

---@return ZoneFateInfoExt 
function GetCurrentZone()
    local zoneInfo = nil
    local targetZoneId = Svc.ClientState.TerritoryType

    for _, zone in ipairs(FatesData) do
        if targetZoneId == zone.zoneId then
            zoneInfo = zone
        end
    end
    if zoneInfo == nil then
        yield("/echo [FATE] Current zone is only partially supported. No data on npc fates.")
        zoneInfo = {
            zoneName = "",
            zoneId = targetZoneId,
            fatesList= {
                collectionsFates= {},
                otherNpcFates= {},
                bossFates= {},
                blacklistedFates= {},
                fatesWithContinuations = {}
            }
        }
    end
    local flying = zoneInfo.flying
    ---@type ZoneFateInfoExt
    local rv = {
        zoneName = zoneInfo.zoneName,
        zoneId = zoneInfo.zoneId,
        fatesList = zoneInfo.fatesList,
        flying = flying == nil or flying,
        aetheryteList = {}
    }
    local aetherytes = GetAetherytesInZone(zoneInfo.zoneId)
    for _, aetheryte in ipairs(aetherytes) do
        local aetherytePos = Instances.Telepo:GetAetherytePosition(aetheryte.AetheryteId)
        local aetheryteTable = {
            name = GetAetheryteName(aetheryte),
            id = aetheryte.AetheryteId,
            position = aetherytePos,
            aetheryteObj = aetheryte
        }
        table.insert(rv.aetheryteList, aetheryteTable)
    end
    return rv
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
    Dalamud.Log("[FATE] Direct flight distance is: "..directFlightDistance)
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
    for i=0, Svc.Objects.Length-1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and obj:IsHostile() and
            not obj.IsDead and EntityWrapper(obj).FateId > 0
        then
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
    if not JoinCollectionsFates then
        for _, collectionsFate in ipairs(zone.fatesList.collectionsFates) do
            if collectionsFate.fateName == fateName then
                return true
            end
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

--TODO(seamooo) below should be in an separate library for 
--internal preambles

function TargetBattle()
    yield("/battletarget")
end

---@class FateObjInfo
---@field obj IGameObject
---@field nameplateKind NameplateKind
---@field distance number
---@field maxHp number
---@field currHp number
---@field kind ObjectKind

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
        kind = obj.ObjectKind
    }
end

---Target an idle fate mob if one exists. Priority
---will be current target -> closest target
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
        if obj ~= nil
            and obj.IsTargetable
            and EntityWrapper(obj).FateId == fate.Id then
            local info = BuildFateObjInfo(obj)
            if info.nameplateKind == NameplateKind.HostileNotEngaged then
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
        if obj ~= nil
            and obj.IsTargetable
            and EntityWrapper(obj).FateId == fate.Id then
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
        if obj ~= nil
            and obj.IsTargetable
            and EntityWrapper(obj).FateId == fate.Id then
            local info = BuildFateObjInfo(obj)
            if info.maxHp > 1 then
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
        if obj ~= nil
            and obj.IsTargetable
            and EntityWrapper(obj).FateId == fate.Id then
            local info = BuildFateObjInfo(obj)
            if info.maxHp > 1 then
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

function TargetForlornMaiden()
    yield("/target Forlorn Maiden")
end

function TargetForlorn()
    yield("/target The Forlorn")
end

---@param statusId number
---@return boolean
function HasStatusId(statusId)
    local statusList = Svc.ClientState.LocalPlayer.StatusList
    if statusList == nil then
        return false
    end
    for i=0, statusList.Length-1 do
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