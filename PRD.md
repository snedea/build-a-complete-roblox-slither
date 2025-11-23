# Product Requirements Document (PRD): Snake Adventure Game

## 1. Introduction
This document outlines the requirements for "Snake Adventure," a multiplayer arcade game on the Roblox platform. The game combines the classic "snake" mechanics with modern multiplayer io-style gameplay, featuring server-authoritative physics, a deep progression system, and rich character customization.

**Note:** This PRD explicitly excludes Non-Player Characters (NPCs). All snakes in the game are player-controlled.

## 2. Product Overview
*   **Genre:** Multiplayer Action / Arcade (IO-style)
*   **Platform:** Roblox (PC, Mobile, Tablet)
*   **Core Loop:** Spawn -> Collect Food -> Grow -> Eliminate Players -> Rank Up -> Unlock Skins -> Die -> Repeat.
*   **Target Audience:** Casual gamers, competitive players, and Roblox enthusiasts.

## 3. Core Gameplay Mechanics

### 3.1 Movement Physics
*   **Base Movement:** Snakes move constantly forward at a base speed (default: 16 studs/sec).
*   **Steering:**
    *   **PC:** The snake's head follows the mouse cursor.
    *   **Mobile:** The snake's head follows a dynamic thumbstick or touch input vector.
*   **Turning Radius:** Snakes have a limited turning speed (default: 5 radians/sec) to prevent instant 180-degree turns.
*   **Body Following:** Body segments must follow the path of the head with precise spacing (2.5 studs), creating a smooth, trailing effect without "cutting corners."

### 3.2 Abilities
*   **Boost:**
    *   **Effect:** Increases speed by 1.8x.
    *   **Cost:** None (Cooldown based).
    *   **Cooldown:** Determined by player rank (starts at 10s, decreases to 6.2s).
*   **Brake:**
    *   **Effect:** Decreases speed by 0.5x for tighter maneuvering.
    *   **Cooldown:** Determined by player rank (starts at 8s, decreases to 5.15s).

### 3.3 Combat & Collision
*   **Hit Detection:**
    *   If Snake A's **head** collides with Snake B's **body**, Snake A dies.
    *   If Snake A's **head** collides with Snake B's **head**, both snakes die.
    *   **Self-Collision:** Snakes can pass through their own bodies without dying (or have a grace period for the first few segments).
*   **Death Consequence:**
    *   The snake is destroyed.
    *   The snake's body segments are converted into food (50% of accumulated gold value) scattered at the death location.
    *   The player is shown a "Game Over" or "Revive" screen.
*   **Spawn Protection:** Newly spawned or revived snakes have a temporary shield (invulnerability) for a duration based on rank (5-10s).

### 3.4 Growth & Economy
*   **Food:** Small orbs spawned randomly in the arena.
*   **Magnetism:** Food within a certain radius (Magnet Range) automatically flies toward the snake's head. Range increases with Rank.
*   **Growth Logic:**
    *   1 Food = +1 Segment (configurable).
    *   1 Kill = +3 Segments (configurable).
*   **Gold:** Currency earned by collecting food. Used for ranking up and tracking score.

### 3.5 Camera & Controls
*   **Camera Modes:** The game features a dynamic camera system that transitions smoothly between two perspectives based on zoom level.
    *   **Top-Down View (Max Zoom):** High-altitude overhead view (90-degree pitch) for strategic arena awareness.
    *   **POV / Third-Person View (Min Zoom):** Close-up view behind the snake's head (10-degree pitch) for immersive maneuvering.
*   **Zoom Controls:**
    *   **PC:** Mouse Wheel scrolls to zoom in/out smoothly.
    *   **PC Shortcut:** Pressing 'Z' toggles instantly between Min (POV) and Max (Top-Down) zoom targets.
    *   **Mobile:** Two-finger pinch gesture to zoom in/out.
*   **Camera Behavior:**
    *   **Glide Interpolation:** Zoom transitions are smoothed/damped for a "gliding" feel.
    *   **Dynamic Pitch:** The camera angle automatically adjusts from -90° (looking down) to -10° (looking forward) as the player zooms in.
    *   **Dynamic FOV:** Field of View expands slightly as the camera zooms out (60° to 90°).
    *   **Look-Ahead:** In POV mode, the camera focuses on a point in front of the snake to aid navigation.

## 4. Progression System

### 4.1 Ranks
*   **Structure:** 20 progressive ranks (e.g., Worm, Viper, Cobra... Ouroboros).
*   **Progression:** Players automatically rank up upon reaching total gold thresholds.
*   **Benefits:** Higher ranks unlock:
    *   Increased Magnet Range (10 -> 66 studs).
    *   Reduced Boost/Brake Cooldowns.
    *   New Snake Variants/Skins.

### 4.2 Leaderboards
*   **Real-time:** Displays top 10 players in the current server by length/score.
*   **Global/Monthly:** Tracks "All-Time Kills," "Longest Snake," and "Total Food" using OrderedDataStores.

## 5. Character Customization

### 5.1 Snake Variants
Players can select from 10 unique snake variants before spawning. Variants are purely cosmetic but offer distinct visual styles.

| Variant Name | Visual Style | Shape | Material | Special Effect |
| :--- | :--- | :--- | :--- | :--- |
| **Classic Viper** | Red | Ball | Neon | Standard |
| **Emerald Python** | Green | Ball | Neon | Standard |
| **Sapphire Serpent** | Blue | Ball | Neon | Standard |
| **Golden Cobra** | Gold | Cylinder | Neon | Metallic shine |
| **Amethyst Adder** | Purple | Ball | Neon | Standard |
| **Cubic Constrictor** | Yellow | Block | SmoothPlastic | Geometric/Voxel look |
| **Diamond Diamondback** | Cyan | Ball | Glass | Semi-transparent (0.3) |
| **Obsidian Mamba** | Dark Gray | Ball | Neon | Stealthy look |
| **Rainbow Rattler** | Pink | Ball | Neon | Animated rainbow color |
| **Plasma Phantom** | Electric Blue | Cylinder | ForceField | Sci-fi energy effect |

### 5.2 Selection UI
*   **Welcome Screen:** A grid view of all 10 variants.
*   **Preview:** Clicking a variant shows a live preview of the head and 3 body segments.
*   **Locking:** (Optional) Some variants may be locked behind Ranks.

## 6. Technical Requirements

### 6.1 Server Authority
*   **Movement Validation:** The server must validate all movement requests to prevent speed hacking or teleportation.
*   **Collision Logic:** All collision detection must happen on the server to ensure fairness.

### 6.2 Performance
*   **Spatial Partitioning:** The arena must be divided into a grid (e.g., 64x64 studs) to optimize collision checks (O(n) instead of O(n^2)).
*   **Object Pooling:** Body segments and food items must be pooled to prevent Garbage Collection spikes.
*   **Network Optimization:** Only head positions and directions should be replicated; clients interpolate body segments locally.

## 7. User Interface (UI)

### 7.1 HUD (Heads-Up Display)
*   **Stats:** Current Length, Rank Name, Gold Collected.
*   **Controls:** Mobile buttons for Boost and Brake (hidden on PC).
*   **Mini-map:** (Optional) Radar showing boundaries and density.

### 7.2 Revive System
*   **Prompt:** Upon death, a UI prompts the player to "Revive" (costing a Donut item) or "Restart".
*   **Timer:** 10-second countdown to make a decision.

## 8. Acceptance Criteria

### 8.1 Gameplay
*   [ ] Player can control the snake using mouse (PC) or touch (Mobile).
*   [ ] Snake moves at constant speed and turns smoothly.
*   [ ] Snake grows in length when collecting food.
*   [ ] Snake dies immediately upon head-collision with another snake's body.
*   [ ] Dead snakes scatter food particles.
*   [ ] Boost and Brake abilities work and respect cooldowns.
*   [ ] Camera smoothly transitions from overhead to third-person view when zooming.
*   [ ] Mouse wheel adjusts zoom level on PC.
*   [ ] 'Z' key toggles between min and max zoom on PC.
*   [ ] Pinch gesture adjusts zoom level on Mobile.
*   [ ] Camera angle changes (pitches up) when zooming in to see the horizon.

### 8.2 Customization
*   [ ] Welcome screen displays all 10 variants correctly.
*   [ ] Selecting "Cubic Constrictor" spawns a snake with Block segments.
*   [ ] Selecting "Diamond Diamondback" spawns a snake with Glass material.
*   [ ] Selecting "Plasma Phantom" spawns a snake with ForceField material.

### 8.3 Technical & Performance
*   [ ] Game runs at 60 FPS with 20+ concurrent players.
*   [ ] No visible lag or "rubber-banding" on movement.
*   [ ] Server memory remains stable over long sessions (no leaks).
*   [ ] Exploiters cannot move faster than the defined maximum speed.

### 8.4 Persistence
*   [ ] Player Rank and Gold are saved between sessions.
*   [ ] Unlocked cosmetics remain unlocked after rejoining.
