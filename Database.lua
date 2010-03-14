
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
