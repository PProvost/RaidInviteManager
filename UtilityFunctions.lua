--[[
RaidInviteManager

Copyright 2010 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local myname, ns = ...

local myfullname = GetAddOnMetadata(myname, "Title")
function ns:Print(...) print("|cFF33FF99".. myfullname.. "|r:", string.join(", ", tostringall(...))) end

local debugf = tekDebug and tekDebug:GetFrame(myname)
function ns:Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

function ns:GetUnitClassInfo(unitOrName)
	local name
	-- Hopefully this will work but not always
	local class, classFilename = UnitClass(unitOrName)
	if classFilename then
		return classFilename
	else
		-- Maybe we can get the GUID
		local guid = UnitGUID(unitOrName)
		if guid then
			return select(2, GetPlayerInfoByGUID(guid))
		end

		-- Try Guild roster next
		for i = 1,GetNumGuildMembers(true) do
			name, _, _, _, _, _, _, _, _, _, classFileName = GetGuildRosterInfo(i)
			if name == unitOrName then
				return classFileName
			end
		end
	end
end

function ns:GetClassRole(class)
	if class == "ROGUE" then return ns.ROLES["MELEE"] end
	if class=="WARLOCK" or class=="MAGE" or class=="HUNTER" then return ns.ROLES["RANGED"] end
	return ns.ROLES["Unknown"]
end

function ns:GetRoleKey(roleName)
	if strlower(roleName)=="tank" or strlower(roleName)=="tanks" then return "TANK" end
	if strlower(roleName)=="healer" or strlower(roleName)=="healers" then return "HEALER" end
	if strlower(roleName)=="melee" then return "MELEE" end
	if strlower(roleName)=="ranged" or strlower(roleName)=="caster" or strlower(roleName)=="casters" then return "RANGED" end
	if strlower(roleName)=="standby" or strlower(roleName)=="waitlist" then return "STANDBY" end
	return "UNKNOWN"
end
