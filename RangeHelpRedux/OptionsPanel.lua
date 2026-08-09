local Addon = RangeHelpRedux
local L = RangeHelpReduxLocale

local panel = Addon:CreateDialogFrame("RangeHelpReduxOptionsFrame", 300, 510)
Addon.optionsPanel = panel

local version = GetAddOnMetadata and GetAddOnMetadata("RangeHelpRedux", "Version") or "1.0.0"
panel.titleText:SetText(L.TITLE:format(version))

--------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------

local function label(parent, text, anchorFrame, x, y)
	local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", x, y)
	fs:SetJustifyH("LEFT")
	fs:SetText(text)
	return fs
end

label(panel, L.OPT_MELEE_SPELL, panel, 24, -40)
local meleeSpellEdit = Addon:CreateEditBox(panel, "RangeHelpReduxMeleeSpellEdit", 150, 20)
meleeSpellEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -40)

label(panel, L.OPT_RANGE_SPELL, panel, 24, -70)
local rangeSpellEdit = Addon:CreateEditBox(panel, "RangeHelpReduxRangeSpellEdit", 150, 20)
rangeSpellEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -70)

label(panel, L.OPT_MELEE_BAR, panel, 24, -100)
local meleeBarEdit = Addon:CreateEditBox(panel, "RangeHelpReduxMeleeBarEdit", 40, 20)
meleeBarEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -100)
meleeBarEdit:SetNumeric(true)

label(panel, L.OPT_RANGE_BAR, panel, 24, -130)
local rangeBarEdit = Addon:CreateEditBox(panel, "RangeHelpReduxRangeBarEdit", 40, 20)
rangeBarEdit:SetPoint("TOPLEFT", panel, "TOPLEFT", 130, -130)
rangeBarEdit:SetNumeric(true)

local lockCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxLockCheck", L.OPT_LOCK_COMBAT_BAR)
lockCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -165)

local hideCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxHideCheck", L.OPT_HIDE_RANGE_INFO)
hideCheck:SetPoint("TOPLEFT", lockCheck, "BOTTOMLEFT", 0, -6)

local deadZoneCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxDeadZoneCheck", L.OPT_DEADZONE_MELEE_PAGE)
deadZoneCheck:SetPoint("TOPLEFT", hideCheck, "BOTTOMLEFT", 0, -6)

local enableBarSwitchCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxEnableBarSwitchCheck", L.OPT_ENABLE_BARSWITCH)
enableBarSwitchCheck:SetPoint("TOPLEFT", deadZoneCheck, "BOTTOMLEFT", 0, -6)

local enableCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxEnableCheck", L.OPT_ENABLE_RANGEHELP)
enableCheck:SetPoint("TOPLEFT", enableBarSwitchCheck, "BOTTOMLEFT", 0, -6)

local custSpellBtn = Addon:CreateButton(panel, "RangeHelpReduxCustSpellBtn", 250, 25, L.BTN_ENABLE_CUST_SPELL, nil)
custSpellBtn:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 4, -20)

local applyBtn = Addon:CreateButton(panel, "RangeHelpReduxApplyBtn", 75, 25, L.BTN_APPLY, nil)
applyBtn:SetPoint("TOPLEFT", custSpellBtn, "BOTTOMLEFT", 4, -20)

local confirmBtn = Addon:CreateButton(panel, "RangeHelpReduxConfirmBtn", 75, 25, L.BTN_CONFIRM, nil)
confirmBtn:SetPoint("LEFT", applyBtn, "RIGHT", 4, 0)

local cancelBtn = Addon:CreateButton(panel, "RangeHelpReduxCancelBtn", 75, 25, L.BTN_CANCEL, nil)
cancelBtn:SetPoint("LEFT", confirmBtn, "RIGHT", 4, 0)

local custUIBtn = Addon:CreateButton(panel, "RangeHelpReduxCustUIBtn", 250, 25, L.BTN_CUSTOMISE_UI, nil)
custUIBtn:SetPoint("TOP", panel, "TOP", 0, -419)

local keyBindBtn = Addon:CreateButton(panel, "RangeHelpReduxKeyBindBtn", 250, 25, L.BTN_SPELL_KEY_BIND, nil)
keyBindBtn:SetPoint("TOP", custUIBtn, "BOTTOM", 0, -10)

--------------------------------------------------------------------------
-- Behaviour
--------------------------------------------------------------------------

local function RefreshSpellDisplay()
	local db = Addon.db
	if db.customSpellEnabled then
		meleeSpellEdit:EnableKeyboard(true)
		rangeSpellEdit:EnableKeyboard(true)
		custSpellBtn:SetText(L.BTN_DISABLE_CUST_SPELL)
		meleeSpellEdit:SetText(db.meleeSpellName)
		rangeSpellEdit:SetText(db.rangeSpellName)
	else
		meleeSpellEdit:EnableKeyboard(false)
		rangeSpellEdit:EnableKeyboard(false)
		custSpellBtn:SetText(L.BTN_ENABLE_CUST_SPELL)
		meleeSpellEdit:SetText(db.meleeSlot ~= -1 and L.SPELL_OK or L.SPELL_NOTFOUND)
		rangeSpellEdit:SetText(db.rangeSlot ~= -1 and L.SPELL_OK or L.SPELL_NOTFOUND)
	end
end

local function ApplyBut()
	local db = Addon.db

	if not enableCheck:GetChecked() then
		db.enabled = false
		Addon:OnEnabledChanged()
		return true
	end
	db.enabled = true

	local meleeText = db.customSpellEnabled and meleeSpellEdit:GetText() or nil
	local rangeText = db.customSpellEnabled and rangeSpellEdit:GetText() or nil
	local barSwitchEnabled = enableBarSwitchCheck:GetChecked() and true or false

	if (db.customSpellEnabled and ((meleeText or "") == "" or (rangeText or "") == ""))
		or (barSwitchEnabled and (meleeBarEdit:GetText() == "" or rangeBarEdit:GetText() == "")) then
		Addon:Print(L.ERR_FILL_FIELDS)
		return false
	end

	local mp, rp = db.meleeBarPage, db.rangeBarPage
	if barSwitchEnabled then
		mp = math.abs(tonumber(meleeBarEdit:GetText()) or 0)
		rp = math.abs(tonumber(rangeBarEdit:GetText()) or 0)
		if mp < 1 or mp > NUM_ACTIONBAR_PAGES or rp < 1 or rp > NUM_ACTIONBAR_PAGES then
			Addon:Print(L.ERR_INVALID_PAGE:format(NUM_ACTIONBAR_PAGES))
			return false
		end
	end

	if db.customSpellEnabled then
		db.meleeSpellName = meleeText
		db.rangeSpellName = rangeText
	end
	db.meleeBarPage = mp
	db.rangeBarPage = rp
	db.lockDuringCombat = lockCheck:GetChecked() and true or false
	db.hideRangeInfo = hideCheck:GetChecked() and true or false
	db.switchAtDeadZone = deadZoneCheck:GetChecked() and true or false
	db.enableBarSwitch = barSwitchEnabled

	Addon:OnEnabledChanged()
	RefreshSpellDisplay()
	return true
end

applyBtn:SetScript("OnClick", ApplyBut)
confirmBtn:SetScript("OnClick", function()
	if ApplyBut() then
		panel:Hide()
	end
end)
cancelBtn:SetScript("OnClick", function()
	panel:Hide()
end)
custUIBtn:SetScript("OnClick", function()
	Addon:ToggleUICustomizePanel(true)
end)
keyBindBtn:SetScript("OnClick", function()
	Addon:ToggleSpellKeyBindPanel(true)
end)
custSpellBtn:SetScript("OnClick", function()
	local db = Addon.db
	if db.customSpellEnabled then
		db.customSpellEnabled = false
		db.meleeSpellName = L.MELEE_SPELLS[1]
		db.rangeSpellName = L.RANGE_SPELLS[1]
		Addon:UpdateSlots()
	else
		db.customSpellEnabled = true
	end
	RefreshSpellDisplay()
end)

panel:SetScript("OnShow", function()
	local db = Addon.db
	local _, englishClass = UnitClass("player")
	if UnitLevel("player") < 12 and englishClass == "HUNTER" then
		Addon:Print(L.LEVEL_NOT_MET)
	end
	Addon:UpdateSlots()
	RefreshSpellDisplay()
	meleeBarEdit:SetText(tostring(db.meleeBarPage))
	rangeBarEdit:SetText(tostring(db.rangeBarPage))
	lockCheck:SetChecked(db.lockDuringCombat)
	hideCheck:SetChecked(db.hideRangeInfo)
	deadZoneCheck:SetChecked(db.switchAtDeadZone)
	enableBarSwitchCheck:SetChecked(db.enableBarSwitch)
	enableCheck:SetChecked(db.enabled)
end)

function Addon:ToggleOptionsPanel()
	if panel:IsShown() then
		panel:Hide()
	else
		panel:Show()
	end
end
