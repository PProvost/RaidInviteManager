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

local keyword = "addraid"
local pattern = "^"..keyword.."%s*(%w*)"

local function IsValidRole(role)
	local role = role:lower()
	return (role=="tank") or (role=="healer") or (role=="melee") or (role=="ranged") or (role=="standby")
end

function ns:CHAT_MSG_WHISPER(event, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter, guid)
	if not ns.db.enableWhisperAdd then return end
	if sender == UnitName("player") then return end
	if string.sub(message:lower(), 1, string.len(keyword)) ~= keyword then return end

	local class, classFilename, race, raceFilename, sex = GetPlayerInfoByGUID(guid)

	local role = string.match(message:lower(), pattern:lower())
	if (role == nil or role == "") then role = "Standby" end
	if IsValidRole(role) then
		local entry = ns:GetRaidMember(sender)
		if entry then
			ns:AddRaidMember(sender, role, classFilename)
			SendChatMessage("RaidInviteManager: You are already listed in the manager. Your information has been updated", "WHISPER", nil, sender)
		else
			ns:AddRaidMember(sender, role, classFilename, "Whispered at "..date("%I:%M:%S %p") )
			SendChatMessage("RaidInviteManager: You have been added.", "WHISPER", nil, sender)
		end
	end
end

ns:RegisterEvent("CHAT_MSG_WHISPER")
