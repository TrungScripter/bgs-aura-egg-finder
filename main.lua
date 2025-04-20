-- CONFIG
local waitBeforeHop = 5

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AuraEggStatus"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0.3, 0, 0.1, 0)
frame.Position = UDim2.new(0.35, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "⏳ Searching for Aura Egg..."
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true

-- Egg Finder
local function findAuraEgg()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and string.lower(v.Name):find("auraegg") then
            return v
        end
    end
    return nil
end

-- Server Hopper
local function hopServer()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local JobID = game.JobId

    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=2&limit=100"))
    end)

    if success and data and data.data then
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= JobID then
                TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
                return
            end
        end
    end
end

-- Main Loop
while true do
    local egg = findAuraEgg()

    if egg then
        label.Text = "✅ Aura Egg found! Running script..."
        wait(1)
        gui:Destroy()

        -- Run loader
        loadstring(game:HttpGet('https://raw.githubusercontent.com/0vma/Strelizia/refs/heads/main/Loader.lua', true))()
        break
    else
        label.Text = "❌ Aura Egg not found. Hopping soon..."
        wait(waitBeforeHop)
        hopServer()
        wait(10) -- Give time to load
    end
end
