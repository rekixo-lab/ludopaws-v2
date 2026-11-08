# Instructions for Codex and all coding agents

You are working in **rekixo-lab/ludopaws-v2**, an independent **PUBLIC experimental Godot 4** repository.

## Hard boundaries

1. This is NOT the production Ludo Paws Android app. Never modify or deploy **rekixo-lab/ludopaws**, Cloudflare Workers, game APIs, Google Play Console, or the production Android application ID **com.rekixo.ludopaws**.
2. The new Android prototype package (if exporting) must be separate, e.g. **com.rekixo.ludopaws.v2prototype**. Use only debug signing for test builds. Do not reuse production keys.
3. No secrets, tokens, service endpoints, player data, private source copies or third-party copyrighted assets may be committed to this public repository. You may examine the original private repo only with authorized read access; extract design requirements instead of dumping its files.
4. Never claim server-authoritative, cryptographic, certified or production-fair dice for the local prototype. Keep dice outcomes separate from animation. Do not introduce unseen biased dice logic.
5. Use **Godot 4.x stable, GDScript**, and a mobile-friendly renderer. No C#, Unity, Flutter, WebView, external online service, or bundled private plugin is required for this milestone.

## Product target

Read these files before changes:
- README.md
- docs/PROTOTYPE_SPEC.md
- docs/CODEX_TASK.md
- docs/TEST_PLAN.md
- docs/TECHNICAL_BOUNDARIES.md

Deliver one playable, two-player local Ludo prototype with a 15×15 board, Cat (Red) and Panda (Yellow), four pawns per player, valid dice/moves, animations and clear mobile UI. Scope includes only the local gameplay test, not accounts, wallets, ads or multiplayer.

## Engineering approach

- First inspect existing files. Preserve this project's working starter scene; replace procedural preview art gradually with clean reusable scenes.
- Separate pure rules and board-coordinate mapping from camera, UI, FX and sound. Rendering is never authoritative.
- Prefer small, legible scene/script files. Avoid a single huge script and avoid new network dependencies.
- Keep all project files inside this repository. Prefer procedurally created licensed-safe placeholders until original art has been explicitly approved for public use.
- Make every control work on mobile touch and desktop mouse. Provide accessibility-conscious high-contrast indicators and a reduced-motion option.
- Implement and run rule tests, smoke tests, and Android/device checks when the tools are available.
- After **each** meaningful change, recheck parsing, affected rules and rendering. At the end, do a **final full recheck** and state exactly which tests ran and which could not run. Do not assert a green CI or a successful device run without evidence.
- Keep commits focused; a PR is preferred for substantive gameplay work, with screenshots or recorded proof of testing when available.
- If Godot/SDK is missing, still implement and statically check what is possible; clearly report the missing validation rather than claiming success.

## Definition of done

All P0 items in docs/TEST_PLAN.md pass, the actual Godot project opens without parser errors, two people can finish a local match, and at least a debug export or explicit Android-export blocker is documented. No production repo or backend touched.
