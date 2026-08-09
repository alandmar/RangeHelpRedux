# RangeHelp Redux

A ground-up rewrite of the classic *RangeHelp* addon for World of Warcraft, rebuilt on current APIs for **Classic Era**, **TBC Classic**, and **Wrath Classic** — the three client flavors where Hunters still have a dead zone, which is what this addon exists to help with.

## Features

- **Live range display** — a movable status frame shows whether your target is in Melee, Range, Dead Zone, or Out of Range at a glance.
- **Fully customizable status frame** — background, border, and font color/opacity per range state, custom text per state, resizable and movable.
- **Automatic spell detection** — finds your melee and ranged abilities on your action bars automatically, or set custom spell names to use it on non-Hunter classes.
- **Spell Key Bind** — bind up to 4 keys that cast a different spell or macro depending on your current range to target. This is the reliable way to get range-based abilities on a single keypress *during combat* — Blizzard blocks addons from switching action bar pages mid-fight, so this addon doesn't try to; Spell Key Bind casts directly off your keypress instead, which works everywhere action bar switching can't.
- **Localization** — English, French, and German.

## Installation

Extract the addon so its files sit inside `Interface/AddOns/RangeHelpRedux/` in your WoW installation.

## Usage

- `/rhr` — open the main configuration panel
- `/rhr ui` — customize the range status frame's appearance and colors
- `/rhr spell` — set up the Spell Key Bind casting system

### Setting up Spell Key Bind

1. Open WoW's **Key Bindings** menu and bind one or more of the "RangeHelp Redux Spell Keys" slots to a key of your choice.
2. Type `/rhr spell` and select that key from the dropdown at the top.
3. Drag a spell or macro from your spellbook or macro list onto each range state you want covered (Melee, Dead Zone, Range, Out of Range, No Target).
4. Press your bound key in combat — RangeHelp Redux casts the right one for your current range automatically.

## Credits

Original RangeHelp by Ralenod (2006). RangeHelp Redux is a complete rewrite for current WoW Classic clients by Lumbergh-Whitemane.
