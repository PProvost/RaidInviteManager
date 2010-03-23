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

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
	if addon ~= myname then return end

	LibStub("tekKonfig-AboutPanel").new(myfullname, myname) -- Make first arg nil if no parent config panel

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end


function ns:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_LOGOUT")

	-- Misc setup
	self:InitDB()
	self:InitLDBPlugin()
	self:InitMinimapIcon()
	self:AddPlayer()

	-- Kick a roster load off just in case nobody else did
	GuildRoster()

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function ns:PLAYER_LOGOUT()
	self:FlushDB()
	-- Do anything you need to do as the player logs out
end
