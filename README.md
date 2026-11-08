# Ludo Paws v2 — Godot Prototype

> STATUS: Experimental Godot visual scaffold. **Not yet a playable Ludo match.** The scene currently displays a 15×15 preview board, stylized placeholder 3D Cat and Panda, and a dice-visualization button. Codex's next job is to implement the complete playable local prototype described below.

This is a **separate experiment**, not a replacement release of Ludo Paws. The original Android game remains in the private repository: https://github.com/rekixo-lab/ludopaws. Do not change that repository, its live backend, Play Store listing, existing signing keys, or player data as part of this prototype.

## Goal

Build a polished, playable **offline, same-device, two-player** Ludo board in Godot, featuring **Cat (Red)** and **Panda (Yellow)**, with four pawns per player. Compare visual quality, animal animation, responsiveness, battery/memory and workflow against the existing Kotlin/OpenGL game. Only after testing should anyone propose a full migration.

**Prototype stack:** Godot 4.x stable, GDScript, 3D scene with mobile-friendly Compatibility renderer; no Cloudflare, accounts, payments, ads, matchmaking or production dice service.

## Open in Godot (Linux Mint / desktop)

1. Install a current **stable Godot 4.x standard edition** (not .NET/C# edition).
2. Clone this repository and open the folder containing project.godot from Godot Project Manager.
3. Press **F6** for the current scene or **F5** to run the configured main scene.
4. On systems with a Godot CLI: ~~~godot --path . --editor~~~ and ~~~godot --path .~~~ (the executable may be named godot4).
5. The current "Roll preview" button **does not play Ludo** and its number is **not** a cryptographic dice result. Do not present this scaffold as complete.

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
