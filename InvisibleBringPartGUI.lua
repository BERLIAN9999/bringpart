-- BERLIAN_BRINGPART SUPER MAGNET FINAL
-- Menarik semua benda di radius (besar/kecil/anchored), karakter aman

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ====== Default Settings ======
local RADIUS = 500
local PULL_STRENGTH = 250000 -- sangat kuat
local VISIBLE_EFFECTS = true
-- ==============================

-- ====== GUI Panel ======
local gui = Instance.new("ScreenGui")
gui.Name = "BERLIAN_BRINGPART_PANEL"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 250, 0, 200)
panel.Position = UDim2.new(0.5, -125, 0.3, -100)
panel.BackgroundColor3 = Color3.fromRGB(20,20,40)
panel.Active = true
panel.Draggable = true
panel.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "BERLIAN_BRINGPART"
title.TextColor3 = Color3.fromRGB(0,200,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = panel

-- On/Off Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 40)
button.Position = UDim2.new(0.5, -100, 0.15, 0)
button.BackgroundColor3 = Color3.fromRGB(0,100,255)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextScaled = true
button.Text = "OFF"
button.Font = Enum.Font.GothamBold
button.Parent = panel

-- Radius Slider
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 100, 0, 20)
radiusLabel.Position = UDim2.new(0.05,0,0.35,0)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Radius: "..RADIUS
radiusLabel.TextColor3 = Color3.new(1,1,1)
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextScaled = true
radiusLabel.Parent = panel

local radiusSlider = Instance.new("TextBox")
radiusSlider.Size = UDim2.new(0, 120, 0, 25)
radiusSlider.Position = UDim2.new(0.5,0,0.35,0)
radiusSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
radiusSlider.TextColor3 = Color3.new(1,1,1)
radiusSlider.Text = tostring(RADIUS)
radiusSlider.ClearTextOnFocus = false
radiusSlider.Font = Enum.Font.Gotham
radiusSlider.TextScaled = true
radiusSlider.Parent = panel

-- Strength Slider
local strengthLabel = Instance.new("TextLabel")
strengthLabel.Size = UDim2.new(0, 100, 0, 20)
strengthLabel.Position = UDim2.new(0.05,0,0.55,0)
strengthLabel.BackgroundTransparency = 1
strengthLabel.Text = "Strength: "..PULL_STRENGTH
strengthLabel.TextColor3 = Color3.new(1,1,1)
strengthLabel.Font = Enum.Font.Gotham
strengthLabel.TextScaled = true
strengthLabel.Parent = panel

local strengthSlider = Instance.new("TextBox")
strengthSlider.Size = UDim2.new(0, 120, 0, 25)
strengthSlider.Position = UDim2.new(0.5,0,0.55,0)
strengthSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
strengthSlider.TextColor3 = Color3.new(1,1,1)
strengthSlider.Text = tostring(PULL_STRENGTH)
strengthSlider.ClearTextOnFocus = false
strengthSlider.Font = Enum.Font.Gotham
strengthSlider.TextScaled = true
strengthSlider.Parent = panel

-- ====== Helper Functions ======
local function applyForceToPart(part, targetPos)
    -- Nonaktifkan Anchored sementara
    if part.Anchored then
        part.Anchored = false
        Debris:AddItem(part, 0) -- akan dikembalikan ke default di frame berikutnya
    end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BERLIAN_PULL_FORCE"
    bv.MaxForce = Vector3.new(1e14,1e14,1e14) -- sangat kuat
    bv.P = math.clamp(tonumber(strengthSlider.Text) or PULL_STRENGTH, 1000, 1e14)
    local direction = (targetPos - part.Position).unit
    local distance = (targetPos - part.Position).magnitude
    -- offset agar mengorbit karakter
    local offset = Vector3.new(math.sin(tick()*distance)*50,0,math.cos(tick()*distance)*50)
    bv.Velocity = direction * math.min(15000, distance*20) + offset
    bv.Parent = part
    Debris:AddItem(bv,0.5)
end

-- ====== BringPart Loop ======
local active = false
local bringPartConnection

local function startBringPart()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not root then return end
    bringPartConnection = RunService.Heartbeat:Connect(function()
        if not active then return end
        local centerPos = root.Position
        local radius = tonumber(radiusSlider.Text) or RADIUS

        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not obj:IsDescendantOf(char) then
                    local dist = (obj.Position - centerPos).magnitude
                    if dist <= radius then
                        applyForceToPart(obj, centerPos)
                    end
                end
            end
        end
    end)
end

local function stopBringPart()
    if bringPartConnection then
        bringPartConnection:Disconnect()
        bringPartConnection = nil
    end
end

-- ====== Button Toggle ======
button.MouseButton1Click:Connect(function()
    active = not active
    button.Text = active and "ON" or "OFF"
    if active then
        startBringPart()
    else
        stopBringPart()
    end
end)
