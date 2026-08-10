# RangeHelp Redux

A ground-up rewrite of the classic *RangeHelp* addon for World of Warcraft, rebuilt on current APIs for **Classic Era**, **TBC Classic**, and **Wrath Classic** — the three client flavors where Hunters still have a dead zone, which is what this addon exists to help with.

## Features

- **Live range display** — a movable status frame shows whether your target is in Melee, Range, Dead Zone, or Out of Range at a glance, with a best-guess yard estimate (e.g. "Range (20-25yd)") while you're in ranged range.
- **Fully customizable status frame** — background, border, and font color/opacity per range state, custom text per state, resizable and movable.
- **Automatic spell detection** — finds your melee and ranged abilities on your action bars automatically, or set custom spell names to use it on non-Hunter classes.
- **Localization** — English, French, and German.

## Installation

Extract the addon so its files sit inside `Interface/AddOns/RangeHelpRedux/` in your WoW installation.

## Usage

- `/rhr` — open the main configuration panel
- `/rhr ui` — customize the range status frame's appearance and colors

## Why there's no "auto-cast the right spell for my range" keybind

Earlier builds tried this (a keybind that cast a different spell depending on melee/range/dead zone/out-of-range) but it's not achievable on the modern client: any function that both reads your addon-computed range state *and* triggers a protected action gets blocked by WoW's taint system once that state has ever been touched by non-hardware-event code (which live range tracking always is) — the same restriction that rules out switching action bar pages mid-fight. There's no reduced version of this that adds value over binding the spell directly with WoW's own keybinds, so it was removed. The status frame's live range display isn't affected by any of this, since it's pure UI, not a protected action.

## Credits

Original RangeHelp by Ralenod (2006). RangeHelp Redux is a complete rewrite for current WoW Classic clients by Lumbergh-Whitemane.
