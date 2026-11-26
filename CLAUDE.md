# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repo contains two independent projects:

1. **`user_unmerge.py`** — A standalone Python script for migrating Zendesk tickets from one user to another via the Zendesk API's ticket import endpoint.
2. **`MoanaOceanQuest/`** — An iOS SpriteKit game (Swift/Xcode project) featuring 10 levels with a Moana theme.

## Python Script (`user_unmerge.py`)

The script uses the `requests` library. Configuration is done by editing constants at the top of the file:
- `url` — Zendesk API endpoint with the source user's ID
- `user` — Zendesk email + `/token`
- `token` — Zendesk API token
- `TARGET_USER_ID_INT` — integer ID of the destination user

Run with: `python user_unmerge.py`

## iOS Game (`MoanaOceanQuest/`)

**Build/Run:** Open `MoanaOceanQuest/MoanaOceanQuest.xcodeproj` in Xcode and run on a simulator or device (iOS). There is no CLI build or test command.

### Architecture

The game uses SpriteKit with a scene-based flow:

```
MainMenuScene → LevelSelectScene → GameScene → LevelCompleteScene / GameOverScene
```

**Key singletons:**
- `GameManager` — persists level progress, stars, high scores, and settings via `UserDefaults`
- `AudioManager` — plays background music and sound effects

**Core gameplay loop lives in `GameScene`**, which orchestrates:
- `LevelManager.shared.configurationForLevel(_:)` — returns a `LevelConfiguration` struct describing ground, platforms, enemies, and collectibles for each of the 10 levels
- `TileMapBuilder` — constructs the physical level geometry from `LevelConfiguration`
- `PlayerCharacter` (subclasses `SKSpriteNode`) — handles movement, jumping (double-jump + dash), attacking, and state via `PlayerState` enum
- `HUDOverlay` — in-game UI for health, score, and timer
- `ParallaxBackground` and `WaterMechanics` — visual/physics components

**Entity hierarchy:**
- `PlayerCharacter: SKSpriteNode`
- `BaseEnemy` → `EnemyTypes` (e.g. `.kakamora`)
- `BossEnemy` (levels end with `TamataoBoss` or `TeKaBoss`)
- `Collectible`, `PowerUp`, `NPCCharacter`

**Physics:** Collision categories defined in `Utils/PhysicsCategories.swift`. Contact handling is in `GameScene` via `SKPhysicsContactDelegate`.

**Level data:** All 10 levels are defined as methods in `LevelManager` returning `LevelConfiguration` structs—no external data files. To add a level, add a case to the `switch` in `configurationForLevel` and implement its method.
