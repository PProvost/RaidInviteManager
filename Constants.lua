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

-- Will return "Unknown" for any value not listed
ns.ROLES = setmetatable({
	["TANK"] = "Tank",
	["MELEE"] = "Melee",
	["RANGED"] = "Ranged",
	["HEALER"] = "Healer",
	["STANDBY"] = "Standby",
}, { __index = function(t,k) return rawget(t,k) or "Unknown" end })

-- Will return Unknown for any value not included in the localized list from Blizzard
ns.CLASSES = setmetatable( LOCALIZED_CLASS_NAMES_MALE, 
	{ __index = function(t,k) return rawget(t,k) or "Unknown" end })
