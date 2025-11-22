#!/bin/bash

# verify-build.sh
# Verifies that all required files are present for the Roblox Slither Simulator

echo "🔍 Verifying Roblox Slither Simulator Build..."
echo ""

MISSING=0
TOTAL=0

check_file() {
    TOTAL=$((TOTAL + 1))
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ MISSING: $1"
        MISSING=$((MISSING + 1))
    fi
}

echo "📁 Project Configuration:"
check_file "default.project.json"
check_file "README.md"
echo ""

echo "📦 Shared Modules (ReplicatedStorage):"
check_file "src/ReplicatedStorage/Shared/Maid.lua"
check_file "src/ReplicatedStorage/Shared/Signal.lua"
check_file "src/ReplicatedStorage/Shared/SpatialGrid.lua"
check_file "src/ReplicatedStorage/Shared/BodySegmentPool.lua"
echo ""

echo "⚙️ Configuration Modules:"
check_file "src/ReplicatedStorage/Modules/SnakeConfig.lua"
check_file "src/ReplicatedStorage/Modules/RankConfig.lua"
check_file "src/ReplicatedStorage/Modules/FoodConfig.lua"
check_file "src/ReplicatedStorage/Modules/CustomizationData.lua"
echo ""

echo "🖥️ Server Services:"
check_file "src/ServerScriptService/GameSystems/PlayerDataManager.lua"
check_file "src/ServerScriptService/GameSystems/RankService.lua"
check_file "src/ServerScriptService/GameSystems/ShieldManager.lua"
check_file "src/ServerScriptService/GameSystems/FoodSpawner.lua"
check_file "src/ServerScriptService/GameSystems/LeaderboardService.lua"
check_file "src/ServerScriptService/GameSystems/SnakeManager.lua"
check_file "src/ServerScriptService/GameSystems/ReviveService.lua"
check_file "src/ServerScriptService/GameInitializer.server.lua"
echo ""

echo "🎮 Client Scripts:"
check_file "src/StarterPlayer/StarterPlayerScripts/SnakeController.lua"
check_file "src/StarterPlayer/StarterPlayerScripts/MobileControls.lua"
check_file "src/StarterPlayer/StarterPlayerScripts/CameraController.lua"
check_file "src/StarterPlayer/StarterPlayerScripts/SnakeRenderer.lua"
echo ""

echo "🎨 UI Scripts:"
check_file "src/StarterGui/HUD/HUD.client.lua"
check_file "src/StarterGui/Leaderboard/Leaderboard.client.lua"
check_file "src/StarterGui/CustomizationMenu/CustomizationMenu.client.lua"
check_file "src/StarterGui/RevivePrompt/RevivePrompt.client.lua"
check_file "src/StarterGui/ShieldTimer/ShieldTimer.client.lua"
echo ""

echo "🧪 Tests:"
check_file "src/ServerScriptService/Tests/SnakeManager.spec.lua"
check_file "src/ServerScriptService/Tests/RankService.spec.lua"
check_file "src/ServerScriptService/Tests/FoodSpawner.spec.lua"
check_file "src/ServerScriptService/Tests/PlayerDataManager.spec.lua"
check_file "src/ServerScriptService/Tests/init.lua"
echo ""

echo "================================================"
if [ $MISSING -eq 0 ]; then
    echo "✅ BUILD VERIFIED! All $TOTAL files present."
    echo ""
    echo "Next steps:"
    echo "  1. Run: rojo build default.project.json -o dist/SlitherSimulator.rbxlx"
    echo "  2. Open dist/SlitherSimulator.rbxlx in Roblox Studio"
    echo "  3. Enable API Access: File → Game Settings → Security"
    echo "  4. Press F5 to test!"
else
    echo "❌ BUILD INCOMPLETE! $MISSING of $TOTAL files missing."
    echo ""
    echo "Please ensure all files are created before building."
fi
echo "================================================"
