-- CONFIG: Wait time before hopping if Aura Egg isn't found
local waitBeforeHop = 5

-- Create "Please Wait" GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AuraEggWaitGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.3, 0, 0.1, 0)
Frame.Position = UDim2.new(0.35, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "⏳ Please wait... Searching for Aura Egg"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Font = Enum.Font.GothamSemibold
Label.TextScaled = true
Label.Parent = Frame

-- Function to find the Aura Egg in the workspace
local function findAuraEgg()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and string.lower(v.Name):find("auraegg") then
            return v
        end
    end
    return nil
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

-- Loop: hop until Aura Egg is found, then run the loader script
while true do
    print("🔍 Checking for Aura Egg...")

    local egg = findAuraEgg()
    if egg then
        print("✅ Aura Egg found! Executing loader script...")

        -- Remove GUI
        ScreenGui:Destroy()

        -- Run the external loader script
        loadstring(game:HttpGet('https://raw.githubusercontent.com/0vma/Strelizia/refs/heads/main/Loader.lua', true))()

        break -- Exit loop after execution
    else
        print("❌ Aura Egg not found. Hopping in " .. waitBeforeHop .. " seconds...")
        wait(waitBeforeHop)
        serverHop()
        wait(10) -- Allow time for server to load
    end
end
