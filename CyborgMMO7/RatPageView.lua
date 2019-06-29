--~ Warcraft Plugin for Cyborg MMO7
--~ Filename: RatPageView.lua
--~ Description: Interaction logic for the RatPage
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

CyborgMMO_RatPageView = {
	new = function(self)
		CyborgMMO_DPrint("new Rat Page View")
		for _,child in ipairs(self:GetChildren()) do
			child.Register()
		end

		self.SlotClicked = function(slot)
			CyborgMMO_DPrint("View Recieved Click")
			CyborgMMO_RatPageController:SlotClicked(slot)
		end

		self.ModeClicked = function(mode)
			CyborgMMO_DPrint("View Recieved Click")
			CyborgMMO_RatPageController:ModeClicked(mode)
		end

		self.RegisterMode = function()
			CyborgMMO_DPrint("ModeRegistered")
		end

		self.RegisterSlot = function()
			CyborgMMO_DPrint("SlotRegistered")
		end

		return self
	end,
}

CyborgMMO_RatQuickPageView = {
	new = function(self)
		for _,child in ipairs(self:GetChildren()) do
			child.Register()
		end

		self.SlotClicked = function(slot)
			CyborgMMO_RatPageController:SlotClicked(slot)
		end

		return self
	end,
}

-- Slot Class --
CyborgMMO_SlotView = {
	new = function(self, parent)
		self._assignedWowObject = nil
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		self.Id = self:GetID()
		CyborgMMO_RatPageModel:AddObserver(self)
		self.UnCheckedTexture = self:GetNormalTexture()

		-- Object Method --
		self.Clicked = function()
			self:GetParent().SlotClicked(self)

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		--	GameTooltip:SetText(self:GetID())
		end

		self.Update = function(data, activeMode)
			local icon = _G[self:GetName().."Icon"]
			if data[activeMode][self.Id] then
				self:SetChecked(true)
				icon:SetTexture(data[activeMode][self.Id].texture)
			else
				icon:SetTexture(nil)
				self:SetChecked(false)
			end


		end

		return self
	end,
}

CyborgMMO_SlotMiniView = {
	new = function(self, parent)
		self._assignedWowObject = nil
		self.Id = self:GetID()
		CyborgMMO_RatPageModel:AddObserver(self)
		self.UnCheckedTexture = self:GetNormalTexture()

		self.Update = function(data, activeMode)
			local icon = _G[self:GetName().."Icon"]
			if data[activeMode][self.Id] then
				self:SetChecked(true)

				icon:SetTexture(data[activeMode][self.Id].texture)
				icon:SetAlpha(.5)
			else
				icon:SetTexture(nil)
				self:SetChecked(false)
			end
		end

		return self
	end,
}


-- ModeButton --
CyborgMMO_ModeView = {
	new = function(self)
		self.Id = self:GetID()
		self.Name = self:GetName()
		CyborgMMO_RatPageModel:AddObserver(self)
		if self.Id ~= 1 then
			self:Hide()
		end

		self.Clicked = function()
			local nextMode
			if self.Id == 1 then
				nextMode = getglobal("Mode2")
			elseif self.Id == 2 then
				nextMode = getglobal("Mode3")
			else
				nextMode = getglobal("Mode1")
			end
			self:GetParent().ModeClicked(nextMode)
		end

		self.Update = function(data, activeMode)
			if self.Id == activeMode then
				self:Show()
			else
				self:Hide()
			end
		end

		return self
	end,
}
