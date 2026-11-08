#!/usr/bin/env python3
"""Static-only structural checks for the Godot visual scaffold.

Does NOT prove Godot parser, gameplay tests, Android export or performance.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "README.md",
    "AGENTS.md",
    "project.godot",
    "scenes/main.tscn",
    "scripts/main.gd",
    "docs/PROTOTYPE_SPEC.md",
    "docs/CODEX_TASK.md",
    "docs/TEST_PLAN.md",
    "docs/TECHNICAL_BOUNDARIES.md",
]


def main() -> None:
    missing = [path for path in REQUIRED if not (ROOT / path).is_file()]
    if missing:
        raise SystemExit(f"Missing required files: {', '.join(missing)}")

    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
    script = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")

    assert "res://scenes/main.tscn" in project
    assert "gl_compatibility" in project
    assert "res://scripts/main.gd" in scene
    assert "extends Node3D" in script
    assert "GRID_SIZE: int = 15" in script
    assert "_build_cat" in script and "_build_panda" in script
    assert "Not yet a playable" in readme
    assert "com.rekixo.ludopaws.v2prototype" in agents

    print("PASS: static starter structure only (Godot runtime NOT verified).")


if __name__ == "__main__":
    main()
