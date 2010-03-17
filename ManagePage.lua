
local myname, ns = ...

local scroll
local OnValueChanged

local rows = {}
local NUMROWS = 22
local SCROLLSTEP = math.floor(NUMROWS/3)

local contextMenu
local CONTEXT_MENU_MODE_NAME = "Name"
local CONTEXT_MENU_MODE_ROLE = "Role"
local CONTEXT_MENU_MODE_CLASS = "Class"

local function SetRaidMemberNote(note)
	ns.raidMembers[contextMenu.index].note = note
end

local function RefreshList()
	OnValueChanged(scroll, 0)
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
		local note = ns.raidMembers[contextMenu.index].note
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
	local roles = { "Tank", "Healer", "Melee", "Ranged", "Not specified" }
	local classes = CLASS_SORT_ORDER -- from FrameXML/Constants.lua

	if contextMenu.mode == CONTEXT_MENU_MODE_ROLE  then
		for i=1,#roles do
			info = UIDropDownMenu_CreateInfo()
			info.text = roles[i]
			info.notCheckable = 1
			info.func = function() 
				ns.raidMembers[contextMenu.index].role = roles[i] 
				RefreshList()
			end
			UIDropDownMenu_AddButton(info)
		end
	end

	if contextMenu.mode == CONTEXT_MENU_MODE_CLASS then
		for i = 1,#classes do
			info = UIDropDownMenu_CreateInfo()
			info.text = classes[i]
			info.notCheckable = 1
			info.func = function()
				ns.raidMembers[contextMenu.index].class = classes[i]
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
		table.remove(ns.raidMembers, contextMenu.index)
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

local function GetRaidListEntry(index)
	if ns.raidMembers[index] then
		return ns.raidMembers[index].name, ns.raidMembers[index].class, ns.raidMembers[index].role, ns.raidMembers[index].note, (ns.raidMembers[index].selected==true)
	else
		return nil, nil, nil, nil, false
	end
end

local orig_OnValueChanged
function OnValueChanged(self, offset, ...)
	offset = math.floor(offset)

	for i,row in ipairs(rows) do
		local index = offset + i
		local name, class, role, note, selected = GetRaidListEntry(index)

		if name then
			-- got one
			local class, classFilename = ns.GetUnitClassInfo(name)
			local color = { r=0.75, g=0.75, b=0.75 }
			if class then color = RAID_CLASS_COLORS[classFilename] or { r=0.75, g=0.75, b=0.75 } end 
			row.name:SetText(name); row.name:SetTextColor(color.r, color.g, color.b)
			row.class:SetText(class); row.class:SetTextColor(color.r, color.g, color.b)
			row.role:SetText(role); row.role:SetTextColor(color.r, color.g, color.b)
			row.note = note
			row.index = index
			row:SetChecked(selected)
			row:Show()

		else
			-- hide the row
			row.name:SetText()
			row.class:SetText()
			row.role:SetText()
			row.note = nil
			row:SetChecked(false)
			row.index = nil
			row:Hide()
		end
	end
end

function ns.CreateManagePage(parent)
	local scrollbox = CreateFrame("Frame", nil, parent)
	scrollbox:SetPoint("TOPLEFT", -14, -5)
	scrollbox:SetPoint("BOTTOMRIGHT", -5, 35)
	scroll = LibStub("tekKonfig-Scroll").new(scrollbox, 0, SCROLLSTEP)

	local lastbutt
	local function OnMouseWheel(self, val) scroll:SetValue(scroll:GetValue() - val*SCROLLSTEP) end
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
					if self:GetChecked() then
						ns.raidMembers[idx].selected = true
						self.check:Show()
					else
						ns.raidMembers[idx].selected = nil
						self.check:Hide()
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
			if self.note and self.note ~= " " then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetText(self.note)
			end
		end)

		table.insert(rows, butt)
		lastbutt = butt
	end

	orig_OnValueChanged = scroll:GetScript("OnValueChanged")
	scroll:SetScript("OnValueChanged", OnValueChanged)

	local firstshow = true
	parent:SetScript("OnShow", function(self)
		scroll:SetMinMaxValues(0, math.max(0, i))
		if firstshow then scroll:SetValue(0); firstshow = nil end
	end)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("TOP", scrollbox, "BOTTOM", 0, -5)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontSmall)
	editBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 5, 5)
	editBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -60, 5)
	editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
	editBox:SetHeight(24)

	local addButton = LibStub("tekKonfig-Button").new_small(parent, "BOTTOMRIGHT", -5, 5)
	addButton:SetText("Add")
	addButton:SetWidth(50)
	addButton:SetHeight(24)

	local addName = function()
		local name = editBox:GetText()
			local t = {
				name = name,
				class = ns.GetUnitClassInfo(name) or "Unknown",
				role = ns.GetRole(name) or "Not specified",
			}
			table.insert(ns.raidMembers, t)
			RefreshList()
			editBox:SetText("")
	end

	addButton:SetScript("OnClick", addName)
	editBox:SetScript("OnEnterPressed", addName)

	local inviteButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMRIGHT", parent, "TOPRIGHT", 0, 5)
	inviteButton:SetText("Begin Invites")

	InitializeContextMenu(parent)

end


