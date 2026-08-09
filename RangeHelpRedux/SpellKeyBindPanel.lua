local Addon = RangeHelpRedux
local L = RangeHelpReduxLocale

local panel = Addon:CreateDialogFrame("RangeHelpReduxKeyBindFrame", 300, 420)
Addon.spellKeyBindPanel = panel

local version = GetAddOnMetadata and GetAddOnMetadata("RangeHelpRedux", "Version") or "1.0.0"
panel.titleText:SetText(L.TITLE:format(version))

local KEY_NAMES = { "RHRSPELLKEY1", "RHRSPELLKEY2", "RHRSPELLKEY3", "RHRSPELLKEY4" }
local ROWS = {
	{ key = "oorUi", label = L.STATE_OUTOFRANGE },
	{ key = "rangeUi", label = L.STATE_RANGE },
	{ key = "deadUi", label = L.STATE_DEADZONE },
	{ key = "meleeUi", label = L.STATE_MELEE },
	{ key = "noTargUi", label = L.STATE_NOTARGET },
}

local tempBinds = {}
local rowWidgets = {}
local RefreshRows -- forward declaration, assigned after the rows are built below

--------------------------------------------------------------------------
-- Key selector dropdown - only lists RHRSPELLKEY slots the user has bound
-- a real key to (via the WoW key bindings menu / Bindings.xml)
--------------------------------------------------------------------------

local keyDropdown = CreateFrame("Frame", "RangeHelpReduxKeyDropdown", panel, "UIDropDownMenuTemplate")
keyDropdown:SetPoint("TOP", panel, "TOP", 0, -55)
UIDropDownMenu_SetWidth(keyDropdown, 220)

local keyDropdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
keyDropdownLabel:SetPoint("BOTTOM", keyDropdown, "TOP", 0, 12)
keyDropdownLabel:SetText(L.KS_SELECT_KEY)

keyDropdown:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(L.KS_DROP_INSTR, 1, 1, 1, 1, 1)
end)
keyDropdown:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local function KeyDropdown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(keyDropdown, self.value)
	RefreshRows()
end

local function KeyDropdown_Initialize()
	for _, keyName in ipairs(KEY_NAMES) do
		local key1, key2 = GetBindingKey(keyName)
		if key1 or key2 then
			local info = UIDropDownMenu_CreateInfo()
			info.text = (_G["BINDING_NAME_" .. keyName] or keyName) .. ": "
			if key1 then
				info.text = info.text .. "'" .. key1 .. "' "
			end
			if key2 then
				info.text = info.text .. "'" .. key2 .. "' "
			end
			info.value = keyName
			info.func = KeyDropdown_OnClick
			UIDropDownMenu_AddButton(info)
		end
	end
end
UIDropDownMenu_Initialize(keyDropdown, KeyDropdown_Initialize)

--------------------------------------------------------------------------
-- Five drag targets (one per range state) for the currently selected key
--------------------------------------------------------------------------

local prevRow
for _, row in ipairs(ROWS) do
	local btn = CreateFrame("Button", "RangeHelpRedux" .. row.key .. "Button", panel, "ActionButtonTemplate")
	btn:SetSize(36, 36)
	if prevRow then
		btn:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -12)
	else
		btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 190, -100)
	end
	btn.stateKey = row.key
	btn.icon = _G[btn:GetName() .. "Icon"]
	local hotkey, count, nameText = _G[btn:GetName() .. "HotKey"], _G[btn:GetName() .. "Count"], _G[btn:GetName() .. "Name"]
	if hotkey then
		hotkey:Hide()
	end
	if count then
		count:Hide()
	end
	if nameText then
		nameText:Hide()
	end

	local lbl = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	lbl:SetPoint("RIGHT", btn, "LEFT", -10, 0)
	lbl:SetJustifyH("RIGHT")
	lbl:SetText(row.label)

	local check = Addon:CreateCheckbox(panel, "RangeHelpRedux" .. row.key .. "Check", "")
	check:SetPoint("LEFT", btn, "RIGHT", 15, 0)
	check:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L.KS_CHECK_INSTR, 1, 1, 1, 1, 1)
	end)
	check:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	check:SetScript("OnClick", function(self)
		local keyName = UIDropDownMenu_GetSelectedValue(keyDropdown)
		if keyName and tempBinds[keyName] and tempBinds[keyName][row.key] then
			tempBinds[keyName][row.key].check = self:GetChecked() and true or false
		else
			self:SetChecked(false)
		end
	end)

	btn:RegisterForDrag("LeftButton")
	btn:RegisterForClicks("AnyUp")
	btn:SetScript("OnReceiveDrag", function(self)
		local keyName = UIDropDownMenu_GetSelectedValue(keyDropdown)
		if not keyName then
			ClearCursor()
			return
		end
		local cursorType, a1, a2, a3 = GetCursorInfo()
		local data
		if cursorType == "spell" then
			local _, spellID = GetSpellBookItemInfo(a1, a2)
			spellID = spellID or a3
			if spellID then
				local spellName, _, icon = GetSpellInfo(spellID)
				data = { type = "spell", spellId = spellID, texture = icon, name = spellName, check = false }
			end
		elseif cursorType == "macro" then
			if a1 then
				local macroName, icon = GetMacroInfo(a1)
				data = { type = "macro", macroId = a1, texture = icon, name = macroName, check = false }
			end
		end
		ClearCursor()
		if data then
			tempBinds[keyName] = tempBinds[keyName] or {}
			tempBinds[keyName][self.stateKey] = data
			self.icon:SetTexture(data.texture)
			check:SetChecked(false)
			check:Enable()
		end
	end)
	-- Right-click clears the slot (simpler and more version-stable than
	-- replicating the original's drag-the-icon-back-off-the-button gesture,
	-- which relies on spellbook-index/bookType pickup semantics we don't keep around).
	btn:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "RightButton" then
			local keyName = UIDropDownMenu_GetSelectedValue(keyDropdown)
			if keyName and tempBinds[keyName] then
				tempBinds[keyName][self.stateKey] = nil
				self.icon:SetTexture(nil)
				check:SetChecked(false)
				check:Disable()
			end
		end
	end)
	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local keyName = UIDropDownMenu_GetSelectedValue(keyDropdown)
		local data = keyName and tempBinds[keyName] and tempBinds[keyName][row.key]
		if data then
			GameTooltip:SetText(data.name or "")
		else
			GameTooltip:SetText(L.KS_DRAG_INSTR, 1, 1, 1, 1, 1)
		end
	end)
	btn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	rowWidgets[row.key] = { button = btn, checkbox = check }
	prevRow = btn
end

RefreshRows = function()
	local keyName = UIDropDownMenu_GetSelectedValue(keyDropdown)
	for _, row in ipairs(ROWS) do
		local w = rowWidgets[row.key]
		local data = keyName and tempBinds[keyName] and tempBinds[keyName][row.key]
		if data then
			w.button.icon:SetTexture(data.texture)
			w.checkbox:Enable()
			w.checkbox:SetChecked(data.check)
		else
			w.button.icon:SetTexture(nil)
			w.checkbox:SetChecked(false)
			w.checkbox:Disable()
		end
	end
end

--------------------------------------------------------------------------
-- Apply / Confirm / Cancel
--------------------------------------------------------------------------

local applyBtn = Addon:CreateButton(panel, "RangeHelpReduxKBApplyBtn", 75, 25, L.BTN_APPLY, nil)
applyBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 25, 25)

local confirmBtn = Addon:CreateButton(panel, "RangeHelpReduxKBConfirmBtn", 75, 25, L.BTN_CONFIRM, nil)
confirmBtn:SetPoint("LEFT", applyBtn, "RIGHT", 4, 0)

local cancelBtn = Addon:CreateButton(panel, "RangeHelpReduxKBCancelBtn", 75, 25, L.BTN_CANCEL, nil)
cancelBtn:SetPoint("LEFT", confirmBtn, "RIGHT", 4, 0)

local function ApplyBut()
	for _, keyName in ipairs(KEY_NAMES) do
		if tempBinds[keyName] then
			Addon.db.keyBinds[keyName] = Addon.CopyTable(tempBinds[keyName], {})
		end
	end
end

applyBtn:SetScript("OnClick", ApplyBut)
confirmBtn:SetScript("OnClick", function()
	ApplyBut()
	panel:Hide()
end)
cancelBtn:SetScript("OnClick", function()
	panel:Hide()
end)

panel:SetScript("OnShow", function()
	tempBinds = {}
	for _, keyName in ipairs(KEY_NAMES) do
		tempBinds[keyName] = Addon.CopyTable(Addon.db.keyBinds[keyName] or {}, {})
	end
	UIDropDownMenu_ClearAll(keyDropdown)
	RefreshRows()
end)

function Addon:ToggleSpellKeyBindPanel(forceShow)
	if forceShow or not panel:IsShown() then
		panel:Show()
	else
		panel:Hide()
	end
end

--------------------------------------------------------------------------
-- Runtime dispatcher, invoked directly from Bindings.xml on a real keypress
-- (a hardware event, which is what allows CastSpellByID/RunMacroText below
-- to run - never call this from a timer or other non-hardware-event context)
--------------------------------------------------------------------------

function RangeHelpReduxKeyBindFunc(keyName)
	local db = Addon.db
	if not db then
		return
	end
	local binds = db.keyBinds[keyName]
	if not binds then
		return
	end

	local stateKey
	if UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
		stateKey = Addon.STATE_KEY_BY_NUMBER[Addon.currentState] or "noTargUi"
	else
		stateKey = "noTargUi"
	end

	local data = binds[stateKey]
	if not data then
		return
	end

	if data.check and data.type == "spell" and Addon:HasBuffBySpellId(data.spellId) then
		return
	end

	if data.type == "spell" then
		CastSpellByID(data.spellId)
	elseif data.type == "macro" then
		local body = select(3, GetMacroInfo(data.macroId))
		if body then
			RunMacroText(body)
		end
	end
end
