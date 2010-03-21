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


ns.defaults = {}

-- TODO: Remove when done testing
ns.raidMembers = {
	[1] = { name="Quaiche", class="Druid", role="Tank", note="Has to leave at 7pm" },
	[2] = { name="Dankish", class="Hunter", role="Ranged" },
	[3] = { name="Hydrogenbomb", class="Shaman", role="Ranged" },
	[4] = { name="Uethar", class="Paladin", role="Healer", note="Also has a rogue" },
	[5] = { name="Vayda", class="Priest", role="Healer" },
	[6] = { name="Airitus", class="Warrior", role="Tank" },
	[7] = { name="Deeoogee", class="Rogue", role="Melee" },
	[8] = { name="Horric", class="Mage", role="Ranged" },
	[9] = { name="Grundy", class="Warlock", role="Ranged" },
	[10] = { name="Peine", class="Death Knight", role="Melee" },
}

function ns.InitDB()
	_G[myname.."DB"] = setmetatable(_G[myname.."DB"] or {}, {__index = ns.defaults})
	ns.db = _G[myname.."DB"]
end


function ns.FlushDB()
	for i,v in pairs(ns.defaults) do if ns.db[i] == v then ns.db[i] = nil end end
end
