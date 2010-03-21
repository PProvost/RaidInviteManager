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

local mainFrame = nil
local pages = {}

function ns.SetActivePage(index)
	assert(mainFrame ~= nil)
	for i = 1,#pages do
		if i == index then
			pages[i]:Show()
		else
			pages[i]:Hide()
		end
	end
	mainFrame.titleString:SetText(pages[index].title or "Unknown")
	PanelTemplates_SetTab(mainFrame, index)
end

local function CreateMainFrame()
	mainFrame = LibStub("tekPanel").new("RaidInviteManagerMainFrame", "Raid Invite Manager")
	mainFrame:SetAttribute("UIPanelLayout-pushable", 5)

	-- Page 1
	local page1 = CreateFrame("Frame", nil, mainFrame)
	page1.title = "Manage Raid"
	page1:SetPoint("TOPLEFT", 22, -75)
	page1:SetPoint("BOTTOMRIGHT", -42, 81)
	ns.CreateManagePage(page1)
	table.insert(pages, page1)
	local tab1Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab1", mainFrame, "CharacterFrameTabButtonTemplate")
	tab1Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 12, 78)
	tab1Button:SetText("Manage")
	tab1Button:SetScript("OnClick", function() ns.SetActivePage(1) end)

	-- Page 2
	local page2 = CreateFrame("Frame", nil, mainFrame)
	page2.title = "Import Roster"
	page2:SetPoint("TOPLEFT", 22, -75)
	page2:SetPoint("BOTTOMRIGHT", -42, 81)
	ns.CreateImportPage(page2)
	table.insert(pages, page2)
	local tab2Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab2", mainFrame, "CharacterFrameTabButtonTemplate")
	tab2Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 75, 78)
	tab2Button:SetText("Import")
	tab2Button:SetScript("OnClick", function() ns.SetActivePage(2) end)

	-- Page 3
	local page3 = CreateFrame("Frame", nil, mainFrame)
	page3.title = "Options"
	page3:SetPoint("TOPLEFT", 22, -75)
	page3:SetPoint("BOTTOMRIGHT", -42, 81)
	ns.CreateOptionsPage(page3)
	table.insert(pages, page3)
	local tab3Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab3", mainFrame, "CharacterFrameTabButtonTemplate")
	tab3Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 133, 78)
	tab3Button:SetText("Options")
	tab3Button:SetScript("OnClick", function() ns.SetActivePage(3) end)

	-- Top Page title FontString
	mainFrame.titleString = mainFrame:CreateFontString()
	mainFrame.titleString:SetFontObject(GameFontNormal)
	mainFrame.titleString:SetPoint("TOP", 0, -40)
	mainFrame.titleString:SetText("Manage")

	-- Final setup
	mainFrame:SetScript("OnShow", function() ns.SetActivePage(1) end)
	PanelTemplates_SetNumTabs(mainFrame, #pages);
end

function ns.ToggleMainFrame()
	if not mainFrame then
		CreateMainFrame()
	end
	ToggleFrame(mainFrame)
end


