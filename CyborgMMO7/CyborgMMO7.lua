--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: CyborgMMO7.lua
--~ Description: Plugin entry point, String tables and other generic crap that I could not think to put anywhere else.
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

local RAT7 = {
	BUTTONS = 13,
	MODES = 3,
	SHIFT = 0,
}

local function toboolean(value)
	if value then
		return true
	else
		return false
	end
end

function CyborgMMO_LoadStrings(self)
--	CyborgMMO_DPrint("LoadStrings("..self:GetName()..") = "..CyborgMMO_StringTable[self:GetName()])
	self:SetText(CyborgMMO_StringTable[self:GetName()])
end

local VarsLoaded = false
local AsyncDataLoaded = false
local EnteredWorld = false
local BindingsLoaded = false
local SettingsLoaded = false
local SaveName = GetRealmName().."_"..UnitName("player")
local Settings = nil
local AutoClosed = false
CyborgMMO_ModeDetected = false


function CyborgMMO_MiniMapButtonReposition(angle)
	local r = 80
	local dx = r * math.cos(angle)
	local dy = r * math.sin(angle)
	CyborgMMO_MiniMapButton:ClearAllPoints()
	CyborgMMO_MiniMapButton:SetPoint("CENTER", "Minimap", "CENTER", dx, dy)
	if SettingsLoaded then
		Settings.MiniMapButtonAngle = angle
	end
end


function CyborgMMO_MiniMapButtonOnUpdate()
	local xpos,ypos = GetCursorPosition()
	local xmap,ymap = Minimap:GetCenter()

	xpos = xpos / UIParent:GetScale() - xmap
	ypos = ypos / UIParent:GetScale() - ymap

	local angle = math.atan2(ypos, xpos)
	CyborgMMO_MiniMapButtonReposition(angle)
end


function CyborgMMO_MouseModeChange(mode)
	local MiniMapTexture = CyborgMMO_MiniMapButtonIcon
	local MiniMapGlowTexture = CyborgMMO_MiniMapButtonIconGlow
	local OpenButtonTexture = CyborgMMO_OpenButtonPageOpenMainForm:GetNormalTexture()
	local OpenButtonGlowTexture = CyborgMMO_OpenButtonPageOpenMainForm:GetHighlightTexture()
	if mode == 1 then
		MiniMapTexture:SetVertexColor(1,0,0,1)
		MiniMapGlowTexture:SetVertexColor(1,0.26,0.26,.75)
		OpenButtonTexture:SetVertexColor(1,0,0,0.75)
		OpenButtonGlowTexture:SetVertexColor(1,0.26,0.26,0.50)
	elseif mode == 2 then
		MiniMapTexture:SetVertexColor(0.07,0.22,1,1)
		MiniMapGlowTexture:SetVertexColor(0.13,0.56,1,.75)
		OpenButtonTexture:SetVertexColor(0.07,0.22,1,0.75)
		OpenButtonGlowTexture:SetVertexColor(0.13,0.56,1,0.5)
	elseif mode == 3 then
		MiniMapTexture:SetVertexColor(0.52,0.08,0.89,1)
		MiniMapGlowTexture:SetVertexColor(0.67,0.31,0.85,.75)
		OpenButtonTexture:SetVertexColor(0.52,0.08,0.89,0.75)
		OpenButtonGlowTexture:SetVertexColor(0.67,0.31,0.85,0.5)
	end
end

function CyborgMMO_GetSaveData()
	assert(VarsLoaded)
	if not CyborgMMO7SaveData then
		CyborgMMO7SaveData = {}
	end
	return CyborgMMO7SaveData
end

function CyborgMMO_SetRatSaveData(objects)
	assert(VarsLoaded)
	local specIndex
	if Settings.PerSpecBindings then
		specIndex = GetSpecialization()
	else
		specIndex = 0
	end
	local ratData = {}
	for mode=1,RAT7.MODES do
		ratData[mode] = {}
		for button=1,RAT7.BUTTONS do
			if objects[mode][button] then
				ratData[mode][button] = objects[mode][button]:SaveData()
			end
		end
	end
	local saveData = CyborgMMO_GetSaveData()
	if not saveData.Rat then saveData.Rat = {} end
	saveData.Rat[specIndex] = ratData
end

function CyborgMMO_GetRatSaveData()
	local specIndex
	if Settings.PerSpecBindings then
		specIndex = GetSpecialization()
	else
		specIndex = 0
	end
	CyborgMMO_DPrint("returning rat data for spec:", specIndex, GetSpecialization())
	local saveData = CyborgMMO_GetSaveData()
	return saveData.Rat and saveData.Rat[specIndex]
end

------------------------------------------------------------------------------

local PreloadFrame
local step_timeout = 1
local total_timeout = 15

local function PreloadFrameUpdate(self, dt)
	self.step_timeout = self.step_timeout - dt
	self.total_timeout = self.total_timeout - dt
	if self.step_timeout < 0 then
		local items = 0
		-- check items
		for itemID in pairs(self.itemIDs) do
			if GetItemInfo(itemID) then
				self.itemIDs[itemID] = nil
			else
				items = items + 1
			end
		end
		CyborgMMO_DPrint("PreloadFrameUpdate step", self.total_timeout, "items:", items)
		if self.total_timeout < 0 or next(self.itemIDs)==nil then
			-- when done destroy the frame and throw an event for further loading
			self:Hide()
			self:SetParent(nil)
			PreloadFrame = nil
			CyborgMMO_Event("CYBORGMMO_ASYNC_DATA_LOADED")
		else
			self.step_timeout = step_timeout
		end
	end
end

local function PreLoad(data)
	-- create ID sets to sync
	local itemIDs = {}
	local petIDs = {}

	-- gather all needed IDs (and trigger sync while doing so)
	if data.Rat then
		for spec,specData in pairs(data.Rat) do
			for mode=1,RAT7.MODES do
				for button=1,RAT7.BUTTONS do
					local buttonData = specData[mode] and specData[mode][button]
					if buttonData then
						if buttonData.type=='item' then
							local itemID = buttonData.detail
							if not GetItemInfo(itemID) then
								itemIDs[itemID] = true
							end
						elseif buttonData.type=='battlepet' then
							local petID = buttonData.detail
							if not C_PetJournal.GetPetInfoByPetID(petID) then
								petIDs[petID] = true
							end
						end
					end
				end
			end
		end
	end

	-- create frame for regular updates
	PreloadFrame = CreateFrame("Frame")
	PreloadFrame.itemIDs = itemIDs
	PreloadFrame.petIDs = petIDs
	PreloadFrame.total_timeout = total_timeout
	PreloadFrame.step_timeout = step_timeout
	PreloadFrame:SetScript("OnUpdate", PreloadFrameUpdate)
	PreloadFrame:Show()
end

------------------------------------------------------------------------------

function CyborgMMO_Event(event, ...)
	if event == "VARIABLES_LOADED" then
		VarsLoaded = true
		-- create root table if necessary
		if not CyborgMMO7SaveData then
			CyborgMMO7SaveData = {}
		end
		PreLoad(CyborgMMO7SaveData)
	elseif event == "CYBORGMMO_ASYNC_DATA_LOADED" then
		AsyncDataLoaded = true
	elseif event == "PLAYER_ENTERING_WORLD" then
		EnteredWorld = true
	elseif event == "PLAYER_REGEN_DISABLED" then
		if CyborgMMO_IsOpen() then
			AutoClosed = true
			CyborgMMO_Close()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if AutoClosed then
			AutoClosed = false
			CyborgMMO_Open()
		end
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		-- force a re-loading of bindings
		BindingsLoaded = false
	else
		CyborgMMO_DPrint("Event is "..tostring(event))
	end

	-- Fire Loading if and only if the player is in the world and vars are loaded
	if not SettingsLoaded and VarsLoaded and AsyncDataLoaded and EnteredWorld then
		local data = CyborgMMO_GetSaveData()

		Settings = data.Settings
		if not Settings then
			Settings = {}
			data.Settings = Settings
		end
		if Settings.MiniMapButton == nil then
			Settings.MiniMapButton = true
		end
		if Settings.CyborgButton == nil then
			Settings.CyborgButton = true
		end
		if Settings.PerSpecBindings == nil then
			Settings.PerSpecBindings = false
		end
		if not Settings.Cyborg then
			Settings.Cyborg = 0.75
		end
		if not Settings.Plugin then
			Settings.Plugin = 0.75
		end
		if not Settings.MiniMapButtonAngle then
			Settings.MiniMapButtonAngle = math.rad(150)
		end

		-- Reload Slider values:
		CyborgMMO_SetOpenButtonSize(Settings.Cyborg)
		CyborgMMO_SetMainPageSize(Settings.Plugin)

		CyborgMMO_SetMiniMapButton(Settings.MiniMapButton)
		CyborgMMO_MiniMapButtonReposition(Settings.MiniMapButtonAngle)
		CyborgMMO_SetCyborgHeadButton(Settings.CyborgButton)
		CyborgMMO_SetPerSpecBindings(Settings.PerSpecBindings)
		CyborgMMO_MouseModeChange(1)

		SettingsLoaded = true
	end

	-- load data AFTER the settings, because PerSpecBindings may affect what's loaded
	if not BindingsLoaded and VarsLoaded and AsyncDataLoaded and EnteredWorld then
		CyborgMMO_RatPageModel:LoadData()

		CyborgMMO_SetupModeCallbacks(1)
		CyborgMMO_SetupModeCallbacks(2)
		CyborgMMO_SetupModeCallbacks(3)

		BindingsLoaded = true
	end
end

function CyborgMMO_SetDefaultSettings()
	CyborgMMO_OpenButtonPageOpenMainForm:ClearAllPoints()
	CyborgMMO_MainPage:ClearAllPoints()
	CyborgMMO_OpenButtonPageOpenMainForm:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
	CyborgMMO_MainPage:SetPoint("LEFT", UIParent, "LEFT", 0, 0)

	CyborgMMO_SetOpenButtonSize(0.75)
	CyborgMMO_SetMainPageSize(0.75)
	CyborgMMO_SetMiniMapButton(true)
	CyborgMMO_SetCyborgHeadButton(true)
end

function CyborgMMO_SetDefaultKeyBindings()
	for mode=1,RAT7.MODES do
		for button=1,RAT7.BUTTONS do
			local k = (mode - 1) * RAT7.BUTTONS + button
			CyborgMMO_ProfileKeyBindings[k] = CyborgMMO_DefaultKeyBindings[k]
			CyborgMMO_SetBindingButtonText(string.format("CyborgMMO_OptionPageRebindMouseRow%XMode%d", button, mode))
		end
	end
end

function CyborgMMO_SetupModeCallbacks(modeNum)
	local fn = function()
		CyborgMMO_ModeDetected = true
		CyborgMMO_MouseModeChange(modeNum)
		CyborgMMO_RatPageModel:SetMode(modeNum)
	end

	local buttonFrame,parentFrame,name = CyborgMMO_CallbackFactory:AddCallback(fn)
	SetOverrideBindingClick(parentFrame, true, CyborgMMO_Mode[modeNum], name, "LeftButton")
end

function CyborgMMO_Loaded()
	CyborgMMO_MainPage:RegisterEvent("VARIABLES_LOADED")
	CyborgMMO_MainPage:RegisterEvent("PLAYER_ENTERING_WORLD")
	CyborgMMO_MainPage:RegisterEvent("PLAYER_REGEN_DISABLED")
	CyborgMMO_MainPage:RegisterEvent("PLAYER_REGEN_ENABLED")
	CyborgMMO_MainPage:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
end

function CyborgMMO_Close()
	CyborgMMO_MainPage:Hide()
end

function CyborgMMO_Open()
	CyborgMMO_MainPage:Show()
	CyborgMMO_RatQuickPage:Hide()
end

function CyborgMMO_IsOpen()
	return CyborgMMO_MainPage:IsVisible()
end

function CyborgMMO_Toggle()
	if CyborgMMO_IsOpen() then
		CyborgMMO_Close()
	else
		CyborgMMO_Open()
	end
end

function CyborgMMO_GetDebugFrame()
	for i=1,NUM_CHAT_WINDOWS do
		local windowName = GetChatWindowInfo(i);
		if windowName == "Debug" then
			return getglobal("ChatFrame" .. i)
		end
	end
end

local log_prefix = "|cffff6666".."CyborgMMO".."|r:"

function CyborgMMO_DPrint(...)
	local debugframe = CyborgMMO_GetDebugFrame()
	if debugframe then
		local t = {log_prefix, ...}
		for i=1,select('#', ...)+1 do
			t[i] = tostring(t[i])
		end
		debugframe:AddMessage(table.concat(t, ' '))
	end
end

function CyborgMMO_SetMainPageSize(percent)
	CyborgMMO_MainPage:SetScale(percent)
	CyborgMMO_OptionPagePluginSizeSlider:SetValue(percent)
	if SettingsLoaded then
		Settings.Plugin = percent
	end
end

function CyborgMMO_SetOpenButtonSize(percent)
	CyborgMMO_OpenButtonPage:SetScale(percent)
	CyborgMMO_OptionPageCyborgSizeSlider:SetValue(percent)
	if SettingsLoaded then
		Settings.Cyborg = percent
	end
end

function CyborgMMO_SetCyborgHeadButton(visible)
	if visible then
		CyborgMMO_OpenButtonPage:Show()
	else
		CyborgMMO_OpenButtonPage:Hide()
	end
	CyborgMMO_OptionPageCyborgButton:SetChecked(visible)
	if SettingsLoaded then
		Settings.CyborgButton = toboolean(visible)
	end
end

function CyborgMMO_SetMiniMapButton(visible)
	if visible then
		CyborgMMO_MiniMapButton:Show()
	else
		CyborgMMO_MiniMapButton:Hide()
	end
	CyborgMMO_OptionPageMiniMapButton:SetChecked(visible)
	if SettingsLoaded then
		Settings.MiniMapButton = toboolean(visible)
	end
end

function CyborgMMO_SetPerSpecBindings(perSpec)
	CyborgMMO_OptionPagePerSpecBindings:SetChecked(perSpec)
	if SettingsLoaded then
		Settings.PerSpecBindings = toboolean(perSpec)
	end
	-- reload bindings if necessary (AFTER altering the setting)
	if BindingsLoaded then
		CyborgMMO_RatPageModel:LoadData()
	end
end

