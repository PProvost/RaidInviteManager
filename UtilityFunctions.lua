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
function ns.Print(...) print("|cFF33FF99".. myfullname.. "|r:", string.join(", ", tostringall(...))) end

local debugf = tekDebug and tekDebug:GetFrame(myname)
function ns.Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

function ns.GetUnitClassInfo(unitName)
	local class, classFilename = select(2,UnitClass(unitName))
	if class == nil then
		for i = 1,GetNumGuildMembers(true) do
			local name, _, _, level, _class, _, _, _, online, _, _classFileName = GetGuildRosterInfo(i)
			if name == unitName then
				class = _class
				classFilename = _classFileName
			end
		end
	end
	return class, classFilename
end

function ns.GetRole(name)
	local class, classFilename = ns.GetUnitClassInfo(name)
	if classFilename == "ROGUE" then return "Melee" end
	if classFilename=="WARLOCK" or classFilename=="MAGE" or classFilename=="HUNTER" then return "Ranged" end
end


