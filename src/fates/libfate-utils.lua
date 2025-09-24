import("System.Numerics")
require("libfate-data")

--#region Utils
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

EntityWrapper = load_type('SomethingNeedDoing.LuaMacro.Wrappers.EntityWrapper')

function GetBuddyTimeRemaining()
    return Instances.Buddy.CompanionInfo.TimeLeft
end

function SetMapFlag(zoneId, position)
    Dalamud.Log("[FATE] Setting map flag to zone #"..zoneId..", (X: "..position.X..", "..position.Z.." )")
    Instances.Map.Flag:SetFlagMapMarker(zoneId, position.X, position.Z)
end

function GetZoneInstance()
    return InstancedContent.PublicInstance.InstanceId
end

function GetTargetName()
    if Svc.Targets.Target == nil then
        return ""
    else
        return Svc.Targets.Target.Name.TextValue
    end
end

function AttemptToTargetClosestFateEnemy()
    --Svc.Targets.Target = Svc.Objects.OrderBy(DistanceToObject).FirstOrDefault(o => o.IsTargetable && o.IsHostile() && !o.IsDead && (distance == 0 || DistanceToObject(o) <= distance) && o.Struct()->FateId > 0);
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

function Normalize(v)
    local len = v:Length()
    if len == 0 then return v end
    return v / len
end

function MoveToTargetHitbox()
    --Dalamud.Log("[FATE] Move to Target Hit Box")
    if Svc.Targets.Target == nil then
        return
    end
    local playerPos = Svc.ClientState.LocalPlayer.Position
    local targetPos = Svc.Targets.Target.Position
    local distance = GetDistanceToTarget()
    if distance == 0 then return end
    local desiredRange = math.max(0.1, GetTargetHitboxRadius() + GetPlayerHitboxRadius() + MaxDistance)
    local STOP_EPS = 0.15
    if distance <= (desiredRange + STOP_EPS) then return end
    local dir = Normalize(playerPos - targetPos)
    if dir:Length() == 0 then return end
    local ideal = targetPos + (dir * desiredRange)
    local newPos = IPC.vnavmesh.PointOnFloor(ideal, false, 1.5) or ideal
    IPC.vnavmesh.PathfindAndMoveTo(newPos, false)
end

function HasPlugin(name)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == name and plugin.IsLoaded then
            return true
        end
    end
    return false
end

--#endregion Utils

--#region Fate Functions
function IsCollectionsFate(fateName)
    for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBossFate(fate)
    return fate.IconId == 60722
end

function IsOtherNpcFate(fateName)
    for i, otherNpcFate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsSpecialFate(fateName)
    if SelectedZone.fatesList.specialFates == nil then
        return false
    end
    for i, specialFate in ipairs(SelectedZone.fatesList.specialFates) do
        if specialFate == fateName then
            return true
        end
    end
end

function IsBlacklistedFate(fateName)
    for i, blacklistedFate in ipairs(SelectedZone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
        end
    end
    if not JoinCollectionsFates then
        for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
            if collectionsFate.fateName == fateName then
                return true
            end
        end
    end
    return false
end

function GetFateNpcName(fateName)
    for i, fate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    for i, fate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
end

function IsFateActive(fate)
    if fate.State == nil then
        return false
    else
        return fate.State ~= FateState.Ending and fate.State ~= FateState.Ended and fate.State ~= FateState.Failed
    end
end

function InActiveFate()
    local activeFates = Fates.GetActiveFates()
    for i=0, activeFates.Count-1 do
        if activeFates[i].InFate == true and IsFateActive(activeFates[i]) then
            return true
        end
    end
    return false
end

function SelectNextZone()
    local nextZone = nil
    local nextZoneId = Svc.ClientState.TerritoryType

    for i, zone in ipairs(FatesData) do
        if nextZoneId == zone.zoneId then
            nextZone = zone
        end
    end
    if nextZone == nil then
        yield("/echo [FATE] Current zone is only partially supported. No data on npc fates.")
        nextZone = {
            zoneName = "",
            zoneId = nextZoneId,
            fatesList= {
                collectionsFates= {},
                otherNpcFates= {},
                bossFates= {},
                blacklistedFates= {},
                fatesWithContinuations = {}
            }
        }
    end

    nextZone.zoneName = nextZone.zoneName
    nextZone.aetheryteList = {}
    local aetherytes = GetAetherytesInZone(nextZone.zoneId)
    for _, aetheryte in ipairs(aetherytes) do
        local aetherytePos = Instances.Telepo.GetAetherytePosition(aetheryte.AetheryteId)
        local aetheryteTable = {
            aetheryteName = GetAetheryteName(aetheryte),
            aetheryteId = aetheryte.AetheryteId,
            position = aetherytePos,
            aetheryteObj = aetheryte
        }
        table.insert(nextZone.aetheryteList, aetheryteTable)
    end

    if nextZone.flying == nil then
        nextZone.flying = true
    end

    return nextZone
end

--[[
    Selects the better fate based on the priority order defined in FatePriority.
    Default Priority order is "DistanceTeleport" -> "Progress" -> "Bonus" -> "TimeLeft" -> "Distance"
]]
function SelectNextFateHelper(tempFate, nextFate)
    if nextFate == nil then
        Dalamud.Log("[FATE] nextFate is nil")
        return tempFate
    elseif BonusFatesOnly then
        Dalamud.Log("[FATE] only doing bonus fates")
        --Check if WaitForBonusIfBonusBuff is true, and have eithe buff, then set BonusFatesOnlyTemp to true
        if not tempFate.isBonusFate and nextFate ~= nil and nextFate.isBonusFate then
            return nextFate
        elseif tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return tempFate
        elseif not tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return nil
        end
        -- if both are bonus fates, go through the regular fate selection process
    end

    if tempFate.timeLeft < MinTimeLeftToIgnoreFate or tempFate.fateObject.Progress > CompletionToIgnoreFate then
        Dalamud.Log("[FATE] Ignoring fate #"..tempFate.fateId.." due to insufficient time or high completion.")
        return nextFate
    elseif nextFate == nil then
        Dalamud.Log("[FATE] Selecting #"..tempFate.fateId.." because no other options so far.")
        return tempFate
    elseif nextFate.timeLeft < MinTimeLeftToIgnoreFate or nextFate.fateObject.Progress > CompletionToIgnoreFate then
        Dalamud.Log("[FATE] Ignoring fate #"..nextFate.fateId.." due to insufficient time or high completion.")
        return tempFate
    end

    -- Evaluate based on priority (Loop through list return first non-equal priority)
    for _, criteria in ipairs(FatePriority) do
        if criteria == "Progress" then
            Dalamud.Log("[FATE] Comparing progress: "..tempFate.fateObject.Progress.." vs "..nextFate.fateObject.Progress)
            if tempFate.fateObject.Progress > nextFate.fateObject.Progress then return tempFate end
            if tempFate.fateObject.Progress < nextFate.fateObject.Progress then return nextFate end
        elseif criteria == "Bonus" then
            Dalamud.Log("[FATE] Checking bonus status: "..tostring(tempFate.isBonusFate).." vs "..tostring(nextFate.isBonusFate))
            if tempFate.isBonusFate and not nextFate.isBonusFate then return tempFate end
            if nextFate.isBonusFate and not tempFate.isBonusFate then return nextFate end
        elseif criteria == "TimeLeft" then
            Dalamud.Log("[FATE] Comparing time left: "..tempFate.timeLeft.." vs "..nextFate.timeLeft)
            if tempFate.timeLeft > nextFate.timeLeft then return tempFate end
            if tempFate.timeLeft < nextFate.timeLeft then return nextFate end
        elseif criteria == "Distance" then
            local tempDist = GetDistanceToPoint(tempFate.position)
            local nextDist = GetDistanceToPoint(nextFate.position)
            Dalamud.Log("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        elseif criteria == "DistanceTeleport" then
            local tempDist = GetDistanceToPointWithAetheryteTravel(tempFate.position)
            local nextDist = GetDistanceToPointWithAetheryteTravel(nextFate.position)
            Dalamud.Log("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        end
    end

    -- Fallback: Select fate with the lower ID
    Dalamud.Log("[FATE] Selecting lower ID fate: "..tempFate.fateId.." vs "..nextFate.fateId)
    return (tempFate.fateId < nextFate.fateId) and tempFate or nextFate
end

--Gets the Location of the next Fate. Prioritizes anything with progress above 0, then by shortest time left
function SelectNextFate()
    local fates = Fates.GetActiveFates()
    if fates == nil then
        return
    end

    local nextFate = nil
    for i = 0, fates.Count-1 do
        Dalamud.Log("[FATE] Building fate table")
        local tempFate = BuildFateTable(fates[i])
        Dalamud.Log("[FATE] Considering fate #"..tempFate.fateId.." "..tempFate.fateName)
        Dalamud.Log("[FATE] Time left on fate #:"..tempFate.fateId..": "..math.floor(tempFate.timeLeft//60).."min, "..math.floor(tempFate.timeLeft%60).."s")

        if not (tempFate.position.X == 0 and tempFate.position.Z == 0) then -- sometimes game doesnt send the correct coords
            if not tempFate.isBlacklistedFate then -- check fate is not blacklisted for any reason
                if tempFate.isBossFate then
                    Dalamud.Log("[FATE] Is a boss fate")
                    if (tempFate.isSpecialFate and tempFate.fateObject.Progress >= CompletionToJoinSpecialBossFates) or
                        (not tempFate.isSpecialFate and tempFate.fateObject.Progress >= CompletionToJoinBossFate) then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        Dalamud.Log("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to boss fate with not enough progress.")
                    end
                elseif (tempFate.isOtherNpcFate or tempFate.isCollectionsFate) and tempFate.startTime == 0 then
                    Dalamud.Log("[FATE] Is not an npc or collections fate")
                    if nextFate == nil then -- pick this if theres nothing else
                        Dalamud.Log("[FATE] Selecting this fate because there's nothing else so far")
                        nextFate = tempFate
                    elseif tempFate.isBonusFate then
                        Dalamud.Log("[FATE] tempFate.isBonusFate")
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    elseif nextFate.startTime == 0 then -- both fates are unopened npc fates
                        Dalamud.Log("[FATE] Both fates are unopened npc fates")
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        Dalamud.Log("[FATE] else")
                    end
                elseif tempFate.duration ~= 0 then -- else is normal fate. avoid unlisted talk to npc fates
                    Dalamud.Log("[FATE] Normal fate")
                    nextFate = SelectNextFateHelper(tempFate, nextFate)
                else
                    Dalamud.Log("[FATE] Fate duration was zero.")
                end
                Dalamud.Log("[FATE] Finished considering fate #"..tempFate.fateId.." "..tempFate.fateName)
            else
                Dalamud.Log("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to blacklist.")
            end
        else
            Dalamud.Log("[FATE] FATE coords were zeroed out")
        end

    end

    Dalamud.Log("[FATE] Finished considering all fates")
    if nextFate == nil then
        Dalamud.Log("[FATE] .>H N found.")
        if Echo == "all" then
            yield("/echo [FATE] No eligible fates found.")
        end
    else
        Dalamud.Log("[FATE] Final selected fate #"..nextFate.fateId.." "..nextFate.fateName)
    end
    yield("/wait 0.211")
    return nextFate
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

--#endregion Fate Functions

--#region Movement Functions

function DistanceBetween(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function GetDistanceToPoint(vec3)
    return DistanceBetween(Svc.ClientState.LocalPlayer.Position, vec3)
end

function GetDistanceToTarget()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPoint(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end

function GetDistanceToTargetFlat()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPointFlat(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end

function GetDistanceToPointFlat(vec3)
    return DistanceBetweenFlat(Svc.ClientState.LocalPlayer.Position, vec3)
end

function DistanceBetweenFlat(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dz * dz)
end

function RandomAdjustCoordinates(position, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = position.X + (x_adjust * math.cos(angle))
    local randomY = position.Y + maxDistance
    local randomZ = position.Z + (z_adjust * math.sin(angle))

    return Vector3(randomX, randomY, randomZ)
end

function GetAetherytesInZone(zoneId)
    local aetherytesInZone = {}
    for _, aetheryte in ipairs(Svc.AetheryteList) do
        if aetheryte.TerritoryId == zoneId then
            table.insert(aetherytesInZone, aetheryte)
        end
    end
    return aetherytesInZone
end

function GetAetheryteName(aetheryte)
    local name = aetheryte.AetheryteData.Value.PlaceName.Value.Name:GetText()
    if name == nil then
        return ""
    else
        return name
    end
end

function DistanceFromClosestAetheryteToPoint(vec3, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, vec3)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        Dalamud.Log("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            Dalamud.Log("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestTravelDistance
end

function GetDistanceToPointWithAetheryteTravel(vec3)
    -- Get the direct flight distance (no aetheryte)
    local directFlightDistance = GetDistanceToPoint(vec3)
    Dalamud.Log("[FATE] Direct flight distance is: " .. directFlightDistance)

    -- Get the distance to the closest aetheryte, including teleportation penalty
    local distanceToAetheryte = DistanceFromClosestAetheryteToPoint(vec3, 200)
    Dalamud.Log("[FATE] Distance via closest Aetheryte is: " .. (distanceToAetheryte or "nil"))

    -- Return the minimum distance, either via direct flight or via the closest aetheryte travel
    if distanceToAetheryte == nil then
        return directFlightDistance
    else
        return math.min(directFlightDistance, distanceToAetheryte)
    end
end

function GetClosestAetheryte(position, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        Dalamud.Log("[FATE] Considering aetheryte "..aetheryte.aetheryteName)
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, position)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        Dalamud.Log("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            Dalamud.Log("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end
    if closestAetheryte ~= nil then
        Dalamud.Log("[FATE] Final selected aetheryte is: "..closestAetheryte.aetheryteName)
    else
        Dalamud.Log("[FATE] Closest aetheryte is nil")
    end

    return closestAetheryte
end

function GetClosestAetheryteToPoint(position, teleportTimePenalty)
    local directFlightDistance = GetDistanceToPoint(position)
    Dalamud.Log("[FATE] Direct flight distance is: "..directFlightDistance)
    local closestAetheryte = GetClosestAetheryte(position, teleportTimePenalty)
    if closestAetheryte ~= nil then
        local closestAetheryteDistance = DistanceBetween(position, closestAetheryte.position) + teleportTimePenalty

        if closestAetheryteDistance < directFlightDistance then
            return closestAetheryte
        end
    end
    return nil
end

function TeleportToClosestAetheryteToFate(nextFate)
    local aetheryteForClosestFate = GetClosestAetheryteToPoint(nextFate.position, 200)
    if aetheryteForClosestFate ~=nil then
        TeleportTo(aetheryteForClosestFate.aetheryteName)
        return true
    end
    return false
end

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
            if teleportOfferLocation ~= nil then
                if string.lower(teleportOfferLocation) == string.lower(destinationAetheryte) then
                    yield("/callback SelectYesno true 0") -- accept teleport
                    return
                else
                    Dalamud.Log("Offer for "..teleportOfferLocation.." and destination "..destinationAetheryte.." are not the same. Declining teleport.")
                end
            end
            yield("/callback SelectYesno true 2") -- decline teleport
            return
        end
    end
end

function TeleportTo(aetheryteName)
    AcceptTeleportOfferLocation(aetheryteName)
    local start = os.clock()

    while EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime) - LastTeleportTimeStamp < 5 do
        Dalamud.Log("[FATE] Too soon since last teleport. Waiting...")
        yield("/wait 5.001")
        if os.clock() - start > 30 then
            yield("/echo [FATE] Teleport failed: Timeout waiting before cast.")
            return false
        end
    end

    yield("/li tp "..aetheryteName)
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.casting] do
        Dalamud.Log("[FATE] Casting teleport...")
        yield("/wait 1")
        if os.clock() - start > 60 then
            yield("/echo [FATE] Teleport failed: Timeout during cast.")
            return false
        end
    end
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.betweenAreas] do
        Dalamud.Log("[FATE] Teleporting...")
        yield("/wait 1")
        if os.clock() - start > 120 then
            yield("/echo [FATE] Teleport failed: Timeout during zone transition.")
            return false
        end
    end
    yield("/wait 1")
    LastTeleportTimeStamp = EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime)
    HasFlownUpYet = false
    return true
end

function ChangeInstance()
    if SuccessiveInstanceChanges >= NumberOfInstances then
        yield("/wait 10")
        SuccessiveInstanceChanges = 0
        return
    end

    yield("/target aetheryte") -- search for nearby aetheryte
    if Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" then -- if no aetheryte within targeting range, teleport to it
        Dalamud.Log("[FATE] Aetheryte not within targetable range")
        local closestAetheryte = nil
        local closestAetheryteDistance = math.maxinteger
        for i, aetheryte in ipairs(SelectedZone.aetheryteList) do
            -- GetDistanceToPoint is implemented with raw distance instead of distance squared
            local distanceToAetheryte = GetDistanceToPoint(aetheryte.position)
            if distanceToAetheryte < closestAetheryteDistance then
                closestAetheryte = aetheryte
                closestAetheryteDistance = distanceToAetheryte
            end
        end
        if closestAetheryte ~= nil then
            TeleportTo(closestAetheryte.aetheryteName)
        end
        return
    end

    if WaitingForFateRewards ~= nil then
        yield("/wait 10")
        return
    end

    if GetDistanceToTarget() > 10 then
        Dalamud.Log("[FATE] Targeting aetheryte, but greater than 10 distance")
        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
            if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                yield("/vnav flytarget")
            else
                yield("/vnav movetarget")
            end
        elseif GetDistanceToTarget() > 20 and not Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.mounting
            Dalamud.Log("[FATE] State Change: Mounting")
        end
        return
    end

    Dalamud.Log("[FATE] Within 10 distance")
    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
        return
    end

    if Svc.Condition[CharacterCondition.mounted] then
        State = CharacterState.changeInstanceDismount
        Dalamud.Log("[FATE] State Change: ChangeInstanceDismount")
        return
    end

    Dalamud.Log("[FATE] Transferring to next instance")
    local nextInstance = (GetZoneInstance() % 2) + 1
    yield("/li "..nextInstance) -- start instance transfer
    yield("/wait 1") -- wait for instance transfer to register
    State = CharacterState.ready
    SuccessiveInstanceChanges = SuccessiveInstanceChanges + 1
    Dalamud.Log("[FATE] State Change: Ready")
end

---@param mainClass JobWrapper
function WaitForContinuation(mainClass)
    if InActiveFate() then
        Dalamud.Log("WaitForContinuation IsInFate")
        local nextFateId = Fates.GetNearestFate()
        if nextFateId ~= CurrentFate.fateObject then
            CurrentFate = BuildFateTable(nextFateId)
            State = CharacterState.doFate
            Dalamud.Log("[FATE] State Change: DoFate")
        end
    elseif os.clock() - LastFateEndTime > 30 then
        Dalamud.Log("WaitForContinuation Abort")
        Dalamud.Log("Over 30s since end of last fate. Giving up on part 2.")
        TurnOffCombatMods()
        State = CharacterState.ready
        Dalamud.Log("State Change: Ready")
    else
        Dalamud.Log("WaitForContinuation Else")
        if BossFatesClass ~= nil then
            local currentClass = Player.Job.Id
            Dalamud.Log("WaitForContinuation "..CurrentFate.fateName)
            if not Player.IsBusy then
                if CurrentFate.continuationIsBoss and currentClass ~= BossFatesClass.Id then
                    Dalamud.Log("WaitForContinuation SwitchToBoss")
                    yield("/gs change "..BossFatesClass.className)
                elseif not CurrentFate.continuationIsBoss and currentClass ~= MainClass.Id then
                    Dalamud.Log("WaitForContinuation SwitchToMain")
                    yield("/gs change "..mainClass.Name)
                end
            end
        end

        yield("/wait 1")
    end
end

function FlyBackToAetheryte()
    NextFate = SelectNextFate()
    if NextFate ~= nil then
        yield("/vnav stop")
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    local closestAetheryte = GetClosestAetheryte(Svc.ClientState.LocalPlayer.Position, 0)
    if closestAetheryte == nil then
        DownTimeWaitAtNearestAetheryte = false
        yield("/echo Could not find aetheryte in the area. Turning off feature to fly back to aetheryte.")
        return
    end
    -- if you get any sort of error while flying back, then just abort and tp back
    if Addons.GetAddon("_TextError").Ready and GetNodeText("_TextError", 1) == "Your mount can fly no higher." then
        yield("/vnav stop")
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    yield("/target aetheryte")

    if Svc.Targets.Target ~= nil and GetTargetName() == "aetheryte" and GetDistanceToTarget() <= 20 then
        if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
            yield("/vnav stop")
        end

        if Svc.Condition[CharacterCondition.flying] then
            yield("/ac dismount") -- land but dont actually dismount, to avoid running chocobo timer
        elseif Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        else
            if MountToUse == "mount roulette" then
                yield('/gaction "mount roulette"')
            else
                yield('/mount "' .. MountToUse)
            end
        end
        return
    end

    if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
        Dalamud.Log("[FATE] ClosestAetheryte.y: "..closestAetheryte.position.Y)
        if closestAetheryte ~= nil then
            SetMapFlag(SelectedZone.zoneId, closestAetheryte.position)
            IPC.vnavmesh.PathfindAndMoveTo(closestAetheryte.position, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
        end
    end

    if not Svc.Condition[CharacterCondition.mounted] then
        Mount()
        return
    end
end

HasFlownUpYet = false
function MoveToRandomNearbySpot(minDist, maxDist)
    local playerPos = Svc.ClientState.LocalPlayer.Position
    local angle = math.random() * 2 * math.pi
    local distance = minDist + math.random() * (maxDist - minDist)
    local dx = math.cos(angle) * distance
    local dz = math.sin(angle) * distance
    local yOffset = 0
    if not HasFlownUpYet then
        -- Always fly upward significantly the first time
        yOffset = 25 + math.random() * 15  -- +25 to +40
        HasFlownUpYet = true
    else
        yOffset = (math.random() * 30) - 15  -- -15 to +15
    end
    local targetPos = Vector3(playerPos.X + dx, playerPos.Y + yOffset, playerPos.Z + dz)
    if not Svc.Condition[CharacterCondition.mounted] then
        Mount()
        yield("/wait 2")
    end
    IPC.vnavmesh.PathfindAndMoveTo(targetPos, true)
    yield("/echo [FATE] Moving to a random location while waiting...")
end

function Mount()
    if MountToUse == "mount roulette" then
        yield('/gaction "mount roulette"')
    else
        yield('/mount "' .. MountToUse)
    end
    yield("/wait 1")
end

function MountState()
    if Svc.Condition[CharacterCondition.mounted] then
        yield("/wait 1") -- wait a second to make sure youre firmly on the mount
        State = CharacterState.moveToFate
        Dalamud.Log("[FATE] State Change: MoveToFate")
    else
        Mount()
    end
end

function Dismount()
    if Svc.Condition[CharacterCondition.flying] then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then

            if Svc.Condition[CharacterCondition.flying] and GetDistanceToPoint(LastStuckCheckPosition) < 2 then
                Dalamud.Log("[FATE] Unable to dismount here. Moving to another spot.")
                local random = RandomAdjustCoordinates(Svc.ClientState.LocalPlayer.Position, 10)
                local nearestFloor = IPC.vnavmesh.PointOnFloor(random, true, 100)
                if nearestFloor ~= nil then
                    IPC.vnavmesh.PathfindAndMoveTo(nearestFloor, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
    elseif Svc.Condition[CharacterCondition.mounted] then
        yield('/ac dismount')
    end
end

function MiddleOfFateDismount()
    if not IsFateActive(CurrentFate.fateObject) then
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    if Svc.Targets.Target ~= nil then
        if GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius() + 5) then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                Dalamud.Log("[FATE] MiddleOfFateDismount IPC.vnavmesh.PathfindAndMoveTo")
                if Svc.Condition[CharacterCondition.flying] then
                    yield("/vnav flytarget")
                else
                    yield("/vnav movetarget")
                end
            end
        else
            if Svc.Condition[CharacterCondition.mounted] then
                Dalamud.Log("[FATE] MiddleOfFateDismount Dismount()")
                Dismount()
            else
                yield("/vnav stop")
                State = CharacterState.doFate
                Dalamud.Log("[FATE] State Change: DoFate")
            end
        end
    else
        AttemptToTargetClosestFateEnemy()
    end
end

function NpcDismount()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
    else
        State = CharacterState.interactWithNpc
        Dalamud.Log("[FATE] State Change: InteractWithFateNpc")
    end
end

function ChangeInstanceDismount()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
    else
        State = CharacterState.changingInstances
        Dalamud.Log("[FATE] State Change: ChangingInstance")
    end
end

--Paths to the Fate NPC Starter
function MoveToNPC()
    yield("/target "..CurrentFate.npcName)
    if Svc.Targets.Target ~= nil and GetTargetName()==CurrentFate.npcName then
        if GetDistanceToTarget() > 5 then
            yield("/vnav movetarget")
        end
    end
end

--Paths to the Fate. CurrentFate is set here to allow MovetoFate to change its mind,
--so CurrentFate is possibly nil.
function MoveToFate()
    SuccessiveInstanceChanges = 0

    if not Player.Available then
        return
    end

    if CurrentFate~=nil and not IsFateActive(CurrentFate.fateObject) then
        Dalamud.Log("[FATE] Next Fate is dead, selecting new Fate.")
        yield("/vnav stop")
        MovingAnnouncementLock = false
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    NextFate = SelectNextFate()
    if NextFate == nil then -- when moving to next fate, CurrentFate == NextFate
        yield("/vnav stop")
        MovingAnnouncementLock = false
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    elseif CurrentFate == nil or NextFate.fateId ~= CurrentFate.fateId then
        yield("/vnav stop")
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.position)
        return
    end

    -- change to secondary class if its a boss fate
    if BossFatesClass ~= nil then
        local currentClass = Player.Job.Id
        if CurrentFate.isBossFate and currentClass ~= BossFatesClass.Id then
            yield("/gs change "..BossFatesClass.Name)
            return
        elseif not CurrentFate.isBossFate and currentClass ~= MainClass.Id then
            yield("/gs change "..MainClass.Name)
            return
        end
    end

    -- upon approaching fate, pick a target and switch to pathing towards target
    if GetDistanceToPoint(CurrentFate.position) < 60 then
        if Svc.Targets.Target ~= nil then
            Dalamud.Log("[FATE] Found FATE target, immediate rerouting")
            yield("/wait 0.1")
            MoveToTargetHitbox()
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) then
                State = CharacterState.interactWithNpc
                Dalamud.Log("[FATE] State Change: Interact with npc")
            -- if GetTargetName() == CurrentFate.npcName then
            --     State = CharacterState.interactWithNpc
            -- elseif GetTargetFateID() == CurrentFate.fateId then
            --     State = CharacterState.middleOfFateDismount
            --     Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
            else
                State = CharacterState.MiddleOfFateDismount
                Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
            end
            return
        else
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) and not InActiveFate() then
                yield("/target "..CurrentFate.npcName)
            else
                AttemptToTargetClosestFateEnemy()
            end
            yield("/wait 0.5") -- give it a moment to make sure the target sticks
            return
        end
    end

    -- check for stuck
    if (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) and Svc.Condition[CharacterCondition.mounted] then
        local now = os.clock()
        if now - LastStuckCheckTime > 10 then

            if GetDistanceToPoint(LastStuckCheckPosition) < 3 then
                yield("/vnav stop")
                yield("/wait 1")
                Dalamud.Log("[FATE] Antistuck")
                local up10 = Svc.ClientState.LocalPlayer.Position + Vector3(0, 10, 0)
                IPC.vnavmesh.PathfindAndMoveTo(up10, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying) -- fly up 10 then try again
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
        return
    end

    if not MovingAnnouncementLock then
        Dalamud.Log("[FATE] Moving to fate #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        MovingAnnouncementLock = true
        if Echo == "all" then
            yield("/echo [FATE] Moving to fate #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        end
    end

    if TeleportToClosestAetheryteToFate(CurrentFate) then
        Dalamud.Log("Executed teleport to closer aetheryte")
        return
    end

    local nearestFloor = CurrentFate.position
    if not (CurrentFate.isCollectionsFate or CurrentFate.isOtherNpcFate) then
        nearestFloor = RandomAdjustCoordinates(CurrentFate.position, 10)
    end

    if GetDistanceToPoint(nearestFloor) > 5 then
        if not Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.mounting
            Dalamud.Log("[FATE] State Change: Mounting")
            return
        elseif not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
            if Player.CanFly and SelectedZone.flying then
                yield("/vnav flyflag")
            else
                yield("/vnav moveflag")
            end
        end
    else
        State = CharacterState.MiddleOfFateDismount
    end
end

function InteractWithFateNpc()
    if InActiveFate() or CurrentFate.startTime > 0 then
        yield("/vnav stop")
        State = CharacterState.doFate
        Dalamud.Log("[FATE] State Change: DoFate")
        yield("/wait 1") -- give the fate a second to register before dofate and lsync
    elseif not IsFateActive(CurrentFate.fateObject) then
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
    elseif IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        if Svc.Targets.Target ~= nil and GetTargetName() == CurrentFate.npcName and GetDistanceToTarget() < (5*math.random()) then
            yield("/vnav stop")
        end
        return
    else
        -- if target is already selected earlier during pathing, avoids having to target and move again
        if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName) then
            yield("/target "..CurrentFate.npcName)
            return
        end

        if Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.npcDismount
            Dalamud.Log("[FATE] State Change: NPCDismount")
            return
        end

        if GetDistanceToPoint(Svc.Targets.Target.Position) > 5 then
            MoveToNPC()
            return
        end

        if Addons.GetAddon("SelectYesno").Ready then
            AcceptNPCFateOrRejectOtherYesno()
        elseif not Svc.Condition[CharacterCondition.occupied] then
            yield("/interact")
        end
    end
end

function CollectionsFateTurnIn()
    AcceptNPCFateOrRejectOtherYesno()

    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateObject) then
        CurrentFate = nil
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName) then
        TurnOffCombatMods()
        yield("/target "..CurrentFate.npcName)
        yield("/wait 1")

        -- if too far from npc to target, then head towards center of fate
        if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName and CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress < 100) then
            if not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
                IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, false)
            end
        else
            yield("/vnav stop")
        end
        return
    end

    if GetDistanceToTarget() > 5 then
        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
            MoveToNPC()
        end
    else
        if Inventory.GetItemCount(CurrentFate.fateObject.EventItem) >= 7 then
            GotCollectionsFullCredit = true
        end

        yield("/vnav stop")
        yield("/interact")
        yield("/wait 3")

        if CurrentFate.fateObject.Progress < 100 then
            TurnOnCombatMods()
            State = CharacterState.doFate
            Dalamud.Log("[FATE] State Change: DoFate")
        else
            if GotCollectionsFullCredit then
                GotCollectionsFullCredit = false
                State = CharacterState.unexpectedCombat
                Dalamud.Log("[FATE] State Change: UnexpectedCombat")
            end
        end

        if CurrentFate ~=nil and CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
            Dalamud.Log("[FATE] Attempting to clear target.")
            ClearTarget()
            yield("/wait 1")
        end
    end
    GotCollectionsFullCredit = false
end

--#endregion movement

--#region Combat Functions

function GetClassJobTableFromName(classString)
    if classString == nil or classString == "" then
        return nil
    end

    for classJobId=1, 42 do
        local job = Player.GetJob(classJobId)
        if job.Name == classString then
            return job
        end
    end

    Dalamud.Log("[FATE] Cannot recognize combat job for boss fates.")
    return nil
end

function SummonChocobo()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
        return
    end

    if ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft then
        if Inventory.GetItemCount(4868) > 0 then
            yield("/item Gysahl Greens")
            yield("/wait 3")
            yield('/cac "'..ChocoboStance..' stance"')
        elseif ShouldAutoBuyGysahlGreens then
            State = CharacterState.autoBuyGysahlGreens
            Dalamud.Log("[FATE] State Change: AutoBuyGysahlGreens")
            return
        end
    end
    State = CharacterState.ready
    Dalamud.Log("[FATE] State Change: Ready")
end

function AutoBuyGysahlGreens()
    if Inventory.GetItemCount(4868) > 0 then -- dont need to buy
        if Addons.GetAddon("Shop").Ready then
            yield("/callback Shop true -1")
        elseif Svc.ClientState.TerritoryType == SelectedZone.zoneId then
            yield("/item Gysahl Greens")
        else
            State = CharacterState.ready
            Dalamud.Log("State Change: ready")
        end
        return
    else
        if Svc.ClientState.TerritoryType ~=  129 then
            yield("/vnav stop")
            TeleportTo("Limsa Lominsa Lower Decks")
            return
        else
            local gysahlGreensVendor = { position=Vector3(-62.1, 18.0, 9.4), npcName="Bango Zango" }
            if GetDistanceToPoint(gysahlGreensVendor.position) > 5 then
                if not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then
                    IPC.vnavmesh.PathfindAndMoveTo(gysahlGreensVendor.position, false)
                end
            elseif Svc.Targets.Target ~= nil and GetTargetName() == gysahlGreensVendor.npcName then
                yield("/vnav stop")
                if Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                elseif Addons.GetAddon("SelectIconString").Ready then
                    yield("/callback SelectIconString true 0")
                    return
                elseif Addons.GetAddon("Shop").Ready then
                    yield("/callback Shop true 0 5 99")
                    return
                elseif not Svc.Condition[CharacterCondition.occupied] then
                    yield("/interact")
                    yield("/wait 1")
                    return
                end
            else
                yield("/vnav stop")
                yield("/target "..gysahlGreensVendor.npcName)
            end
        end
    end
end

function ClearTarget()
    Svc.Targets.Target = nil
end

function GetTargetHitboxRadius()
    if Svc.Targets.Target ~= nil then
        return Svc.Targets.Target.HitboxRadius
    else
        return 0
    end
end

function GetPlayerHitboxRadius()
    if Svc.ClientState.LocalPlayer ~= nil then
        return Svc.ClientState.LocalPlayer.HitboxRadius
    else
        return 0
    end
end

function TurnOnAoes()
    if not AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation off")
            yield("/rotation auto on")
            Dalamud.Log("[FATE] TurnOnAoes /rotation auto on")

            if RSRAoeType == "Off" then
                yield("/rotation settings aoetype 0")
            elseif RSRAoeType == "Cleave" then
                yield("/rotation settings aoetype 1")
            elseif RSRAoeType == "Full" then
                yield("/rotation settings aoetype 2")
            end
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.SetActive(RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.SetActive(RotationAoePreset)
        end
        AoesOn = true
    end
end

function TurnOffAoes()
    if AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation settings aoetype 1")
            yield("/rotation manual")
            Dalamud.Log("[FATE] TurnOffAoes /rotation manual")
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.SetActive(RotationSingleTargetPreset)
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.SetActive(RotationSingleTargetPreset)
        end
        AoesOn = false
    end
end

function TurnOffRaidBuffs()
    if AoesOn then
        if RotationPlugin == "BMR" then
            IPC.BossMod.SetActive(RotationHoldBuffPreset)
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.SetActive(RotationHoldBuffPreset)
        end
    end
end

function SetMaxDistance()
    -- Check if the current job is a melee DPS or tank.
    if Player.Job and (Player.Job.IsMeleeDPS or Player.Job.IsTank) then
        MaxDistance = MeleeDist
        MoveToMob = true
        Dalamud.Log("[FATE] Setting max distance to " .. tostring(MeleeDist) .. " (melee/tank)")
    else
        MoveToMob = false
        MaxDistance = RangedDist
        Dalamud.Log("[FATE] Setting max distance to " .. tostring(RangedDist) .. " (ranged/caster)")
    end
end

function TurnOnCombatMods(rotationMode)
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if RotationPlugin == "RSR" then
            if rotationMode == "manual" then
                yield("/rotation manual")
                Dalamud.Log("[FATE] TurnOnCombatMods /rotation manual")
            else
                yield("/rotation off")
                yield("/rotation auto on")
                Dalamud.Log("[FATE] TurnOnCombatMods /rotation auto on")
            end
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.SetActive(RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.SetActive(RotationAoePreset)
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto on")
        end

        if not AiDodgingOn then
            SetMaxDistance()

            if DodgingPlugin == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/bmrai followcombat on")
                yield("/bmrai maxdistancetarget " .. MaxDistance)
                if MoveToMob == true then
                    yield("/bmrai followoutofcombat on")
                end
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ai on")
                --[[vbm ai doesn't support these options
                yield("/vbmai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/vbmai followcombat on")
                yield("/vbmai maxdistancetarget " .. MaxDistance)
                if MoveToMob == true then
                    yield("/vbmai followoutofcombat on")
                end
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions on") --This Disables VBM AI Auto-Target
                end]]
            end
            AiDodgingOn = true
        end
    end
end

function TurnOffCombatMods()
    if CombatModsOn then
        Dalamud.Log("[FATE] Turning off combat mods")
        CombatModsOn = false

        if RotationPlugin == "RSR" then
            yield("/rotation off")
            Dalamud.Log("[FATE] TurnOffCombatMods /rotation off")
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.ClearActive()
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.ClearActive()
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto off")
        end

        -- turn off BMR so you dont start following other mobs
        if AiDodgingOn then
            if DodgingPlugin == "BMR" then
                yield("/bmrai off")
                yield("/bmrai followtarget off")
                yield("/bmrai followcombat off")
                yield("/bmrai followoutofcombat off")
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ai off")
                --[[vbm ai doesn't support these options.
                yield("/vbmai followtarget off")
                yield("/vbmai followcombat off")
                yield("/vbmai followoutofcombat off")
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions off") --This Enables VBM AI Auto-Target
                end]]
            end
            AiDodgingOn = false
        end
    end
end

function HandleUnexpectedCombat()
    if Svc.Condition[CharacterCondition.mounted] or Svc.Condition[CharacterCondition.flying] then
        Dalamud.Log("[FATE] UnexpectedCombat: Dismounting due to combat")
        Dismount()
        return
    end
    TurnOnCombatMods("manual")

    local nearestFate = Fates.GetNearestFate()
    if InActiveFate() and nearestFate.Progress < 100 then
        CurrentFate = BuildFateTable(nearestFate)
        State = CharacterState.doFate
        Dalamud.Log("[FATE] State Change: DoFate")
        return
    elseif not Svc.Condition[CharacterCondition.inCombat] then
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        local randomWait = (math.floor(math.random()*MaxWait * 1000)/1000) + MinWait -- truncated to 3 decimal places
        yield("/wait "..randomWait)
        return
    end

    -- if Svc.Condition[CharacterCondition.mounted] then
    --     if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
    --         IPC.vnavmesh.PathfindAndMoveTo(Svc.ClientState.Location, true)
    --     end
    --     yield("/wait 10")
    --     return
    -- end

    -- targets whatever is trying to kill you
    if Svc.Targets.Target == nil then
        yield("/battletarget")
    end

    -- pathfind closer if enemies are too far
    if Svc.Targets.Target ~= nil then
        if GetDistanceToTargetFlat() > (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                if Player.CanFly and SelectedZone.flying then
                    yield("/vnav flytarget")
                else
                    MoveToTargetHitbox()
                end
            end
        else
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            elseif not Svc.Condition[CharacterCondition.inCombat] then
                --inch closer 3 seconds
                if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                    yield("/vnav flytarget")
                else
                    MoveToTargetHitbox()
                end
                yield("/wait 3")
            end
        end
    end
    yield("/wait 1")
end

---@param mainClass JobWrapper
function DoFate(mainClass)
    Dalamud.Log("[FATE] DoFate")
    if WaitingForFateRewards == nil or WaitingForFateRewards.fateId ~= CurrentFate.fateId then
        WaitingForFateRewards = CurrentFate
        Dalamud.Log("[FATE] WaitingForFateRewards DoFate: "..tostring(WaitingForFateRewards.fateId))
    end
    local currentClass = Player.Job
    -- switch classes (mostly for continutation fates that pop you directly into the next one)
    if CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= BossFatesClass.classId and not Player.IsBusy then
        TurnOffCombatMods()
        yield("/gs change "..BossFatesClass.className)
        yield("/wait 1")
        return
    elseif not CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= MainClass.Id and not Player.IsBusy then
        TurnOffCombatMods()
        yield("/gs change "..mainClass.Name)
        yield("/wait 1")
        return
    elseif InActiveFate() and (CurrentFate.fateObject.MaxLevel < Player.Job.Level) and not Player.IsLevelSynced then
        yield("/lsync")
        yield("/wait 0.5") -- give it a second to register
    elseif IsFateActive(CurrentFate.fateObject) and not InActiveFate() and CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress < 100 and (GetDistanceToPoint(CurrentFate.position) < CurrentFate.fateObject.Radius + 10) and not Svc.Condition[CharacterCondition.mounted] and not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then -- got pushed out of fate. go back
        yield("/vnav stop")
        yield("/wait 1")
        Dalamud.Log("[FATE] pushed out of fate going back!")
        IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
        return
    elseif not IsFateActive(CurrentFate.fateObject) or CurrentFate.fateObject.Progress == 100 then
        yield("/vnav stop")
        ClearTarget()
        if not Dalamud.Log("[FATE] HasContintuation check") and CurrentFate.hasContinuation then
            LastFateEndTime = os.clock()
            State = CharacterState.waitForContinuation
            Dalamud.Log("[FATE] State Change: WaitForContinuation")
            return
        else
            DidFate = true
            Dalamud.Log("[FATE] No continuation for "..CurrentFate.fateName)
            local randomWait = (math.floor(math.random() * (math.max(0, MaxWait - 3)) * 1000)/1000) + MinWait -- truncated to 3 decimal places
            yield("/wait "..randomWait)
            TurnOffCombatMods()
            ForlornMarked = false
            MovingAnnouncementLock = false
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
        return
    elseif Svc.Condition[CharacterCondition.mounted] then
        State = CharacterState.MiddleOfFateDismount
        Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
        return
    elseif CurrentFate.isCollectionsFate then
        yield("/wait 1") -- needs a moment after start of fate for GetFateEventItem to populate
        if Inventory.GetItemCount(CurrentFate.fateObject.EventItem) >= 7 or (GotCollectionsFullCredit and CurrentFate.fateObject.Progress == 100) then
            yield("/vnav stop")
            State = CharacterState.collectionsFateTurnIn
            Dalamud.Log("[FATE] State Change: CollectionsFatesTurnIn")
        end
    end

    Dalamud.Log("[FATE] DoFate->Finished transition checks")

    -- do not target fate npc during combat
    if CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
        Dalamud.Log("[FATE] Attempting to clear target.")
        ClearTarget()
        yield("/wait 1")
    end

    TurnOnCombatMods("auto")

    GemAnnouncementLock = false

    -- switches to targeting forlorns for bonus (if present)
    if not IgnoreForlorns then
        yield("/target Forlorn Maiden")
        if not IgnoreBigForlornOnly then
            yield("/target The Forlorn")
        end
    end

    if (GetTargetName() == "Forlorn Maiden" or GetTargetName() == "The Forlorn") then
        if IgnoreForlorns or (IgnoreBigForlornOnly and GetTargetName() == "The Forlorn") then
            ClearTarget()
        elseif not Svc.Targets.Target.IsDead then
            if not ForlornMarked then
                yield("/enemysign attack1")
                if Echo == "all" then
                    yield("/echo Found Forlorn! <se.3>")
                end
                TurnOffAoes()
                ForlornMarked = true
            end
        else
            ClearTarget()
            TurnOnAoes()
        end
    else
        TurnOnAoes()
    end

    -- targets whatever is trying to kill you
    if Entity.Target == nil then
        yield("/battletarget")
    end

    -- clears target
    if Entity.Target ~= nil and Entity.Target.FateId ~= CurrentFate.fateId and not Entity.Target.IsInCombat then
        Entity.Target:ClearTarget()
    end

    -- do not interrupt casts to path towards enemies
    if Svc.Condition[CharacterCondition.casting] then
        return
    end

    --hold buff thingy
    if CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress >= PercentageToHoldBuff then
        TurnOffRaidBuffs()
    end

    -- pathfind closer if enemies are too far
    if not Svc.Condition[CharacterCondition.inCombat] then
        if Svc.Targets.Target ~= nil then
            if GetDistanceToTargetFlat() <= (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
                if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                    yield("/vnav stop")
                    yield("/wait 5.002") -- wait 5s before inching any closer
                elseif (GetDistanceToTargetFlat() > (1 + GetTargetHitboxRadius() + GetPlayerHitboxRadius())) and not Svc.Condition[CharacterCondition.casting] then -- never move into hitbox
                    yield("/vnav movetarget")
                    yield("/wait 1") -- inch closer by 1s
                end
            elseif not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                yield("/wait 5.003") -- give 5s for enemy AoE casts to go off before attempting to move closer
                if (Svc.Targets.Target ~= nil and not Svc.Condition[CharacterCondition.inCombat]) and not Svc.Condition[CharacterCondition.casting] then
                    MoveToTargetHitbox()
                end
            end
            return
        else
            AttemptToTargetClosestFateEnemy()
            yield("/wait 1") -- wait in case target doesnt stick
            if (Svc.Targets.Target == nil) and not Svc.Condition[CharacterCondition.casting] then
                IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, false)
            end
        end
    else
        if Svc.Targets.Target ~= nil and (GetDistanceToTargetFlat() <= (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius())) then
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            end
        elseif not CurrentFate.isBossFate then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                yield("/wait 5.004")
                if Svc.Targets.Target ~= nil and not Svc.Condition[CharacterCondition.casting] then
                    if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                        yield("/vnav flytarget")
                    else
                        MoveToTargetHitbox()
                    end
                end
            end
        end
    end
end

--#endregion

--#region State Transition Functions

function Ready()
    if SelectedZone == nil or SelectedZone.zoneId == nil then
        yield("/echo [FATE] ERROR: SelectedZone is not set! Aborting.")
        StopScript = true
        return
    end
    if StopScript then return end --Early exit before running ready checks.

    FoodCheck()
    PotionCheck()

    CombatModsOn = false

    local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))
    local needsRepair = Inventory.GetItemsInNeedOfRepairs(RemainingDurabilityToRepair)
    local spiritbonded = Inventory.GetSpiritbondedItems()

    if not GemAnnouncementLock and (Echo == "all" or Echo == "gems") then
        GemAnnouncementLock = true
        if BicolorGemCount >= 1400 then
            yield("/echo [FATE] You're almost capped with "..tostring(BicolorGemCount).."/1500 gems! <se.3>")
            if ShouldExchangeBicolorGemstones and not shouldWaitForBonusBuff and Player.IsLevelSynced ~= true then
                State = CharacterState.exchangingVouchers
                Dalamud.Log("[FATE] State Change: ExchangingVouchers")
                return
            end
        else
            yield("/echo [FATE] Gems: "..tostring(BicolorGemCount).."/1500")
        end
    end

    if RemainingDurabilityToRepair > 0 and needsRepair.Count > 0 and (not shouldWaitForBonusBuff or (SelfRepair and Inventory.GetItemCount(33916) > 0)) then
        State = CharacterState.repair
        Dalamud.Log("[FATE] State Change: Repair")
        return
    end

    if ShouldExtractMateria and spiritbonded.Count > 0 and Inventory.GetFreeInventorySlots() > 1 then
        State = CharacterState.extractMateria
        Dalamud.Log("[FATE] State Change: ExtractMateria")
        return
    end

    if WaitingForFateRewards == nil and Retainers and ARRetainersWaitingToBeProcessed() and Inventory.GetFreeInventorySlots() > 1 and not shouldWaitForBonusBuff then
        State = CharacterState.processRetainers
        Dalamud.Log("[FATE] State Change: ProcessingRetainers")
        return
    end

    if ShouldGrandCompanyTurnIn and Inventory.GetFreeInventorySlots() < InventorySlotsLeft and not shouldWaitForBonusBuff then
        State = CharacterState.gcTurnIn
        Dalamud.Log("[FATE] State Change: GCTurnIn")
        return
    end

    if Svc.ClientState.TerritoryType ~= SelectedZone.zoneId then
        if not SelectedZone or not SelectedZone.aetheryteList or not SelectedZone.aetheryteList[1] then
            yield("/echo [FATE] ERROR: No aetheryte found for selected zone. Cannot teleport. Stopping script.")
            StopScript = true
            return
        end
        local teleSuccess = TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        if teleSuccess == false then
            yield("/echo [FATE] ERROR: Teleportation failed. Stopping script.")
            StopScript = true
            return
        end
        Dalamud.Log("[FATE] Teleport Back to Farming Zone")
        return
    end

    if ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft and (not shouldWaitForBonusBuff or Inventory.GetItemCount(4868) > 0) then
        State = CharacterState.summonChocobo
        Dalamud.Log("[FATE] State Change: summonChocobo")
        return
    end

    NextFate = SelectNextFate()
    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateObject) then
        CurrentFate = nil
    end

    if NextFate == nil then
        if EnableChangeInstance and GetZoneInstance() > 0 and not shouldWaitForBonusBuff then
            State = CharacterState.changingInstances
            Dalamud.Log("[FATE] State Change: ChangingInstances")
            return
        end
        if DownTimeWaitAtNearestAetheryte and (Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 20) then
            State = CharacterState.flyBackToAetheryte
            Dalamud.Log("[FATE] State Change: FlyBackToAetheryte")
            return
        end
        if MoveToRandomSpot then
            MoveToRandomNearbySpot(50, 75)
            yield("/wait 10")
        end
        return
    end


    if NextFate == nil and shouldWaitForBonusBuff and DownTimeWaitAtNearestAetheryte then
        if Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 20 then
            State = CharacterState.flyBackToAetheryte
            Dalamud.Log("[FATE] State Change: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    end

    if not Player.Available then
        return
    end

    CurrentFate = NextFate
    HasFlownUpYet = false
    SetMapFlag(SelectedZone.zoneId, CurrentFate.position)
    State = CharacterState.moveToFate
    Dalamud.Log("[FATE] State Change: MovingtoFate "..CurrentFate.fateName)
end

function HandleDeath()
    CurrentFate = nil

    if CombatModsOn then
        TurnOffCombatMods()
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    end

    if Svc.Condition[CharacterCondition.dead] then --Condition Dead
        if ReturnOnDeath then
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "all" then
                    yield("/echo [FATE] You have died. Returning to home aetheryte.")
                end
            end

            if Addons.GetAddon("SelectYesno").Ready then --rez addon yes
                yield("/callback SelectYesno true 0")
                yield("/wait 0.1")
            end
        else
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "all" then
                    yield("/echo [FATE] You have died. Waiting until script detects you're alive again...")
                end
            end
            yield("/wait 1")
        end
    else
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        DeathAnnouncementLock = false
        HasFlownUpYet = false
    end
end

function ExecuteBicolorExchange()
    CurrentFate = nil

    if BicolorGemCount >= 1400 then
        if Addons.GetAddon("SelectYesno").Ready then
            yield("/callback SelectYesno true 0")
            return
        end

        if Addons.GetAddon("ShopExchangeCurrency").Ready then
            yield("/callback ShopExchangeCurrency false 0 "..SelectedBicolorExchangeData.item.itemIndex.." "..(BicolorGemCount//SelectedBicolorExchangeData.item.price))
            return
        end

        if Svc.ClientState.TerritoryType ~=  SelectedBicolorExchangeData.zoneId then
            TeleportTo(SelectedBicolorExchangeData.aetheryteName)
            return
        end

        if SelectedBicolorExchangeData.miniAethernet ~= nil and
            GetDistanceToPoint(SelectedBicolorExchangeData.position) > (DistanceBetween(SelectedBicolorExchangeData.miniAethernet.position, SelectedBicolorExchangeData.position) + 10) then
            Dalamud.Log("Distance to shopkeep is too far. Using mini aetheryte.")
            yield("/li "..SelectedBicolorExchangeData.miniAethernet.name)
            yield("/wait 1") -- give it a moment to register
            return
        elseif Addons.GetAddon("TelepotTown").Ready then
            Dalamud.Log("TelepotTown open")
            yield("/callback TelepotTown false -1")
        elseif GetDistanceToPoint(SelectedBicolorExchangeData.position) > 5 then
            Dalamud.Log("Distance to shopkeep is too far. Walking there.")
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                Dalamud.Log("Path not running")
                IPC.vnavmesh.PathfindAndMoveTo(SelectedBicolorExchangeData.position, false)
            end
        else
            Dalamud.Log("[FATE] Arrived at Shopkeep")
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            end

            if Svc.Targets.Target == nil or GetTargetName() ~= SelectedBicolorExchangeData.shopKeepName then
                yield("/target "..SelectedBicolorExchangeData.shopKeepName)
            elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                yield("/interact")
            end
        end
    else
        if Addons.GetAddon("ShopExchangeCurrency").Ready then
            Dalamud.Log("[FATE] Attemping to close shop window")
            yield("/callback ShopExchangeCurrency true -1")
            return
        elseif Svc.Condition[CharacterCondition.occupiedInEvent] then
            Dalamud.Log("[FATE] Character still occupied talking to shopkeeper")
            yield("/wait 0.5")
            return
        end

        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end
end

function ProcessRetainers()
    CurrentFate = nil

    Dalamud.Log("[FATE] Handling retainers...")
    if ARRetainersWaitingToBeProcessed() and Inventory.GetFreeInventorySlots() > 1 then

        if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
            return
        end

        if Svc.ClientState.TerritoryType ~=  129 then
            yield("/vnav stop")
            TeleportTo("Limsa Lominsa Lower Decks")
            return
        end

        local summoningBell = {
            name="Summoning Bell",
            position=Vector3(-122.72, 18.00, 20.39)
        }
        if GetDistanceToPoint(summoningBell.position) > 4.5 then
            IPC.vnavmesh.PathfindAndMoveTo(summoningBell.position, false)
            return
        end

        if Svc.Targets.Target == nil or GetTargetName() ~= summoningBell.name then
            yield("/target "..summoningBell.name)
            return
        end

        if not Svc.Condition[CharacterCondition.occupiedSummoningBell] then
            yield("/interact")
            if Addons.GetAddon("RetainerList").Ready then
                yield("/ays e")
                if Echo == "all" then
                    yield("/echo [FATE] Processing retainers")
                end
                yield("/wait 1")
            end
        end
    else
        if Addons.GetAddon("RetainerList").Ready then
            yield("/callback RetainerList true -1")
        elseif not Svc.Condition[CharacterCondition.occupiedSummoningBell] then
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

function GrandCompanyTurnIn()
    if Inventory.GetFreeInventorySlots() <= InventorySlotsLeft then
        if IPC.Lifestream and IPC.Lifestream.ExecuteCommand then
            IPC.Lifestream.ExecuteCommand("gc")
            Dalamud.Log("[FATE] Executed Lifestream teleport to GC.")
        else
            yield("/echo [FATE] Lifestream IPC not available! Cannot teleport to GC.")
            return
        end
        yield("/wait 1")
        while (IPC.Lifestream.IsBusy and IPC.Lifestream.IsBusy())
            or (Svc.Condition[CharacterCondition.betweenAreas]) do
            yield("/wait 0.5")
        end
        Dalamud.Log("[FATE] Lifestream complete, standing at GC NPC.")
        if IPC.AutoRetainer and IPC.AutoRetainer.EnqueueInitiation then
            IPC.AutoRetainer.EnqueueInitiation()
            Dalamud.Log("[FATE] Called AutoRetainer.EnqueueInitiation() for GC handin.")
        else
            yield("/echo [FATE] AutoRetainer IPC not available! Cannot process GC turnin.")
        end
    else
        State = CharacterState.ready
        Dalamud.Log("State Change: Ready")
    end
end

function Repair()
    local needsRepair = Inventory.GetItemsInNeedOfRepairs(RemainingDurabilityToRepair)
    if Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
        return
    end

    if Addons.GetAddon("Repair").Ready then
        if needsRepair.Count == nil or needsRepair.Count == 0 then
            yield("/callback Repair true -1") -- if you dont need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
        Dalamud.Log("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = {position = Vector3(-213.95, 15.99, 49.35)}
    if SelfRepair then
        if Inventory.GetItemCount(33916) > 0 then
            if Addons.GetAddon("Shop").Ready then
                yield("/callback Shop true -1")
                return
            end

            if Svc.ClientState.TerritoryType ~=  SelectedZone.zoneId then
                TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
                return
            end

            if Svc.Condition[CharacterCondition.mounted] then
                Dismount()
                Dalamud.Log("[FATE] State Change: Dismounting")
                return
            end

            if needsRepair.Count > 0 then
                if not Addons.GetAddon("Repair").Ready then
                    Dalamud.Log("[FATE] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                Dalamud.Log("[FATE] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if Svc.ClientState.TerritoryType ~=  129 then
                if Echo == "all" then
                    yield("/echo Out of Dark Matter! Purchasing more from Limsa Lominsa.")
                end
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local darkMatterVendor = {npcName="Unsynrael", position = Vector3(-257.71, 16.19, 50.11), wait=0.08}
            if GetDistanceToPoint(darkMatterVendor.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, darkMatterVendor.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.position) > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    IPC.vnavmesh.PathfindAndMoveTo(darkMatterVendor.position, false)
                end
            else
                if Svc.Targets.Target == nil or GetTargetName() ~= darkMatterVendor.npcName then
                    yield("/target "..darkMatterVendor.npcName)
                elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                    yield("/interact")
                elseif Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                elseif Addons.GetAddon("Shop") then
                    yield("/callback Shop true 0 40 99")
                end
            end
        else
            if Echo == "all" then
                yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Limsa mender.")
            end
            SelfRepair = false
        end
    else
        if needsRepair.Count > 0 then
            if Svc.ClientState.TerritoryType ~= 129 then
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local mender = { npcName="Alistair", position = Vector3(-246.87, 16.19, 49.83)}
            if GetDistanceToPoint(mender.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, mender.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
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
        else
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

function ExtractMateria()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
        Dalamud.Log("[FATE] State Change: Dismounting")
        return
    end

    if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
        return
    end

    if Inventory.GetSpiritbondedItems().Count > 0 and Inventory.GetFreeInventorySlots() > 1 then
        if not Addons.GetAddon("Materialize").Ready then
            yield("/generalaction \"Materia Extraction\"")
            yield("/wait .25")
            return
        end

        Dalamud.Log("[FATE] Extracting materia...")

        if Addons.GetAddon("MaterializeDialog").Ready then
            yield("/callback MaterializeDialog true 0")
            yield("/wait .25")
        else
            yield("/callback Materialize true 2 0")
            yield("/wait .25")
        end
    else
        if Addons.GetAddon("Materialize").Ready then
            yield("/callback Materialize true -1")
            yield("/wait .25")
        else
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

--#endregion State Transition Functions

--#region Misc Functions

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
end

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

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

function GetNodeText(addonName, nodePath, ...)
    local addon = Addons.GetAddon(addonName)
    repeat
        yield("/wait 0.1")
    until addon.Ready
    return addon.GetNode(nodePath, ...).Text
end

function ARRetainersWaitingToBeProcessed()
    local offlineCharacterData = IPC.AutoRetainer.GetOfflineCharacterData(Svc.ClientState.LocalContentId)
    for i=0, offlineCharacterData.RetainerData.Count-1 do
        local retainer = offlineCharacterData.RetainerData[i]
        if retainer.HasVenture and retainer.VentureEndsAt <= os.time() then
            return true
        end
    end
    return false
end

--#endregion Misc Functions