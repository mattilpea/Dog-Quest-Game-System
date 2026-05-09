# Dog Quest Game System

Pictures and Video for the game:-
https://drive.google.com/drive/folders/11fO_OR2-79YNxQV1n3Pq05FomzbJqUe9?usp=sharing

A modular Roblox game framework focused on procedural world progression, quest systems, exploration, and scalable gameplay architecture.

This repository contains selected gameplay systems from one of my larger Roblox projects.

The original game was significantly larger and included multiple interconnected systems such as:

- Quest systems
- Endless quest generation
- Procedural chunk unlocking
- Grid-based world expansion
- UI management systems
- Notification handlers
- Daily reward systems
- Dialogue systems
- Localization support
- Data persistence
- Leveling systems
- Multiplayer-compatible progression

Due to project limitations, I am only able to publicly release portions of the game's source code rather than the complete project.

---

# Overview

The core gameplay loop revolves around a dog NPC that acts as the main progression controller for the game world.

Players:
1. Receive quests from the dog
2. Complete objectives
3. Unlock new world chunks
4. Expand the playable world
5. Progress into endless procedural quests

The project was designed around scalability and modularity rather than placing all logic inside a few scripts.

---

# Included Systems

## Quest System

The quest framework supports:

- Structured quest progression
- Dynamic quest tracking
- Completion rewards
- Quest state persistence
- Task generation
- Localization support
- Modular quest behaviors
- Endless/procedural quests

Example architecture:

```lua
trackingFunction = QuestTrackingFunctions.StartTrack[currentQuestNum]
```

Instead of large conditional chains, quest behavior is dynamically mapped through indexed modules.

---

## Endless Quest System

The endless quest framework generates repeatable procedural objectives while avoiding repetitive gameplay patterns.

Features include:

- Randomized objectives
- Dynamic requirement scaling
- Reward scaling
- Quest-type filtering
- Progress persistence
- Special-condition quests
- Boss territory progression

Example:

```lua
if EndlessQuestsInfo[EndlessQuestIndex].QuestType ~= EndlessQuestsInfo[rng].QuestType then
```

This prevents consecutive quests from sharing the same gameplay category.

---

## Procedural Grid / Chunk System

One of the main gameplay systems is a spiral-based world expansion framework.

The game world expands outward from a central origin point using a mathematically generated spiral traversal system.

Features:

- Spiral chunk indexing
- Persistent world progression
- Dynamic chunk unlocking
- Procedural exploration flow
- Asymmetrical grid support
- Chunk progression serialization
- Unlock visualization systems

The spiral traversal algorithm:

```lua
local directions = {
	{1, 0},
	{0, 1},
	{-1, 0},
	{0, -1},
}
```

World expansion is generated dynamically rather than manually placing progression points.

---

# Technical Features

## Modular Architecture

The project heavily uses ModuleScripts to separate responsibilities into isolated systems.

Examples:

- Quest tracking modules
- Reward modules
- OnStart quest modules
- Grid systems
- Notification systems
- Dialogue systems
- Data management systems

---

## Localization Support

The project integrates Roblox localization systems using `LocalizationService`.

Example:

```lua
translator:FormatByKey(...)
```

Dialogue and quest text can be translated dynamically per-player.

---

## Persistent Progression

Player progression is saved through centralized data systems.

This includes:

- Quest progression
- Chunk unlock progression
- Endless quest state
- Rewards
- World expansion state

---

## Gameplay Feedback Systems

The project also includes gameplay feedback systems such as:

- Billboard indicators
- Notifications
- Task UI generation
- Unlock effects
- Dynamic quest UI updates

---

# Design Philosophy

The project was built around interconnected gameplay systems rather than isolated mechanics.

Core gameplay flow:

```text
Quest -> Progress -> Unlock Area -> Explore -> Endless Quest -> Expand World
```

The dog NPC intentionally remains simple while acting as the central gameplay progression hub.

---

# Important Note

This repository only contains selected systems from the original project.

The complete game included:

- Additional gameplay systems
- UI frameworks
- Multiplayer systems
- World content
- Additional progression mechanics
- Proprietary assets and game files

Because of this, some scripts may reference modules or systems that are not included in this public repository.

---

# About This Project

This was one of my earlier large-scale Roblox projects and one of my first attempts at building a fully interconnected game architecture rather than isolated gameplay scripts.

Although there are areas I would structure differently today, this project represents an important stage in my growth as a programmer and game systems developer.
