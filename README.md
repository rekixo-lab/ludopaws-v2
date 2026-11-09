# Ludo Paws v2 — Godot Prototype

> STATUS: Experimental Godot visual scaffold. **Not yet a playable Ludo match.** The scene currently displays a 15×15 preview board, stylized placeholder 3D Cat and Panda, and a dice-visualization button. Codex's next job is to implement the complete playable local prototype described below.

This is a **separate experiment**, not a replacement release of Ludo Paws. The original Android game remains in the private repository: https://github.com/rekixo-lab/ludopaws. Do not change that repository, its live backend, Play Store listing, existing signing keys, or player data as part of this prototype.

## Goal

Build a polished, playable **offline, same-device, two-player** Ludo board in Godot, featuring **Cat (Red)** and **Panda (Yellow)**, with four pawns per player. Compare visual quality, animal animation, responsiveness, battery/memory and workflow against the existing Kotlin/OpenGL game. Only after testing should anyone propose a full migration.

**Prototype stack:** Godot 4.x stable, GDScript, 3D scene with mobile-friendly Compatibility renderer; no Cloudflare, accounts, payments, ads, matchmaking or production dice service.

## Open in Godot (Linux Mint / desktop)

1. Install **Godot 4.7.2 stable standard edition** (the version used by this repository's headless smoke workflow; no .NET/C# edition required).
2. Clone this repository and open the folder containing project.godot from Godot Project Manager.
3. Press **F6** for the current scene or **F5** to run the configured main scene.
4. On systems with a Godot CLI: ~~~godot --path . --editor~~~ and ~~~godot --path .~~~ (the executable may be named godot4).
5. The current "Roll preview" button **does not play Ludo** and its number is **not** a cryptographic dice result. Do not present this scaffold as complete.

**Continuous integration:** [Static structure check](https://github.com/rekixo-lab/ludopaws-v2/actions/workflows/static-scaffold-check.yml) and [Godot 4.7.2 headless smoke](https://github.com/rekixo-lab/ludopaws-v2/actions/workflows/godot-smoke.yml) cover file integrity and early parser/startup problems. **Neither means the local Ludo game is playable yet.**

## Home UI preview

Open `scenes/ui/home/home_screen.tscn` in Godot and press **F6** to preview it.
The Home scene uses sample balances and match text, and emits `route_requested` for
future navigation. **F5** still opens the separate board scaffold.

- `assets/ui/backgrounds` holds reusable scenery and panel art.
- `assets/ui/brand` holds the title plaque, display font resource and Home illustration.
- `assets/ui/icons` holds single-purpose SVG glyphs.
- `scenes/ui/components` and `scripts/ui/components` hold shared Godot controls.
- `scenes/ui/home` and `scripts/ui/home` hold Home composition and behavior.

## Next job for Codex

Read **AGENTS.md**, **docs/PROTOTYPE_SPEC.md**, **docs/CODEX_TASK.md**, **docs/TEST_PLAN.md** and **docs/TECHNICAL_BOUNDARIES.md** before editing. Complete all acceptance criteria and test in a Godot 4 editor/device. The source-of-truth implementation can be inspected in the original repository if authorized, but do not copy credentials, binary assets or private source into this public repository without permission.

## What the finished first milestone must contain

- A readable, touch-friendly **15×15 Ludo board** with Red Cat and Yellow Panda seats.
- **Two local human players, four playable animal pawns each**, turn indicator, dice, legal-move selection, capture, safe cells, home lanes, and victory.
- **3D Cat and Panda** (reusable models) with visible idle, hop/move, capture and win reactions; animation never chooses dice outcomes.
- Premium but lightweight lighting, shadows and particle/feedback effects; responsive portrait and landscape layout.
- Offline mode only; deterministic rule tests and repeatable gameplay checks.
- Clear run instructions and (when locally available) a **separately identified Android debug APK** for testing, not a Play Store release.

See the detailed documents for definitions, acceptance criteria, and the ready-to-paste Codex task.

## Folders

| Path | Purpose |
|---|---|
| project.godot | Godot project entry |
| scenes/main.tscn | Current 3D visual scaffold |
| scripts/main.gd | Current procedural preview, **not** the game engine |
| AGENTS.md | Standing instructions for Codex |
| docs/PROTOTYPE_SPEC.md | Gameplay, visual, and accessibility requirements |
| docs/CODEX_TASK.md | First implementation task for Codex |
| docs/TEST_PLAN.md | Acceptance and validation checklist |
| docs/TECHNICAL_BOUNDARIES.md | Original-game and Android safety boundaries |

## Android test identity

Use a distinct prototype package ID, e.g. **com.rekixo.ludopaws.v2prototype**. Never replace or uninstall the existing production Ludo Paws package **com.rekixo.ludopaws**. Android exports require matching Godot export templates and an Android SDK/JDK as described in the official guide: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html .

## Decision gate

**No automatic migration.** Compare both versions on the same physical Android devices. Record gameplay feel, rendering FPS/frame time, memory, battery, cold start, APK size, visual clarity and development effort. Make an explicit go/no-go decision only after the prototype is playable and measured.
