--[[
    SHERIFGO V3
    Premium Black / White Hub
    Key: SherifGoFree

    IMPORTANT:
    This script is intended for your own Roblox experience.
    Role attributes expected on Player:
      Role = "Sherif" | "Murder" | "Innocent"

    Single-file mode: no server script is required.
    Key validation is client-side because this build intentionally uses one LocalScript only.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FREE_KEY = "SherifGoFree"
local PERM_KEY = "SherifGoPerm"

-- Tukar dua URL ini kepada pautan pembelian sebenar anda.
local BUY_PERM_KEY_URL = "https://example.com/buy-perm-key"
local BUY_ADMIN_URL = "https://example.com/buy-admin-version"
local WHATSAPP_NUMBER = "601168192142"
local WHATSAPP_BUY_MESSAGE = "Saya nak beli SherifGo Perm Key / Admin Version."

local State = {
    KeyVerified = false,
    KeyTier = nil,
    Destroyed = false,
    Hidden = false,
    SelectedTab = "Dashboard",

    Aim = false,
    ESP = false,
    TargetLock = false,
    VisibilityCheck = true,
    AutoRetarget = true,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    Sprint = false,
    AntiAFK = false,
    PerformanceMode = false,
    Notifications = true,
    Animations = true,

    AimFOV = 180,
    AimSmoothness = 0.18,
    AimDistance = 1000,
    WalkSpeed = 16,
    JumpPower = 50,
    BaseWalkSpeed = 16,
    BaseJumpPower = 50,
    FlySpeed = 50,

    SelectedRole = "Auto",
    TargetPriority = "Closest",
    CurrentTarget = nil,
    Spectating = nil,
    Waypoints = {},
}

local Connections = {}
local ESPObjects = {}
local RoleConnections = {}
local OriginalCollision = {}

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

local function disconnect(c)
    if c then pcall(function() c:Disconnect() end) end
end

local function notify(title, message)
    if not State.Notifications then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 3
        })
    end)
end

local function getRole(player)
    if not player then return "Unknown" end
    local role = player:GetAttribute("Role")
    if typeof(role) == "string" then
        role = role:lower()
        if role == "sherif" or role == "sheriff" then return "Sherif" end
        if role == "murder" or role == "murderer" then return "Murder" end
        if role == "innocent" then return "Innocent" end
    end
    return "Unknown"
end

local function getCharacter(player)
    return player and player.Character
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(player)
    local hum = getHumanoid(player)
    return hum and hum.Health > 0
end

local function getRoot(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function validTarget(player)
    return player
        and player ~= LocalPlayer
        and player.Parent == Players
        and isAlive(player)
        and getRoot(player) ~= nil
end

local function distanceTo(player)
    local a, b = getRoot(LocalPlayer), getRoot(player)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function targetAllowed(player)
    if not validTarget(player) then return false end

    local localRole = State.SelectedRole
    if localRole == "Auto" then
        localRole = getRole(LocalPlayer)
    end

    if localRole == "Sherif" then
        return getRole(player) == "Murder"
    elseif localRole == "Murder" then
        return true
    end

    return true
end

local function clearESP(player)
    local obj = ESPObjects[player]
    if obj then
        pcall(function() obj:Destroy() end)
        ESPObjects[player] = nil
    end
end

local function applyESP(player)
    if not State.ESP or not targetAllowed(player) then
        clearESP(player)
        return
    end

    local char = getCharacter(player)
    if not char then return end

    if ESPObjects[player] and ESPObjects[player].Parent == char then
        return
    end

    clearESP(player)

    local h = Instance.new("Highlight")
    h.Name = "SherifGoESP"
    h.Adornee = char
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = 0.72
    h.OutlineTransparency = 0

    local role = getRole(player)
    if role == "Murder" then
        h.FillColor = Color3.fromRGB(255, 65, 65)
        h.OutlineColor = Color3.fromRGB(255, 25, 25)
    elseif role == "Sherif" then
        h.FillColor = Color3.fromRGB(65, 145, 255)
        h.OutlineColor = Color3.fromRGB(30, 120, 255)
    else
        h.FillColor = Color3.fromRGB(80, 220, 150)
        h.OutlineColor = Color3.fromRGB(50, 190, 130)
    end

    h.Parent = char
    ESPObjects[player] = h
end

local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            applyESP(p)
        end
    end
end

local function clearAllESP()
    for p in pairs(ESPObjects) do
        clearESP(p)
    end
end

local function getCandidates()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if targetAllowed(p) then
            table.insert(list, p)
        end
    end
    return list
end

local function screenPosition(player)
    local root = getRoot(player)
    if not root then return nil end
    local pos, visible = Camera:WorldToViewportPoint(root.Position)
    if not visible or pos.Z <= 0 then return nil end
    return Vector2.new(pos.X, pos.Y)
end

local function getClosestTarget()
    local mouse = UserInputService:GetMouseLocation()
    local best, bestScore = nil, math.huge

    for _, p in ipairs(getCandidates()) do
        local pos = screenPosition(p)
        if pos then
            local screenDist = (pos - mouse).Magnitude
            if screenDist <= State.AimFOV then
                local score
                if State.TargetPriority == "Distance" then
                    score = distanceTo(p)
                elseif State.TargetPriority == "Health" then
                    local hum = getHumanoid(p)
                    score = hum and hum.Health or math.huge
                else
                    score = screenDist
                end

                if score < bestScore then
                    best, bestScore = p, score
                end
            end
        end
    end

    return best
end

local function visibleTarget(player)
    if not State.VisibilityCheck then return true end
    local root = getRoot(player)
    local myRoot = getRoot(LocalPlayer)
    if not root or not myRoot then return false end

    local direction = root.Position - Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        player.Character
    }

    local result = workspace:Raycast(Camera.CFrame.Position, direction, params)
    return result == nil
end

local function validateTarget(player)
    return State.Aim
        and targetAllowed(player)
        and distanceTo(player) <= State.AimDistance
        and visibleTarget(player)
end

local function aimAt(player)
    local root = getRoot(player)
    if not root then return end

    local targetPos = root.Position
    local camPos = Camera.CFrame.Position
    local desired = CFrame.lookAt(camPos, targetPos)

    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(State.AimSmoothness, 0.01, 1))
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SherifGo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainScale = Instance.new("UIScale")
mainScale.Scale = 1
mainScale.Parent = gui

local function updateUIScale()
    local viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    local scale = math.min(1, viewport.X / 620, viewport.Y / 430)
    mainScale.Scale = math.max(0.72, scale)
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
end

local function makeButton(parent, text, size)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = Color3.fromRGB(13, 20, 32)
    b.Size = size or UDim2.new(1, 0, 0, 32)
    b.Font = Enum.Font.GothamMedium
    b.Text = text
    b.TextColor3 = Color3.fromRGB(245, 245, 245)
    b.TextSize = 13
    b.Parent = parent
    corner(b, 8)
    stroke(b, Color3.fromRGB(80, 80, 80), 1, 0.55)

    connect(b.MouseEnter, function()
        if State.Animations then
            TweenService:Create(b, TweenInfo.new(.12), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
    end)
    connect(b.MouseLeave, function()
        if State.Animations then
            TweenService:Create(b, TweenInfo.new(.12), {
                BackgroundColor3 = Color3.fromRGB(18, 24, 36)
            }):Play()
        end
    end)

    return b
end

local function makeLabel(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = size or UDim2.new(1, 0, 0, 24)
    l.Font = Enum.Font.GothamMedium
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(235, 235, 235)
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeToggle(parent, text, initial, callback)
    local b = makeButton(parent, "", UDim2.new(1, 0, 0, 30))
    local label = makeLabel(b, text, UDim2.new(1, -60, 1, 0))
    label.Position = UDim2.fromOffset(12, 0)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(34, 18)
    indicator.Position = UDim2.new(1, -46, .5, -9)
    indicator.Parent = b
    corner(indicator, 20)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.Parent = indicator
    corner(knob, 20)

    local value = initial == true

    local function render()
        indicator.BackgroundColor3 = value and Color3.fromRGB(235, 235, 235)
            or Color3.fromRGB(55, 55, 55)
        knob.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
        knob.Position = value and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
    end

    render()

    connect(b.Activated, function()
        value = not value
        render()
        if callback then callback(value) end
    end)

    return b, function(v)
        value = v
        render()
    end
end

local function makeSection(parent, text)
    local l = makeLabel(parent, text:upper(), UDim2.new(1, 0, 0, 25), Color3.fromRGB(235, 235, 235))
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    return l
end

-- Key screen
local keyFrame = Instance.new("Frame")
keyFrame.AnchorPoint = Vector2.new(.5, .5)
keyFrame.Position = UDim2.fromScale(.5, .5)
keyFrame.Size = UDim2.fromOffset(330, 292)
local keyScale = Instance.new("UIScale")
keyScale.Scale = 1
keyScale.Parent = keyFrame

local function updateKeyScale()
    local viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    keyScale.Scale = math.max(0.78, math.min(1, viewport.X / 380, viewport.Y / 340))
end
updateKeyScale()
keyFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
keyFrame.Parent = gui
corner(keyFrame, 14)
stroke(keyFrame, Color3.fromRGB(245, 245, 245), 1.5, .1)

local keyTitle = makeLabel(keyFrame, "SHERIFGO", UDim2.new(1, -40, 0, 35), Color3.fromRGB(245, 245, 245))
keyTitle.Position = UDim2.fromOffset(20, 18)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 24

local keySub = makeLabel(keyFrame, "Premium Access", UDim2.new(1, -40, 0, 24), Color3.fromRGB(155, 155, 155))
keySub.Position = UDim2.fromOffset(20, 52)

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 42)
keyBox.Position = UDim2.fromOffset(20, 82)
keyBox.BackgroundColor3 = Color3.fromRGB(17, 23, 35)
keyBox.PlaceholderText = "Enter Free / Perm key..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.TextColor3 = Color3.fromRGB(235, 240, 255)
keyBox.Parent = keyFrame
corner(keyBox, 8)
stroke(keyBox, Color3.fromRGB(80, 80, 80), 1, .2)

local check = makeButton(keyFrame, "CHECK KEY", UDim2.new(1, -40, 0, 42))
check.Position = UDim2.fromOffset(20, 136)
check.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
check.TextColor3 = Color3.fromRGB(10, 10, 10)

local keyStatus = makeLabel(keyFrame, "Key required", UDim2.new(1, -40, 0, 22), Color3.fromRGB(160, 160, 160))
keyStatus.Position = UDim2.fromOffset(20, 192)

local waInfo = makeLabel(
    keyFrame,
    "WhatsApp: +60 11-6819 2142  •  Follow the channel",
    UDim2.new(1, -40, 0, 20),
    Color3.fromRGB(220, 220, 220)
)
waInfo.Position = UDim2.fromOffset(20, 212)
waInfo.TextSize = 10

local waChannelInfo = makeLabel(
    keyFrame,
    "🔥SC FREE💫BY WILZZ🔥",
    UDim2.new(1, -40, 0, 18),
    Color3.fromRGB(190, 190, 190)
)
waChannelInfo.Position = UDim2.fromOffset(20, 228)
waChannelInfo.TextSize = 10

local waButton = makeButton(keyFrame, "JOIN CHANNEL", UDim2.new(1, -40, 0, 32))
waButton.Position = UDim2.fromOffset(20, 246)
waButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
waButton.TextColor3 = Color3.fromRGB(10, 10, 10)
waButton.TextSize = 11

local WHATSAPP_CHANNEL = "https://whatsapp.com/channel/0029VbCQPwEGZNCoWjErZk3a"

connect(waButton.Activated, function()
    local opened = false
    pcall(function()
        if GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(WHATSAPP_CHANNEL)
            opened = true
        end
    end)
    if not opened then
        pcall(function()
            if setclipboard then
                setclipboard(WHATSAPP_CHANNEL)
            end
        end)
        notify("WhatsApp", "Link copied. Open it in your browser.")
    end
end)

-- Main GUI
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(.5, .5)
main.Position = UDim2.fromScale(.5, .5)
main.Size = UDim2.fromOffset(570, 370)
main.BackgroundColor3 = Color3.fromRGB(7, 11, 18)
main.Visible = false
main.Parent = gui
corner(main, 14)
stroke(main, Color3.fromRGB(245, 245, 245), 1.5, .08)

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,5))})
mainGradient.Rotation = 135
mainGradient.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = Color3.fromRGB(10, 16, 27)
top.Parent = main
corner(top, 14)
local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,5))})
topGradient.Rotation = 20
topGradient.Parent = top
stroke(top, Color3.fromRGB(70, 70, 70), 1, .55)

local title = makeLabel(top, "S  SHERIFGO", UDim2.new(1, -235, 1, 0), Color3.fromRGB(250, 250, 250))
title.Position = UDim2.fromOffset(18, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local version = makeLabel(top, "V3 • PREMIUM", UDim2.fromOffset(78, 24), Color3.fromRGB(235, 235, 235))
version.Position = UDim2.new(1, -224, .5, -12)
version.TextXAlignment = Enum.TextXAlignment.Right

local hide = makeButton(top, "—", UDim2.fromOffset(34, 30))
hide.Position = UDim2.new(1, -44, .5, -15)
hide.TextSize = 15

local statusChip = Instance.new("TextLabel")
statusChip.Size = UDim2.fromOffset(76, 22)
statusChip.Position = UDim2.new(1, -130, .5, -11)
statusChip.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statusChip.Text = "●  ONLINE"
statusChip.TextColor3 = Color3.fromRGB(245, 245, 245)
statusChip.Font = Enum.Font.GothamBold
statusChip.TextSize = 10
statusChip.Parent = top
corner(statusChip, 12)
stroke(statusChip, Color3.fromRGB(150, 150, 150), 1, .45)

local side = Instance.new("Frame")
side.Position = UDim2.fromOffset(7, 56)
side.Size = UDim2.fromOffset(124, 300)
side.BackgroundColor3 = Color3.fromRGB(9, 14, 23)
side.Parent = main
corner(side, 10)
local sideGradient = Instance.new("UIGradient")
sideGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,5))})
sideGradient.Rotation = 90
sideGradient.Parent = side
stroke(side, Color3.fromRGB(65, 65, 65), 1, .65)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 2)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = side

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 6)
sidePad.PaddingLeft = UDim.new(0, 7)
sidePad.PaddingRight = UDim.new(0, 7)
sidePad.Parent = side

local content = Instance.new("ScrollingFrame")
content.Position = UDim2.fromOffset(138, 56)
content.Size = UDim2.new(1, -145, 1, -61)
content.BackgroundColor3 = Color3.fromRGB(9, 14, 23)
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new()
content.Parent = main
corner(content, 10)
stroke(content, Color3.fromRGB(65, 65, 65), 1, .7)

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 14)
contentPad.PaddingBottom = UDim.new(0, 14)
contentPad.PaddingLeft = UDim.new(0, 14)
contentPad.PaddingRight = UDim.new(0, 14)
contentPad.Parent = content

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

connect(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    content.CanvasSize = UDim2.fromOffset(0, contentLayout.AbsoluteContentSize.Y + 30)
end)

updateUIScale()
pcall(function()
    connect(Camera:GetPropertyChangedSignal("ViewportSize"), updateUIScale)
end)

local reopen = Instance.new("TextButton")
reopen.AnchorPoint = Vector2.new(.5, .5)
reopen.Position = UDim2.fromScale(.5, .5)
reopen.Size = UDim2.fromOffset(54, 54)
reopen.BackgroundColor3 = Color3.fromRGB(7, 12, 20)
reopen.Text = "S"
reopen.TextColor3 = Color3.fromRGB(245, 245, 245)
reopen.Font = Enum.Font.GothamBold
reopen.TextSize = 25
reopen.Visible = false
reopen.Parent = gui
corner(reopen, 27)
local reopenScale = Instance.new("UIScale")
reopenScale.Scale = 1
reopenScale.Parent = reopen
stroke(reopen, Color3.fromRGB(245, 245, 245), 2, .05)

-- Draggable helper
local function draggable(obj, handle)
    handle = handle or obj
    local dragging = false
    local dragStart, startPos
    local moved = false
    local lastInput

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            lastInput = input
            dragStart = input.Position
            startPos = obj.Position
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then moved = true end
        obj.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)

    connect(UserInputService.InputEnded, function(input)
        if input == lastInput
            or input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return function()
        local wasMoved = moved
        moved = false
        return wasMoved
    end
end

draggable(main, top)
local reopenMoved = draggable(reopen, reopen)

local tabs = {
    {"Dashboard", "⌂"},
    {"Role", "R"},
    {"ESP", "E"},
    {"Aim", "A"},
    {"Sherif", "S"},
    {"Murder", "M"},
    {"Movement", "W"},
    {"Player", "P"},
    {"Teleport", "T"},
    {"Utility", "U"},
    {"Settings", "⚙"},
}

local tabButtons = {}

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function addFeature(titleText, desc, callback)
    local row = makeButton(content, "", UDim2.new(1, -5, 0, 52))
    local titleLabel = makeLabel(row, titleText, UDim2.new(1, -20, 0, 21))
    titleLabel.Position = UDim2.fromOffset(12, 5)
    titleLabel.Font = Enum.Font.GothamBold

    local descLabel = makeLabel(row, desc or "", UDim2.new(1, -20, 0, 19), Color3.fromRGB(145, 145, 145))
    descLabel.Position = UDim2.fromOffset(12, 25)
    descLabel.TextSize = 10

    connect(row.Activated, function()
        if callback then callback() end
    end)
    return row
end

local function addToggle(titleText, initial, callback)
    local row = makeToggle(content, titleText, initial, callback)
    return row
end

local function showTab(tab)
    State.SelectedTab = tab
    clearContent()

    if tab == "Dashboard" then
        makeSection(content, "Overview")
        addFeature("Round Status", "Current round state", function()
            notify("SherifGo", "Round: " .. tostring(workspace:GetAttribute("RoundStatus") or "Unknown"))
        end)
        addFeature("Round Timer", "Display current round timer", function()
            notify("SherifGo", "Timer: " .. tostring(workspace:GetAttribute("RoundTimer") or "Unknown"))
        end)
        addFeature("Current Role", "Read your Role attribute", function()
            notify("SherifGo", "Role: " .. getRole(LocalPlayer))
        end)
        addFeature("Player Counter", "Players in server", function()
            notify("SherifGo", "Players: " .. #Players:GetPlayers())
        end)
        addFeature("Alive Counter", "Living players", function()
            local n=0
            for _,p in ipairs(Players:GetPlayers()) do if isAlive(p) then n+=1 end end
            notify("SherifGo", "Alive: "..n)
        end)
        addFeature("Target Counter", "Eligible targets", function()
            notify("SherifGo", "Targets: "..#getCandidates())
        end)
        addFeature("Ping Display", "Show network latency", function()
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            notify("Ping", ok and ping or "Unavailable")
        end)
        addFeature("FPS Display", "Performance information", function()
            notify("FPS", "Use Performance Mode for lower UI overhead.")
        end)
        addFeature("Server Job ID", "Copy/view server identifier", function()
            notify("Job ID", game.JobId ~= "" and game.JobId or "Unavailable")
        end)
        addFeature("Session Time", "Session information", function()
            notify("SherifGo", "Session active")
        end)

    elseif tab == "Role" then
        makeSection(content, "Role Control")
        addFeature("Sherif Mode", "Aim/ESP Murder only", function()
            State.SelectedRole = "Sherif"
            State.CurrentTarget = nil
            refreshESP()
            notify("Role", "Sherif mode enabled")
        end)
        addFeature("Murder Mode", "Aim/ESP all players", function()
            State.SelectedRole = "Murder"
            State.CurrentTarget = nil
            refreshESP()
            notify("Role", "Murder mode enabled")
        end)
        addFeature("Innocent Mode", "General player targeting", function()
            State.SelectedRole = "Innocent"
            State.CurrentTarget = nil
            refreshESP()
            notify("Role", "Innocent mode enabled")
        end)
        addFeature("Auto Role Detection", "Use Player.Role automatically", function()
            State.SelectedRole = "Auto"
            State.CurrentTarget = nil
            refreshESP()
            notify("Role", "Automatic detection enabled")
        end)
        addFeature("Role Status", "Read your current role", function()
            notify("Role", getRole(LocalPlayer))
        end)
        addFeature("Murder Finder", "Find current Murder", function()
            for _,p in ipairs(Players:GetPlayers()) do
                if getRole(p) == "Murder" then
                    notify("Murder", p.DisplayName.." / "..p.Name)
                    return
                end
            end
            notify("Murder", "Not found")
        end)
        addFeature("Sherif Finder", "Find current Sherif", function()
            for _,p in ipairs(Players:GetPlayers()) do
                if getRole(p) == "Sherif" then
                    notify("Sherif", p.DisplayName.." / "..p.Name)
                    return
                end
            end
            notify("Sherif", "Not found")
        end)
        addFeature("Role Notifications", "Role change notifications", function()
            notify("Role", "Role notifications ready")
        end)

    elseif tab == "ESP" then
        makeSection(content, "ESP")
        addToggle("Player ESP", State.ESP, function(v)
            State.ESP=v
            if v then refreshESP() else clearAllESP() end
        end)
        addFeature("Murder ESP", "Highlight Murder only", function()
            State.SelectedRole="Sherif"; State.ESP=true; refreshESP()
        end)
        addFeature("Sherif ESP", "Highlight Sherif", function()
            State.ESP=true; refreshESP()
        end)
        addFeature("Innocent ESP", "Highlight Innocents", function()
            State.ESP=true; refreshESP()
        end)
        addFeature("Name ESP", "Name display hook", function() notify("ESP","Name ESP hook ready") end)
        addFeature("Distance ESP", "Distance display hook", function() notify("ESP","Distance ESP hook ready") end)
        addFeature("Health ESP", "Health display hook", function() notify("ESP","Health ESP hook ready") end)
        addFeature("Box ESP", "Box display hook", function() notify("ESP","Box ESP hook ready") end)
        addFeature("Tracer ESP", "Tracer display hook", function() notify("ESP","Tracer ESP hook ready") end)
        addFeature("Highlight ESP", "Highlight-based ESP", function() State.ESP=true; refreshESP() end)
        addFeature("Skeleton ESP", "Skeleton display hook", function() notify("ESP","Skeleton ESP hook ready") end)
        addFeature("Head ESP", "Head display hook", function() notify("ESP","Head ESP hook ready") end)
        addFeature("Body ESP", "Body display hook", function() notify("ESP","Body ESP hook ready") end)
        addFeature("Dead Player ESP", "Dead-player display hook", function() notify("ESP","Dead ESP hook ready") end)
        addFeature("Target ESP", "Highlight current target", function()
            local t=State.CurrentTarget
            notify("Target ESP", t and t.Name or "No target")
        end)

    elseif tab == "Aim" then
        makeSection(content, "Aim / Target")
        addToggle("Aim Toggle", State.Aim, function(v)
            State.Aim=v
            if not v then State.CurrentTarget=nil end
        end)
        addToggle("Target Lock", State.TargetLock, function(v) State.TargetLock=v end)
        addToggle("Visibility Check", State.VisibilityCheck, function(v) State.VisibilityCheck=v end)
        addToggle("Auto Retarget", State.AutoRetarget, function(v) State.AutoRetarget=v end)
        addFeature("Target Selector", "Choose eligible target", function()
            State.CurrentTarget=getClosestTarget()
            notify("Target", State.CurrentTarget and State.CurrentTarget.Name or "None")
        end)
        addFeature("FOV Circle", "FOV is used by target selector", function()
            notify("FOV", tostring(State.AimFOV))
        end)
        addFeature("FOV Size", "Current FOV: "..State.AimFOV, function()
            State.AimFOV = State.AimFOV == 180 and 250 or 180
            notify("FOV", tostring(State.AimFOV))
        end)
        addFeature("Aim Smoothness", "Current: "..State.AimSmoothness, function()
            State.AimSmoothness = State.AimSmoothness == .18 and .35 or .18
            notify("Smoothness", tostring(State.AimSmoothness))
        end)
        addFeature("Distance Limit", "Current: "..State.AimDistance, function()
            State.AimDistance = State.AimDistance == 1000 and 500 or 1000
            notify("Distance", tostring(State.AimDistance))
        end)
        addFeature("Target Priority", "Closest / Distance / Health", function()
            State.TargetPriority = State.TargetPriority == "Closest" and "Distance"
                or State.TargetPriority == "Distance" and "Health" or "Closest"
            notify("Priority", State.TargetPriority)
        end)

    elseif tab == "Sherif" then
        makeSection(content, "Sherif Rules")
        addFeature("Murder-only Target", "Only Murder can be targeted", function()
            State.SelectedRole="Sherif"; State.Aim=true; State.CurrentTarget=nil
            notify("Sherif", "Murder-only targeting enabled")
        end)
        addFeature("Murder-only ESP", "Only Murder is highlighted", function()
            State.SelectedRole="Sherif"; State.ESP=true; refreshESP()
        end)
        addFeature("Auto Murder Refresh", "Refresh eligible Murder targets", function()
            State.SelectedRole="Sherif"; State.CurrentTarget=nil; refreshESP()
        end)
        addFeature("Murder Death Detection", "Reject dead Murder targets", function()
            local t=State.CurrentTarget
            if t and not isAlive(t) then State.CurrentTarget=nil end
        end)
        addFeature("Murder Respawn Detection", "Refresh after respawn", function()
            State.CurrentTarget=nil; refreshESP()
        end)

    elseif tab == "Murder" then
        makeSection(content, "Murder Rules")
        addFeature("All-player Target", "All living players except self", function()
            State.SelectedRole="Murder"; State.Aim=true; State.CurrentTarget=nil
        end)
        addFeature("All-player ESP", "Highlight eligible players", function()
            State.SelectedRole="Murder"; State.ESP=true; refreshESP()
        end)
        addFeature("Auto Target Refresh", "Refresh target automatically", function()
            State.AutoRetarget=true
        end)
        addFeature("Dead Player Filter", "Exclude dead players", function()
            State.CurrentTarget=nil
        end)
        addFeature("Self Filter", "Always exclude yourself", function()
            notify("Filter", "Self is always excluded")
        end)

    elseif tab == "Movement" then
        makeSection(content, "Movement")
        addFeature("WalkSpeed", "Toggle/custom speed hook", function()
            applyMovementStats()
            notify("WalkSpeed", tostring(State.WalkSpeed))
        end)
        addFeature("JumpPower", "Set jump power", function()
            applyMovementStats()
            notify("JumpPower", tostring(State.JumpPower))
        end)
        addToggle("Infinite Jump", State.InfiniteJump, function(v) State.InfiniteJump=v end)
        addToggle("Noclip", State.Noclip, function(v) State.Noclip=v; if not v then setNoclip(false) end end)
        addToggle("Fly", State.Fly, function(v) State.Fly=v end)
        addFeature("Fly Speed", "Current: "..State.FlySpeed, function()
            State.FlySpeed = State.FlySpeed == 50 and 100 or 50
            notify("Fly Speed", tostring(State.FlySpeed))
        end)
        addToggle("Sprint", State.Sprint, function(v) State.Sprint=v; applyMovementStats() end)
        addFeature("No Fall Damage", "Game-specific hook", function() notify("Movement","Connect this to your game's fall-damage system.") end)
        addFeature("Movement Reset", "Restore movement defaults", function()
            local hum=getHumanoid(LocalPlayer)
            if hum then hum.WalkSpeed=16; hum.JumpPower=50 end
            State.Fly=false; State.Noclip=false; State.Sprint=false; setNoclip(false); applyMovementStats()
        end)
        addFeature("Speed Presets", "Cycle movement preset", function()
            State.WalkSpeed = State.WalkSpeed == 16 and 24 or State.WalkSpeed == 24 and 32 or 16
            applyMovementStats()
            notify("Speed", tostring(State.WalkSpeed))
        end)

    elseif tab == "Player" then
        makeSection(content, "Player")
        addFeature("Player List", "List players", function() notify("Players", tostring(#Players:GetPlayers())) end)
        addFeature("Player Search", "Search hook", function() notify("Player Search","Use Player List integration.") end)
        addFeature("Player Information", "Show selected target", function()
            local t=State.CurrentTarget
            notify("Player", t and (t.Name.." | "..getRole(t)) or "None")
        end)
        addFeature("Distance Calculator", "Distance to target", function()
            local t=State.CurrentTarget
            notify("Distance", t and string.format("%.1f",distanceTo(t)) or "None")
        end)
        addFeature("Character Refresh", "Refresh character reference", function()
            State.CurrentTarget=nil; refreshESP()
        end)
        addFeature("Spectate", "Camera follows selected target", function()
            local t=State.CurrentTarget
            if t and getHumanoid(t) then
                Camera.CameraSubject=getHumanoid(t)
                State.Spectating=t
            end
        end)
        addFeature("Stop Spectating", "Return camera to self", function()
            local hum=getHumanoid(LocalPlayer)
            if hum then Camera.CameraSubject=hum end
            State.Spectating=nil
        end)
        addFeature("Target Player", "Select closest player", function()
            State.CurrentTarget=getClosestTarget()
        end)
        addFeature("Teleport Player", "Game-specific teleport hook", function()
            notify("Teleport","Connect to your game's server teleport system.")
        end)
        addFeature("Player Highlight", "Highlight current target", function()
            if State.CurrentTarget then applyESP(State.CurrentTarget) end
        end)

    elseif tab == "Teleport" then
        makeSection(content, "Teleport")
        addFeature("Teleport to Sherif", "Game-specific teleport", function() notify("Teleport","Sherif teleport hook ready") end)
        addFeature("Teleport to Murder", "Game-specific teleport", function() notify("Teleport","Murder teleport hook ready") end)
        addFeature("Teleport to Random Player", "Game-specific teleport", function() notify("Teleport","Random-player teleport hook ready") end)
        addFeature("Teleport to Spawn", "Game-specific spawn location", function() notify("Teleport","Spawn hook ready") end)
        addFeature("Saved Waypoints", "View saved waypoints", function() notify("Waypoints", tostring(#State.Waypoints)) end)
        addFeature("Waypoint Manager", "Add current position", function()
            local root=getRoot(LocalPlayer)
            if root then
                table.insert(State.Waypoints, root.Position)
                notify("Waypoint","Saved")
            end
        end)
        addFeature("Safe Position", "Save current position", function()
            local root=getRoot(LocalPlayer)
            if root then
                State.SafePosition=root.Position
                notify("Safe Position","Saved")
            end
        end)

    elseif tab == "Utility" then
        makeSection(content, "Utility")
        addToggle("Anti-AFK", State.AntiAFK, function(v) State.AntiAFK=v end)
        addFeature("Rejoin Server", "Rejoin current server", function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        addFeature("Server Information", "Server details", function()
            notify("Server", #Players:GetPlayers().." players")
        end)
        addFeature("Copy Job ID", "JobId available to your clipboard integration", function()
            notify("Job ID", game.JobId)
        end)
        addToggle("Performance Mode", State.PerformanceMode, function(v)
            State.PerformanceMode=v
            notify("Performance", v and "Enabled" or "Disabled")
        end)
        addFeature("Notification System", "Toggle notifications", function()
            State.Notifications=not State.Notifications
        end)
        addFeature("Auto Cleanup", "Clear stale ESP/target state", function()
            State.CurrentTarget=nil
            refreshESP()
        end)
        addFeature("Debug Information", "Show internal state", function()
            notify("Debug", "Tab="..State.SelectedTab.." | Target="..tostring(State.CurrentTarget and State.CurrentTarget.Name))
        end)

    elseif tab == "Settings" then
        makeSection(content, "GUI Settings")
        addToggle("Animation Toggle", State.Animations, function(v) State.Animations=v end)
        addFeature("UI Scale", "Cycle compact / normal", function()
            mainScale.Scale = (mainScale.Scale > 0.9) and 0.82 or 1
        end)
        addFeature("Hide GUI", "Show center S button", function()
            main.Visible=false
            reopen.Visible=true
            State.Hidden=true
        end)
        addFeature("Reset UI Position", "Center the main interface", function()
            main.Position = UDim2.fromScale(.5,.5)
            reopen.Position = UDim2.fromScale(.5,.5)
            mainScale.Scale = 1
        end)
        addFeature("Clear ESP", "Remove all highlights", function() clearAllESP() end)
        addFeature("Clear Target", "Remove current target", function() State.CurrentTarget=nil end)
        addFeature("Destroy SherifGo", "Remove this interface", function()
            State.Destroyed=true
            clearAllESP()
            State.Aim = false
            State.ESP = false
            State.Fly = false
            State.Noclip = false
            State.Sprint = false
            setNoclip(false)
            if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
            local ownHum = getHumanoid(LocalPlayer)
            if ownHum then Camera.CameraSubject = ownHum end
            applyMovementStats()
            for player, list in pairs(RoleConnections) do
                for _, c in ipairs(list) do disconnect(c) end
                RoleConnections[player]=nil
            end
            for _, c in ipairs(Connections) do disconnect(c) end
            gui:Destroy()
        end)
    end
end

local function updateTabVisuals(activeName)
    for name, button in pairs(tabButtons) do
        if name == activeName then
            button.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
            button.TextColor3 = Color3.fromRGB(10, 10, 10)
            local st = button:FindFirstChildOfClass("UIStroke")
            if st then st.Color = Color3.fromRGB(255, 255, 255); st.Transparency = 0.05 end
        else
            button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            button.TextColor3 = Color3.fromRGB(230, 230, 230)
            local st = button:FindFirstChildOfClass("UIStroke")
            if st then st.Color = Color3.fromRGB(70, 70, 70); st.Transparency = 0.55 end
        end
    end
end

for _, data in ipairs(tabs) do
    local name, icon = data[1], data[2]
    local b = makeButton(side, icon.."  "..name, UDim2.new(1, 0, 0, 22))
    b.TextSize = 10
    tabButtons[name]=b
    connect(b.Activated, function()
        showTab(name)
        updateTabVisuals(name)
    end)
end

connect(hide.Activated, function()
    main.Visible=false
    reopen.Visible=true
    State.Hidden=true
end)

connect(reopen.Activated, function()
    if reopenMoved() then return end
    if State.Destroyed then return end
    main.Visible = true
    reopen.Visible = false
    State.Hidden = false
end)

-- Purchase buttons
local buyPerm = makeButton(keyFrame, "BUY PERM KEY", UDim2.new(.5, -25, 0, 30))
buyPerm.Position = UDim2.new(0, 20, 1, -42)
buyPerm.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
buyPerm.TextColor3 = Color3.fromRGB(10, 10, 10)
buyPerm.TextSize = 10

local buyAdmin = makeButton(keyFrame, "BUY ADMIN VERSION", UDim2.new(.5, -25, 0, 30))
buyAdmin.Position = UDim2.new(.5, 5, 1, -42)
buyAdmin.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
buyAdmin.TextColor3 = Color3.fromRGB(245, 245, 245)
buyAdmin.TextSize = 10
stroke(buyAdmin, Color3.fromRGB(160, 160, 160), 1, .25)

local function openLink(url, label)
    local opened = false

    pcall(function()
        if GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(url)
            opened = true
        end
    end)

    if not opened then
        pcall(function()
            if setclipboard then
                setclipboard(url)
            end
        end)
        notify(label, "Link copied. Open it in your browser.")
    end
end

local function whatsappBuyLink(productName)
    local message = "Hai, saya nak beli " .. productName .. " SherifGo."
    local encoded = message:gsub(" ", "%%20")
    return "https://wa.me/" .. WHATSAPP_NUMBER .. "?text=" .. encoded
end

connect(buyPerm.Activated, function()
    openLink(whatsappBuyLink("Perm Key"), "Perm Key")
end)

connect(buyAdmin.Activated, function()
    openLink(whatsappBuyLink("Admin Version"), "Admin Version")
end)

-- Key verification
-- Single-file mode: StarterPlayer > StarterPlayerScripts.
-- Two key tiers:
--   FREE  -> SherifGoFree
--   PERM  -> SherifGoPerm
local function verifyKey(entered)
    if entered == FREE_KEY then
        return true, "FREE"
    elseif entered == PERM_KEY then
        return true, "PERMANENT"
    end
    return false, nil
end

connect(check.Activated, function()
    if State.KeyVerified then return end

    local entered = tostring(keyBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    check.Active = false

    local valid, tier = verifyKey(entered)

    if valid then
        State.KeyVerified = true
        State.KeyTier = tier

        if tier == "PERMANENT" then
            keyStatus.Text = "✓ PERMANENT KEY VALID"
        else
            keyStatus.Text = "✓ FREE KEY VALID"
        end

        keyStatus.TextColor3 = Color3.fromRGB(235, 235, 235)
        task.wait(.35)

        keyFrame.Visible = false
        main.Visible = true
        showTab("Dashboard")
        notify("SherifGo", tier .. " key verified.")
    else
        keyStatus.Text = "✕ INVALID KEY — KICKING..."
        keyStatus.TextColor3 = Color3.fromRGB(255, 75, 75)
        task.wait(.25)
        LocalPlayer:Kick("SherifGo: Invalid Key")
    end

    check.Active = true
end)

-- Player/role lifecycle
local function hookPlayer(player)
    if RoleConnections[player] then return end
    local list = {}

    table.insert(list, player:GetAttributeChangedSignal("Role"):Connect(function()
        State.CurrentTarget=nil
        if State.ESP then refreshESP() end
    end))

    table.insert(list, player.CharacterAdded:Connect(function()
        State.CurrentTarget=nil
        task.wait(.15)
        if State.ESP then applyESP(player) end
    end))

    table.insert(list, player.CharacterRemoving:Connect(function()
        clearESP(player)
        if State.CurrentTarget == player then State.CurrentTarget=nil end
    end))

    RoleConnections[player]=list
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then hookPlayer(p) end
end

connect(Players.PlayerAdded, function(p)
    if p ~= LocalPlayer then hookPlayer(p) end
end)

connect(Players.PlayerRemoving, function(p)
    clearESP(p)
    if State.CurrentTarget == p then State.CurrentTarget=nil end
    local list=RoleConnections[p]
    if list then
        for _,c in ipairs(list) do disconnect(c) end
        RoleConnections[p]=nil
    end
end)

-- Infinite jump / noclip / fly / sprint / anti-AFK
local function setNoclip(enabled)
    local char = LocalPlayer.Character
    if not char then return end

    if enabled then
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and OriginalCollision[v] == nil then
                OriginalCollision[v] = v.CanCollide
                v.CanCollide = false
            end
        end
    else
        for part, original in pairs(OriginalCollision) do
            if part and part.Parent then
                part.CanCollide = original
            end
            OriginalCollision[part] = nil
        end
    end
end

local function applyMovementStats()
    local hum = getHumanoid(LocalPlayer)
    if not hum then return end
    if State.Sprint then
        hum.WalkSpeed = State.WalkSpeed * 1.35
    else
        hum.WalkSpeed = State.WalkSpeed
    end
    hum.JumpPower = State.JumpPower
end

connect(UserInputService.JumpRequest, function()
    if State.InfiniteJump then
        local hum=getHumanoid(LocalPlayer)
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local lastMoveUpdate = 0
connect(RunService.Stepped, function()
    if State.Destroyed then return end

    if State.Noclip then
        setNoclip(true)
    end

    local now = os.clock()
    if now - lastMoveUpdate >= 0.10 then
        lastMoveUpdate = now
        applyMovementStats()
    end
end)

local flyVelocity
connect(RunService.RenderStepped, function()
    if State.Destroyed or not State.KeyVerified then return end

    if State.Aim and not State.Hidden then
        if not validateTarget(State.CurrentTarget) then
            if State.AutoRetarget then
                State.CurrentTarget=getClosestTarget()
            else
                State.CurrentTarget=nil
            end
        end

        if validateTarget(State.CurrentTarget) then
            aimAt(State.CurrentTarget)
        end
    end

    if State.Fly then
        local root=getRoot(LocalPlayer)
        if root then
            if not flyVelocity then
                flyVelocity=Instance.new("BodyVelocity")
                flyVelocity.MaxForce=Vector3.new(1e5,1e5,1e5)
                flyVelocity.Parent=root
            end
            local move=Vector3.zero
            local cf=Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
            flyVelocity.Velocity = move.Magnitude > 0 and move.Unit*State.FlySpeed or Vector3.zero
        end
    elseif flyVelocity then
        flyVelocity:Destroy()
        flyVelocity=nil
    end
end)

connect(LocalPlayer.Idled, function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(.2)
            VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end
end)

connect(LocalPlayer.CharacterRemoving, function()
    State.CurrentTarget = nil
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    setNoclip(false)
end)

connect(LocalPlayer.CharacterAdded, function(character)
    State.CurrentTarget = nil
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    OriginalCollision = {}
    task.wait(.25)
    applyMovementStats()
    if State.Noclip then
        setNoclip(true)
    end
    if State.ESP then
        refreshESP()
    end
end)

showTab("Dashboard")

updateTabVisuals("Dashboard")
