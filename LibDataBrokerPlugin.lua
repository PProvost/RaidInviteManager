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

function ns:InitLDBPlugin()
	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(myname, {
		type = "launcher",
		icon = "Interface\\Addons\\"..myname.."\\Icon",
		OnClick = function(clickedFrame, button)
			ns:ToggleMainFrame()
		end,
	})

	ns.ldb = ldb
end
