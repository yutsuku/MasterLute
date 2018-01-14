local _G = getfenv()
local MasterLute = _G.MasterLute

MasterLute.hooks = {}
MasterLute.LootCloseError = 0

local Event = CreateFrame('Frame')

Event:SetScript('OnEvent', function()
	this[event](this)
end)

MasterLute.Event = Event