local Addon = RangeHelpRedux
local L = RangeHelpReduxLocale

local panel = Addon:CreateDialogFrame("RangeHelpReduxUICustomizeFrame", 300, 520)
Addon.uiCustomizePanel = panel

local version = GetAddOnMetadata and GetAddOnMetadata("RangeHelpRedux", "Version") or "1.0.0"
panel.titleText:SetText(L.TITLE:format(version))

local tempColors = {}
local currentStateKey = nil

--------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------

local resizeCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxResizeCheck", L.UI_RESIZABLE)
resizeCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -40)

local moveCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxMoveCheck", L.UI_MOVABLE)
moveCheck:SetPoint("TOPLEFT", resizeCheck, "BOTTOMLEFT", 0, -6)

local fontSlider = CreateFrame("Slider", "RangeHelpReduxFontSlider", panel, "OptionsSliderTemplate")
fontSlider:SetSize(140, 17)
fontSlider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -50)
fontSlider:SetMinMaxValues(0, 3)
fontSlider:SetValueStep(0.1)
if fontSlider.SetObeyStepOnDrag then
	fontSlider:SetObeyStepOnDrag(true)
end
_G[fontSlider:GetName() .. "Text"]:SetText(L.UI_FONT_SIZE)
_G[fontSlider:GetName() .. "Low"]:SetText("0.0")
_G[fontSlider:GetName() .. "High"]:SetText("3.0")

local bgLockCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxBGLockCheck", L.UI_BG_LOCK)
bgLockCheck:SetPoint("TOPLEFT", moveCheck, "BOTTOMLEFT", 0, -30)

local borderLockCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxBorderLockCheck", L.UI_BORDER_LOCK)
borderLockCheck:SetPoint("TOPLEFT", bgLockCheck, "BOTTOMLEFT", 0, -6)

local fontLockCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxFontLockCheck", L.UI_FONT_LOCK)
fontLockCheck:SetPoint("TOPLEFT", borderLockCheck, "BOTTOMLEFT", 0, -6)

local linkCheck = Addon:CreateCheckbox(panel, "RangeHelpReduxLinkCheck", L.UI_LINK_BG_BORDER)
linkCheck:SetPoint("TOPLEFT", fontLockCheck, "BOTTOMLEFT", 0, -6)

-- Deliberately NOT Blizzard's UIDropDownMenuTemplate: driving it taints
-- shared UIDropDownMenu globals, which persist for the session and can end
-- up blocking unrelated protected calls elsewhere. Self-contained picker.
local stateDropdown = CreateFrame("Button", "RangeHelpReduxStateDropdown", panel, "UIPanelButtonTemplate")
stateDropdown:SetSize(130, 22)
stateDropdown:SetPoint("TOP", linkCheck, "BOTTOM", 50, -30)
stateDropdown:SetText(L.UI_RANGE_STATE)

local stateDropdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
stateDropdownLabel:SetPoint("BOTTOMLEFT", stateDropdown, "TOPLEFT", 20, 0)
stateDropdownLabel:SetText(L.UI_RANGE_STATE)

local stateDropdownList = CreateFrame("Frame", "RangeHelpReduxStateDropdownList", panel, "BackdropTemplate")
stateDropdownList:SetPoint("TOP", stateDropdown, "BOTTOM", 0, -2)
stateDropdownList:SetWidth(160)
stateDropdownList:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
stateDropdownList:SetBackdropColor(0, 0, 0, 1)
stateDropdownList:SetFrameStrata("DIALOG")
stateDropdownList:Hide()

local selectedStateValue
local ColorSetup -- forward declaration, assigned below

local function SetSelectedStateValue(value, label)
	selectedStateValue = value
	stateDropdown:SetText(label or L.UI_RANGE_STATE)
	stateDropdownList:Hide()
	ColorSetup(value)
end

local function GetSelectedStateValue()
	return selectedStateValue
end

local STATE_DROPDOWN_ENTRIES = {
	{ text = L.STATE_MELEE, value = "meleeUi" },
	{ text = L.STATE_DEADZONE, value = "deadUi" },
	{ text = L.STATE_RANGE, value = "rangeUi" },
	{ text = L.STATE_OUTOFRANGE, value = "oorUi" },
	{ text = L.STATE_ALL, value = "all" },
}

local prevStateBtn
for i, e in ipairs(STATE_DROPDOWN_ENTRIES) do
	local sBtn = CreateFrame("Button", "RangeHelpReduxStateDropdownButton" .. i, stateDropdownList, "UIPanelButtonTemplate")
	sBtn:SetSize(140, 20)
	if prevStateBtn then
		sBtn:SetPoint("TOP", prevStateBtn, "BOTTOM", 0, -2)
	else
		sBtn:SetPoint("TOP", stateDropdownList, "TOP", 0, -10)
	end
	sBtn:SetText(e.text)
	sBtn:SetScript("OnClick", function()
		SetSelectedStateValue(e.value, e.text)
	end)
	prevStateBtn = sBtn
end
stateDropdownList:SetHeight(#STATE_DROPDOWN_ENTRIES * 22 + 16)

stateDropdown:SetScript("OnClick", function()
	if stateDropdownList:IsShown() then
		stateDropdownList:Hide()
	else
		stateDropdownList:Show()
	end
end)

local bgColorBtn = Addon:CreateButton(panel, "RangeHelpReduxBGColorBtn", 160, 25, L.UI_BG_COLOUR, nil)
bgColorBtn:SetPoint("TOP", stateDropdown, "BOTTOM", 30, -10)

local borderColorBtn = Addon:CreateButton(panel, "RangeHelpReduxBorderColorBtn", 160, 25, L.UI_BORDER_COLOUR, nil)
borderColorBtn:SetPoint("TOP", bgColorBtn, "BOTTOM", 0, 0)

local fontColorBtn = Addon:CreateButton(panel, "RangeHelpReduxFontColorBtn", 160, 25, L.UI_FONT_COLOUR, nil)
fontColorBtn:SetPoint("TOP", borderColorBtn, "BOTTOM", 0, 0)

local stateTextEdit = Addon:CreateEditBox(panel, "RangeHelpReduxStateTextEdit", 120, 20)
stateTextEdit:SetPoint("TOP", fontColorBtn, "BOTTOM", 0, -10)

local applyBtn = Addon:CreateButton(panel, "RangeHelpReduxUIApplyBtn", 75, 25, L.BTN_APPLY, nil)
applyBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 25, 45)

local confirmBtn = Addon:CreateButton(panel, "RangeHelpReduxUIConfirmBtn", 75, 25, L.BTN_CONFIRM, nil)
confirmBtn:SetPoint("LEFT", applyBtn, "RIGHT", 4, 0)

local cancelBtn = Addon:CreateButton(panel, "RangeHelpReduxUICancelBtn", 75, 25, L.BTN_CANCEL, nil)
cancelBtn:SetPoint("LEFT", confirmBtn, "RIGHT", 4, 0)

local defaultBtn = Addon:CreateButton(panel, "RangeHelpReduxUIDefaultBtn", 100, 25, L.UI_DEFAULT, nil)
defaultBtn:SetPoint("TOP", applyBtn, "BOTTOM", 90, -10)

local resetLocBtn = Addon:CreateButton(panel, "RangeHelpReduxResetLocBtn", 200, 25, L.UI_RESET_FRAME_LOC, nil)
resetLocBtn:SetPoint("BOTTOM", applyBtn, "TOP", 60, 10)

--------------------------------------------------------------------------
-- Behaviour
--------------------------------------------------------------------------

local function ApplyPreviewColor(key)
	local frame = Addon.statusFrame
	local c = tempColors[currentStateKey]
	if key == "bg" then
		frame:SetBackdropColor(c.bg.r, c.bg.g, c.bg.b, c.bg.a)
		if linkCheck:GetChecked() then
			frame:SetBackdropBorderColor(c.bg.r, c.bg.g, c.bg.b, c.bg.a)
		end
	elseif key == "border" then
		frame:SetBackdropBorderColor(c.border.r, c.border.g, c.border.b, c.border.a)
	elseif key == "font" then
		frame.text:SetTextColor(c.font.r, c.font.g, c.font.b)
	end
end

local function OpenColorPicker(key)
	local c = tempColors[currentStateKey][key]
	local info = {}
	info.r, info.g, info.b = c.r, c.g, c.b
	info.hasOpacity = (key ~= "font")
	info.opacity = c.a
	info.swatchFunc = function()
		c.r, c.g, c.b = ColorPickerFrame:GetColorRGB()
		ApplyPreviewColor(key)
	end
	if info.hasOpacity then
		info.opacityFunc = function()
			c.a = ColorPickerFrame:GetColorAlpha()
			ApplyPreviewColor(key)
		end
	end
	info.cancelFunc = function(previous)
		c.r, c.g, c.b = previous.r, previous.g, previous.b
		if previous.opacity then
			c.a = previous.opacity
		end
		ApplyPreviewColor(key)
	end
	ColorPickerFrame:SetupColorPickerAndShow(info)
end

bgColorBtn:SetScript("OnClick", function()
	OpenColorPicker("bg")
end)
borderColorBtn:SetScript("OnClick", function()
	OpenColorPicker("border")
end)
fontColorBtn:SetScript("OnClick", function()
	OpenColorPicker("font")
end)

ColorSetup = function(value)
	value = value or GetSelectedStateValue()
	if not value then
		return
	end
	currentStateKey = value
	bgColorBtn:Disable()
	borderColorBtn:Disable()
	fontColorBtn:Disable()

	local frame = Addon.statusFrame
	if value ~= "all" then
		local c = tempColors[value]
		if not bgLockCheck:GetChecked() then
			bgColorBtn:Enable()
			frame:SetBackdropColor(c.bg.r, c.bg.g, c.bg.b, c.bg.a)
		else
			frame:SetBackdropColor(tempColors.all.bg.r, tempColors.all.bg.g, tempColors.all.bg.b, tempColors.all.bg.a)
		end
		if not borderLockCheck:GetChecked() and not linkCheck:GetChecked() then
			borderColorBtn:Enable()
			frame:SetBackdropBorderColor(c.border.r, c.border.g, c.border.b, c.border.a)
		elseif bgLockCheck:GetChecked() and linkCheck:GetChecked() then
			frame:SetBackdropBorderColor(tempColors.all.bg.r, tempColors.all.bg.g, tempColors.all.bg.b, tempColors.all.bg.a)
		elseif borderLockCheck:GetChecked() then
			frame:SetBackdropBorderColor(tempColors.all.border.r, tempColors.all.border.g, tempColors.all.border.b, tempColors.all.border.a)
		elseif linkCheck:GetChecked() then
			frame:SetBackdropBorderColor(c.bg.r, c.bg.g, c.bg.b, c.bg.a)
		end
		if not fontLockCheck:GetChecked() then
			fontColorBtn:Enable()
			frame.text:SetTextColor(c.font.r, c.font.g, c.font.b)
		else
			frame.text:SetTextColor(tempColors.all.font.r, tempColors.all.font.g, tempColors.all.font.b)
		end
		frame.text:SetText(c.text)
		stateTextEdit:SetText(c.text)
		stateTextEdit:EnableKeyboard(true)
	else
		if bgLockCheck:GetChecked() then
			bgColorBtn:Enable()
			frame:SetBackdropColor(tempColors.all.bg.r, tempColors.all.bg.g, tempColors.all.bg.b, tempColors.all.bg.a)
		else
			frame:SetBackdropColor(0, 0, 0, 0)
		end
		if borderLockCheck:GetChecked() and not linkCheck:GetChecked() then
			borderColorBtn:Enable()
			frame:SetBackdropBorderColor(tempColors.all.border.r, tempColors.all.border.g, tempColors.all.border.b, tempColors.all.border.a)
		elseif bgLockCheck:GetChecked() and linkCheck:GetChecked() then
			frame:SetBackdropBorderColor(tempColors.all.bg.r, tempColors.all.bg.g, tempColors.all.bg.b, tempColors.all.bg.a)
		else
			frame:SetBackdropBorderColor(0, 0, 0, 0)
		end
		if fontLockCheck:GetChecked() then
			fontColorBtn:Enable()
			frame.text:SetTextColor(tempColors.all.font.r, tempColors.all.font.g, tempColors.all.font.b)
			tempColors.all.text = L.UI_FONT_COLOUR
		else
			tempColors.all.text = ""
		end
		frame.text:SetText(tempColors.all.text)
		stateTextEdit:EnableKeyboard(false)
		stateTextEdit:SetText("")
	end
end

stateTextEdit:SetScript("OnTextChanged", function(self)
	local value = GetSelectedStateValue()
	if value and value ~= "all" then
		Addon.statusFrame.text:SetText(self:GetText())
		tempColors[value].text = self:GetText()
	end
end)

fontSlider:SetScript("OnValueChanged", function(self)
	Addon.statusFrame.fontFrame:SetScale(self:GetValue())
end)

resizeCheck:SetScript("OnClick", function(self)
	Addon.db.ui.resize = self:GetChecked() and true or false
	Addon:ApplyStatusFrameLocks()
end)
moveCheck:SetScript("OnClick", function(self)
	Addon.db.ui.move = self:GetChecked() and true or false
	Addon:ApplyStatusFrameLocks()
end)
bgLockCheck:SetScript("OnClick", function()
	ColorSetup()
end)
borderLockCheck:SetScript("OnClick", function()
	ColorSetup()
end)
fontLockCheck:SetScript("OnClick", function()
	ColorSetup()
end)
linkCheck:SetScript("OnClick", function(self)
	if self:GetChecked() then
		borderLockCheck:SetChecked(false)
		borderLockCheck:Disable()
	else
		borderLockCheck:Enable()
	end
	ColorSetup()
end)

local function ResetPreviewFrame()
	local frame = Addon.statusFrame
	frame:Show()
	frame.text:SetText(L.UI_CUSTOMISE_PREVIEW)
	frame.text:SetTextColor(1, 1, 1)
	frame:SetBackdropColor(1, 1, 1, 1)
	frame:SetBackdropBorderColor(1, 1, 1, 1)
end

local function ApplyBut()
	local db = Addon.db.ui
	db.fontHeight = fontSlider:GetValue()
	db.lockBack = bgLockCheck:GetChecked() and true or false
	db.lockBorder = borderLockCheck:GetChecked() and true or false
	db.lockFont = fontLockCheck:GetChecked() and true or false
	db.linkBackBorder = linkCheck:GetChecked() and true or false
	db.resize = resizeCheck:GetChecked() and true or false
	db.move = moveCheck:GetChecked() and true or false

	for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
		Addon.CopyTable(tempColors[key], db.states[key])
	end

	if db.linkBackBorder then
		for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
			Addon.CopyTable(tempColors[key].bg, db.states[key].border)
		end
	end
	if db.lockBack then
		for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
			Addon.CopyTable(tempColors.all.bg, db.states[key].bg)
		end
	end
	if db.lockBack and db.linkBackBorder then
		for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
			Addon.CopyTable(tempColors.all.bg, db.states[key].border)
		end
	end
	if db.lockBorder then
		for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
			Addon.CopyTable(tempColors.all.border, db.states[key].border)
		end
	end
	if db.lockFont then
		for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
			Addon.CopyTable(tempColors.all.font, db.states[key].font)
		end
	end

	Addon:ApplyStatusFrameFontHeight()
	Addon:ApplyStatusFrameLocks()
end

applyBtn:SetScript("OnClick", ApplyBut)
confirmBtn:SetScript("OnClick", function()
	ApplyBut()
	panel:Hide()
end)
cancelBtn:SetScript("OnClick", function()
	panel:Hide()
end)
resetLocBtn:SetScript("OnClick", function()
	Addon:ResetStatusFramePosition()
end)
defaultBtn:SetScript("OnClick", function()
	bgLockCheck:SetChecked(false)
	borderLockCheck:SetChecked(false)
	borderLockCheck:Enable()
	fontLockCheck:SetChecked(true)
	linkCheck:SetChecked(true)
	borderLockCheck:Disable()
	fontSlider:SetValue(1.0)

	local defaults = Addon:GetDefaults().ui.states
	tempColors = {}
	for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
		tempColors[key] = Addon.CopyTable(defaults[key], {})
	end
	tempColors.all = Addon.CopyTable(defaults.meleeUi, {})
	tempColors.all.text = L.STATE_ALL

	bgColorBtn:Disable()
	borderColorBtn:Disable()
	fontColorBtn:Disable()
	SetSelectedStateValue(nil)
	stateDropdownList:Hide()
	currentStateKey = nil
	ResetPreviewFrame()
	stateTextEdit:SetText("")
end)

panel:SetScript("OnShow", function()
	local db = Addon.db.ui
	resizeCheck:SetChecked(db.resize)
	moveCheck:SetChecked(db.move)
	bgLockCheck:SetChecked(db.lockBack)
	borderLockCheck:SetChecked(db.lockBorder)
	fontLockCheck:SetChecked(db.lockFont)
	linkCheck:SetChecked(db.linkBackBorder)
	if db.linkBackBorder then
		borderLockCheck:Disable()
	else
		borderLockCheck:Enable()
	end
	fontSlider:SetValue(db.fontHeight)

	bgColorBtn:Disable()
	borderColorBtn:Disable()
	fontColorBtn:Disable()
	SetSelectedStateValue(nil)
	stateDropdownList:Hide()
	currentStateKey = nil

	tempColors = {}
	for _, key in ipairs(Addon.STATUS_STATE_KEYS) do
		tempColors[key] = Addon.CopyTable(db.states[key], {})
	end
	tempColors.all = Addon.CopyTable(db.states.meleeUi, {})
	tempColors.all.text = L.STATE_ALL

	ResetPreviewFrame()
	stateTextEdit:SetText("")
	stateTextEdit:EnableKeyboard(false)
end)

panel:SetScript("OnHide", function()
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	end
	Addon:RefreshStatusFrameDisplay()
end)

function Addon:ToggleUICustomizePanel(forceShow)
	if forceShow or not panel:IsShown() then
		panel:Show()
	else
		panel:Hide()
	end
end
