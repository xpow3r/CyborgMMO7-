--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: WowObjects.lua
--~ Description: Warcraft in game object models
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

local WowObject_methods = {}
local WowObject_mt = {__index=WowObject_methods}

local function WowObject(type, detail, subdetail)
	local self = {}

	self.type = type
	self.detail = detail
	self.subdetail = subdetail

	setmetatable(self, WowObject_mt)

	return self
end

function WowObject_methods:SaveData()
	return {
		type = self.type,
		detail = self.detail,
		subdetail = self.subdetail,
	}
end

function WowObject_methods:DoAction()
	CyborgMMO_DPrint("Nothing To Do")
end

function WowObject_methods:Pickup()
	CyborgMMO_DPrint("Pick up Item")
end

function WowObject_methods:SetBinding(key)
end

------------------------------------------------------------------------------

local WowCallback_methods = setmetatable({}, {__index=WowObject_methods})
local WowCallback_mt = {__index=WowCallback_methods}

local function WowCallback(callbackName)
	local self = WowObject("callback", callbackName, "")

	self.callbackName = callbackName
	self.texture = "Interface\\AddOns\\CyborgMMO7\\Graphics\\"..callbackName.."Unselected"

	setmetatable(self, WowCallback_mt)

	return self
end

function WowCallback_methods:SetTextures(buttonFrame)
	buttonFrame:SetNormalTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.callbackName.."Unselected")
	buttonFrame:SetPushedTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.callbackName.."Down")
	buttonFrame:SetHighlightTexture("Interface\\AddOns\\CyborgMMO7\\Graphics\\"..self.callbackName.."Over")
end

function WowCallback_methods:DoAction()
	local action = CyborgMMO_CallbackFactory:GetCallback(self.callbackName)
	action()
end

function WowCallback_methods:PickupCallback()
	local slot = nil
	local observers = CyborgMMO_RatPageModel:GetAllObservers()
	for i=1,#observers do
		if MouseIsOver(observers[i]) then
			slot = observers[i]
			break
		end
	end
	slot:SetNormalTexture(slot.UnCheckedTexture)
end

function WowCallback_methods:Pickup()
	PlaySound("igAbilityIconDrop")
	ClearCursor()
	self:PickupCallback()
end

function WowCallback_methods:SetBinding(key)
	local buttonFrame,parentFrame,name = CyborgMMO_CallbackFactory:AddCallback(function(...) return self:DoAction(...) end)
	SetOverrideBindingClick(CyborgMMO_CallbackFactory.Frame, true, key, name, "LeftButton")
end

------------------------------------------------------------------------------

local WowItem_methods = setmetatable({}, {__index=WowObject_methods})
local WowItem_mt = {__index=WowItem_methods}

local function WowItem(itemID)
	local texture = select(10, GetItemInfo(itemID)) -- :FIXME: this may fail too early in the session (like when loading saved data)
	if not texture then
		return nil
	end

	local self = WowObject("item", itemID)

	self.itemID = itemID
	self.texture = texture

	setmetatable(self, WowItem_mt)

	return self
end

function WowItem_methods:Pickup()
--	PlaySound("igAbilityIconDrop")
	ClearCursor()
--	SetCursor(self.texture)
	return PickupItem(self.itemID)
end

function WowItem_methods:SetBinding(key)
	local name = GetItemInfo(self.itemID)
	SetOverrideBindingItem(CyborgMMO_CallbackFactory.Frame, true, key, name)
end

------------------------------------------------------------------------------

local WowSpell_methods = setmetatable({}, {__index=WowObject_methods})
local WowSpell_mt = {__index=WowSpell_methods}

local function WowSpell(spellID)
	local texture = GetSpellTexture(spellID)
	if not texture then
		return nil
	end

	local self = WowObject("spell", spellID)

	self.spellID = spellID
	self.texture = texture

	setmetatable(self, WowSpell_mt)

	return self
end

function WowSpell_methods:DoAction()
	CyborgMMO_DPrint("Cast Spell")
end

function WowSpell_methods:Pickup()
--	PlaySound("igAbilityIconDrop")
	ClearCursor()
--	SetCursor(self.texture)
--	return PickupSpellBookItem(self.SpellbookID, self.Spellbook)
	return PickupSpell(self.spellID)
end

function WowSpell_methods:SetBinding(key)
--	CyborgMMO_DPrint("Binding to key "..key)
	local name = GetSpellInfo(self.spellID)
	CyborgMMO_DPrint("binding spell:", self.spellID, name)
	SetOverrideBindingSpell(CyborgMMO_CallbackFactory.Frame, true, key, name)
end

------------------------------------------------------------------------------

local WowMacro_methods = setmetatable({}, {__index=WowObject_methods})
local WowMacro_mt = {__index=WowMacro_methods}

local function WowMacro(name)
	local texture = select(2, GetMacroInfo(name))
	if not texture then
		return nil
	end

	local self = WowObject("macro", name)

	self.name = name
	self.texture = texture

	setmetatable(self, WowMacro_mt)

	return self
end

function WowMacro_methods:DoAction()
	CyborgMMO_DPrint("Use Item")
end

function WowMacro_methods:Pickup()
--	PlaySound("igAbilityIconDrop")
	ClearCursor()
--	SetCursor(self.texture)
	return PickupMacro(self.name)
end

function WowMacro_methods:SetBinding(key)
	SetOverrideBindingMacro(CyborgMMO_CallbackFactory.Frame, true, key, self.name)
end

------------------------------------------------------------------------------

local WowEquipmentSet_methods = setmetatable({}, {__index=WowObject_methods})
local WowEquipmentSet_mt = {__index=WowEquipmentSet_methods}

local function WowEquipmentSet(name)
	local texture = GetEquipmentSetInfoByName(name)
	if not texture then
		return nil
	end

	local self = WowObject("equipmentset", name)

	self.name = name
	self.texture = "Interface\\Icons\\"..texture

	setmetatable(self, WowEquipmentSet_mt)

	return self
end

function WowEquipmentSet_methods:DoAction()
	UseEquipmentSet(self.name)
end

function WowEquipmentSet_methods:Pickup()
--	PlaySound("igAbilityIconDrop")
	ClearCursor()
--	SetCursor(self.texture)
	return PickupEquipmentSetByName(self.name)
end

function WowEquipmentSet_methods:SetBinding(key)
	local buttonFrame,parentFrame,name = CyborgMMO_CallbackFactory:AddCallback(function() self:DoAction() end)
	SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")
end

------------------------------------------------------------------------------

local WowBattlePet_methods = setmetatable({}, {__index=WowObject_methods})
local WowBattlePet_mt = {__index=WowBattlePet_methods}

local function WowBattlePet(petID)
	local texture = select(9, C_PetJournal.GetPetInfoByPetID(petID)) -- :FIXME: this may fail too early in the session (like when loading saved data)
	if not texture then
		return nil
	end

	local self = WowObject("battlepet", petID)
	CyborgMMO_DPrint("creating battle pet binding:", petID)

	self.petID = petID
	self.texture = texture

	setmetatable(self, WowBattlePet_mt)

	return self
end

--[[
local function IdentifyPet(petID)
	local creatureID = select(11, C_PetJournal.GetPetInfoByPetID(petID))
	for index=1,GetNumCompanions('CRITTER') do
		local creatureID2,_,spellID = GetCompanionInfo('CRITTER', index)
		if creatureID2 == creatureID then
			return spellID
		end
	end
end
--]]

function WowBattlePet_methods:DoAction()
--	PlaySound("igMainMenuOptionCheckBoxOn")
	C_PetJournal.SummonPetByGUID(self.petID)
end

function WowBattlePet_methods:Pickup()
--	PlaySound("igAbilityIconDrop")
	return C_PetJournal.PickupPet(self.petID)
end

function WowBattlePet_methods:SetBinding(key)
	local buttonFrame,parentFrame,name = CyborgMMO_CallbackFactory:AddCallback(function() self:DoAction() end)
	SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")
end

------------------------------------------------------------------------------

local function GetMountInfoEx(mountID)
	-- special case for random mount
	if mountID == 0xFFFFFFF then
		return 0,"Interface/ICONS/ACHIEVEMENT_GUILDPERK_MOUNTUP"
	end
	
	--local spellID = CyborgMMO_MountMap[mountID] or CyborgMMO_LocalMountMap[mountID]
	--if not spellID then return nil,"not in database" end
	
--	local mountIndex
--	for i=1,C_MountJournal.GetNumMounts() do
	local _,spell,texture = C_MountJournal.GetMountInfoByID(mountID)
--		if spell==spellID then
--		if i==spellID then
	return mountID,texture
--		end
--	end
	
--	return nil,"not in journal"
end

local function FindMountFromSpellID(spellID)
	for mount,spell in pairs(CyborgMMO_MountMap) do
		if spell==spellID then
			return mount
		end
	end
	for mount,spell in pairs(CyborgMMO_MountMap) do
		if spell==spellID then
			return mount
		end
	end
	for i=1,C_MountJournal.GetNumMounts() do
		local _,spell = C_MountJournal.GetMountInfoByID(i)
		if spell==spellID then
			local cursor = pack(GetCursorInfo())
			C_MountJournal.Pickup(i)
			local _,mountID = GetCursorInfo()
			ClearCursor()
			return mountID
		end
	end
	return nil
end

local WowMount_methods = setmetatable({}, {__index=WowObject_methods})
local WowMount_mt = {__index=WowMount_methods}

local function WowMount(mountID)
	local mountIndex,texture = GetMountInfoEx(mountID)
	if not mountIndex then
		-- the mount might have been removed from the game
		return nil
	end
	
	local self = WowObject("mount", mountID)
	CyborgMMO_DPrint("creating mount binding:", mountID, texture)

	self.mountID = mountID
	self.texture = texture

	setmetatable(self, WowMount_mt)

	return self
end

function WowMount_methods:DoAction()
	local mountIndex = GetMountInfoEx(self.mountID)
	if not mountIndex then return end
	
	C_MountJournal.SummonByID(mountIndex)
end

function WowMount_methods:Pickup()
	local mountIndex = GetMountInfoEx(self.mountID)
	if not mountIndex then return end
	
	return C_MountJournal.Pickup(mountIndex)
end

function WowMount_methods:SetBinding(key)
	local buttonFrame,parentFrame,name = CyborgMMO_CallbackFactory:AddCallback(function() self:DoAction() end)
	SetOverrideBindingClick(parentFrame, true, key, name, "LeftButton")
end

------------------------------------------------------------------------------

-- this class is used by pre-defined icons in the corner of the Rat page
CyborgMMO_CallbackIcons = {
	new = function(self)
		self.point,
		self.relativeTo,
		self.relativePoint,
		self.xOfs,
		self.yOfs = self:GetPoint()
	--	self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs)
		self.strata = self:GetFrameStrata()
		self.wowObject = WowCallback(string.gsub(self:GetName(), self:GetParent():GetName(), "",1))
		self.wowObject:SetTextures(self)
		self:RegisterForDrag("LeftButton","RightButton")
		self:SetResizable(false)

		self.OnClick = function()
			self.wowObject:DoAction()
		end

		self.DragStart = function()
			self:SetMovable(true)
			self:StartMoving()
			self.isMoving = true
			self:SetFrameStrata("TOOLTIP")
		end

		self.DragStop = function()
			self:SetFrameStrata(self.strata)
			self.isMoving = false
			self:SetMovable(false)
			self:StopMovingOrSizing()

			self:ClearAllPoints()
			self:SetPoint(self.point, self.relativeTo, self.relativePoint, self.xOfs, self.yOfs)
			local x,y = GetCursorPosition()
			CyborgMMO_RatPageController:CallbackDropped(self)
		end

		return self
	end,
}

------------------------------------------------------------------------------

function CyborgMMO_CreateWowObject(type, ...)
	local object,unsupported

	if type == "item" then
		object = WowItem(...)
	elseif type == "macro" then
		object = WowMacro(...)
	elseif type == "spell" then
		object = WowSpell(...)
	elseif type == "companion" then
		-- most likely a legacy mount in an old SavedVariables
		local spellID = ...
		local mountID = FindMountFromSpellID(spellID)
		if mountID then
			object = WowMount(mountID)
		end
	elseif type == "equipmentset" then
		object = WowEquipmentSet(...)
	elseif type == "battlepet" then
		object = WowBattlePet(...)
	elseif type == "mount" then
		object = WowMount(...)
	elseif type == "callback" then
		object = WowCallback(...)
	else
		CyborgMMO_DPrint("unsupported wow object:", type, ...)
		unsupported = true
	end
	if not object and not unsupported then
		CyborgMMO_DPrint("creating "..tostring(type).." object failed:", type, ...)
	end

	return object
end

function CyborgMMO_ClearBinding(key)
	SetOverrideBinding(CyborgMMO_CallbackFactory.Frame, true, key, nil)
end

