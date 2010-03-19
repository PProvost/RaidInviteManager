--[[
Copyright 2009 Quaiche of Dragonblight

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

--[[ 
Example usage:
	local panel = LibStub("tekPanel").new("TestPanel2", "TestPanel2")
	local scrollEdit = LibStub("QScrollingEditBox"):New("TestPanelEdit", panel)
	scrollEdit:SetPoint("TOPLEFT", 21, -76)
	scrollEdit:SetPoint("BOTTOMRIGHT", -65, 82)
	ShowUIPanel(panel)
]]

assert(LibStub, "QScrollingEditBox requires LibStub")

local lib, oldminor = LibStub:NewLibrary("QScrollingEditBox", 2)
if not lib then return end

function lib:New(name, parent)
   if not name then error("QScrollingEditBox:New - invalid name") end
	 if not parent then parent = UIParent end
   
   local parentFrame = CreateFrame("Frame", name.."ParentFrame", parent)
   
   local scroll = CreateFrame("ScrollFrame", name.."ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
   scroll:SetAllPoints()
   
   local editBox = CreateFrame("EditBox", name.."EditBox", scroll)
   scroll:SetScrollChild(editBox)
   editBox:SetAutoFocus(false)
   editBox:SetMultiLine(true)
   editBox:SetTextInsets(5,5,5,15)
   editBox:SetFontObject(GameFontHighlight)
   editBox:EnableMouse(true)
   editBox:SetWidth(1000)
   scroll:UpdateScrollChildRect()
   
	local scrollBorder = CreateFrame("Frame", nil, scroll)
	scrollBorder:SetPoint("TOPLEFT", _G[name.."ScrollFrameScrollBarScrollUpButton"], -5, 5)
	scrollBorder:SetPoint("BOTTOMRIGHT", _G[name.."ScrollFrameScrollBarScrollDownButton"], 5, -3)
	scrollBorder:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12,
		insets = { left = 0, right = 0, top = 5, bottom = 5 }
	})
	scrollBorder:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0.5)

   local focusBtn = CreateFrame("Button", name.."FocusButton", scroll)
   focusBtn:SetAllPoints()
   focusBtn:SetScript("OnClick", function() editBox:SetFocus() end)
   
   editBox:SetScript("OnUpdate", function(self) 
         ScrollingEdit_OnUpdate(self)
   end)
   
   editBox:SetScript("OnTextChanged", function(self) 
         ScrollingEdit_OnTextChanged(self, self:GetParent())
   end)
   
   editBox:SetScript("OnEscapePressed", function(self)
         self:ClearFocus()
   end)
   
   editBox:SetScript("OnCursorChanged", function(self, x, y, width, height) 
         ScrollingEdit_OnCursorChanged(self, x, y, width, height) 
   end)
   
   parentFrame:SetScript("OnSizeChanged", function(self, width, height)
         editBox:SetWidth(width)
         scroll:UpdateScrollChildRect()
   end)

	 parentFrame:SetScript("OnShow", function()
		 editBox:SetCursorPosition(0)
	 end)

	 parentFrame.GetText = function(self)
		return editBox:GetText()
	 end
   
	 parentFrame.SetText = function(self, text)
		 editBox:SetText(text)
	 end

   return parentFrame
end


