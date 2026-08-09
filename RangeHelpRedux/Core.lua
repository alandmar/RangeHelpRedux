local ADDON_NAME = ...
local L = RangeHelpReduxLocale

RangeHelpRedux = RangeHelpRedux or {}
local Addon = RangeHelpRedux

Addon.MAX_BAR = 120
Addon.DEAD_ZONE_INTERACT_INDEX = 4 -- CheckInteractDistance index 4 == ~28yd "follow" distance
Addon.STATE_ORDER = { notarget = 0, meleeUi = 1, rangeUi = 2, deadUi = 3, oorUi = 4 }

--------------------------------------------------------------------------
-- Small utilities shared by every panel
--------------------------------------------------------------------------

function Addon.CopyTable(src, dst)
	dst = dst or {}
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = Addon.CopyTable(v, type(dst[k]) == "table" and dst[k] or {})
		else
			dst[k] = v
		end
	end
	return dst
end

local function mergeDefaults(dst, defaults)
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			if type(dst[k]) ~= "table" then
				dst[k] = {}
			end
			mergeDefaults(dst[k], v)
		elseif dst[k] == nil then
			dst[k] = v
		end
	end
end

function Addon:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99RangeHelp Redux|r: " .. tostring(msg))
end

--------------------------------------------------------------------------
-- Shared widget builders used by every panel (Options / UICustomize / SpellKeyBind)
--------------------------------------------------------------------------

function Addon:CreateDialogFrame(name, width, height)
	local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
	frame:SetSize(width, height)
	frame:SetPoint("TOP", UIParent, "TOP", 0, -40)
	frame:SetToplevel(true)
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 11, top = 11, bottom = 11 },
	})
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()

	local titleBg = frame:CreateTexture(nil, "ARTWORK")
	titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	titleBg:SetSize(256, 64)
	titleBg:SetPoint("TOP", frame, "TOP", 0, 12)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	title:SetPoint("TOP", titleBg, "TOP", 0, -14)
	title:SetWidth(220)
	title:SetJustifyH("CENTER")
	frame.titleText = title

	tinsert(UISpecialFrames, name)
	return frame
end

function Addon:CreateCheckbox(parent, name, labelText)
	local check = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	check:SetSize(24, 24)
	local label = check:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("LEFT", check, "RIGHT", 2, 0)
	label:SetJustifyH("LEFT")
	label:SetText(labelText)
	check.label = label
	return check
end

function Addon:CreateEditBox(parent, name, width, height)
	local edit = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	edit:SetSize(width, height or 20)
	edit:SetAutoFocus(false)
	edit:SetScript("OnEnterPressed", edit.ClearFocus)
	edit:SetScript("OnEscapePressed", edit.ClearFocus)
	return edit
end

function Addon:CreateButton(parent, name, width, height, text, onClick)
	local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	btn:SetSize(width, height)
	btn:SetText(text)
	btn:SetScript("OnClick", onClick)
	return btn
end

--------------------------------------------------------------------------
-- Saved variable defaults
--------------------------------------------------------------------------

local function stateColorDefaults(r, g, b, text)
	return {
		bg = { r = r, g = g, b = b, a = 0.7 },
		border = { r = r, g = g, b = b, a = 0.7 },
		font = { r = 1, g = 1, b = 1 },
		text = text,
	}
end

function Addon:GetDefaults()
	local _, englishClass = UnitClass("player")
	return {
		enabled = (englishClass == "HUNTER"),
		hideRangeInfo = false,
		customSpellEnabled = false,
		meleeSpellName = L.MELEE_SPELLS[1],
		rangeSpellName = L.RANGE_SPELLS[1],
		meleeSlot = -1,
		rangeSlot = -1,
		ui = {
			resize = false,
			move = true,
			lockBack = false,
			lockBorder = false,
			lockFont = true,
			linkBackBorder = true,
			fontHeight = 1.0,
			point = { "TOP", "UIParent", "TOP", 0, -20 },
			states = {
				meleeUi = stateColorDefaults(0, 1, 0, L.STATE_MELEE),
				deadUi = stateColorDefaults(1, 0.5, 0, L.STATE_DEADZONE),
				rangeUi = stateColorDefaults(0, 0, 1, L.STATE_RANGE),
				oorUi = stateColorDefaults(1, 0, 0, L.STATE_OUTOFRANGE),
			},
		},
		keyBinds = {
			RHRSPELLKEY1 = {},
			RHRSPELLKEY2 = {},
			RHRSPELLKEY3 = {},
			RHRSPELLKEY4 = {},
		},
	}
end

--------------------------------------------------------------------------
-- Slot resolution (finds which action bar slot holds the melee/range spell)
--------------------------------------------------------------------------

local function scanForSpell(candidateNames)
	for _, candidate in ipairs(candidateNames) do
		if candidate and candidate ~= "" then
			local lowerCandidate = candidate:lower()
			for slot = 1, Addon.MAX_BAR do
				local actionType, id = GetActionInfo(slot)
				if actionType == "spell" and id then
					local name = GetSpellInfo(id)
					if name and name:lower() == lowerCandidate then
						return slot
					end
				end
			end
		end
	end
	return -1
end

function Addon:UpdateSlots()
	local db = self.db
	local meleeCandidates = { db.meleeSpellName }
	for _, n in ipairs(L.MELEE_SPELLS) do
		meleeCandidates[#meleeCandidates + 1] = n
	end
	local rangeCandidates = { db.rangeSpellName }
	for _, n in ipairs(L.RANGE_SPELLS) do
		rangeCandidates[#rangeCandidates + 1] = n
	end

	db.meleeSlot = scanForSpell(meleeCandidates)
	db.rangeSlot = scanForSpell(rangeCandidates)
end

--------------------------------------------------------------------------
-- Buff check (used before casting a key-bound spell, if requested)
--------------------------------------------------------------------------

function Addon:HasBuffBySpellId(spellId)
	if not spellId then
		return false
	end
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, id = UnitAura("player", i, "HELPFUL")
		if not name then
			break
		end
		if id == spellId then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------
-- Main range/state update loop
--------------------------------------------------------------------------

Addon.currentState = 0 -- 0 notarget, 1 melee, 2 range, 3 dead zone, 4 out of range

Addon.STATUS_STATE_KEYS = { "meleeUi", "deadUi", "rangeUi", "oorUi" }
Addon.ALL_STATE_KEYS = { "meleeUi", "deadUi", "rangeUi", "oorUi", "noTargUi" }
local STATE_KEY_BY_NUMBER = { [1] = "meleeUi", [2] = "rangeUi", [3] = "deadUi", [4] = "oorUi" }
Addon.STATE_KEY_BY_NUMBER = STATE_KEY_BY_NUMBER

function Addon:RefreshStatusFrameDisplay()
	local db = self.db
	if not db.enabled or self.currentState == 0 then
		self:HideStatusFrame()
		return
	end
	if db.meleeSlot ~= -1 and db.rangeSlot ~= -1 then
		self:SetStatusFrameState(STATE_KEY_BY_NUMBER[self.currentState])
	end
end

function Addon:UpdateState()
	local db = self.db
	if not db.enabled then
		return
	end

	if not (UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target")) then
		if self.currentState ~= 0 then
			self:HideStatusFrame()
			self.currentState = 0
		end
		return
	end

	if not db.hideRangeInfo then
		self:ShowStatusFrame()
	end

	if db.meleeSlot == -1 then
		self:SetStatusFrameRaw(L.OPT_MELEE_SPELL .. " " .. L.STATE_NOTSET, 0.5, 0.5, 0.5)
		return
	elseif db.rangeSlot == -1 then
		self:SetStatusFrameRaw(L.OPT_RANGE_SPELL .. " " .. L.STATE_NOTSET, 0.5, 0.5, 0.5)
		return
	end

	local newState
	if IsActionInRange(db.meleeSlot, "target") == true then
		newState = 1
	else
		if IsActionInRange(db.rangeSlot, "target") == true then
			newState = 2
		elseif CheckInteractDistance("target", Addon.DEAD_ZONE_INTERACT_INDEX) then
			newState = 3
		else
			newState = 4
		end
	end

	local prevState = self.currentState

	if newState ~= prevState then
		self:SetStatusFrameState(STATE_KEY_BY_NUMBER[newState])
		self.currentState = newState
	end
end

--------------------------------------------------------------------------
-- Event driven init / update loop
--------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
Addon.eventFrame = eventFrame

local elapsedAccum = 0
local UPDATE_INTERVAL = 0.1

local function OnUpdate(_, elapsed)
	elapsedAccum = elapsedAccum + elapsed
	if elapsedAccum < UPDATE_INTERVAL then
		return
	end
	elapsedAccum = 0
	Addon:UpdateState()
end

local function OnEvent(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON_NAME then
			return
		end
		RangeHelpReduxDB = RangeHelpReduxDB or Addon:GetDefaults()
		mergeDefaults(RangeHelpReduxDB, Addon:GetDefaults())
		Addon.db = RangeHelpReduxDB
		eventFrame:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		Addon:ApplyStatusFrameConfig()
		if Addon.db.enabled then
			eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			Addon:UpdateSlots()
		end
		eventFrame:SetScript("OnUpdate", OnUpdate)
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		Addon:UpdateSlots()
	end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnEvent)

--------------------------------------------------------------------------
-- Called by OptionsPanel whenever the enable-rangehelp checkbox flips
--------------------------------------------------------------------------

function Addon:OnEnabledChanged()
	if self.db.enabled then
		eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
		self:UpdateSlots()
	else
		eventFrame:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
		self:HideStatusFrame()
		self.currentState = 0
	end
end

--------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------

SLASH_RANGEHELPREDUX1 = "/rangehelprx"
SLASH_RANGEHELPREDUX2 = "/rhr"
SlashCmdList["RANGEHELPREDUX"] = function(msg)
	msg = msg and msg:lower():match("^%s*(.-)%s*$") or ""
	if msg == "ui" then
		Addon:ToggleUICustomizePanel()
	elseif msg == "spell" then
		Addon:ToggleSpellKeyBindPanel()
	else
		Addon:ToggleOptionsPanel()
	end
end
