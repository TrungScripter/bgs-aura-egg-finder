local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local eggName = "Aura Egg"
local waitBeforeHop = 3
local maxHops = 20
local hopCount = 0

local function findAuraEgg()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == eggName then
            return obj
        end
    end
    return nil
end

local function teleportTo(part)
    if not part or not HumanoidRootPart then return end
    local goal = {CFrame = part.CFrame + Vector3.new(0, 5, 0)}
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, goal)
    tween:Play()
end

local function tryInteract(egg)
    for _, prompt in pairs(egg:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
            print("🖱 Interacted with Aura Egg!")
            return true
        end
    end
    return false
end

local function serverHop()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

while hopCount < maxHops do
    hopCount += 1
    print("🔁 Hop #" .. hopCount .. ": Checking for Aura Egg...")
    local egg = findAuraEgg()
    if egg then
        print("✅ Aura Egg found!")
        teleportTo(egg:FindFirstChild("PrimaryPart") or egg:FindFirstChildWhichIsA("BasePart"))
        wait(2)
        local interacted = tryInteract(egg)
        if not interacted then
            print("⚠️ Couldn't interact with the egg.")
        end
        break
    else
        print("❌ Aura Egg not here. Hopping in " .. waitBeforeHop .. "s...")
        wait(waitBeforeHop)
        serverHop()
        wait(10)
    end
end

if hopCount >= maxHops then
    warn("🛑 Max hop attempts reached. Stopping script.")
end
