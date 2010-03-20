
local myname, ns = ...

-- Will return "Standby" for any value not listed
local roles = setmetatable({
	["TANKS"] = "Tank",
	["TANK"] = "Tank",
	["MELEE"] = "Melee",
	["RANGED"] = "Ranged",
	["HEALER"] = "Healer",
	["HEALERS"] = "Healer",
}, { __index = function(t,k) return rawget(t,k) or "Standby" end })

function ns.CreateImportPage(parent)
	local instructionsText = parent:CreateFontString()
	instructionsText:SetFontObject(GameFontNormalSmall)
	instructionsText:SetJustifyH("LEFT")
	instructionsText:SetJustifyV("TOP")
	instructionsText:SetPoint("TOPLEFT", 5, -5)
	instructionsText:SetPoint("RIGHT", -5)
	instructionsText:SetHeight(100)
	instructionsText:SetText("To import a roster, paste it here, one name per line and click the Import button.\n\nLines that begin with # will be ignored, unless followed by the word \"Tanks\", \"Healers\", \"Melee\", \"Ranged\", or \"Standby\" in which case it will be used to set the role for the following names.\n\nNote: Your existing lineup will be replaced!")

	local scrollEdit = LibStub("QScrollingEditBox"):New("RaidInviteManagerImportEdit", parent)
	scrollEdit:SetPoint("TOPLEFT", 5, -105)
	scrollEdit:SetPoint("BOTTOMRIGHT", -25, 40)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("BOTTOM", scrollEdit, "TOP", 0, 8)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local sep2 = parent:CreateTexture()
	sep2:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep2:SetPoint("TOP", scrollEdit, "BOTTOM", 0, -8)
	sep2:SetPoint("LEFT", parent, "LEFT", 10)
	sep2:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep2:SetHeight(3)

	local importButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMRIGHT", -5, 5)
	importButton:SetText("Import")
	importButton:SetScript("OnClick", function()
		ns.raidMembers = {}
		local text = scrollEdit:GetText()
		local lines = { string.split("\n", text) }
		local role = "Standby"
		for i,line in ipairs(lines) do
			line = strtrim(line)
			if string.sub(line, 1, 1) == "#" then
				-- special line
				local directive = string.upper(string.match(line, "#%s*(%w+)"))
				role = roles[directive]
			else
				-- assume it is a name
				local name = string.match(line, "%w+")
				if name then
					table.insert( ns.raidMembers, {
						name = name,
						role = role,
						class = ns.GetUnitClassInfo(name) or "Unknown"
					})
				end
			end
		end

		ns.SetActivePage(1) -- Switch to the manage page after import
	end)


end

