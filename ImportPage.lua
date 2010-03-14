
local myname, ns = ...

local LINEHEIGHT, maxoffset, offset = 12, 0, 0

local function doscroll(v)
	offset = math.max(math.min(v, 0), maxoffset)
	scroll:SetVerticalScroll(-offset)
	textBox:SetPoint("TOP", 0, offset)
end

function ns.CreateImportPage(parent)
	local instructionsText = parent:CreateFontString()
	instructionsText:SetFontObject(GameFontNormalSmall)
	instructionsText:SetJustifyH("LEFT")
	instructionsText:SetJustifyV("TOP")
	instructionsText:SetPoint("TOPLEFT", 5, -5)
	instructionsText:SetPoint("RIGHT", -5)
	instructionsText:SetHeight(100)
	instructionsText:SetText("To import a roster, paste it here, one name per line and click the Import button.\n\nLines that begin with # will be ignored, unless followed by the word \"Tanks\", \"Healers\", \"Melee\", \"Ranged\", or \"Standby\" in which case it will be used to set the role for the following names.\n\nNote: Your existing lineup will be replaced!")

	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll:SetPoint("TOPLEFT", 5, -105)
	scroll:SetPoint("BOTTOMRIGHT", -5, 40)
	local HEIGHT = scroll:GetHeight()

	local textBox = CreateFrame("EditBox", nil, scroll)
	scroll:SetScrollChild(textBox)
	textBox:SetMultiLine(true)
	textBox:SetAutoFocus(false)
	textBox:SetFontObject(ChatFontSmall)
	textBox:SetPoint("TOP")
	textBox:SetPoint("LEFT")
	textBox:SetPoint("RIGHT")
	textBox:SetHeight(1000)
	textBox:SetScript("OnEscapePressed", textBox.ClearFocus)
	textBox:SetScript("OnShow", function(self) self:SetFocus() end)

	textBox:SetScript("OnCursorChanged", function(self, x, y, width, height)
		LINEHIGHT = height
		if offset < y then
			doscroll(y)
		elseif math.floor(offset-HEIGHT + height*2) > y then
			local v = y + HEIGHT - height*2
			maxoffset = math.min(maxoffset, v)
			doscroll(v)
		end
	end)

	scroll:UpdateScrollChildRect()
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self,val) doscroll(offset + val*LINEHEIGHT*3) end)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("BOTTOM", scroll, "TOP", 0, 8)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local sep2 = parent:CreateTexture()
	sep2:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep2:SetPoint("TOP", scroll, "BOTTOM", 0, -8)
	sep2:SetPoint("LEFT", parent, "LEFT", 10)
	sep2:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep2:SetHeight(3)


	local importButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMRIGHT", -5, 5)
	importButton:SetText("Import")

end


