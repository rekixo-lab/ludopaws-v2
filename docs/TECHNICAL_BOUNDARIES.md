# Original Game vs Godot v2 — Technical Boundaries

The existing live product is in **rekixo-lab/ludopaws** (private). It is built with Native Kotlin Android, custom OpenGL/Canvas rendering, and a Cloudflare Worker/Durable Object server-authoritative multiplayer backend. Its code includes LudoPaws3DSceneView.kt, LudoPawsBoardView.kt, CatRenderer.kt and PandaRenderer.kt plus authoritative game/rule modules.

This repository is **rekixo-lab/ludopaws-v2 (public)**. It is a controlled visual and game-feel experiment. Only requirements and explicitly approved/licensed assets should be transferred.

## Keep separate

| Existing product | Experimental v2 |
|---|---|
| Production Android application ID: com.rekixo.ludopaws | Prototype-only package ID: com.rekixo.ludopaws.v2prototype |
| Existing Play Console release, signing, updates | Never push to Play Store |
| Cloudflare Worker, Durable Objects, accounts | Offline local gameplay only |
| Cryptographic online dice/proofs & stored user data | Prototype local RNG; clearly labeled, no fairness claims |
| Original Kotlin/OpenGL renderer | New Godot scenes and GDScript |
| All production features and characters | One board, Cat and Panda only |

## Visual reference is not source migration

Do not copy the original Kotlin renderer or gameplay code into a public Godot repo. Read it (if authorized) to identify exact Ludo geometry, board color mapping, model silhouette and expected animation transitions; implement independently in GDScript. Do not copy private assets or credentials without explicit rights approval.

The eventual migration, if ever approved, would require a separate security architecture and compatibility study covering player identity, Google Play signing/package continuity, saved games, Cloudflare protocol, commerce and rollout/rollback. **Do not do that in milestone 1.**

## Rule parity

Current game's readme describes 2–4 players, four tokens each, exact home, six-to-exit, safe squares, extra turn on six/capture, third consecutive six forfeiture and no blockade restrictions in v1. Confirm exact path/cell mapping and edge cases against read-only source before declaring parity. This prototype must not falsely claim that a visual imitation is mathematically or cryptographically identical.
