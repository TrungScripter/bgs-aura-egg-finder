-- CONFIG: Wait time before hopping if Aura Egg isn't found
local waitBeforeHop = 5

-- Function to find the Aura Egg in the workspace
local function findAuraEgg()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and string.lower(v.Name):find("auraegg") then
            return v
        end
    end
    return nil
end

-- Function to teleport to the egg (optional, for future use)
local function teleportTo(part)
    if part and part:IsA("BasePart") then
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

-- Function to hop servers
local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local placeId = game.PlaceId

    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=2&limit=100"))
    end)

    if success and servers and servers.data then
        for _, v in pairs(servers.data) do
            if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(placeId, v.id, game.Players.LocalPlayer)
                wait(5)
                return
            end
        end
    end
end

-- Infinite loop: keep hopping until Aura Egg is found
while true do
    print("🔍 Searching for Aura Egg...")

    local egg = findAuraEgg()
    if egg then
        print("✅ Aura Egg found! Executing loader script...")
        
        -- Optional: teleport to egg location
        teleportTo(egg:FindFirstChild("PrimaryPart") or egg:FindFirstChildWhichIsA("BasePart"))

        -- Execute the desired script when egg is found
        loadstring(game:HttpGet('https://raw.githubusercontent.com/0vma/Strelizia/refs/heads/main/Loader.lua', true))()
        
        break -- Exit loop after running the script
    else
        print("❌ Aura Egg not here. Hopping in " .. waitBeforeHop .. " seconds...")
        wait(waitBeforeHop)
        serverHop()
        wait(10) -- Allow time for new server to load
    end
end
