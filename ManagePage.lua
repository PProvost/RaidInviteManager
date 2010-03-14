
local myname, ns = ...

function ns.CreateManagePage(parent)
	local NUMROWS = 22
	local SCROLLSTEP = math.floor(NUMROWS/3)
	local scrollbox = CreateFrame("Frame", nil, parent)
	scrollbox:SetPoint("TOPLEFT", -14, -5)
	scrollbox:SetPoint("BOTTOMRIGHT", -5, 35)
	local scroll = LibStub("tekKonfig-Scroll").new(scrollbox, 0, SCROLLSTEP)

	local rows, lastbutt = {}
	local function OnMouseWheel(self, val) scroll:SetValue(scroll:GetValue() - val*SCROLLSTEP) end
	for i=1,NUMROWS do
		local butt = CreateFrame("Button", nil, parent)
		butt:SetWidth(318) butt:SetHeight(16)
		if lastbutt then butt:SetPoint("TOP", lastbutt, "BOTTOM") else butt:SetPoint("TOPLEFT", 0, 0) end

		local name = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		name:SetPoint("LEFT", 5, 0)
		butt.name = name

		local detail = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		detail:SetPoint("LEFT", 100, 0)
		butt.detail = detail

		local time = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		time:SetPoint("RIGHT", -25, 0)
		butt.time = time

		butt:EnableMouseWheel(true)
		butt:SetScript("OnMouseWheel", OnMouseWheel)
		butt:SetScript("OnClick", OnClick)
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

	local orig = scroll:GetScript("OnValueChanged")
	local function OnValueChanged(self, offset, ...)
		offset = math.floor(offset)

		local i = 0
		for _,v in ipairs(ns.raidMembers) do
			i = i+1
			if (i-offset) > 0 and (i-offset) <= NUMROWS then
				local row = rows[i-offset]
				local class, classFilename = ns.GetUnitClassInfo(v.name)
				local color = { r=1.0, g=1.0, b=1.0 }
				if class then
					color = RAID_CLASS_COLORS[classFilename]
				end

				row.name:SetText(v.name)
				row.name:SetTextColor(color.r, color.g, color.b)

				row.detail:SetText(v.class)
				row.detail:SetTextColor(color.r, color.g, color.b)

				row.time:SetText(v.role)
				row.time:SetTextColor(color.r, color.g, color.b)

				row:Show()
			end
		end

		if (i-offset) < NUMROWS then
			for j=(i-offset+1),NUMROWS do rows[j]:Hide() end
		end

		return orig(self, offset, ...)
	end
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
				role = ns.GetRole(name) or "No role selected",
			}
			table.insert(ns.raidMembers, t)
			OnValueChanged(scroll, 0)
			editBox:SetText("")
	end

	addButton:SetScript("OnClick", addName)
	editBox:SetScript("OnEnterPressed", addName)
end


