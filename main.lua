-- CONFIG: No wait between hops if Aura Egg isn't found
local waitBeforeHop = 0  -- No wait before hopping
local doubleCheckDelay = 0  -- No double check delay

-- GUI (for user feedback)
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
local function hopServer()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local JobID = game.JobId

    -- Get the available public servers
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=2&limit=10"))
    end)

    if success and data and data.data then
        for _, server in ipairs(data.data) do
            -- Check if server is not the same as current one, and has available space
            if server.playing < server.maxPlayers and server.id ~= JobID then
                -- Attempt to teleport
                print("Teleporting to server with ID: " .. server.id)
                TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
                return true  -- Successful hop
            end
        end
    end

    return false  -- If no valid server found, return false
end

-- Main loop to keep checking for the Aura Egg and hop if needed
while true do
    -- First check for the Aura Egg
    local egg = findAuraEgg()

    if egg then
        -- If the Aura Egg is found, update GUI and run the loader script
        label.Text = "✅ Aura Egg found! Running script..."
        wait(1)
        gui:Destroy()

        -- Run the external loader script
        loadstring(game:HttpGet('https://raw.githubusercontent.com/0vma/Strelizia/refs/heads/main/Loader.lua', true))()

        break -- Stop the loop after running the loader
    else
        -- If no Aura Egg found, show waiting text
        label.Text = "❌ Aura Egg not found. Hopping to a new server..."
        
        -- Hop to a new server immediately
        local hopped = hopServer()  -- Attempt to hop to a new server
        
        -- If the teleportation didn't succeed, try again
        if not hopped then
            label.Text = "❌ Server hopping failed. Trying again..."
        end
    end

    wait(1)  -- Small delay to avoid infinite loop spamming
end
