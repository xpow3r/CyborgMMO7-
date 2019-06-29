--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: RatPageController.lua
--~ Description: Controller logic for the RatPage
--~ Copyright (C) 2012 Mad Catz Inc.
--~ Author: Christopher Hooks

--~ This program is free software; you can redistribute it and/or
--~ modify it under the terms of the GNU General Public License
--~ as published by the Free Software Foundation; either version 2
--~ of the License, or (at your option) any later version.

--~ This program is distributed in the hope that it will be useful,
--~ but WITHOUT ANY WARRANTY; without even the implied warranty of
--~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--~ GNU General Public License for more details.

--~ You should have received a copy of the GNU General Public License
--~ along with this program; if not, write to the Free Software
--~ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

------------------------------------------------------------------------------

local RatPageController_methods = {}
local RatPageController_mt = {__index=RatPageController_methods}

local function RatPageController()
	local self = {}
	setmetatable(self, RatPageController_mt)
	return self
end

function RatPageController_methods:SlotClicked(slot)
	local slotObject = nil
	slotObject = CyborgMMO_RatPageModel:GetObjectOnButton(slot.Id)
	CyborgMMO_RatPageModel:SetObjectOnButton(slot.Id, CyborgMMO_RatPageModel:GetMode(), self:GetCursorObject())

	if slotObject then
		slotObject:Pickup()
	end
end

function RatPageController_methods:ModeClicked(mode)
	CyborgMMO_DPrint("Setting mode "..tostring(mode.Id))
	CyborgMMO_RatPageModel:SetMode(mode.Id)
end

function RatPageController_methods:GetCursorObject()
	local type,a,b,c = GetCursorInfo()
	ClearCursor()	
	if type=='item' then
		local id,link = a,b
		return CyborgMMO_CreateWowObject('item', id)
	elseif type=='spell' then
		local index,book,id = a,b,c
		return CyborgMMO_CreateWowObject('spell', id)
	elseif type=='macro' then
		local index = a
		local name = GetMacroInfo(index)
		return CyborgMMO_CreateWowObject('macro', name)
	elseif type=='battlepet' then
		local petID = a
		return CyborgMMO_CreateWowObject('battlepet', petID)
	elseif type=='mount' then
		local mountID = a
		return CyborgMMO_CreateWowObject('mount', mountID)
	elseif type=='equipmentset' then
		local name = a
		return CyborgMMO_CreateWowObject('equipmentset', name)
	elseif type=='money' then
		return nil
	elseif type=='merchant' then
		return nil
	elseif type==nil then
		return nil
	else
		CyborgMMO_DPrint("unexpected cursor info:", type, a, b, c)
		return nil
	end
end

function RatPageController_methods:CallbackDropped(callbackObject)
	local slot = nil
	local observers = CyborgMMO_RatPageModel:GetAllObservers()
	for i=1,#observers do
		if MouseIsOver(observers[i]) then
			slot = observers[i]
			break
		end
	end
	if slot then
		CyborgMMO_RatPageModel:SetObjectOnButton(slot.Id, CyborgMMO_RatPageModel:GetMode(), callbackObject.wowObject)
	end
end

------------------------------------------------------------------------------

CyborgMMO_RatPageController = RatPageController()

