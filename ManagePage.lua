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

local scrollBar
local OnValueChanged
local firstshow = true

local rows = {}
local NUMROWS = 18
local SCROLLSTEP = 2 -- math.floor(NUMROWS/4)

local contextMenu
local CONTEXT_MENU_MODE_NAME = "Name"
local CONTEXT_MENU_MODE_ROLE = "Role"
local CONTEXT_MENU_MODE_CLASS = "Class"

local function SetRaidMemberNote(note)
	local entry = ns:GetRaidMemberByIndex(contextMenu.index)
	if entry then
		entry.note = note
	end
end

local function RefreshList()
	if scrollBar then
		local num = ns:GetNumRaidMembers()
		scrollBar:SetMinMaxValues(0, math.max(0, num))
		OnValueChanged(scrollBar, 0)
	end
end

-- TODO: Hack
function ns:RefreshList()
	if not firstShow then
		RefreshList()
	end
end

local function IsGuildMember(name)
	for i = 1, GetNumGuildMembers(true) do
		if GetGuildRosterInfo(i) == name then return true end
	end
end

local function IsGuildMemberOnline(name)
   local count = GetNumGuildMembers(true)
   local nom, online
   for index = 1,count do
      nom, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      if name == nom and online == 1 then
         return 1
      end
   end
end

local function IsInRaid(name)
	for i=1,GetNumRaidMembers() do
		if GetRaidRosterInfo(i) == name then return true end
	end
end

local function DoInviteUnit(name)
	if UnitIsUnit(name, "player") then return end
	if IsInRaid(name) then return end
	if IsGuildMember(name) then
		if IsGuildMemberOnline(name) then
			InviteUnit(name)
		else
			ns:Print("Not online "..name)
		end
	else
		ns:Print("Inviting "..name.." (non guild)")
		InviteUnit(name)
	end
end

local function Invite_OnClick()
	local approved = ns:GetSelectedRaidMembers()
	if not UnitInRaid("player") then
		if GetNumPartyMembers() == 0 then
			ns:RegisterEvent("PARTY_MEMBERS_CHANGED")
			for i = 1,4 do
				local u = table.remove(approved)
				if u then DoInviteUnit(u) end
			end
			return
		else
			ConvertToRaid()
			ns:ScheduleTimer(Invite_OnClick, 2)
			return
		end
	end

	local v = table.remove(approved)
	while v do
		DoInviteUnit(v)
		v = table.remove(approved)
	end
end

function ns:PARTY_MEMBERS_CHANGED()
	if GetNumPartyMembers() > 0 then
		ConvertToRaid()
		ns:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		ns:ScheduleTimer(Invite_OnClick, 2)
	end
end

StaticPopupDialogs["RAIDINVITEMANAGER_SET_NOTE"] = {
	text = "Set note",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	hasWideEditBox = 1,
	OnAccept = function(self)
		SetRaidMemberNote(self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local note = ns:GetRaidMemberByIndex(contextMenu.index).note
		if ( note ) then
			self.wideEditBox:SetText(note);
		end
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		RefreshList()
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		SetRaidMemberNote(parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local function menuCallback(frame, level)
	local info

	if contextMenu.mode == CONTEXT_MENU_MODE_ROLE  then
		for key,roleName in pairs(ns.ROLES) do
			info = UIDropDownMenu_CreateInfo()
			info.text = roleName
			info.notCheckable = 1
			info.func = function() 
				local entry = ns:GetRaidMemberByIndex(contextMenu.index)
				if entry then entry.role = roleName end
				RefreshList()
			end
			UIDropDownMenu_AddButton(info)
		end
	end

	if contextMenu.mode == CONTEXT_MENU_MODE_CLASS then
		for key,className in pairs(ns.CLASSES) do
			info = UIDropDownMenu_CreateInfo()
			info.text = className
			info.notCheckable = 1
			info.func = function()
				local entry = ns:GetRaidMemberByIndex(contextMenu.index)
				if entry then entry.class = className end
				RefreshList()
			end
			UIDropDownMenu_AddButton(info)
		end
	end

	if contextMenu.mode == CONTEXT_MENU_MODE_NAME then
		info = UIDropDownMenu_CreateInfo()
		info.text = "Change name..."
		info.notCheckable = 1
		info.func = function()
			-- static popup to get new name and replace the entry in the list
			-- remember to reset/clear class and role
		end
		UIDropDownMenu_AddButton(info)
	end

	--
	-- Standard context menu stuff
	-- the following stuff shows in all context menus
	
	-- Spacer
	if contextMenu.mode ~= nil then
		info = UIDropDownMenu_CreateInfo()
		info.text = ""
		info.notCheckable = 1
		info.notClickable = 1
		UIDropDownMenu_AddButton(info)
	end

	-- Delete
	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete"
	info.notCheckable = 1
	info.func = function()
		ns:RemoveRaidMemberByIndex(contextMenu.index)
		RefreshList()
	end
	UIDropDownMenu_AddButton(info)

	-- Set note
	info = UIDropDownMenu_CreateInfo()
	info.text = "Set note..."
	info.notCheckable = 1
	info.func = function()
		StaticPopup_Show("RAIDINVITEMANAGER_SET_NOTE")
	end
	UIDropDownMenu_AddButton(info)
end

local function InitializeContextMenu(parent)
	contextMenu = CreateFrame("Frame", "RaidInviteManager_ContextMenu", parent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(contextMenu, menuCallback, "MENU")
end

local orig_OnValueChanged
function OnValueChanged(self, offset, ...)
	offset = math.floor(offset)

	for i,row in ipairs(rows) do
		local index = offset + i
		local entry = ns:GetRaidMemberByIndex(index)

		if entry then
			-- got one
			local classFilename = ns:GetUnitClassInfo(entry.name)
			local color = { r=0.75, g=0.75, b=0.75 }
			if classFilename then color = RAID_CLASS_COLORS[classFilename] or { r=0.75, g=0.75, b=0.75 } end 
			row.name:SetText(entry.name); row.name:SetTextColor(color.r, color.g, color.b)
			row.class:SetText(entry.class); row.class:SetTextColor(color.r, color.g, color.b)
			row.role:SetText(entry.role); row.role:SetTextColor(color.r, color.g, color.b)
			row.note = entry.note
			row.index = index
			row:SetChecked(entry.selected)
			if entry.selected then row.check:Show() else row.check:Hide() end
			row:Show()

		else
			-- hide the row
			row.name:SetText()
			row.class:SetText()
			row.role:SetText()
			row.note = nil
			row:SetChecked(false)
			row.check:Hide()
			row.index = nil
			row:Hide()
		end
	end
	if orig_OnValueChanged then orig_OnValueChanged(self, offset, ...) end
end

function ns:CreateManagePage(parent)
	local scrollbox = CreateFrame("Frame", nil, parent)
	scrollbox:SetPoint("TOPLEFT", -14, -6)
	scrollbox:SetPoint("BOTTOMRIGHT", -5, 65)
	scrollBar = LibStub("tekKonfig-Scroll").new(scrollbox, 0, SCROLLSTEP)

	scrollbox:SetScript("OnShow", RefreshList)

	local lastbutt
	local function OnMouseWheel(self, val) scrollBar:SetValue(scrollBar:GetValue() - val*SCROLLSTEP) end
	for i=1,NUMROWS do
		local butt = CreateFrame("CheckButton", nil, parent)
		butt:SetWidth(318) butt:SetHeight(16)
		if lastbutt then butt:SetPoint("TOP", lastbutt, "BOTTOM") else butt:SetPoint("TOPLEFT", 0, 0) end

		local check = butt:CreateTexture()
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetHeight(16); check:SetWidth(16)
		check:SetPoint("LEFT")
		check:Hide()
		butt.check = check

		local name = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		name:SetPoint("LEFT", 15, 0)
		butt.name = name

		local class = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		class:SetPoint("LEFT", 150, 0)
		butt.class = class

		local role = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		role:SetPoint("RIGHT", -25, 0)
		butt.role = role

		butt:EnableMouseWheel(true)
		butt:SetScript("OnMouseWheel", OnMouseWheel)
		butt:RegisterForClicks("AnyUp")

		butt:SetScript("OnClick", function(self, button, down)
			if button == "LeftButton" then
				-- checkmark
				local idx = self.index
				if idx then
					local entry = ns:GetRaidMemberByIndex(idx)
					if entry then
						if self:GetChecked() then
							entry.selected = true
							self.check:Show()
						else
							entry.selected = nil
							self.check:Hide()
						end
					end
				end

			elseif button == "RightButton" then
				-- Context menu
				if self.name:IsMouseOver() then
					contextMenu.mode = CONTEXT_MENU_MODE_NAME
				elseif self.role:IsMouseOver() then
					contextMenu.mode = CONTEXT_MENU_MODE_ROLE
				elseif self.class:IsMouseOver() then
					contextMenu.mode = CONTEXT_MENU_MODE_CLASS
				else
					contextMenu.mode = nil
				end
				contextMenu.index = self.index
				ToggleDropDownMenu(1, nil, contextMenu, "cursor", 0, 0)
			end
		end)

		butt:SetScript("OnLeave", function() GameTooltip:Hide() end)
		butt:SetScript("OnEnter", function(self)
			if self.note and (self.note ~= " ") then
				ns:Debug("Note", self.note)
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetText(tostring(self.note))
			end
		end)

		table.insert(rows, butt)
		lastbutt = butt
	end

	orig_OnValueChanged = scrollBar:GetScript("OnValueChanged")
	scrollBar:SetScript("OnValueChanged", OnValueChanged)

	parent:SetScript("OnShow", function(self)
		local num = ns:GetNumRaidMembers()
		scrollBar:SetMinMaxValues(0, math.max(0, num))
		if firstshow then scrollBar:SetValue(0); firstshow = nil end
	end)

	local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontSmall)
	editBox:SetPoint("TOPLEFT", scrollbox, "BOTTOMLEFT", 23, -5)
	editBox:SetPoint("TOPRIGHT", scrollbox, "BOTTOMRIGHT", -48, -5)
	editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
	editBox:SetHeight(24)

	local addButton = LibStub("tekKonfig-Button").new_small(parent, "LEFT", editBox, "RIGHT", 5)
	addButton:SetText("Add")
	addButton:SetWidth(50)
	addButton:SetHeight(24)

	local addName = function()
		local name = editBox:GetText()
		ns:AddRaidMember(name)
		editBox:SetText("")
	end

	addButton:SetScript("OnClick", addName)
	editBox:SetScript("OnEnterPressed", addName)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("TOP", editBox, "BOTTOM", 0, -5)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local inviteButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMLEFT", parent, "BOTTOM", 3, 5)
	inviteButton:SetWidth(100)
	inviteButton:SetText("Begin Invites")
	inviteButton:SetScript("OnClick", Invite_OnClick)
	
	local clearButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMRIGHT", parent, "BOTTOM", -3, 5)
	clearButton:SetWidth(100)
	clearButton:SetText("Clear")
	clearButton:SetScript("OnClick", function()
		ns:RemoveAllRaidMembers()
	end)


	InitializeContextMenu(parent)
end


