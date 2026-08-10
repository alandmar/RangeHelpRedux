local Addon = RangeHelpRedux

--------------------------------------------------------------------------
-- The movable/resizable range status display (equivalent of the original's
-- TargetRangeInfo frame).
--------------------------------------------------------------------------

function Addon:CreateStatusFrame()
	local frame = CreateFrame("Frame", "RangeHelpReduxStatusFrame", UIParent, "BackdropTemplate")
	self.statusFrame = frame

	frame:SetSize(135, 35)
	frame:SetPoint("TOP", UIParent, "TOP", 0, -20)
	frame:SetToplevel(true)
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:SetResizable(true)
	if frame.SetResizeBounds then
		frame:SetResizeBounds(60, 20, 400, 150)
	elseif frame.SetMinResize then
		frame:SetMinResize(60, 20)
		frame:SetMaxResize(400, 150)
	end
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})

	local fontFrame = CreateFrame("Frame", nil, frame)
	fontFrame:SetAllPoints(true)
	local text = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetAllPoints(true)
	frame.fontFrame = fontFrame
	frame.text = text

	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnMouseDown", function(self)
		self.mouseX, self.mouseY = GetCursorPosition()
	end)
	frame:SetScript("OnDragStart", function(self)
		local db = Addon.db
		if not db then
			return
		end
		if db.ui.resize then
			local uiScale = UIParent:GetScale()
			local hotLeft = self:GetLeft() * uiScale + 7
			local hotTop = self:GetTop() * uiScale - 7
			local hotBottom = self:GetBottom() * uiScale + 7
			local hotRight = self:GetRight() * uiScale - 7
			local mx, my = self.mouseX or 0, self.mouseY or 0
			if mx < hotLeft and my > hotTop then
				self:StartSizing("TOPLEFT")
			elseif mx > hotRight and my > hotTop then
				self:StartSizing("TOPRIGHT")
			elseif mx > hotRight and my < hotBottom then
				self:StartSizing("BOTTOMRIGHT")
			elseif mx < hotLeft and my < hotBottom then
				self:StartSizing("BOTTOMLEFT")
			elseif mx > hotRight then
				self:StartSizing("RIGHT")
			elseif mx < hotLeft then
				self:StartSizing("LEFT")
			elseif my > hotTop then
				self:StartSizing("TOP")
			elseif my < hotBottom then
				self:StartSizing("BOTTOM")
			elseif db.ui.move then
				self:StartMoving()
			end
		elseif db.ui.move then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		Addon:SaveStatusFramePosition()
	end)

	frame:Hide()
	return frame
end

function Addon:SaveStatusFramePosition()
	local frame = self.statusFrame
	local point, _, relativePoint, x, y = frame:GetPoint(1)
	self.db.ui.point = { point, "UIParent", relativePoint, x, y }
end

function Addon:ApplyStatusFramePosition()
	local frame = self.statusFrame
	local p = self.db.ui.point
	frame:ClearAllPoints()
	frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
end

function Addon:ResetStatusFramePosition()
	self.db.ui.point = { "TOP", "UIParent", "TOP", 0, -20 }
	self:ApplyStatusFramePosition()
end

function Addon:ApplyStatusFrameFontHeight()
	self.statusFrame.fontFrame:SetScale(self.db.ui.fontHeight)
end

function Addon:ApplyStatusFrameLocks()
	local db = self.db.ui
	self.statusFrame:EnableMouse(db.move or db.resize)
end

function Addon:ApplyStatusFrameConfig()
	self:ApplyStatusFramePosition()
	self:ApplyStatusFrameFontHeight()
	self:ApplyStatusFrameLocks()
end

function Addon:ShowStatusFrame()
	if not self.statusFrame:IsVisible() then
		self.statusFrame:Show()
	end
end

function Addon:HideStatusFrame()
	self.statusFrame:Hide()
end

function Addon:SetStatusFrameState(stateKey)
	local state = self.db.ui.states[stateKey]
	if not state then
		return
	end
	local frame = self.statusFrame
	frame:SetBackdropColor(state.bg.r, state.bg.g, state.bg.b, state.bg.a)
	frame:SetBackdropBorderColor(state.border.r, state.border.g, state.border.b, state.border.a)
	frame.text:SetTextColor(state.font.r, state.font.g, state.font.b)
	frame.text:SetText(state.text)
end

-- Best-guess yard estimate for the "Range" state, via LibRangeCheck-3.0 (same
-- technique TargetRange/!Ranges-style addons use: bracket the target's
-- distance between the nearest known spell/item range checkers). WoW doesn't
-- expose exact distance to the API, so this is a bracket, not a precise
-- number - purely informational, no protected calls involved.
function Addon:UpdateRangeDistanceText()
	local state = self.db.ui.states.rangeUi
	if not state or not self.RC then
		return
	end
	local minRange, maxRange = self.RC:GetRange("target")
	local text = state.text
	if minRange then
		if maxRange then
			text = string.format("%s (%d-%dyd)", state.text, minRange, maxRange)
		else
			text = string.format("%s (%d+yd)", state.text, minRange)
		end
	end
	self.statusFrame.text:SetText(text)
end

function Addon:SetStatusFrameRaw(text, r, g, b)
	local frame = self.statusFrame
	frame:SetBackdropColor(1, 1, 1, 1)
	frame:SetBackdropBorderColor(1, 1, 1, 1)
	frame.text:SetTextColor(r, g, b)
	frame.text:SetText(text)
end

Addon:CreateStatusFrame()
