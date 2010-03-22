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

local raidMembers = {}

function ns:GetSelectedRaidMembers()
	local result = {}
	for i=1,#(raidMembers) do
		if raidMembers[i].selected then
			table.insert(result, raidMembers[i].name)
		end
	end
	return result
end

function ns:GetRaidMemberByIndex(index)
	return raidMembers[index]
end

function ns:GetRaidMember(name)
	for i = 1,#raidMembers do
		if raidMembers[i].name:lower() == name:lower() then
			return raidMembers[i], i
		end
	end
end

function ns:AddRaidMember(name, role, class, note)
	local entry = ns:GetRaidMember(name)
	if not entry then 
		entry = {} 
		table.insert(raidMembers, entry)
	end

	entry.name = name
	entry.role = role
	entry.class = class
	entry.note = note

	ns:RefreshList()
end

function ns:RemoveRaidMemberByIndex(index)
	table.remove(index)
	ns:RefreshList()
end

function ns:RemoveAllRaidMembers()
	raidMembers = {}
	ns:RefreshList()
end

function ns:RemoveRaidMember(name)
	local entry, index = GetRaidMember(name)
	if entry then
		ns:RemoveRaidMemberByIndex(index)
	end
end

function ns:InitDB()
	local db = RaidInviteManagerDB
	if not db.minimap then
		db.minimap = { hide = true }
	end
	ns.db = db
end

