# Scout Report: Roblox Slither Simulator Clone

**Session ID**: build-a-complete-roblox-slither
**Phase**: Scout
**Date**: 2025-11-22

---

## Executive Summary

Building a complete multiplayer Slither.io-style game in Roblox featuring smooth snake movement with body segment physics, collision-based death mechanics, boost/brake abilities with cooldowns, dynamic food spawning system, 20-rank progression with scaling benefits (magnet range, boost/brake improvements), dual currency system (gold + revive donuts), shield spawn protection, comprehensive customization (colors, mouth/eyes, effects, emotes), triple-category leaderboards (kills, length, food consumed), death/revival mechanics with food scatter, arena boundaries with edge penalties, camera zoom/pan controls, and full mobile support (thumbstick, touch controls, pinch-to-zoom).

This is a **complex multiplayer game** requiring: (1) client-server architecture with authoritative server validation, (2) real-time physics for 20+ snakes with 50+ body segments each (1000+ dynamic parts), (3) spatial partitioning for O(n) collision detection, (4) object pooling to prevent GC spikes, (5) network-efficient body interpolation, (6) DataStore persistence with retry logic, (7) OrderedDataStore leaderboards with batched updates, (8) mobile input parity with desktop, and (9) 60 FPS performance optimization.

Key technical challenges: smooth body following with network latency, fair collision detection under lag, secure rank/currency progression (anti-cheat), scalable food distribution (Poisson disk sampling), efficient leaderboard updates (batch flush), memory leak prevention (Maid cleanup pattern), and mobile control fairness (normalized turn rates).

---

## Past Learnings Applied

### From Roblox Expertise Patterns

⚠️ **roblox-remote-events-security**: All snake movement, food collection, ability activation, and currency changes MUST validate server-side. Never trust client-reported speed, position, gold amounts, or rank. Implement rate limiting on RemoteEvents for boost/brake (prevent spam). Type-check all parameters.

⚠️ **roblox-datastore-best-practices**: Player rank, gold, revive donuts, customization choices, and leaderboard stats require UpdateAsync with 3-retry exponential backoff (1s, 2s, 4s) and pcall error handling. Implement schema versioning `{version=1, data={...}}` for future migrations. Cache all data in memory (ServerStorage) for resilience.

⚠️ **roblox-performance-001**: With 20+ snakes × 50+ segments = 1000+ parts, must cache :GetChildren() results, use spatial partitioning (64×64 studs grid) for collision checks, avoid tight loops in Heartbeat. Throttle body segment updates to 0.05-0.1s for non-local snakes (client interpolation).

⚠️ **roblox-memory-leak-001**: Snake body segments are dynamically created/destroyed. MUST use Maid/Janitor pattern to disconnect Touched events, clean up tweens, and release object pool references on death. Profile with DevConsole memory tab to verify no leaks.

⚠️ **roblox-async-patterns-signals-maids**: Use signals for snake events (food collected, rank up, death, revival) to decouple systems. Bind all Touched connections, RunService connections, and tweens through Maid. Call `snakeMaid:DoCleaning()` on death.

✅ **roblox-module-structure**: Organize as services in ServerScriptService/GameSystems (SnakeManager, FoodSpawner, RankService, LeaderboardService, PlayerDataManager, ReviveService, ShieldManager) with shared config in ReplicatedStorage/Modules.

✅ **roblox-studio-safety-net**: Mock DataStore in Studio (provide test data), fallback spawn arena if map not loaded, guard UI against nil rank/gold values (default to 0), gracefully handle missing customization data.

✅ **roblox-advanced-modules-and-performance**: Use spatial grid for collision (O(n) instead of O(n²)), object pool for body segments (prevent GC spikes), client-side body interpolation (reduce bandwidth), batched leaderboard updates (prevent DataStore rate limits).

---

## Key Requirements

### 1. Snake Movement System
- **Smooth head movement**: Follows mouse position (desktop) or dynamic thumbstick (mobile) with configurable turn rate
- **Body segment following**: CFrame interpolation using bezier curves or spring dampening, segments trail head naturally
- **Collision detection**: Death on head touching other snake bodies (excluding own body), server-authoritative hitboxes
- **Boost ability**: 20-50% speed increase (rank-dependent), visual light-up effect (glow/particle), cooldown system (15-30s, scales with rank)
- **Brake ability**: 50% speed reduction, red tint visual, enables sharper turning (2x turn rate), cooldown system (10-20s, scales with rank)
- **Wraparound physics**: Snakes exceeding arena boundaries teleport to opposite side (seamless transition)

### 2. Food & Consumption
- **Food spawning**: Continuous generation across arena using Poisson disk sampling (even distribution)
- **Snake growth**: +1 body segment per food consumed, dynamic segment creation from object pool
- **Gold reward**: Scales with rank (5 gold at Rank 1 → 195 gold at Rank 20), awarded on food collection
- **Visual feedback**: Particle effects, sound effects, magnet attraction animation (for high-rank players)

### 3. Shield System
- **Spawn protection**: 5-second invulnerability on respawn, 10 seconds for Rank 1 players (beginner advantage)
- **Shield visual**: Light blue semi-transparent sphere with pulsing effect
- **Countdown timer**: UI overlay showing remaining seconds (e.g., "Shield: 3s")
- **Invulnerability**: Collision checks disabled, can pass through other snakes' bodies safely

### 4. Arena & Boundaries
- **Large playable arena**: 2000×2000 studs (adjustable), visible edge markers (walls/force fields)
- **Edge penalty**: Snakes >200 length touching edges for 3+ consecutive seconds lose 5% length every 2 seconds
- **Tactical edge use**: Brief edge contact (<3s) allowed for positioning, no penalty for snakes <200 length
- **Boundary wraparound**: Seamless teleportation to opposite side when crossing boundaries

### 5. Camera System
- **Zoom controls**: Keybinds (Q/E or +/-) to zoom out/in, revealing opponent positions
- **Dynamic FOV**: Larger snakes (>100 segments) have wider camera view (FOV scales with length)
- **Mobile support**: Pinch-to-zoom gesture, swipe-to-pan gesture for camera control
- **Smooth transitions**: Camera position/FOV interpolates smoothly (no sudden jumps)

### 6. Rank System (20 Ranks)
- **Gold-based progression**: Each rank requires increasing gold thresholds (e.g., Rank 1: 0g, Rank 2: 500g, Rank 20: 50,000g)
- **Magnet range scaling**: Auto-collect nearby food within radius (Rank 1: 10 studs → Rank 20: 100 studs)
- **Boost improvements**: Faster speed (+10% per 5 ranks), longer duration (+2s per 5 ranks), shorter cooldown (-3s per 5 ranks)
- **Brake improvements**: Better turn rate (+20% per 5 ranks), shorter cooldown (-2s per 5 ranks)
- **DataStore persistence**: Save player rank, load on join, never reset (lifetime progression)

### 7. Currency System
- **Gold**: Primary currency earned from food consumption (5-195 gold per food based on rank)
- **Revive Donuts**: Limited-use revival items, players start with 3 free, max capacity 12
- **Random donut drops**: Spawn in arena every 3-5 minutes (random location), collectible by any player
- **DataStore persistence**: Save gold and donut counts, load on join

### 8. Snake Customization
- **Color selection**: Preset colors (10 options) + custom RGB sliders (0-255 for R/G/B)
- **Mouth styles**: 5 options (default, wide, small, triangle, circle)
- **Eye styles**: 5 options (default, angry, happy, sleepy, spiral)
- **Visual effects**: Non-collidable cosmetic (trail particles, glow, sparkles) - optional cosmetic purchases
- **Emote system**: 8 emotes (happy, sad, angry, wave, taunt, celebrate, laugh, cry) with cooldown (5s)
- **DataStore persistence**: Save customization choices, apply on join

### 9. Leaderboards
- **Monthly rankings**: Resets on 1st of each month (automatic server-side reset)
- **All-time rankings**: Never resets, lifetime stats
- **Three categories**:
  - Kills (total opponent snakes killed)
  - Longest Length (max body segments achieved in single life)
  - Hungriest (total food consumed across all lives)
- **Top player badges**: Pink numbered shield badges (1-10) displayed above snake head
- **Leaderboard UI**: Scrollable frame showing top 100 players, tabs for Monthly/All-Time and category selection

### 10. Death & Revival
- **Death trigger**: Head collides with other snake body → instant death
- **Food scatter**: Snake body converts to food (1 food per 2 body segments), scatters in area
- **Revival option**: If player has revive donuts, prompt appears "Revive? (X donuts remaining)"
- **Respawn with shield**: On revival or natural respawn, player gets shield protection (5-10s based on rank)
- **Leaderboard update**: Update kill count for killer, reset current length for dead player

### 11. Mobile Support
- **Dynamic thumbstick**: Bottom-left of screen, draggable joystick for movement direction
- **Touch boost/brake buttons**: Bottom-right of screen, large tap targets, cooldown overlay
- **Pinch-to-zoom**: Two-finger pinch gesture scales camera FOV
- **Swipe-to-pan**: Two-finger swipe gesture moves camera position (within bounds)
- **Responsive UI**: All UI elements scale for phone/tablet screens

### 12. Monetization Framework (Optional)
- **Double Gold gamepass**: 2x gold earned per food (cosmetic advantage, not pay-to-win)
- **VIP/Premium benefits**: Extended shield duration (+3s), exclusive cosmetic effects
- **Cosmetic purchases**: Special trails, glow effects, eye/mouth styles (Robux currency)

---

## Technology Stack

**Project Structure**: Rojo-based Roblox game project (`default.project.json`)

**Core Systems** (ModuleScripts in ReplicatedStorage/Modules):
- `SnakeConfig.lua` - Snake physics constants (base speed: 16 studs/s, turn rate: 120°/s, boost multiplier: 1.5, segment spacing: 3 studs, segment size: 2 studs)
- `RankConfig.lua` - 20 rank thresholds (gold requirements), magnet ranges (10-100 studs), boost/brake cooldowns and durations
- `FoodConfig.lua` - Food spawn rates (3-5 food per second), gold rewards by rank (5-195), Poisson disk minimum distance (8 studs)
- `CustomizationData.lua` - Available colors (10 presets + RGB), mouth styles (5), eye styles (5), visual effects (8), emotes (8)

**Server Services** (ServerScriptService/GameSystems):
- `SnakeManager.lua` - Snake creation, movement validation (anti-speed-hack), collision detection (spatial grid), death handling, respawn logic
- `FoodSpawner.lua` - Continuous food spawning with Poisson disk sampling, density tracking per grid cell, despawn old food (5min timeout)
- `RankService.lua` - Rank progression calculations, magnet range application, boost/brake stat scaling, rank-up event dispatching
- `LeaderboardService.lua` - Monthly/all-time stat tracking using OrderedDataStore (6 stores: kills, length, food × monthly/all-time), batched updates (60s flush), top 100 queries
- `PlayerDataManager.lua` - DataStore persistence (rank, gold, donuts, customization, stats), 3-retry exponential backoff, schema versioning, save queue on failure
- `ReviveService.lua` - Donut consumption validation, respawn logic with shield, UI prompt handling
- `ShieldManager.lua` - Spawn protection timers (5-10s based on rank), invulnerability logic (disable collision checks), visual effect management

**Client Scripts** (StarterPlayer/StarterPlayerScripts):
- `SnakeController.lua` - Mouse/touch input capture, server movement requests (RemoteEvent with direction vector), local prediction with server reconciliation
- `CameraController.lua` - Zoom controls (Q/E or +/-), FOV scaling by snake size (50-120 FOV range), smooth interpolation (0.1s tween)
- `MobileControls.lua` - Dynamic thumbstick UI (GuiButton with dragging), boost/brake touch buttons, mobile-only visibility (UserInputService.TouchEnabled)
- `SnakeRenderer.lua` - Smooth body segment interpolation for other players' snakes (bezier curve following), visual effects (glow on boost, red tint on brake)

**UI** (StarterGui):
- `HUD.lua` - Gold display (TextLabel), rank display (ImageLabel + TextLabel), length display (TextLabel), kill count display (TextLabel), boost/brake cooldown indicators (circular progress)
- `Leaderboard.lua` - Top players list (ScrollingFrame), monthly/all-time tabs (TextButton), category tabs (kills/length/food), badge rendering (top 10 pink shields)
- `CustomizationMenu.lua` - Color picker (preset buttons + RGB sliders), mouth/eye selection (ImageButtons), visual effect toggles (CheckBoxes), emote selector (ImageButtons)
- `RevivePrompt.lua` - Death screen overlay (Frame), revive button (TextButton), donut count display (TextLabel), respawn timer (TextLabel)
- `ShieldTimer.lua` - Countdown overlay (BillboardGui above snake head), remaining seconds display (TextLabel), pulsing effect (TweenService)

**Shared Utilities** (ReplicatedStorage/Shared):
- `SpatialGrid.lua` - 64×64 studs grid cells, Insert/Remove/GetNearby methods, O(n) collision optimization
- `Maid.lua` - Cleanup pattern for connections, tweens, parts, events (prevents memory leaks)
- `Signal.lua` - Event system for decoupled snake events (food collected, rank up, death, revival)
- `ObjectPool.lua` - Body segment pooling (preallocate 1000 segments, Acquire/Release methods)

**Rationale**: Roblox + Rojo for version-controlled Luau development. Server-authoritative architecture prevents exploits (client sends input, server validates and applies). ModuleScript organization for testability and reusability. DataStore for persistence. OrderedDataStore for leaderboards. Spatial partitioning and object pooling for performance. Maid pattern for memory safety.

---

## Critical Architecture Recommendations

### 1. **Spatial Partitioning for Collision Detection** (PERFORMANCE-CRITICAL)

With 20+ snakes × 50+ segments = 1000+ parts, checking every head against every body segment = O(n²) catastrophe (1,000,000 checks per frame = 16,666 checks per ms at 60 FPS).

**Solution**: Spatial grid with 64×64 studs cells. Only check head vs. parts in same + adjacent 8 cells (max 9 cells).

```lua
-- Pattern: SpatialGrid:Insert(bodyPart, position) → cellKey
-- Collision: SpatialGrid:GetNearby(headPosition, radius) → {bodyParts}
-- Only check head vs parts in nearby cells (reduced from 1000 parts to ~50 parts)
-- Performance: O(n²) → O(n), <5ms collision checks per frame
```

**Implementation**:
- Update grid on segment position changes (throttled to 0.05s for non-local snakes)
- Cache cell keys to avoid redundant calculations
- Clear stale entries on snake death (Maid cleanup)

### 2. **Client-Side Body Interpolation with Server Authority** (NETWORK-CRITICAL)

Replicating every body segment position every frame = bandwidth explosion (1000 segments × 16 bytes × 60 FPS = 960KB/s per player = instant lag).

**Solution**: Server sends head CFrame + length at 20Hz (50ms). Client interpolates body segments locally at 60 FPS using bezier curves or spring dampening. Server only validates collisions.

```lua
-- Server: Broadcast head CFrame + length every 0.05s (20Hz)
-- Client: Interpolate segments to follow head smoothly at 60 FPS
-- Security: Server validates head position against speed limits (detect teleportation exploits)
-- Network savings: 960KB/s → 5KB/s (192x reduction)
```

**Implementation**:
- Local snake: Client-side prediction (instant response), server reconciliation on mismatch
- Other snakes: Interpolation buffer (0.1s delay for smooth movement)
- Physics timestep-independent rendering (deltaTime-based interpolation)

### 3. **Dynamic Body Segment Pooling** (MEMORY-CRITICAL)

Creating/destroying 50+ parts per snake on grow/death = GC spikes (100ms pauses = dropped frames).

**Solution**: Object pool pattern. Preallocate 1000 body segments at server start, activate/deactivate as needed. Bind to Maid for cleanup.

```lua
-- BodySegmentPool:Acquire() → part (from inactive pool, set Parent to Workspace)
-- BodySegmentPool:Release(part) → return to pool (set Parent to nil, don't Destroy)
-- Maid tracks active segments, releases on snake death
-- Memory savings: No GC spikes, constant memory usage (500MB vs. 2GB with spikes)
```

**Implementation**:
- Preallocate 1000 segments (BasePart clones) on server start
- Track inactive pool (array of available parts) and active assignments (map of snake → parts)
- Reset part properties on Release (Color, Transparency, CFrame)
- Profile with DevConsole memory tab (verify no leaks)

### 4. **Leaderboard Update Throttling** (DATASTORE-CRITICAL)

Updating OrderedDataStore every food collection = rate limit death (60 requests/min limit = 1 request/second, but 20 players collecting 5 food/sec = 100 requests/second).

**Solution**: Batch updates. Cache stats in memory, flush to OrderedDataStore every 60 seconds + on player leave. Use UpdateAsync to prevent race conditions.

```lua
-- Cache: statsCache[userId] = {kills=5, length=120, food=89}
-- Flush: Every 60s → OrderedDataStore:UpdateAsync(userId, ...)
-- On leave: Immediate flush with 3-retry exponential backoff
-- Rate limit safety: 20 players × 6 stores = 120 requests per minute (under 60/min limit with 2 flushes)
```

**Implementation**:
- In-memory cache (table in ServerStorage) for all player stats
- RunService.Heartbeat loop for periodic flush (60s timer)
- Players.PlayerRemoving event for immediate flush (with retry queue)
- UpdateAsync with oldValue merge (prevent race condition data loss)

### 5. **Input Validation for Speed Exploiters** (SECURITY-CRITICAL)

Client sends movement direction, server calculates position based on validated speed (base + boost multiplier). Reject impossible positions (teleportation detection).

```lua
-- Client: RemoteEvent:FireServer("move", direction) -- unit vector
-- Server: validatedSpeed = baseSpeed * (isBoosting and boostMultiplier or 1)
--         newPos = lastPos + (direction * validatedSpeed * deltaTime)
--         if (newPos - lastPos).Magnitude > maxPossibleDistance then
--             kick player (exploit detected)
-- Anti-cheat: Log suspicious movements (>2x expected speed) for manual review
```

**Implementation**:
- Server tracks last known position + timestamp for each snake
- Validate movement distance against max possible (speed × deltaTime + 20% tolerance for latency)
- Rate-limit RemoteEvent calls (max 60 requests/second per player)
- Type-check direction vector (must be unit length, no NaN/inf values)

---

## Main Challenges & Mitigations

### 1. **Challenge**: Smooth 60 FPS snake movement with network latency (100-200ms typical)
**Mitigation**: Client-side prediction for local snake (instant response), server reconciliation. Other snakes use interpolation buffer (0.1s delay, smooth). Physics timestep-independent rendering (deltaTime-based). Store last 5 server positions for rollback verification on collision disputes.

### 2. **Challenge**: Fair collision detection with body segment lag (server sees different positions than client)
**Mitigation**: Server uses authoritative hitboxes (final source of truth). On collision, verify both client and server agree within tolerance (±5 studs). If latency too high (>300ms), favor defender (snake gets brief shield grace period). Use spatial grid to minimize false positives.

### 3. **Challenge**: Food spawning distribution (avoid clustering in same area, avoid spawning inside snakes)
**Mitigation**: Use Poisson disk sampling for even distribution (minimum 8 studs between food). Track food density per grid cell (max 10 food per 64×64 cell), spawn in low-density areas. Check spatial grid for nearby snake segments before spawning. Despawn old food after 5 minutes to prevent buildup (max 500 food in arena).

### 4. **Challenge**: Mobile touch controls vs. desktop mouse (fairness concerns - mouse may be more precise)
**Mitigation**: Normalize input speeds - both control schemes achieve same max turn rate (120°/s). Mobile thumbstick uses unit vector direction (same as mouse). Add mobile-specific sensitivity slider. Test on iOS/Android devices for parity. Consider mobile-only server pool if fairness issues persist.

### 5. **Challenge**: DataStore failures during peak traffic (rate limits, server errors, data loss)
**Mitigation**: Implement 3-retry exponential backoff (1s, 2s, 4s delays). Cache ALL data in memory (ServerStorage). On save failure, queue for retry (max 10 retries). Warn player "Data saving failed, please don't leave yet" (UI alert). Provide manual save button in settings. Log failures to Analytics for monitoring.

### 6. **Challenge**: Memory leaks from dynamic body segments (1000+ parts created/destroyed, connections not cleaned up)
**Mitigation**: Strict Maid cleanup pattern. Every snake gets Maid instance. All segments, connections (Touched, Heartbeat, InputBegan), tweens added to Maid. On death: `snakeMaid:DoCleaning()` destroys everything. Use object pool to reuse parts (no Destroy calls). Profile with DevConsole memory tab (watch for climbing memory usage over 30min test).

---

## Testing Approach

### Unit Tests (TestEZ in ServerScriptService/Tests)
- `SnakeManager.spec.lua`: Movement validation (reject invalid direction vectors), collision detection (spatial grid accuracy), death handling (food scatter calculation), respawn logic (shield application)
- `RankService.spec.lua`: Rank calculations (gold thresholds), magnet range formulas (linear scaling), boost/brake stat scaling (verify rank 1 vs. rank 20 differences)
- `FoodSpawner.spec.lua`: Poisson disk sampling (verify minimum distance), density checks (max food per cell), despawn logic (5min timeout)
- `PlayerDataManager.spec.lua`: DataStore mock (save/load), retry logic (exponential backoff), schema migration (v1 → v2), UpdateAsync race condition handling

### Integration Tests (Manual in Studio with 2+ local players)
1. **Movement**: 2+ players, verify snake follows mouse/touch accurately (no jitter), body segments trail smoothly (no gaps/overlaps), turn rate matches config
2. **Collision**: Snake head touches body → instant death, food scatters (1 food per 2 segments), leaderboard updates (killer +1 kill, dead player stats saved)
3. **Boost/Brake**: Cooldowns respect rank bonuses (Rank 1: 30s, Rank 20: 15s), visual effects show/hide correctly (glow on boost, red tint on brake), speed changes apply immediately
4. **Food Collection**: Gold awarded matches rank (Rank 1: 5g, Rank 20: 195g), magnet auto-collects nearby food (range scales with rank), body grows by 1 segment per food
5. **Rank Progression**: Collect enough gold → rank up (UI notification), magnet range increases (verify auto-collect radius), boost/brake cooldowns decrease (measure times)
6. **Shield**: Spawn with shield (5-10s based on rank), countdown displays correctly (updates every second), collision ignored for duration (can pass through snakes), visual effect shows (light blue sphere)
7. **Leaderboards**: Kill/length/food stats update in real-time, monthly resets work (test with mocked date), badges show for top 10 (pink numbered shields above heads)
8. **Revival**: Die with donuts → prompt shows ("Revive? X donuts remaining"), click revive → respawn with shield, donut count decreases by 1, gold/rank preserved
9. **Customization**: Change colors/mouth/eyes → applies immediately to snake, persists on rejoin (verify DataStore load), RGB sliders work (0-255 range)
10. **Mobile**: Test on iOS/Android device - thumbstick moves snake, pinch zooms camera (FOV changes), boost/brake buttons work (cooldown overlay shows), swipe pans camera

### Performance Benchmarks (Measure in Studio with simulated load)
- **Target**: 60 FPS client-side with 20 snakes (50 segments each = 1000 parts), 30 FPS minimum acceptable
- **Collision**: <5ms per frame for spatial grid queries (DevConsole > Scripts > SnakeManager collision function)
- **Network**: <5KB/s per player for snake position updates (DevConsole > Network > incoming data rate)
- **Memory**: <500MB server memory (DevConsole > Memory > total usage), no climbing over 30min test (detect leaks)
- **DataStore**: <50 requests/minute (DevConsole > DataStore requests counter), no rate limit warnings

### Load Testing (Post-launch in live environment)
- Stress test with 50+ concurrent players (monitor server performance)
- Check script execution time (DevConsole > Scripts > sort by time per frame, flag >5ms functions)
- Monitor memory usage (should stabilize after 10min, not climb continuously)
- Verify DataStore throttling (should stay under 60 requests/min with batching)
- Collect player feedback on mobile controls (fairness vs. desktop)

---

## Timeline Estimate

**Estimated Development**: 3-4 weeks for complete implementation with testing, assuming 20-30 hours/week (60-120 total hours).

**Phased Breakdown**:
- **Phase 1** (Week 1, 20-30 hours): Core snake movement + body following + basic collision + food spawning → **Playable prototype** (can move, eat, grow, die)
- **Phase 2** (Week 2, 20-30 hours): Boost/brake abilities + shield system + rank system + gold currency + magnet auto-collect → **Core loop complete** (progression incentive)
- **Phase 3** (Week 3, 20-30 hours): Leaderboards + customization + revival system + DataStore persistence → **Full feature set** (competitive + personalization)
- **Phase 4** (Week 4, 20-30 hours): Mobile controls + camera system + polish (VFX, SFX, UI animations) + performance optimization + testing → **Launch-ready**

---

## Roblox-Specific Patterns Applied

### Directory Layout (Rojo-based, maps to Roblox place file structure)
```
src/
├── ServerScriptService/
│   ├── GameSystems/
│   │   ├── SnakeManager.lua          -- Core snake logic
│   │   ├── FoodSpawner.lua           -- Food generation
│   │   ├── RankService.lua           -- Rank progression
│   │   ├── LeaderboardService.lua    -- OrderedDataStore stats
│   │   ├── PlayerDataManager.lua     -- DataStore persistence
│   │   ├── ReviveService.lua         -- Donut revival
│   │   └── ShieldManager.lua         -- Spawn protection
│   └── Tests/
│       ├── SnakeManager.spec.lua     -- TestEZ unit tests
│       └── RankService.spec.lua      -- TestEZ unit tests
├── ReplicatedStorage/
│   ├── Modules/
│   │   ├── SnakeConfig.lua           -- Physics constants
│   │   ├── RankConfig.lua            -- 20 rank data
│   │   ├── FoodConfig.lua            -- Spawn rates
│   │   └── CustomizationData.lua     -- Cosmetic options
│   └── Shared/
│       ├── SpatialGrid.lua           -- Collision optimization
│       ├── Maid.lua                  -- Cleanup pattern
│       ├── Signal.lua                -- Event system
│       └── ObjectPool.lua            -- Body segment pooling
├── StarterPlayer/
│   └── StarterPlayerScripts/
│       ├── SnakeController.lua       -- Input handling
│       ├── CameraController.lua      -- Zoom/pan
│       ├── MobileControls.lua        -- Thumbstick/buttons
│       └── SnakeRenderer.lua         -- Body interpolation
└── StarterGui/
    ├── HUD/                          -- Gold, rank, length
    ├── Leaderboard/                  -- Top players
    ├── CustomizationMenu/            -- Color picker
    ├── RevivePrompt/                 -- Death screen
    └── ShieldTimer/                  -- Countdown overlay
```

### Security Checklist (RemoteEvent validation)
- ✅ Validate all movement direction vectors (must be unit length: `direction.Magnitude ≈ 1`, no NaN/inf)
- ✅ Rate-limit boost/brake requests (cooldown enforcement server-side, reject rapid requests >1/second)
- ✅ Never trust client gold amounts (server calculates from food collected, client UI is display only)
- ✅ Verify rank progression server-side (client cannot trigger rank-up, only food collection counts)
- ✅ Validate customization choices against allowed values (check CustomizationData.lua whitelist)
- ✅ Type-check all RemoteEvent parameters (use `typeof()`, reject unexpected types)
- ✅ Kick exploiters on repeated validation failures (log to Analytics for tracking)

### DataStore Strategy
- **PlayerData** (DataStoreService): `{version=1, data={rank, gold, reviveDonuts, customization, stats}}`
- **Leaderboards** (OrderedDataStoreService): 6 stores (kills_monthly, kills_alltime, length_monthly, length_alltime, food_monthly, food_alltime)
- **Retry Logic**: 3 attempts with exponential backoff (1s, 2s, 4s) on failure, queue for manual retry if all fail
- **Schema Versioning**: `{version=1, ...}` wrapper for future migrations (e.g., v2 adds new fields)
- **Save Cadence**: Every 5 minutes (auto-save loop) + on player leave (immediate flush) + on rank up (preserve progress)
- **UpdateAsync**: Use for all writes (prevents race condition data loss if player joins multiple servers)

---

## Anti-Patterns to Avoid

❌ **Don't**: Replicate every body segment position every frame (bandwidth explosion, 960KB/s per player)
✅ **Do**: Server sends head position at 20Hz, client interpolates body segments locally (5KB/s per player)

❌ **Don't**: Check collision between all snakes' all segments (O(n²), 1,000,000 checks per frame)
✅ **Do**: Use spatial grid to only check nearby segments (O(n), ~50 checks per frame)

❌ **Don't**: Create/destroy body segments on every grow/shrink (GC spikes, 100ms pauses)
✅ **Do**: Use object pool to reuse parts (constant memory, no GC)

❌ **Don't**: Update leaderboard OrderedDataStore every food collection (rate limit death, 100 requests/s)
✅ **Do**: Batch updates every 60 seconds + on leave (20 requests/min, under limit)

❌ **Don't**: Trust client-reported speed, position, or gold amounts (exploits rampant)
✅ **Do**: Server validates all state changes, kick on repeated violations

❌ **Don't**: Use `while true do ... end` without `task.wait()` (script timeout, server crash)
✅ **Do**: Always include `task.wait()` in loops (yield control, prevent timeout)

❌ **Don't**: Store snake references in `_G` or global tables (memory leaks, hard to debug)
✅ **Do**: Use proper module returns and clean up with Maid (explicit lifecycle)

❌ **Don't**: Use :Destroy() on body segments frequently (GC spikes, performance hit)
✅ **Do**: Return segments to object pool (set Parent to nil, reuse later)

---

## Implementation Priority Order

### Phase 1: Core Gameplay (Week 1)
1. ✅ **Snake Movement & Body Following** - Core gameplay foundation (smooth head, trailing body)
2. ✅ **Collision Detection** - Death mechanics (head vs. body, spatial grid)
3. ✅ **Food Spawning & Collection** - Growth loop (Poisson disk, gold reward, body segment +1)
4. ✅ **Basic Arena** - Boundaries with wraparound physics

### Phase 2: Abilities & Progression (Week 2)
5. ✅ **Boost/Brake Abilities** - Tactical gameplay (speed changes, visual effects, cooldowns)
6. ✅ **Shield System** - Spawn protection (invulnerability, countdown timer, visual)
7. ✅ **Rank Progression & Gold** - Progression incentive (20 ranks, thresholds, UI)
8. ✅ **Magnet System** - Rank benefit (auto-collect food, range scaling)

### Phase 3: Social & Persistence (Week 3)
9. ✅ **Leaderboards** - Competitive layer (kills, length, food; monthly, all-time; top 100 UI)
10. ✅ **Customization & DataStore** - Personalization + persistence (colors, mouth/eyes, effects, emotes)
11. ✅ **Revival System** - Revive donuts (death prompt, respawn with shield, donut spawns)

### Phase 4: Polish & Platform Support (Week 4)
12. ✅ **Mobile Controls** - Platform support (thumbstick, touch buttons, pinch/swipe)
13. ✅ **Camera System** - Zoom/pan/FOV (keybinds, scaling by size, smooth transitions)
14. ✅ **Polish** - VFX (particles, glow), SFX (eat, death, rank up), UI animations (tweens), edge penalties (-5% length), arena improvements

---

## Deployment Readiness

Checking deployment environment...

- ✅ **Rojo Installed**: Required for building `.rbxlx` place file from source code (`rojo build default.project.json -o dist/SlitherSimulator.rbxlx`)
- ✅ **Roblox Studio**: Required for testing (F5 local server) and publishing (File → Publish to Roblox)
- ⚠️ **DataStore API Access**: Must enable in Studio (File → Game Settings → Security → Enable Studio Access to API Services) for testing DataStore save/load
- ⚠️ **Publishing**: Manual via Roblox Studio (File → Publish to Roblox) - no automated deployment via Open Cloud API in V1

**Deployment Status**: ⚠️ Manual deployment required (Context Foundry V1 does not automate publishing to Roblox cloud)

**Build Command**:
```bash
rojo build default.project.json -o dist/SlitherSimulator.rbxlx
```

**Testing in Studio**:
1. Open `dist/SlitherSimulator.rbxlx` in Roblox Studio
2. Enable Studio API Access (File → Game Settings → Security → Enable Studio Access to API Services)
3. Press F5 to start local server (Test tab → Play)
4. Open multiple client windows (Test tab → Clients and Servers → 2 Players) for multiplayer testing

**Publishing to Roblox**:
1. Test thoroughly in Studio (all 10 integration tests pass, performance benchmarks met)
2. File → Publish to Roblox (or File → Publish to Roblox As... for new game)
3. Create new game or update existing place
4. Configure game settings:
   - Max players: 20-50 recommended (performance-tested)
   - Server fill: Roblox Optimized (auto-balance servers)
   - Enable Studio API Access: Yes (for DataStore)
5. Test in live environment with multiple real players (monitor DevConsole for issues)
6. Monitor Analytics (player retention, average session length, common death causes)

---

## Additional Notes

### Inspirations from Approved Roblox Frameworks
- **Knit Framework** (Sleitnick): Service/controller pattern for SnakeManager, FoodSpawner, etc. (separation of server/client logic)
- **Nevermore Engine** (Quenty): Maid cleanup pattern for body segment management (prevents memory leaks)
- **ProfileService** (loleris): DataStore session locking pattern (if needed for anti-dupe in future, not V1 priority)

### Performance Targets (Must-Hit for Launch)
- **60 FPS** client-side with 20 snakes visible (1000 parts), 30 FPS minimum acceptable
- **<100ms** latency for movement input → server response → visual update (measured with ping tool)
- **<5KB/s** bandwidth per player (network efficiency, critical for mobile players)
- **<500MB** server memory usage (object pooling critical, prevents server crashes)

### Known Limitations (V1 Scope)
- No Roblox-TS support (pure Luau only, TypeScript not in V1 scope)
- Manual publishing only (no Open Cloud API automation for CI/CD)
- Monthly leaderboard reset requires manual script trigger (V2: scheduled server-side reset via os.time() checks)
- Edge penalties (-5% length) require careful tuning (too harsh = frustrating, too lenient = exploitable camping)
- No cross-server leaderboards (each server instance independent, V2: MessagingService aggregation)

### Future Enhancements (V2 Scope, Post-Launch)
- Team mode (2-4 player co-op snakes, shared length pool)
- Power-ups (speed boost, invincibility, ghost mode, magnet supercharge)
- Seasonal events (Halloween cosmetics, Christmas themes, limited-time challenges)
- Clans/guilds (clan leaderboards, shared rewards, clan wars)
- Spectator mode (watch top players after death, learn strategies)
- Replays (save last 30 seconds before death, share on social)

---

**Scout Phase Complete**.

✅ All 12 core systems analyzed
✅ Roblox-specific patterns applied (from extension patterns)
✅ Critical performance/security/architecture recommendations documented
✅ Testing strategy defined (unit, integration, performance, load)
✅ Timeline estimated (3-4 weeks, phased breakdown)
✅ Deployment checklist prepared (Rojo build → Studio test → Roblox publish)

**Ready for Architect phase** to design detailed system architecture, module APIs, and data schemas.
