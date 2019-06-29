--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: OptionView.lua
--~ Description: The code for the Option page in the UI, not much here because we dont have many options. Probably could refactor.
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

CyborgMMO_OptionView = {
	new = function(self)
		self.name = CyborgMMO_StringTable.CyborgMMO_OptionPageTitle
		self.default = CyborgMMO_SetDefaultSettings
		InterfaceOptions_AddCategory(self)
		return self
	end,
}

local lastButton = nil

function CyborgMMO_BindButton(name)
	lastButton = name
	local index = CyborgMMO_GetButtonIndex(name)
	local mode = 1
	while index > 13 do
		mode = mode + 1
		index = index - 13
	end
	local buttonStr = CyborgMMO_StringTable[("CyborgMMO_OptionPageRebindMouseRow"..index.."Name")]

	CyborgMMO_BindingFrameButtonName:SetText(buttonStr.." Mode "..mode)
	CyborgMMO_BindingFrameKey:SetText(CyborgMMO_StringTable["CyborgMMO_CurrentBinding"].." "..CyborgMMO_ProfileKeyBindings[CyborgMMO_GetButtonIndex(lastButton)])
	CyborgMMO_BindingFrame:Show()
end

function CyborgMMO_SetBindingButtonText(name)
	local binding = CyborgMMO_ProfileKeyBindings[CyborgMMO_GetButtonIndex(name)]
	getglobal(name):SetText(binding)
end

function CyborgMMO_GetButtonIndex(name)
	local row,mode = name:match('Row(.)Mode(.)')
	row = tonumber(row, 16)
	mode = tonumber(mode)
	local modeStr = string.sub(name, mode +1,mode+2)
	local rowStr = string.sub(name, row-1,row-1)
	return (mode-1) * 13 + row
end

function CyborgMMO_ShowProfileTooltip(self)
	if not CyborgMMO_ModeDetected then
		GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
		GameTooltip:SetText(CyborgMMO_StringTable["CyborgMMO_ToolTipLine1"], nil, nil, nil, nil, 1)
		GameTooltip:AddLine(nil, 0.8, 1.0, 0.8)
		GameTooltip:AddLine(CyborgMMO_StringTable["CyborgMMO_ToolTipLine2"], 0.8, 1.0, 0.8)
		GameTooltip:AddLine(nil, 0.8, 1.0, 0.8)
		GameTooltip:AddLine(CyborgMMO_StringTable["CyborgMMO_ToolTipLine3"], 0.8, 1.0, 0.8)
		GameTooltip:AddLine(CyborgMMO_StringTable["CyborgMMO_ToolTipLine4"], 0.8, 1.0, 0.8)
		GameTooltip:AddLine(CyborgMMO_StringTable["CyborgMMO_ToolTipLine5"], 0.8, 1.0, 0.8)
		GameTooltip:AddLine(nil, 0.8, 1.0, 0.8)
		GameTooltip:AddLine(CyborgMMO_StringTable["CyborgMMO_ToolTipLine6"], 0.8, 1.0, 0.8)
		GameTooltip:Show()
	end
end

function CyborgMMO_HideProfileTooltip(self)
	GameTooltip:Hide()
end

function CyborgMMO_SetNewKeybind(keyOrButton)
	CyborgMMO_ProfileKeyBindings[CyborgMMO_GetButtonIndex(lastButton)] = keyOrButton
	CyborgMMO_SetBindingButtonText(lastButton)
	CyborgMMO_BindingFrame:Hide()
	CyborgMMO_RatPageModel:LoadData()
end

function CyborgMMO_BindingFrameOnKeyDown(self, keyOrButton)
	if keyOrButton == "ESCAPE" then
		CyborgMMO_BindingFrame:Hide()
		return
	end

	if GetBindingFromClick(keyOrButton) == "SCREENSHOT" then
		RunBinding("SCREENSHOT")
		return
	end

	local keyPressed = keyOrButton

	if keyPressed == "UNKNOWN" then
		return
	end

	-- Convert the mouse button names
	if keyPressed == "LeftButton" then
		keyPressed = "BUTTON1"
	elseif keyPressed == "RightButton" then
		keyPressed = "BUTTON2"
	elseif keyPressed == "MiddleButton" then
		keyPressed = "BUTTON3"
	elseif keyPressed == "Button4" then
		keyPressed = "BUTTON4"
	elseif keyOrButton == "Button5" then
		keyPressed = "BUTTON5"
	elseif keyPressed == "Button6" then
		keyPressed = "BUTTON6"
	elseif keyOrButton == "Button7" then
		keyPressed = "BUTTON7"
	elseif keyPressed == "Button8" then
		keyPressed = "BUTTON8"
	elseif keyOrButton == "Button9" then
		keyPressed = "BUTTON9"
	elseif keyPressed == "Button10" then
		keyPressed = "BUTTON10"
	elseif keyOrButton == "Button11" then
		keyPressed = "BUTTON11"
	elseif keyPressed == "Button12" then
		keyPressed = "BUTTON12"
	elseif keyOrButton == "Button13" then
		keyPressed = "BUTTON13"
	elseif keyPressed == "Button14" then
		keyPressed = "BUTTON14"
	elseif keyOrButton == "Button15" then
		keyPressed = "BUTTON15"
	elseif keyPressed == "Button16" then
		keyPressed = "BUTTON16"
	elseif keyOrButton == "Button17" then
		keyPressed = "BUTTON17"
	elseif keyPressed == "Button18" then
		keyPressed = "BUTTON18"
	elseif keyOrButton == "Button19" then
		keyPressed = "BUTTON19"
	elseif keyPressed == "Button20" then
		keyPressed = "BUTTON20"
	elseif keyOrButton == "Button21" then
		keyPressed = "BUTTON21"
	elseif keyPressed == "Button22" then
		keyPressed = "BUTTON22"
	elseif keyOrButton == "Button23" then
		keyPressed = "BUTTON23"
	elseif keyPressed == "Button24" then
		keyPressed = "BUTTON24"
	elseif keyOrButton == "Button25" then
		keyPressed = "BUTTON25"
	elseif keyPressed == "Button26" then
		keyPressed = "BUTTON26"
	elseif keyOrButton == "Button27" then
		keyPressed = "BUTTON27"
	elseif keyPressed == "Button28" then
		keyPressed = "BUTTON28"
	elseif keyOrButton == "Button29" then
		keyPressed = "BUTTON29"
	elseif keyPressed == "Button30" then
		keyPressed = "BUTTON30"
	elseif keyOrButton == "Button31" then
		keyPressed = "BUTTON31"
	end

	if keyPressed == "LSHIFT" or
	   keyPressed == "RSHIFT" or
	   keyPressed == "LCTRL" or
	   keyPressed == "RCTRL" or
	   keyPressed == "LALT" or
	   keyPressed == "RALT" then
		return
	end
	if IsShiftKeyDown() then
		keyPressed = "SHIFT-"..keyPressed
	end
	if IsControlKeyDown() then
		keyPressed = "CTRL-"..keyPressed
	end
	if IsAltKeyDown() then
		keyPressed = "ALT-"..keyPressed
	end
	if keyPressed == "BUTTON1" or keyPressed == "BUTTON2" then
		return
	end

	CyborgMMO_SetNewKeybind(keyPressed)
end
