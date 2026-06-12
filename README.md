# NeonSiege 🛡️

A modern neon tower-defense game for iPhone **and Mac**, inspired by TowerMadness.
Glitch invaders pour out of spawn gates to steal your energy cores — build
towers to bend their path, shred them, and rescue any stolen shards before
they escape.

## How to run (2 minutes)

1. Install **Xcode** from the Mac App Store (free).
2. Double-click `NeonSiege.xcodeproj` to open the project.
3. At the top of Xcode, pick a simulator (e.g. *iPhone 15 Pro*) and press **▶ Run**.

### Run as a native Mac app 🖥️

1. At the top of Xcode, click the scheme selector (says *NeonSiege*) and
   choose **NeonSiegeMac**.
2. Pick **My Mac** as the destination and press **▶ Run**.
3. That's it — the game opens in a resizable window (also supports
   fullscreen). Click instead of tap.

**Mac keyboard shortcuts:**

| Key | Action |
| --- | ------ |
| `1` – `6` | Select tower (Pulse / Cryo / Arc / Rail / Flak / Wunderwaffe) |
| `Space` or `P` | Pause / resume |
| `Esc` | Close tower popup, or pause |
| `F` | Toggle 2x speed |
| `W` | Launch / call next wave early |

### Make an installable `NeonSiege.dmg` 💿

In Terminal, from the project folder, run:

```bash
./make_dmg.sh
```

This builds the Mac app and produces `NeonSiege.dmg` — open it and drag
*NeonSiege.app* into *Applications* like any normal Mac app.
(I can't compile Mac apps for you remotely — building requires Xcode on
your Mac — but this script makes it one command.)

### Run on your own iPhone

1. Plug in your iPhone and select it as the run target.
2. In Xcode: select the *NeonSiege* project → *Signing & Capabilities* →
   choose your **Personal Team** (sign in with your Apple ID if needed).
3. Change the *Bundle Identifier* to something unique, e.g.
   `com.yourname.neonsiege`.
4. Press **▶ Run**. On the phone: *Settings → General → VPN & Device
   Management* → trust your developer certificate.

## How to play

- **Tap a tower card** at the bottom, then **tap any empty grid cell** to build.
- Enemies always take the shortest path to your core — **build walls of towers
  to force them through long, deadly mazes**. You can never fully block them.
- **Tap a placed tower** to upgrade (3 tiers) or sell it.
- When an enemy reaches your core it **steals a shard** and runs back to its
  spawn gate — kill it on the way out to rescue the shard!
- Use the **2x button** to speed things up and **tap the wave banner** to call
  the next wave early for bonus credits.
- **Sound:** synthwave music loop + retro sound effects. Toggle via the
  *SOUND* button on the main menu or in the pause menu. (Audio plays even
  with the silent switch on.)

### Towers

| Tower | Cost | Specialty |
|-------|------|-----------|
| Pulse | $50  | Fast single-target laser |
| Cryo  | $70  | Slows enemies + chip damage |
| Arc   | $110 | Chains between up to 3 enemies |
| Rail  | $160 | Long-range piercing shot |
| Flak  | $210 | Explosive splash damage |
| **Wunderwaffe** | $666 | Nova strikes EVERYTHING in range — even cloaked Phantoms |

Towers sell back for 70% of everything invested. Full stats live in the
in-game **HELP** screen (main menu, bottom-left).

### Enemies

Drones, fast Sprinters, swarming Swarmlings, armored Bulwarks, cloaking
Phantoms (untargetable while cloaked!) and the **Overload** boss every 5th wave.

New in v2.0 — the heavyweights:

- **Juggernaut** — an armored giant boss (levels 11+, every 5th wave).
- **Colossus** — a massive boss that **splits into a swarm when killed**.
- **OMEGA PRIME** — the superboss. Resists slows, takes a small army to stop,
  and waits at the end of level 20.

## 20 levels

Campaign I: Boot Camp, Twin Streams, The Spiral, Crossfire, Glitch Gate,
The Gauntlet, Parallax, Reactor Ring, Vortex Run, **Final Protocol**.

Campaign II (v2.0): The Switchback, Diamond Field, The Hive, Mirror Maze,
Pinwheel, Catacombs, Twin Vortex, The Crucible, Labyrinth of Echoes and the
grand finale — **Omega Citadel**: a concentric fortress, four armies, a
treacherous portal and OMEGA PRIME itself on the final wave.

Every next level is harder than the last: enemy HP scales with level number,
waves get denser, and Campaign II layouts (staggered ribs, crystal diamonds,
kill-boxes, portal mazes) demand real maze engineering.

Every level starts in a **planning phase**: no timer, study the layout,
pre-build your maze, then tap **LAUNCH WAVE 1** when you're ready.

Earn up to ★★★ per level by keeping your shards safe. Beating a level unlocks
the next.

### Robo-voice

Win or lose a level and a Russian robo-voice will let you know exactly how it
feels about your performance. 🤖

### Help

The main menu has a **HELP** button (bottom-left) with the full field manual:
rules, every enemy's HP/speed/bounty, and every weapon's buy/sell price and
damage.

---
Built with Swift + SpriteKit. No external assets or dependencies — all visuals
are drawn procedurally in neon and all audio (synthwave loop + retro SFX) was
synthesized programmatically.
