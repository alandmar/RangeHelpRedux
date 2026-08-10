RangeHelpReduxLocale = {}
local L = RangeHelpReduxLocale

-- English (default / fallback for any locale without an override below)
L.MELEE_SPELLS = { "Wing Clip", "Disengage" }
L.RANGE_SPELLS = { "Auto Shot", "Arcane Shot", "Concussive Shot", "Serpent Sting", "Aimed Shot" }

L.TITLE = "RangeHelp Redux v%s"

L.OPT_MELEE_SPELL = "Melee Spell"
L.OPT_RANGE_SPELL = "Range Spell"
L.OPT_HIDE_RANGE_INFO = "Hide Range Info Frame"
L.OPT_ENABLE_RANGEHELP = "Enable RangeHelp"

L.BTN_APPLY = "Apply"
L.BTN_CONFIRM = "Confirm"
L.BTN_CANCEL = "Cancel"
L.BTN_CUSTOMISE_UI = "Customise UI"
L.BTN_ENABLE_CUST_SPELL = "Enable Custom Range Check Spells"
L.BTN_DISABLE_CUST_SPELL = "Disable Custom Range Check Spells"

L.SPELL_OK = "OK"
L.SPELL_NOTFOUND = "Not found"
L.LEVEL_NOT_MET = "This addon can only be used properly when your character is equipped with LEVEL 12 or above spells."

L.ERR_FILL_FIELDS = "Please fill in all fields to proceed."

L.UI_RESIZABLE = "Resizable"
L.UI_MOVABLE = "Movable"
L.UI_FONT_SIZE = "Font Size"
L.UI_BG_LOCK = "Background Colour Lock"
L.UI_BORDER_LOCK = "Border Colour Lock"
L.UI_FONT_LOCK = "Font Colour Lock"
L.UI_LINK_BG_BORDER = "Link Background and Border Colour"
L.UI_TEXT = "Text"
L.UI_RANGE_STATE = "Range State"
L.UI_BG_COLOUR = "Background Colour"
L.UI_BORDER_COLOUR = "Border Colour"
L.UI_FONT_COLOUR = "Font Colour"
L.UI_DEFAULT = "Default"
L.UI_RESET_FRAME_LOC = "Reset Frame Location"
L.UI_CUSTOMISE_PREVIEW = "UI Customise"

L.STATE_MELEE = "Melee"
L.STATE_DEADZONE = "Dead Zone"
L.STATE_RANGE = "Range"
L.STATE_OUTOFRANGE = "Out of Range"
L.STATE_ALL = "All State"
L.STATE_NOTARGET = "No Target"
L.STATE_NOTSET = "not set"

local locale = GetLocale()

if locale == "deDE" then
	-- German text. Thanks to Shamane for the original RangeHelp translation this is adapted from.
	L.MELEE_SPELLS = { "Zurechtstutzen", "R\195\188ckzug" }
	L.RANGE_SPELLS = { "Automatischer Schuss", "Arkaner Schuss", "Ersch\195\188tternder Schuss", "Schlangenbiss", "Gezielter Schuss" }

	L.OPT_MELEE_SPELL = "Nahkampf-Zauber"
	L.OPT_RANGE_SPELL = "Fernkampf-Zauber"
	L.OPT_HIDE_RANGE_INFO = "Reichweiten-Info ausblenden"
	L.OPT_ENABLE_RANGEHELP = "RangeHelp aktivieren"

	L.BTN_APPLY = "Anwenden"
	L.BTN_CONFIRM = "Best\195\164tigen"
	L.BTN_CANCEL = "Abbrechen"
	L.BTN_CUSTOMISE_UI = "UI anpassen"
	L.BTN_ENABLE_CUST_SPELL = "Manuelle Zaubereingabe aktivieren"
	L.BTN_DISABLE_CUST_SPELL = "Automatische Zaubererkennung nutzen"

	L.SPELL_OK = "OK"
	L.SPELL_NOTFOUND = "Nicht gefunden"
	L.LEVEL_NOT_MET = "Dieses Addon funktioniert nur richtig, wenn dein Charakter Zauber der Stufe 12 oder h\195\182her besitzt."

	L.ERR_FILL_FIELDS = "Bitte f\195\188lle alle Felder aus."

	L.UI_RESIZABLE = "Gr\195\182\195\159e ver\195\164nderbar"
	L.UI_MOVABLE = "Verschiebbar"
	L.UI_FONT_SIZE = "Schriftgr\195\182\195\159e"
	L.UI_BG_LOCK = "Hintergrundfarbe sperren"
	L.UI_BORDER_LOCK = "Rahmenfarbe sperren"
	L.UI_FONT_LOCK = "Schriftfarbe sperren"
	L.UI_LINK_BG_BORDER = "Hintergrund- und Rahmenfarbe verkn\195\188pfen"
	L.UI_TEXT = "Text"
	L.UI_RANGE_STATE = "Zone"
	L.UI_BG_COLOUR = "Hintergrundfarbe"
	L.UI_BORDER_COLOUR = "Rahmenfarbe"
	L.UI_FONT_COLOUR = "Schriftfarbe"
	L.UI_DEFAULT = "Standard"
	L.UI_RESET_FRAME_LOC = "Position zur\195\188cksetzen"
	L.UI_CUSTOMISE_PREVIEW = "UI Anpassung"

	L.STATE_MELEE = "Nahkampf"
	L.STATE_DEADZONE = "Tote Zone"
	L.STATE_RANGE = "Fernkampf"
	L.STATE_OUTOFRANGE = "Au\195\159er Reichweite"
	L.STATE_ALL = "Alle Zonen"
	L.STATE_NOTARGET = "Kein Ziel"
	L.STATE_NOTSET = "nicht gesetzt"
elseif locale == "frFR" then
	-- French text. Thanks to Mips and Corwin Whitehorn for the original RangeHelp translation this is adapted from.
	L.MELEE_SPELLS = { "Coupure d'ailes", "D\195\169sengagement" }
	L.RANGE_SPELLS = { "Tir automatique", "Tir des arcanes", "Trait de choc", "Morsure de serpent", "Tir vis\195\169" }

	L.OPT_MELEE_SPELL = "Sort de m\195\170l\195\169e"
	L.OPT_RANGE_SPELL = "Sort \195\160 distance"
	L.OPT_HIDE_RANGE_INFO = "Cacher le cadre d'info de port\195\169e"
	L.OPT_ENABLE_RANGEHELP = "Activer RangeHelp"

	L.BTN_APPLY = "Appliquer"
	L.BTN_CONFIRM = "Confirmer"
	L.BTN_CANCEL = "Annuler"
	L.BTN_CUSTOMISE_UI = "Personnaliser l'interface"
	L.BTN_ENABLE_CUST_SPELL = "Activer la saisie manuelle des sorts"
	L.BTN_DISABLE_CUST_SPELL = "Activer la d\195\169tection automatique"

	L.SPELL_OK = "OK"
	L.SPELL_NOTFOUND = "Non trouv\195\169"
	L.LEVEL_NOT_MET = "Cet addon ne fonctionne correctement que si votre personnage dispose de sorts de niveau 12 ou plus."

	L.ERR_FILL_FIELDS = "Veuillez compl\195\169ter tous les champs."

	L.UI_RESIZABLE = "Redimensionnable"
	L.UI_MOVABLE = "D\195\169pla\195\167able"
	L.UI_FONT_SIZE = "Taille de la police"
	L.UI_BG_LOCK = "Verrouiller la couleur de fond"
	L.UI_BORDER_LOCK = "Verrouiller la couleur du contour"
	L.UI_FONT_LOCK = "Verrouiller la couleur de la police"
	L.UI_LINK_BG_BORDER = "Lier la couleur de fond et du contour"
	L.UI_TEXT = "Texte"
	L.UI_RANGE_STATE = "\195\137tat de port\195\169e"
	L.UI_BG_COLOUR = "Couleur de fond"
	L.UI_BORDER_COLOUR = "Couleur du contour"
	L.UI_FONT_COLOUR = "Couleur de la police"
	L.UI_DEFAULT = "D\195\169faut"
	L.UI_RESET_FRAME_LOC = "R\195\169initialiser l'emplacement"
	L.UI_CUSTOMISE_PREVIEW = "Personnalisation"

	L.STATE_MELEE = "M\195\170l\195\169e"
	L.STATE_DEADZONE = "Zone morte"
	L.STATE_RANGE = "\195\128 port\195\169e"
	L.STATE_OUTOFRANGE = "Hors de port\195\169e"
	L.STATE_ALL = "Tous \195\169tats"
	L.STATE_NOTARGET = "Pas de cible"
	L.STATE_NOTSET = "non d\195\169fini"
end
