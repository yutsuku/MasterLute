local _G = getfenv(0)
local debug_level = 0 -- 0 release, 1 some messages, 3 all messages
local addon = CreateFrame('Frame', 'MasterLute')

addon:SetScript('OnEvent', function()
	this[event](this)
end)

addon.hooks = {}
addon.LootCloseError = 0

addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_LOGIN')

function addon:print(message, level, headless)
	if not message then return end
	if level then
		if level <= debug_level then
			if headless then
				ChatFrame1:AddMessage(message, 0.53, 0.69, 0.19)
			else
				ChatFrame1:AddMessage('[MasterLute]: ' .. message, 0.53, 0.69, 0.19)
			end
		end
	else
		if headless then
			ChatFrame1:AddMessage(message)
		else
			ChatFrame1:AddMessage('[MasterLute]: ' .. message)
		end
	end
end

function addon:ADDON_LOADED()
	if arg1 ~= 'MasterLute' then
		return
	end
	
	if not MasterLute_Data then
		MasterLute_Data = {}
	end
	
	if not MasterLute_Data.prices then
		MasterLute_Data.prices = {}
	end
	
	if not MasterLute_Data.messageFormat then
		MasterLute_Data.messageFormat = 'Roll $item price $price.'
	end
	
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('LOOT_CLOSED')
	
	self:MakeUI()
	self.main_frame:Hide()
end

function addon:ClearItem()
	self.main_frame.item.hasItem = nil
	self.main_frame.item.itemLink = nil
	self.main_frame.item.itemString = nil
	self.main_frame.item.texture = nil
	self.main_frame.item.itemID = nil
	self.main_frame.price:SetText('0')
	
	self.main_frame.item.icon:SetTexture([[Interface\Icons\Temp]])
end

function addon:MakeUI()
	local main_frame = CreateFrame('Frame', nil, UIParent)
	self.main_frame = main_frame
	main_frame:SetPoint('CENTER', 0, 0)
	main_frame:SetWidth(256)
	main_frame:SetHeight(64)
	main_frame:SetBackdrop({
		bgFile=[[Interface\Buttons\YELLOWORANGE64]],
		--edgeFile=[[Interface\Minimap\TooltipBackdrop]],
		tile = false,
		tileSize = 16,
		--edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	--main_frame:SetBackdropColor(0, 0, 0, .6)
	main_frame:SetMovable(true)
	main_frame:SetClampedToScreen(true)
	main_frame:SetToplevel(true)
	main_frame:EnableMouse(true)
	main_frame:RegisterForDrag('LeftButton')
	main_frame:SetScript('OnDragStart', function()
		this:StartMoving()
	end)
	main_frame:SetScript('OnDragStop', function()
		this:StopMovingOrSizing()
	end)

	local messageFormat = CreateFrame('EditBox', nil, self.main_frame)
	main_frame.messageFormat = messageFormat
	messageFormat:SetPoint('TOP', 0, -2)
	messageFormat:SetPoint('LEFT', 2, 0)
	messageFormat:SetPoint('RIGHT', -2, 0)
	messageFormat:SetAutoFocus(false)
	messageFormat:SetTextInsets(0, 0, 3, 3)
	messageFormat:SetMaxLetters(256)
	messageFormat:SetHeight(20)
	messageFormat:SetFontObject(ChatFontNormal)
	messageFormat:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'})
	messageFormat:SetBackdropColor(0, 0, 0, .5)
	messageFormat:SetText(MasterLute_Data.messageFormat)
	messageFormat:SetScript('OnTextChanged', function()
		
	end)
	messageFormat:SetScript('OnEditFocusLost', function()
		this:HighlightText(0, 0)
	end)
	messageFormat:SetScript('OnEscapePressed', function()
		this:ClearFocus()
	end)
	messageFormat:SetScript('OnEnterPressed', function()
		this:ClearFocus()
		MasterLute_Data.messageFormat = this:GetText()
	end)
	
	local item = CreateFrame('Frame', nil, main_frame)
	main_frame.item = item
	item:SetWidth(37)
	item:SetHeight(37)
	item:SetPoint('TOPLEFT', 2, -24)
	item:EnableMouse(true)
	
	item.hasItem = nil
	item.itemLink = nil
	item.itemID = nil
	item.itemString = nil
	item.texture = nil
	
	item:SetScript('OnEnter', function()
		if this.hasItem then
			GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
			GameTooltip:SetHyperlink(this.itemLink)
		end
	end)
	
	item:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	local icon = item:CreateTexture(nil, "OVERLAY")
	main_frame.item.icon = icon
	icon:SetAllPoints()
	icon:SetTexture([[Interface\Icons\Temp]])
	
	local price = CreateFrame('EditBox', nil, self.main_frame)
	main_frame.price = price
	price:SetPoint('TOPLEFT', 41, -24)
	price:SetAutoFocus(false)
	price:SetTextInsets(0, 0, 3, 3)
	price:SetMaxLetters(4)
	price:SetHeight(37)
	price:SetWidth(37)
	price:SetFontObject(NumberFontNormalLarge)
	price:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'})
	price:SetBackdropColor(0, 0, 0, .5)
	price:SetText('0')
	
	price:SetScript('OnTextChanged', function()
		
	end)
	price:SetScript('OnEditFocusLost', function()
		this:HighlightText(0, 0)
	end)
	price:SetScript('OnEscapePressed', function()
		this:ClearFocus()
	end)
	price:SetScript('OnEnterPressed', function()
		this:ClearFocus()
	end)
	
	local send = CreateFrame('Button', nil, main_frame, 'UIPanelButtonTemplate')
	main_frame.send = send
	send:SetWidth(37)
	send:SetHeight(37)
	send:SetPoint('TOPRIGHT', -2, -24)
	send:SetText('Send')
	
	send:SetScript('OnClick', function()
		if not self.main_frame.item.itemLink then return end
		
		local str = self.main_frame.messageFormat:GetText()
		str = gsub(str, '$item', self.main_frame.item.itemString)
		str = gsub(str, '$price', self.main_frame.price:GetText())
		
		MasterLute_Data.prices[self.main_frame.item.itemID] = self.main_frame.price:GetText()
		
		SendChatMessage(str, 'RAID')
	end)
	
	self.hooks.LootFrameItem_OnClick = LootFrameItem_OnClick
	self.hooks.LootFrame_Update = LootFrame_Update
	self.hooks.LootFrame_OnHide = LootFrame_OnHide
	self.hooks.LootFrame_OnShow = LootFrame_OnShow
	self.hooks.CloseLoot = CloseLoot
	
	function LootFrame_OnHide()
		addon.hooks.LootFrame_OnHide()
		self:OnClose()
	end
	
	function LootFrame_OnShow()
		addon.hooks.LootFrame_OnShow()
		self:OnShow()
	end
	
	function LootFrame_Update()
		addon.hooks.LootFrame_Update()
		self:ClearItem()
	end
	
	function CloseLoot(reason)
		self.LootCloseError = reason
		addon.hooks.CloseLoot(reason)
		self:OnClose()
	end
	
	function LootFrameItem_OnClick(button)
		addon.hooks.LootFrameItem_OnClick(button)
		
		if ( not ChatFrameEditBox:IsVisible() and IsShiftKeyDown() and self.main_frame:IsVisible() ) then
			local _, _, item_id, enchant_id, suffix_id, unique_id, name = strfind(GetLootSlotLink(this.slot), '^|c%x%x%x%x%x%x%x%x|Hitem:(%d+):(%d+):(%d+):(%d+)|h%[(.+)%]|h|r$')
			if item_id then
				self.main_frame.item.hasItem = true
				self.main_frame.item.texture = GetLootSlotInfo(this.slot)
				self.main_frame.item.itemString = GetLootSlotLink(this.slot)
				self.main_frame.item.itemLink = format('item:%d:%d%d:%d', item_id, enchant_id, suffix_id, unique_id)
				self.main_frame.item.itemID = item_id
				self.main_frame.item.icon:SetTexture(self.main_frame.item.texture)
				self.main_frame.price:SetText('0')
				
				if MasterLute_Data.prices[item_id] then
					self.main_frame.price:SetText(MasterLute_Data.prices[item_id])
				end
				
				self:print(self.main_frame.item.itemString, 1)
			end
		end
	end
	
end

function addon:LOOT_OPENED()
	self:OnShow()
end

function addon:LOOT_CLOSED()
	self:OnClose()
end

function addon:OnShow()
	if self.LootCloseError and self.LootCloseError > 0 then
		self.LootCloseError = 0
		return
	end
	
	self:ClearItem()
	self.main_frame:Show()
end

function addon:OnClose()
	self:ClearItem()
	self.main_frame:Hide()
end

function addon:PLAYER_LOGIN()

	self.enabled = true
	self.version = GetAddOnMetadata('MasterLute', 'Version')
	
	SLASH_MASTERLUTE1, SLASH_MASTERLUTE2 = '/masterlute', '/lute'
	function SlashCmdList.MASTERLUTE(arg)
		local msg = {}
		for w in gmatch(arg, '[^%s]+') do
			tinsert(msg, w)
		end
		
		if arg == 'debug' then
			debug_level = debug_level + 1
			if debug_level > 3 then debug_level = 0 end
			self:print('Debug level is now set to ' .. debug_level)
		else
			
		end
		
	end
end