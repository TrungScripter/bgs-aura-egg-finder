-- SETTINGS
local auraEggName = "AuraEgg"
local retryDelay = 1 -- seconds between hops if failed
local guiEnabled = true

-- GUI Setup
local gui, label
if guiEnabled then
    gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AuraEggHopGUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.3, 0, 0.1, 0)
    frame.Position = UDim2.new(0.35, 0, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3

    label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "🔍 Searching for Aura Egg..."
end

-- Aura Egg Check
local function findAuraEgg()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and string.lower(v.Name):find(string.lower(auraEggName)) then
            return v
        end
    end
    return nil
end

-- Server Hop Function
local function hopServer()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local currentJobId = game.JobId
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=2&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local response = HttpService:JSONDecode(game:HttpGet(url))
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(servers, server.id)
            end
        end
        cursor = response.nextPageCursor
    until not cursor or #servers > 0

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(PlaceID, chosen, game.Players.LocalPlayer)
    end
end

-- Main Loop
while true do
    local found = findAuraEgg()
    if found then
        if label then label.Text = "✅ Aura Egg Found! Stopping hops..." end
        break
    else
        if label then label.Text = "❌ Aura Egg not found. Hopping..." end
        local success = pcall(hopServer)
        if not success and label then
            label.Text = "⚠️ Hop failed. Retrying..."
            wait(retryDelay)
        end
    end
    wait(1)
end
