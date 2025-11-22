# Architecture: Roblox Slither Simulator Clone

**Session ID**: build-a-complete-roblox-slither
**Date**: 2025-11-22
**Architect Phase**: Complete System Design

---

## System Overview

A complete multiplayer Slither.io-style snake game built in Roblox with:
- **Real-time multiplayer snake movement** with smooth body segment following
- **Server-authoritative physics** for fair collision detection and exploit prevention
- **Progression system**: 20 ranks, gold economy, revive donuts
- **Competitive features**: Leaderboards (monthly + all-time), customization, badges
- **Cross-platform support**: Desktop (mouse) + mobile (touch controls, pinch zoom)
- **Performance optimizations**: Spatial partitioning, object pooling, client-side interpolation

**Architecture Philosophy**: Server-authoritative with client-side prediction. Server validates all state changes (movement, collisions, currency), clients render smoothly with interpolation. All data persists via DataStore with robust retry logic.

---

## Technology Stack

**Core Platform**: Roblox + Rojo (version-controlled Luau development)

**Server-Side** (ServerScriptService):
- **SnakeManager.lua** - Snake lifecycle, movement validation, collision detection
- **FoodSpawner.lua** - Continuous food generation with Poisson disk sampling
- **RankService.lua** - Rank progression, magnet range calculations
- **LeaderboardService.lua** - Monthly/all-time stats via OrderedDataStore
- **PlayerDataManager.lua** - DataStore persistence with retry logic
- **ReviveService.lua** - Donut consumption, respawn with shield
- **ShieldManager.lua** - Spawn protection timers, invulnerability logic

**Client-Side** (StarterPlayerScripts):
- **SnakeController.lua** - Input capture (mouse/touch), movement requests
- **CameraController.lua** - Zoom controls, FOV scaling, pinch/pan
- **MobileControls.lua** - Dynamic thumbstick + boost/brake buttons
- **SnakeRenderer.lua** - Body segment interpolation for other players

**Shared Modules** (ReplicatedStorage):
- **SnakeConfig.lua** - Physics constants (speed, boost multiplier, segment spacing)
- **RankConfig.lua** - 20 rank thresholds, magnet ranges, boost/brake stats
- **FoodConfig.lua** - Spawn rates, gold rewards by rank
- **CustomizationData.lua** - Available colors, mouth/eye styles, effects
- **SpatialGrid.lua** - O(n) collision detection via spatial partitioning
- **Maid.lua** - Memory leak prevention (cleanup pattern)
- **Signal.lua** - Event-driven architecture (decouple systems)

**UI** (StarterGui):
- **HUD** - Gold, rank, length, kills
- **Leaderboard** - Top players, monthly/all-time tabs
- **CustomizationMenu** - Color picker, mouth/eye selection
- **RevivePrompt** - Donut revival UI on death
- **ShieldTimer** - Countdown overlay during spawn protection

---

## Architecture

### High-Level Data Flow

```
[Client Input] → [SnakeController] → RemoteEvent("MoveSnake") → [SnakeManager]
                                                                      ↓
                                                          Server validates direction
                                                          Server calculates new position
                                                          Server checks collisions
                                                                      ↓
[SnakeRenderer] ← RemoteEvent("UpdateSnakes") ← [SnakeManager broadcasts]
       ↓
Client interpolates body segments (60 FPS smooth)
```

### Critical Design Patterns Applied

#### 1. **Spatial Partitioning (Performance-Critical)**
- **Problem**: 20 snakes × 50 segments = 1,000 parts. Checking every head vs every segment = O(n²) disaster.
- **Solution**: Divide arena into 64×64 stud grid cells. Store body segments by cell. Only check head vs segments in same + adjacent 8 cells (9 cells max).
- **Implementation**: `SpatialGrid.lua` with `Insert(part, position) → cellKey` and `GetNearby(position, radius) → {parts}`.
- **Pattern Source**: Roblox Advanced Modules & Performance pattern.

#### 2. **Client-Side Body Interpolation (Network-Critical)**
- **Problem**: Replicating every segment position every frame = bandwidth explosion (1,000 parts × 60 FPS = 60,000 updates/sec).
- **Solution**: Server broadcasts head position + rotation at 20 Hz (every 0.05s). Client interpolates body segments locally using spring dampening or bezier curves.
- **Security**: Server still validates collisions server-side using authoritative hitboxes.
- **Pattern Source**: Roblox Async Patterns - prefer signals over polling.

#### 3. **Dynamic Body Segment Pooling (Memory-Critical)**
- **Problem**: Creating/destroying 50+ parts per snake on grow/death causes GC spikes and memory leaks.
- **Solution**: Preallocate 1,000 body segments at game start. `BodySegmentPool:Acquire()` activates a segment, `Release(part)` deactivates (doesn't destroy). Maid tracks active segments.
- **Cleanup**: On snake death, `snakeMaid:DoCleaning()` releases all segments back to pool.
- **Pattern Source**: Roblox Memory Leak 001 + Maid cleanup pattern.

#### 4. **Leaderboard Update Throttling (DataStore-Critical)**
- **Problem**: Updating OrderedDataStore every food collection = rate limit death (60 + numPlayers × 10 requests/min limit).
- **Solution**: Cache stats in memory (`statsCache[userId] = {kills, length, food}`). Flush to OrderedDataStore every 60 seconds + on player leave using `UpdateAsync`.
- **Pattern Source**: Roblox DataStore Best Practices.

#### 5. **Input Validation for Speed Exploiters (Security-Critical)**
- **Problem**: Client sends movement direction; exploiter could send impossible speed or teleport.
- **Solution**: Client sends unit direction vector only. Server calculates `newPos = lastPos + (direction × validatedSpeed × deltaTime)`. Reject if distance exceeds max possible distance.
- **Pattern Source**: Roblox RemoteEvents Security.

---

## File Structure

```
build-a-complete-roblox-slither/
├── default.project.json              # Rojo project configuration
├── .context-foundry/
│   ├── scout-report.md
│   ├── architecture.md               # This document
│   └── session-summary.json
├── src/
│   ├── ServerScriptService/
│   │   ├── GameSystems/
│   │   │   ├── SnakeManager.lua      # Core snake lifecycle + collision
│   │   │   ├── FoodSpawner.lua       # Poisson disk food spawning
│   │   │   ├── RankService.lua       # Rank progression calculations
│   │   │   ├── LeaderboardService.lua # OrderedDataStore stats
│   │   │   ├── PlayerDataManager.lua # DataStore persistence
│   │   │   ├── ReviveService.lua     # Donut revival logic
│   │   │   └── ShieldManager.lua     # Spawn protection timers
│   │   ├── GameInitializer.server.lua # Server startup script
│   │   └── Tests/
│   │       ├── SnakeManager.spec.lua
│   │       ├── RankService.spec.lua
│   │       ├── FoodSpawner.spec.lua
│   │       └── PlayerDataManager.spec.lua
│   ├── ReplicatedStorage/
│   │   ├── Modules/
│   │   │   ├── SnakeConfig.lua       # Physics constants
│   │   │   ├── RankConfig.lua        # 20 rank definitions
│   │   │   ├── FoodConfig.lua        # Spawn rates, rewards
│   │   │   └── CustomizationData.lua # Colors, styles, effects
│   │   └── Shared/
│   │       ├── SpatialGrid.lua       # Collision optimization
│   │       ├── Maid.lua              # Cleanup pattern
│   │       ├── Signal.lua            # Event decoupling
│   │       └── BodySegmentPool.lua   # Object pooling
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       ├── SnakeController.lua   # Input capture + prediction
│   │       ├── CameraController.lua  # Zoom + FOV scaling
│   │       ├── MobileControls.lua    # Touch thumbstick + buttons
│   │       └── SnakeRenderer.lua     # Body interpolation
│   └── StarterGui/
│       ├── HUD/
│       │   └── HUD.client.lua        # Gold, rank, length, kills
│       ├── Leaderboard/
│       │   └── Leaderboard.client.lua
│       ├── CustomizationMenu/
│       │   └── CustomizationMenu.client.lua
│       ├── RevivePrompt/
│       │   └── RevivePrompt.client.lua
│       └── ShieldTimer/
│           └── ShieldTimer.client.lua
└── dist/
    └── SlitherSimulator.rbxlx        # Built place file
```

---

## Module Specifications

### Server Services

#### Module: SnakeManager.lua
**Responsibility**: Core snake lifecycle - creation, movement validation, collision detection, death handling.

**Key Files**: `src/ServerScriptService/GameSystems/SnakeManager.lua`

**Dependencies**:
- `ReplicatedStorage.Modules.SnakeConfig`
- `ReplicatedStorage.Shared.SpatialGrid`
- `ReplicatedStorage.Shared.BodySegmentPool`
- `ReplicatedStorage.Shared.Maid`
- `ShieldManager.lua` (check invulnerability)
- `RankService.lua` (get magnet range)
- `FoodSpawner.lua` (scatter food on death)
- `LeaderboardService.lua` (update kill stats)

**Public API**:
```lua
SnakeManager:CreateSnake(player) → snake
SnakeManager:MoveSnake(player, direction: Vector3) → void
SnakeManager:ActivateBoost(player) → void
SnakeManager:ActivateBrake(player) → void
SnakeManager:GrowSnake(player, segments: number) → void
SnakeManager:KillSnake(player, killer: Player?) → void
SnakeManager:GetSnakeData(player) → {headPos, rotation, length, color}
```

**State Structure**:
```lua
snakes[player] = {
  head: Part,                        -- Head part (collision detection)
  bodySegments: {Part},              -- Array of body segments
  maid: Maid,                        -- Cleanup tracker
  speed: number,                     -- Current speed (base + boost)
  boostCooldown: number,             -- Remaining cooldown (seconds)
  brakeCooldown: number,             -- Remaining cooldown (seconds)
  lastPosition: Vector3,             -- For teleport detection
  lastMoveTime: number,              -- For speed validation
  spatialCells: {cellKey},           -- Grid cells occupied
}
```

**Applied Patterns**:
- ✅ Roblox RemoteEvents Security: All movement validated server-side
- ✅ Roblox Performance 001: SpatialGrid avoids O(n²) collision checks
- ✅ Roblox Memory Leak 001: Maid cleanup on snake death
- ✅ Roblox Async Patterns: Signals for snake events (death, grow, rank up)

---

#### Module: FoodSpawner.lua
**Responsibility**: Continuous food generation with even distribution, auto-despawn, collection handling.

**Key Files**: `src/ServerScriptService/GameSystems/FoodSpawner.lua`

**Dependencies**:
- `ReplicatedStorage.Modules.FoodConfig`
- `ReplicatedStorage.Shared.SpatialGrid`

**Public API**:
```lua
FoodSpawner:Initialize() → void
FoodSpawner:SpawnFood(count: number) → void
FoodSpawner:ScatterFood(position: Vector3, count: number) → void  -- On snake death
FoodSpawner:CollectFood(player, food: Part) → void
FoodSpawner:GetFoodInRange(position: Vector3, radius: number) → {Part}
```

**Applied Patterns**:
- ✅ Spatial partitioning for even distribution + fast lookups
- ✅ Server-authoritative gold rewards (never trust client)
- ✅ Timeout cleanup prevents memory buildup

---

#### Module: RankService.lua
**Responsibility**: Rank progression calculations, magnet range/boost/brake stat calculations.

**Key Files**: `src/ServerScriptService/GameSystems/RankService.lua`

**Dependencies**:
- `ReplicatedStorage.Modules.RankConfig`

**Public API**:
```lua
RankService:GetRank(gold: number) → rank: number
RankService:GetMagnetRange(rank: number) → studs: number
RankService:GetBoostCooldown(rank: number) → seconds: number
RankService:GetBrakeCooldown(rank: number) → seconds: number
RankService:GetShieldDuration(rank: number) → seconds: number
RankService:GetRankThreshold(rank: number) → goldRequired: number
```

**Rank Configuration** (20 ranks):
```lua
-- RankConfig.lua:
RANKS = {
  {goldRequired = 0,      magnet = 10,  boostCD = 10.0, brakeCD = 8.0, shieldDuration = 10},
  {goldRequired = 100,    magnet = 12,  boostCD = 9.8,  brakeCD = 7.85, shieldDuration = 9},
  {goldRequired = 300,    magnet = 14,  boostCD = 9.6,  brakeCD = 7.7,  shieldDuration = 8},
  -- ... (17 more ranks)
  {goldRequired = 40000,  magnet = 50,  boostCD = 6.0,  brakeCD = 5.0,  shieldDuration = 5.0},
}
```

---

#### Module: LeaderboardService.lua
**Responsibility**: Monthly + all-time stat tracking via OrderedDataStore, badge assignment.

**Key Files**: `src/ServerScriptService/GameSystems/LeaderboardService.lua`

**Dependencies**:
- `DataStoreService` (OrderedDataStore)

**Public API**:
```lua
LeaderboardService:Initialize() → void
LeaderboardService:IncrementStat(player, statName: string, amount: number) → void
LeaderboardService:GetTopPlayers(statName: string, scope: "monthly" | "alltime", count: number) → {userId, value}
LeaderboardService:FlushStats(player) → void  -- Save to OrderedDataStore
LeaderboardService:ResetMonthlyStats() → void  -- Called on month change
```

**Applied Patterns**:
- ✅ Roblox DataStore Best Practices: Batched updates, retry logic, UpdateAsync
- ✅ Rate limit mitigation: In-memory cache + periodic flush

---

#### Module: PlayerDataManager.lua
**Responsibility**: DataStore persistence for rank, gold, donuts, customization, stats.

**Key Files**: `src/ServerScriptService/GameSystems/PlayerDataManager.lua`

**Dependencies**:
- `DataStoreService`
- `RankService.lua` (for rank calculations)

**Public API**:
```lua
PlayerDataManager:LoadData(player) → data
PlayerDataManager:SaveData(player) → success: boolean
PlayerDataManager:AddGold(player, amount: number) → void
PlayerDataManager:DeductGold(player, amount: number) → success: boolean
PlayerDataManager:AddDonuts(player, amount: number) → void
PlayerDataManager:UseDonuts(player, amount: number) → success: boolean
PlayerDataManager:GetRank(player) → rank: number
PlayerDataManager:SetRank(player, rank: number) → void
PlayerDataManager:GetCustomization(player) → {color, mouth, eyes, effects}
PlayerDataManager:SetCustomization(player, customization) → void
```

**Data Schema** (versioned):
```lua
playerData = {
  version = 1,  -- For future migrations
  data = {
    rank = 1,
    gold = 0,
    reviveDonuts = 3,  -- Free starter donuts
    customization = {
      color = Color3.fromRGB(255, 100, 100),  -- Default red
      mouth = "default",
      eyes = "default",
      effects = {},
    },
    stats = {
      totalKills = 0,
      longestLength = 0,
      totalFood = 0,
    },
  }
}
```

**Applied Patterns**:
- ✅ Roblox DataStore Best Practices: UpdateAsync, retry logic, schema versioning
- ✅ In-memory cache reduces DataStore requests
- ✅ Graceful degradation (defaults on failure)

---

#### Module: ReviveService.lua
**Responsibility**: Donut consumption, revival prompt, respawn with shield.

**Key Files**: `src/ServerScriptService/GameSystems/ReviveService.lua`

**Dependencies**:
- `PlayerDataManager.lua`
- `SnakeManager.lua`
- `ShieldManager.lua`

**Public API**:
```lua
ReviveService:OfferRevival(player) → void
ReviveService:AcceptRevival(player) → success: boolean
ReviveService:DeclineRevival(player) → void
```

**Applied Patterns**:
- ✅ Server validates donut availability (no client trust)
- ✅ Timeout prevents infinite prompts

---

#### Module: ShieldManager.lua
**Responsibility**: Spawn protection timers, invulnerability logic, visual effects.

**Key Files**: `src/ServerScriptService/GameSystems/ShieldManager.lua`

**Dependencies**:
- `RankService.lua` (for rank-based shield duration)

**Public API**:
```lua
ShieldManager:ActivateShield(player, duration: number?) → void
ShieldManager:IsShielded(player) → boolean
ShieldManager:GetRemainingTime(player) → seconds: number
```

**Applied Patterns**:
- ✅ Server-authoritative invulnerability (client UI is cosmetic)
- ✅ Auto-cleanup prevents stuck shields

---

### Client Scripts

#### Module: SnakeController.lua
**Responsibility**: Input capture (mouse/touch), movement requests, local prediction.

**Key Files**: `src/StarterPlayer/StarterPlayerScripts/SnakeController.lua`

**Dependencies**:
- `ReplicatedStorage.Modules.SnakeConfig`
- `MobileControls.lua` (for thumbstick input)

**Applied Patterns**:
- ✅ Client-side prediction for responsive controls
- ✅ Server reconciliation prevents drift
- ✅ Input throttling (20 Hz) reduces network traffic

---

#### Module: CameraController.lua
**Responsibility**: Zoom controls, FOV scaling by snake size, pinch/pan for mobile.

**Key Files**: `src/StarterPlayer/StarterPlayerScripts/CameraController.lua`

**Dependencies**:
- `SnakeController.lua` (for snake reference)

**Applied Patterns**:
- ✅ Dynamic FOV improves gameplay (larger snakes see more)
- ✅ Smooth interpolation prevents jarring camera jumps

---

#### Module: MobileControls.lua
**Responsibility**: Dynamic thumbstick + boost/brake buttons (mobile only).

**Key Files**: `src/StarterPlayer/StarterPlayerScripts/MobileControls.lua`

**Dependencies**:
- `UserInputService` (to detect mobile)

**Applied Patterns**:
- ✅ Touch-only initialization (no clutter on desktop)
- ✅ Thumbstick normalized to unit vector (same precision as mouse)

---

#### Module: SnakeRenderer.lua
**Responsibility**: Body segment interpolation for other players' snakes.

**Key Files**: `src/StarterPlayer/StarterPlayerScripts/SnakeRenderer.lua`

**Dependencies**:
- `ReplicatedStorage.Modules.SnakeConfig`

**Applied Patterns**:
- ✅ Client-side interpolation reduces network traffic (20 Hz server → 60 FPS client)
- ✅ Spring dampening creates natural body following motion
- ✅ Separation of local vs. other snakes (different rendering strategies)

---

### Shared Modules

#### Module: SpatialGrid.lua
**Responsibility**: O(n) collision detection via spatial partitioning.

**Key Files**: `src/ReplicatedStorage/Shared/SpatialGrid.lua`

**Implementation**:
- Divide arena into 64×64 stud cells
- Store body segments by cell key (`"x,z"`)
- Query returns parts in same + 8 adjacent cells (9 total)

**Applied Patterns**:
- ✅ O(n) collision detection (vs. O(n²) brute force)
- ✅ Roblox Performance 001: Avoid tight loops

---

#### Module: BodySegmentPool.lua
**Responsibility**: Object pooling to prevent GC spikes from dynamic segments.

**Key Files**: `src/ReplicatedStorage/Shared/BodySegmentPool.lua`

**Applied Patterns**:
- ✅ Object pooling prevents GC spikes
- ✅ Maid cleanup pattern for automatic resource management

---

#### Module: Maid.lua
**Responsibility**: Memory leak prevention via cleanup pattern.

**Key Files**: `src/ReplicatedStorage/Shared/Maid.lua`

**Applied Patterns**:
- ✅ Roblox Memory Leak 001: Disconnect events, clean up references
- ✅ Nevermore Engine Maid pattern

---

## Data Models

### Player Data Schema

```lua
{
  version = 1,
  data = {
    rank = 1,
    gold = 0,
    reviveDonuts = 3,
    customization = {
      color = Color3.fromRGB(255, 100, 100),
      mouth = "default",
      eyes = "default",
      effects = {},
    },
    stats = {
      totalKills = 0,
      longestLength = 0,
      totalFood = 0,
    },
  }
}
```

### Snake State (Server-Side)

```lua
snakes[player] = {
  head: Part,
  bodySegments: {Part},
  maid: Maid,
  speed: number,
  boostActive: boolean,
  brakeActive: boolean,
  boostCooldownRemaining: number,
  brakeCooldownRemaining: number,
  lastPosition: Vector3,
  lastMoveTime: number,
  spatialCells: {cellKey},
  color: BrickColor,
  mouth: string,
  eyes: string,
}
```

---

## API Design

### RemoteEvents (Client ↔ Server)

**Client → Server**:
```lua
RemoteEvent:FireServer("MoveSnake", direction: Vector3)
RemoteEvent:FireServer("ActivateBoost")
RemoteEvent:FireServer("ActivateBrake")
RemoteEvent:FireServer("AcceptRevival")
RemoteEvent:FireServer("DeclineRevival")
RemoteEvent:FireServer("SetCustomization", {color, mouth, eyes, effects})
```

**Server → Client**:
```lua
RemoteEvent:FireClient(player, "UpdateSnakes", {[playerId] = {headPos, rotation, length, color}})
RemoteEvent:FireClient(player, "GoldUpdated", newGold)
RemoteEvent:FireClient(player, "RankUp", newRank)
RemoteEvent:FireClient(player, "ShieldActivated", duration)
RemoteEvent:FireClient(player, "FoodCollected", goldValue)
RemoteEvent:FireClient(player, "SnakeDied", killer)
RemoteEvent:FireClient(player, "ShowRevivePrompt", donutCount)
```

---

## Applied Patterns & Preventive Measures

### From Roblox Expertise Patterns

✅ **roblox-remote-events-security**: All RemoteEvents validated (type, range, business logic). Server calculates all rewards and state changes.

✅ **roblox-datastore-best-practices**: UpdateAsync for atomic operations, retry logic with exponential backoff, schema versioning, in-memory cache.

✅ **roblox-performance-001**: SpatialGrid caches body segments by cell, :GetChildren() results cached, Heartbeat loops throttled.

✅ **roblox-memory-leak-001**: Maid cleanup pattern for all snakes, connections, segments. Strict :Disconnect() on death.

✅ **roblox-async-patterns-signals-maids**: Signal events for snake death, rank-up, food collection. Decoupled systems via event-driven architecture.

✅ **roblox-module-structure**: Services in ServerScriptService, shared modules in ReplicatedStorage, client scripts in StarterPlayerScripts.

✅ **roblox-studio-safety-net**: Mock DataStore in Studio (RunService:IsStudio()), fallback spawn arena, nil-guards in UI.

✅ **roblox-advanced-modules-and-performance**: Body segment updates throttled to 0.05s for other players, client interpolates at 60 FPS.

### From Critical Architecture Recommendations

✅ **Spatial Partitioning**: 64×64 stud grid, O(n) collision detection.

✅ **Client-Side Body Interpolation**: Server sends head position at 20 Hz, client interpolates segments at 60 FPS.

✅ **Dynamic Body Segment Pooling**: Preallocate 1,000 segments, acquire/release instead of create/destroy.

✅ **Leaderboard Update Throttling**: In-memory cache, flush to OrderedDataStore every 60s + on leave.

✅ **Input Validation for Speed Exploiters**: Server calculates position from validated speed, rejects teleportation.

### Risk Mitigations

⚠️ **Risk**: Network latency causes unfair collisions
✅ **Mitigation**: Server uses authoritative hitboxes, stores last 5 positions for rollback verification. If latency too high, favor defender (grace period).

⚠️ **Risk**: DataStore failures lose player data
✅ **Mitigation**: 3-retry exponential backoff, in-memory cache, warn player on failure, provide manual save button.

⚠️ **Risk**: Memory leaks from dynamic body segments
✅ **Mitigation**: Maid cleanup pattern, object pooling, strict :Disconnect() on death. Profile with DevConsole.

⚠️ **Risk**: Food spawning clusters in one area
✅ **Mitigation**: Poisson disk sampling, density tracking per cell, minimum distance enforcement.

⚠️ **Risk**: Mobile players disadvantaged vs. desktop
✅ **Mitigation**: Normalize input speeds, thumbstick has same precision as mouse (unit vector direction).

---

## Implementation Steps

### Phase 1: Core Snake Movement (Week 1)

1. **Project Setup**
   - Create Rojo project (`default.project.json`)
   - Set up directory structure (ServerScriptService, ReplicatedStorage, StarterPlayer)
   - Initialize shared modules (Maid, Signal, SpatialGrid, BodySegmentPool)

2. **Snake Movement**
   - Create SnakeConfig.lua (physics constants)
   - Implement SnakeManager:CreateSnake (head + initial body segments)
   - Implement server-side movement validation (direction vector, speed check)
   - Create SnakeController (client input capture, movement requests)
   - Add local prediction with server reconciliation

3. **Body Following**
   - Implement server-side body segment position updates (Heartbeat loop)
   - Create SnakeRenderer (client-side interpolation for other players)
   - Add spring dampening for smooth body following

4. **Basic Collision**
   - Implement SpatialGrid insertion/removal on segment position changes
   - Add collision detection in SnakeManager (head vs. nearby segments)
   - Implement KillSnake (cleanup, respawn)

5. **Food Spawning**
   - Create FoodConfig.lua
   - Implement FoodSpawner:SpawnFood (Poisson disk sampling)
   - Add Touched event handler for collection
   - Implement food timeout (auto-despawn after 5 min)

**Deliverable**: Playable prototype with snake movement, body following, collision death, food collection.

---

### Phase 2: Boost/Brake, Shield, Rank System (Week 2)

6. **Boost/Brake Abilities**
7. **Shield System**
8. **Rank Progression**
9. **Gold Currency**
10. **Magnet System**

**Deliverable**: Core gameplay loop complete with progression incentives.

---

### Phase 3: Leaderboards, Customization, Revival (Week 3)

11. **Leaderboards**
12. **Customization**
13. **Revival System**
14. **Food Scattering**

**Deliverable**: Full feature set complete with persistence and competitive elements.

---

### Phase 4: Mobile Controls, Camera, Polish (Week 4)

15. **Mobile Controls**
16. **Camera System**
17. **Visual Polish**
18. **Arena Features**
19. **Performance Optimization**
20. **Testing & Bug Fixes**

**Deliverable**: Polished, production-ready game with cross-platform support.

---

## Testing Requirements

### Unit Tests (TestEZ)

**File**: `src/ServerScriptService/Tests/SnakeManager.spec.lua`
- Test snake creation (initial state)
- Test movement validation (direction vectors, teleportation)
- Test collision detection (head vs. body)
- Test boost/brake cooldowns

**File**: `src/ServerScriptService/Tests/RankService.spec.lua`
- Test rank calculations from gold
- Test magnet range formulas
- Test cooldown calculations

**File**: `src/ServerScriptService/Tests/FoodSpawner.spec.lua`
- Test Poisson disk distribution (density checks)
- Test minimum distance enforcement
- Test auto-despawn timeout

**File**: `src/ServerScriptService/Tests/PlayerDataManager.spec.lua`
- Test DataStore save/load
- Test retry logic (mock failures)
- Test schema migrations

**How to run**:
```bash
# In Roblox Studio:
# 1. Install TestEZ from Roblox marketplace
# 2. Open Command Bar (View → Command Bar)
# 3. Run: require(game.ServerScriptService.Tests).run()
```

---

### Integration Tests (Manual in Studio)

1. **Movement**: 2+ players, verify snake follows mouse/touch accurately, body segments trail smoothly
2. **Collision**: Snake head touches body → death, food scatters, leaderboard updates
3. **Boost/Brake**: Cooldowns respect rank bonuses, visual effects show/hide correctly
4. **Food Collection**: Gold awarded matches rank, magnet auto-collects nearby food
5. **Rank Progression**: Collect enough gold → rank up, magnet range increases, UI updates
6. **Shield**: Spawn with shield, countdown displays, collision ignored for duration
7. **Leaderboards**: Kill/length/food stats update, monthly resets work, badges show top 10
8. **Revival**: Die with donuts → prompt shows, revive respawns with shield
9. **Customization**: Change colors/mouth/eyes → persists on rejoin
10. **Mobile**: Test on device - thumbstick moves, pinch zooms, boost/brake buttons work

---

### Performance Benchmarks

**Target**: 60 FPS with 20 snakes (50 segments each = 1,000 parts)

**Collision**: <5ms per frame for SpatialGrid queries
**Network**: <5KB/s per player for snake position updates
**Memory**: <500MB server memory (object pooling prevents leaks)

**Load Testing**: Stress test with 50+ concurrent players, monitor server performance, check DataStore throttling

---

## Success Criteria

### Functional Completeness
✅ Smooth 60 FPS snake movement (desktop + mobile)
✅ Fair collision detection (head vs. body, no false positives)
✅ Food spawning with even distribution (Poisson disk)
✅ Boost/Brake abilities with cooldowns
✅ Shield system (spawn protection, revival)
✅ 20 ranks with progression (gold → rank → magnet/cooldowns)
✅ Leaderboards (monthly + all-time, kills/length/food)
✅ Customization (colors, mouth/eyes, persist to DataStore)
✅ Revival system (donuts, respawn with shield)
✅ Mobile support (thumbstick, pinch zoom, touch buttons)
✅ Camera system (dynamic zoom, FOV scaling)

### Performance Targets
✅ 60 FPS client-side with 20 snakes visible
✅ <100ms latency for movement input → server response → visual update
✅ <5KB/s bandwidth per player
✅ <500MB server memory usage
✅ <5ms per frame for collision detection

### Security & Reliability
✅ All RemoteEvents validated (type, range, business logic)
✅ Server-authoritative rewards (gold, rank, kills)
✅ DataStore persistence with retry logic
✅ No memory leaks (Maid cleanup verified)
✅ No exploit vulnerabilities (speed, teleportation, currency)

---

## Deployment

**Build Command**:
```bash
rojo build default.project.json -o dist/SlitherSimulator.rbxlx
```

**Testing in Studio**:
1. Open `dist/SlitherSimulator.rbxlx` in Roblox Studio
2. Enable Studio API Access (File → Game Settings → Security → Enable Studio Access to API Services)
3. Press F5 to test locally (single-player)
4. Use "Test" → "Start Server and Players" for multiplayer testing (2+ clients)

**Publishing to Roblox**:
1. Test thoroughly in Studio (all integration tests pass)
2. File → Publish to Roblox
3. Create new game or update existing
4. Configure game settings:
   - Max Players: 20-50 (recommended based on performance targets)
   - Genre: Action, Multiplayer
   - Enable Studio API Access for live DataStore
5. Publish and test in live environment with real players

---

## Known Limitations & Future Improvements

### V1 Limitations
- **Monthly leaderboard reset**: Requires manual script trigger (no scheduled task)
- **Edge penalties**: Require careful tuning (playtest-driven balancing)
- **No Roblox-TS support**: Pure Luau only
- **Manual publishing**: No Open Cloud API automation

### V2 Roadmap
- **Scheduled monthly reset**: Use time-scoped OrderedDataStore keys
- **Advanced customization**: Particle trails, animated mouths, emotes
- **Spectate mode**: Watch other players after death
- **Team mode**: 2v2 or team deathmatch variants
- **Power-ups**: Temporary invincibility, speed boosts
- **Analytics dashboard**: Track player retention, session length

---

**Architecture Phase Complete**. Ready for Builder phase to implement code.

---

**Approved Architectural Inspirations**:
- **Knit Framework**: Service/controller pattern for SnakeManager, FoodSpawner, etc.
- **Nevermore Engine**: Maid cleanup pattern for body segment management
- **ProfileService**: DataStore session locking pattern (if needed for anti-dupe in V2)
- **TestEZ**: Unit testing framework for spec files

**Tags**: roblox, multiplayer, slither.io, server-authoritative, spatial-partitioning, object-pooling, datastore, leaderboards, mobile-support
