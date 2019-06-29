--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: CalbackFactory.lua
--~ Description: Creates lua callbacks that can be executed from a user keycombination
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

local CallbackFactory_methods = {}
local CallbackFactory_mt = {__index=CallbackFactory_methods}

local function CallbackFactory()
	local self = {}
	self.Frame = CreateFrame("Frame", "CallbackFactoryFrame", UIParent)
	self.Callbacks = {}
	self.Id = 1

	setmetatable(self, CallbackFactory_mt)

	return self
end

function CallbackFactory_methods:AddCallback(fn)
	local name = "Button"..self.Id
	self.Callbacks[name] = CreateFrame("Button", name, self.Frame)
	self.Callbacks[name]:SetScript("OnClick", fn)
	self.Id = self.Id + 1
	return self.Callbacks[name],self.Frame,name
end

function CallbackFactory_methods:RemoveCallback(name)
	self.Callbacks[name] = nil
end

local callbacks = {}

function CallbackFactory_methods:GetCallback(name)
	return callbacks[name]
end

------------------------------------------------------------------------------

function callbacks.Map()
	ToggleWorldMap()
end

function callbacks.CharacterPage()
	ToggleCharacter("PaperDollFrame")
end

function callbacks.Spellbook()
	ToggleFrame(SpellBookFrame)
end

function callbacks.Macros()
	if MacroFrame and MacroFrame:IsShown() and MacroFrame:IsVisible() then
		HideUIPanel(MacroFrame)
	else
		ShowMacroFrame()
	end
end

function callbacks.QuestLog()
	ToggleQuestLog()
end

function callbacks.Achievement()
	ToggleAchievementFrame()
end

function callbacks.Inventory()
	ToggleAllBags()
end

------------------------------------------------------------------------------

CyborgMMO_CallbackFactory = CallbackFactory()

