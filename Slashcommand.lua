
local myname, ns = ...


_G["SLASH_".. myname:upper().."1"] = "/rim"
_G["SLASH_".. myname:upper().."2"] = "/raidinvitemanager"

SlashCmdList[myname:upper()] = function(msg)
	ns.ToggleMainFrame()
end
