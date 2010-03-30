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
local tekcheck = LibStub("tekKonfig-Checkbox")
local icon = LibStub("LibDBIcon-1.0")

local HGAP = 15
local VGAP = 10

function ns:CreateOptionsPage(parent)
	local showMinimap = tekcheck.new(parent, nil, "Show Minimap", "TOPLEFT", HGAP, -VGAP)
	showMinimap.tiptext = "Shows/hides the minimap icon"
	local orig = showMinimap:GetScript("OnClick")
	showMinimap:SetScript("OnClick", function(self) 
		orig(self); 
		ns.db.minimap.hide = not ns.db.minimap.hide
		if ns.db.minimap.hide then
			icon:Hide(myname)
		else
			icon:Show(myname)
		end
	end)
	showMinimap:SetChecked(not ns.db.minimap.hide)

	--[[
	local enableWhisperAdd = tekcheck.new(parent, nil, "Enable Whisper Add", "TOPLEFT", showMinimap, "BOTTOMLEFT", 0, -VGAP)
	enableWhisperAdd.tiptext = "Enables people to whisper you \"!add\" (followed optionally by a role) to be added to the current roster."
	orig = enableWhisperAdd:GetScript("OnClick")
	enableWhisperAdd:SetScript("OnClick", function(self)
		ns.db.enableWhisperAdd = not ns.db.enableWhisperAdd
	end)
	enableWhisperAdd:SetChecked(ns.db.enableWhisperAdd)
	]]
end


