# 🏓 PONGI — Modern Arcade Pong

A feature-rich arcade Pong game with an **ability system**, **5 skin themes**, **XP / leveling**, and **bot AI** — built with [Processing 4](https://processing.org/).

---

## 🚀 Running the Game

### Option A — Pre-built executable (recommended)

Go to the [**Releases page**](https://github.com/AndreiShorop/pongi/releases/latest) and download the zip for your platform:

#### Linux (`pongi-linux.zip`)
1. Extract the zip
2. Run the game:

```bash
cd pongi-linux
chmod +x pong   # only needed once
./pong
```

> Requires 64-bit Linux (x86-64). No Java installation needed — JRE is bundled.

#### Windows (`pongi-windows.zip`)
1. Extract the zip
2. Double-click **`pong.bat`** to launch (no console window)

> Requires Java 11+ installed on Windows ([download here](https://adoptium.net/)).

---

### Option B — Run from source with Processing

1. Install [Processing 4](https://processing.org/download)
2. Open `pong.pde` in the Processing IDE
3. Press **▶ Run**

---

## 🎮 Controls

| Action | Player 1 | Player 2 |
|--------|----------|----------|
| Move up | `W` | `↑` |
| Move down | `S` | `↓` |
| Use ability | `X` | `M` |

**Menus:** `↑` / `↓` navigate · `Enter` confirm · `Esc` back  
**In-game:** `Esc` returns to main menu · `Space` rematch (on game over)

---

## ⚡ Abilities

Each player picks one ability before the match. Abilities have cooldowns and some have active durations.

| Ability | Category | Effect | Cooldown |
|---------|----------|--------|----------|
| **GROW** | DEF | Enlarges your paddle for 4s | 8s |
| **SHIELD** | DEF | Blocks one missed ball | 15s |
| **SLOW** | DEF | Slows the ball for 3s | 7s |
| **POWER** | ATK | Doubles ball speed instantly | 6s |
| **CURVE** | ATK | Bends ball trajectory | 5s |
| **DASH** | AGI | Instantly dash up/down | 4s |
| **BOOST** | AGI | Doubles paddle speed for 3s | 6s |
| **TELEPORT** | AGI | Teleports paddle to ball | 8s |

---

## 🎨 Skins

5 visual themes selectable from the main menu:

| # | Name | Style |
|---|------|-------|
| 1 | **CLASSIC** | Deep space, blue/red paddles |
| 2 | **NEON** | Dark cyan grid, neon colors |
| 3 | **COSMIC** | Purple space, violet accents |
| 4 | **RETRO** | Black with scanlines, green accent |
| 5 | **MINIMAL** | Light background, monochrome |

---

## 🤖 Game Modes

- **1 Player** — Play against a bot at three difficulty levels:
  - **Easy** — slow, makes errors, uses abilities rarely
  - **Medium** — balanced speed and accuracy
  - **Hard** — fast reactions, efficient ability usage
- **2 Players** — Local multiplayer on the same keyboard

---

## 🏆 XP & Levels

Earn XP after every match:
- **Win vs Bot** → +100 XP
- **Lose vs Bot** → +25 XP
- **2-Player match** → +50 XP

Progress is saved automatically to `pongi_save.txt` next to the executable.

---

## 📁 Project Structure

```
pingpong/
├── pong.pde              # Full game source (~1600 lines, Processing 4)
├── linux/
│   ├── pong              # Linux launcher script
│   ├── java/             # Bundled JRE (no install needed)
│   └── lib/              # Game JARs
├── windows/
│   ├── pong.bat          # Windows launcher (double-click to run)
│   └── lib/              # Game JARs
└── README.md
```

---

## 🛠 Built With

- [Processing 4.5.2](https://processing.org/) — Java-based creative coding framework
- Portable Linux export — no runtime dependencies for end users
