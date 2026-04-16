# PONGI — Changelog

## v0.2.0 — 2026-04-15

### New Features

**New XP System (difficulty-based)**
- Win vs Bot on Easy → +100 XP
- Win vs Bot on Medium → +200 XP
- Win vs Bot on Hard → +300 XP
- Win in Local 2P mode → +200 XP
- No XP awarded for losses against bot
- XP is awarded only once per match (no duplicate awards)

**ESC Pause Menu**
- Pressing ESC during a match now opens a Pause menu instead of exiting to main menu
- Pause works in both Bot and Local 2P modes
- Physics, timers, abilities, and match state are fully frozen during pause
- Pause menu options: **Continue**, **Restart Match**, **Main Menu**
- Press ESC again while paused to resume instantly

**Skin & Decoration Unlock System**
- Skins are now unlocked by reaching certain levels:
  - CLASSIC — Level 1 (default, always available)
  - NEON — Level 2
  - COSMIC — Level 3
  - RETRO — Level 5
  - MINIMAL — Level 7
- New **Decorations** (player title system) unlocked by level:
  - ROOKIE — Level 1 (default)
  - STRIKER — Level 3
  - VETERAN — Level 5
  - MASTER — Level 8
  - LEGEND — Level 12
- Customize menu split into two tabs: **SKINS** and **DECORATIONS**
  - Switch tabs with Q / E keys
  - Locked items are shown greyed out with their unlock level
- Active decoration title shown in the XP bar
- Level-up overlay shows newly unlocked skin/title

**Stat Reset for v0.2.0**
- All previous progress (XP, level, skins, decorations) is reset on first launch
- Fresh progression starts from Lv.1 with all rewards recalculated under the new system

### Controls
- **In-game:** ESC = Pause  |  X = Use ability (P1)  |  M = Use ability (P2)
- **Pause menu:** UP/DOWN = Navigate  |  ENTER = Confirm  |  ESC = Resume
- **Customize menu:** Q/E = Switch Tab  |  LEFT/RIGHT or UP/DOWN = Browse  |  ENTER = Select

---

## v0.1.0 — Initial Release

- Classic Pong with abilities (GROW, SHIELD, SLOW, POWER, CURVE, DASH, BOOST, TELEPORT)
- 1 Player vs Bot (Easy/Medium/Hard) and Local 2P modes
- XP and level system
- 5 visual skins
- Ball fire mode, screen shake, particles
