-- DaMityhicHub Combat V2 Premium
-- Same compact black/red GUI style. Old gameplay features removed.
-- New combat/visual suite: Player ESP, Health, Armor/Shield, Distance,
-- Weapon, Visible Check, 2D Box, Skeleton, Target Indicator,
-- Enemy Warning, Enemy Counter, Dead Filter, Team Check, Max Distance.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Connections = {}
local OriginalFOV = Camera and Camera.FieldOfView or 70
table.insert(Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
    if Camera then OriginalFOV = Camera.FieldOfView end
end))

local CONFIG = {
    ESP_MAX_DISTANCE = 1000,
    WARNING_DISTANCE = 60,
    UPDATE_INTERVAL = 0.08,
}

local State = {
    Unlocked = false,
    PlayerESP = false,
    HealthESP = false,
    ArmorESP = false,
    DistanceESP = false,
    WeaponESP = false,
    VisibleCheck = false,
    BoxESP = false,
    SkeletonESP = false,
    TargetIndicator = false,
    EnemyWarning = false,
    DeadFilter = true,
    TeamCheck = true,
    MaxDistance = CONFIG.ESP_MAX_DISTANCE,
    WarningDistance = CONFIG.WARNING_DISTANCE,
    -- Premium combat / movement
    Aimbot = false,
    AimFOV = 260,
    AimSmooth = 0.32,
    AimMaxDistance = 1000,
    AimPrediction = 0.12,
    AimVisibleOnly = true,
    AimTargetPart = "HumanoidRootPart",
    AimTargetTeam = "",
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    Fly = false,
    FlySpeed = 80,
    Noclip = false,
    InfiniteJump = false,
    FOV = 70,
    FOVEnabled = false,
    FPSCounter = true,
    OffscreenArrow = true,
    EnemyRadar = false,
    LookDirection = false,
    MovementIndicator = false,
    PlayerNameESP = true,
    HeadDot = false,
    LowHealthAlert = false,
    DistanceColor = false,
    HealthPercent = false,
    EnemyDirection = false,
    NearbyAlert = false,
    TeamCounter = false,
    ESPRefreshRate = 12,
    ESPEnemyColor = Color3.fromRGB(225,35,48),
    ESPTeamColor = Color3.fromRGB(55,220,125),
    ESPLowHealthColor = Color3.fromRGB(255,200,65),
    PingCounter = false,
    PerformanceMode = false,
    ServerInfo = false,
    PlayerCounter = false,
    GUITransparency = 0,
    GUICompact = false,
}

local Character, Humanoid, RootPart
local OriginalWalkSpeed = 16
local ESPObjects = {}

local function disconnectAll(list)
    for _, c in ipairs(list) do
        if typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(list)
end

local function setupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 10)
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    if Humanoid then OriginalWalkSpeed = Humanoid.WalkSpeed end
    if Camera then OriginalFOV = Camera.FieldOfView end
end

if LocalPlayer.Character then
    task.spawn(setupCharacter, LocalPlayer.Character)
end
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(setupCharacter))

local oldGui = PlayerGui:FindFirstChild("DaMityhicHub")
if oldGui then
    oldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "DaMityhicHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local C = {
    Black = Color3.fromRGB(8, 8, 10),
    Black2 = Color3.fromRGB(13, 13, 16),
    Panel = Color3.fromRGB(18, 18, 22),
    Panel2 = Color3.fromRGB(23, 23, 28),
    Red = Color3.fromRGB(225, 35, 48),
    Red2 = Color3.fromRGB(255, 65, 75),
    DarkRed = Color3.fromRGB(95, 18, 25),
    White = Color3.fromRGB(245, 245, 248),
    Gray = Color3.fromRGB(160, 160, 170),
    Gray2 = Color3.fromRGB(105, 105, 115),
    Green = Color3.fromRGB(55, 220, 125),
    Yellow = Color3.fromRGB(255, 200, 65),
}

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Red
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function Gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2),
    })
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local function Tween(obj, props, duration)
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end)
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

local function ClampNumber(value, min, max, fallback)
    local n = tonumber(value)
    if not n then return fallback end
    return math.clamp(n, min, max)
end

local function MakeDraggable(object, handle)
    handle = handle or object
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.new(0.92, 0, 0, 470)
Main.BackgroundColor3 = C.Black
Main.BackgroundTransparency = 0.08
Main.Visible = false
Main.Parent = Gui
Corner(Main, 14)
Stroke(Main, C.DarkRed, 1.5, 0.15)
local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MinSize = Vector2.new(340, 400)
MainConstraint.MaxSize = Vector2.new(680, 650)
MainConstraint.Parent = Main
Gradient(Main, Color3.fromRGB(12,12,15), Color3.fromRGB(7,7,9), 90)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 66)
Header.BackgroundColor3 = C.Panel
Header.Parent = Main
Corner(Header, 14)
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0,0,1,-2)
HeaderLine.BackgroundColor3 = C.Red
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header
Gradient(HeaderLine, C.Red, Color3.fromRGB(100,10,20), 0)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(44,44)
Logo.Position = UDim2.fromOffset(12,11)
Logo.BackgroundColor3 = C.Red
Logo.Parent = Header
Corner(Logo,12)
Gradient(Logo, C.Red2, Color3.fromRGB(125,12,22), 45)
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1,1)
LogoText.BackgroundTransparency = 1
LogoText.Text = "M"
LogoText.TextColor3 = Color3.new(1,1,1)
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 25
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(68,9)
Title.Size = UDim2.new(1,-150,0,26)
Title.Text = "DaMityhicHub"
Title.TextColor3 = C.White
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(69,34)
Version.Size = UDim2.new(1,-150,0,18)
Version.Text = "V3 Premium • Premium Control"
Version.TextColor3 = C.Gray
Version.Font = Enum.Font.Gotham
Version.TextSize = 11
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.fromOffset(38,38)
HideButton.Position = UDim2.new(1,-50,0,14)
HideButton.BackgroundColor3 = C.Panel2
HideButton.Text = "—"
HideButton.TextColor3 = C.White
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 19
HideButton.AutoButtonColor = false
HideButton.Parent = Header
Corner(HideButton,10)
Stroke(HideButton,C.Gray2,1,0.55)

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(8,76)
Sidebar.Size = UDim2.new(0,102,1,-86)
Sidebar.BackgroundColor3 = C.Panel
Sidebar.Parent = Main
Corner(Sidebar,12)
Stroke(Sidebar,Color3.fromRGB(45,45,50),1,0.6)
local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = Sidebar
local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0,10)
SidePadding.PaddingLeft = UDim.new(0,5)
SidePadding.PaddingRight = UDim.new(0,5)
SidePadding.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(118,76)
Content.Size = UDim2.new(1,-128,1,-86)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Red
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,2)
    pad.PaddingBottom = UDim.new(0,12)
    pad.PaddingLeft = UDim.new(0,2)
    pad.PaddingRight = UDim.new(0,8)
    pad.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,10)
    layout.Parent = page
    Pages[name] = page
    return page
end

local HomePage = CreatePage("Home")
local PlayerPage = CreatePage("Player")
local VisualPage = CreatePage("Visual")
local CombatPage = CreatePage("Combat")
local DiscoveryPage = CreatePage("Discovery")
local CreditsPage = CreatePage("Credits")
local AimPage = CreatePage("Aimbot")
local MovePage = CreatePage("Movement")
local UtilityPage = CreatePage("Utility")
local AdvancedPage = CreatePage("Advanced")

local function CreateCard(parent, title, subtitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-2,0,90)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C.Panel
    card.Parent = parent
    Corner(card,11)
    Stroke(card,Color3.fromRGB(45,45,52),1,0.5)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(3,55)
    accent.Position = UDim2.fromOffset(0,17)
    accent.BackgroundColor3 = C.Red
    accent.BorderSizePixel = 0
    accent.Parent = card
    Corner(accent,2)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.fromOffset(15,10)
    titleLabel.Size = UDim2.new(1,-25,0,22)
    titleLabel.Text = title
    titleLabel.TextColor3 = C.White
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    local subLabel = Instance.new("TextLabel")
    subLabel.BackgroundTransparency = 1
    subLabel.Position = UDim2.fromOffset(15,34)
    subLabel.Size = UDim2.new(1,-25,0,35)
    subLabel.Text = subtitle or ""
    subLabel.TextColor3 = C.Gray
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 10
    subLabel.TextWrapped = true
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextYAlignment = Enum.TextYAlignment.Top
    subLabel.Parent = card
    return card
end

local function CreateStatus(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,30)
    label.BackgroundColor3 = C.Black2
    label.Text = text
    label.TextColor3 = C.Gray
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.Parent = parent
    Corner(label,8)
    return label
end

local function CreateActionButton(parent,text,callback,height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,height or 40)
    button.BackgroundColor3 = C.Panel2
    button.Text = text
    button.TextColor3 = C.White
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = parent
    Corner(button,9)
    Stroke(button,Color3.fromRGB(50,50,57),1,0.45)
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return button
end

local function CreateToggle(parent,title,initial,callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,44)
    button.BackgroundColor3 = C.Panel2
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent
    Corner(button,9)
    Stroke(button,Color3.fromRGB(48,48,55),1,0.5)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12,0)
    label.Size = UDim2.new(1,-78,1,0)
    label.Text = title
    label.TextColor3 = C.White
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(48,24)
    pill.Position = UDim2.new(1,-58,0.5,-12)
    pill.BackgroundColor3 = Color3.fromRGB(45,45,50)
    pill.Parent = button
    Corner(pill,20)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.fromOffset(18,18)
    circle.Position = UDim2.fromOffset(3,3)
    circle.BackgroundColor3 = C.Gray2
    circle.Parent = pill
    Corner(circle,20)
    local enabled = initial == true
    local function refresh()
        if enabled then
            pill.BackgroundColor3 = C.DarkRed
            circle.Position = UDim2.new(1,-21,0,3)
            circle.BackgroundColor3 = C.Red2
        else
            pill.BackgroundColor3 = Color3.fromRGB(45,45,50)
            circle.Position = UDim2.fromOffset(3,3)
            circle.BackgroundColor3 = C.Gray2
        end
    end
    refresh()
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        refresh()
        if callback then callback(enabled) end
    end)
    return {Button=button,Set=function(v) enabled=v==true;refresh();if callback then callback(enabled) end end,Get=function() return enabled end}
end

local function CreateInput(parent,placeholder,defaultText)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,0,0,40)
    box.BackgroundColor3 = C.Black2
    box.TextColor3 = C.White
    box.PlaceholderColor3 = C.Gray2
    box.PlaceholderText = placeholder
    box.Text = defaultText or ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = parent
    Corner(box,9)
    Stroke(box,Color3.fromRGB(55,55,62),1,0.35)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,12)
    pad.PaddingRight = UDim.new(0,12)
    pad.Parent = box
    return box
end

-- HOME
local hero = Instance.new("Frame")
hero.Size = UDim2.new(1,-2,0,125)
hero.BackgroundColor3 = C.Panel
hero.Parent = HomePage
Corner(hero,12)
Stroke(hero,C.DarkRed,1,0.3)
Gradient(hero,Color3.fromRGB(28,13,16),Color3.fromRGB(15,15,18),0)
local h1 = Instance.new("TextLabel")
h1.BackgroundTransparency = 1
h1.Position = UDim2.fromOffset(17,16)
h1.Size = UDim2.new(1,-34,0,28)
h1.Text = "Welcome to DaMityhicHub"
h1.TextColor3 = C.White
h1.Font = Enum.Font.GothamBold
h1.TextSize = 19
h1.TextXAlignment = Enum.TextXAlignment.Left
h1.Parent = hero
local h2 = Instance.new("TextLabel")
h2.BackgroundTransparency = 1
h2.Position = UDim2.fromOffset(18,47)
h2.Size = UDim2.new(1,-36,0,42)
h2.Text = "Combat V2 Premium • Visual intelligence suite\nBuilt for mobile & desktop."
h2.TextColor3 = C.Gray
h2.Font = Enum.Font.Gotham
h2.TextSize = 11
h2.TextWrapped = true
h2.TextXAlignment = Enum.TextXAlignment.Left
h2.Parent = hero
local homeStatus = CreateStatus(hero,"● SYSTEM READY")
homeStatus.Position = UDim2.new(0,17,1,-38)
homeStatus.Size = UDim2.new(1,-34,0,26)
homeStatus.TextColor3 = C.Green
homeStatus.BackgroundColor3 = Color3.fromRGB(12,28,20)

local function getTargetTeamName()
    local configured = tostring(State.AimTargetTeam or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if configured ~= "" then return configured end
    return LocalPlayer.Team and LocalPlayer.Team.Name or ""
end

-- PLAYER PAGE
local playerCard = CreateCard(PlayerPage,"Player Status","Live local-player information.")
local playerContainer = Instance.new("Frame")
playerContainer.BackgroundTransparency = 1
playerContainer.Position = UDim2.fromOffset(15,64)
playerContainer.Size = UDim2.new(1,-30,0,112)
playerContainer.Parent = playerCard
local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,6)
playerLayout.Parent = playerContainer
local characterStatus = CreateStatus(playerContainer,"Character: Loading...")
local teamStatus = CreateStatus(playerContainer,"Team: None")
local healthStatus = CreateStatus(playerContainer,"Health: --")
local enemyStatus = CreateStatus(playerContainer,"Enemies: 0")

-- VISUAL PAGE
local visualCard = CreateCard(VisualPage,"Visual Controls","Visual helpers are controlled from Combat V2 Premium.")
local visualContainer = Instance.new("Frame")
visualContainer.BackgroundTransparency = 1
visualContainer.Position = UDim2.fromOffset(15,64)
visualContainer.Size = UDim2.new(1,-30,0,100)
visualContainer.Parent = visualCard
local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0,6)
visualLayout.Parent = visualContainer
CreateStatus(visualContainer,"• Player ESP / Box / Skeleton")
CreateStatus(visualContainer,"• Health / Armor / Weapon / Distance")
CreateStatus(visualContainer,"• Visible Check / Off-Screen Indicator")

-- COMBAT PAGE
local combatCard = CreateCard(CombatPage,"Combat ESP V2 Premium","New battlefield information tools. Old aim/movement features removed.")
local combatContainer = Instance.new("Frame")
combatContainer.BackgroundTransparency = 1
combatContainer.Position = UDim2.fromOffset(15,64)
combatContainer.Size = UDim2.new(1,-30,0,1200)
combatContainer.Parent = combatCard
local combatLayout = Instance.new("UIListLayout")
combatLayout.Padding = UDim.new(0,6)
combatLayout.Parent = combatContainer

local function makeToggle(title, desc, key)
    local card = CreateCard(combatContainer,title,desc)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.fromOffset(15,63)
    holder.Size = UDim2.new(1,-30,0,44)
    holder.Parent = card
    return CreateToggle(holder,title,State[key],function(v) State[key]=v end)
end

makeToggle("Player ESP","Body highlight for enemies.","PlayerESP")
makeToggle("Health ESP","Shows live health above enemies.","HealthESP")
makeToggle("Armor / Shield ESP","Shows common armor or shield values when available.","ArmorESP")
makeToggle("Distance ESP","Shows world distance to enemies.","DistanceESP")
makeToggle("Weapon ESP","Shows the equipped Tool name.","WeaponESP")
makeToggle("Visible Check","Only highlights targets that are visible from your camera.","VisibleCheck")
makeToggle("2D Box ESP","Shows a screen-space box around enemies.","BoxESP")
makeToggle("Skeleton ESP","Shows a lightweight body-joint skeleton.","SkeletonESP")
makeToggle("Target Indicator","Marks the nearest valid enemy without camera locking.","TargetIndicator")
makeToggle("Enemy Warning","Shows a warning when an enemy enters the warning range.","EnemyWarning")
makeToggle("Dead Player Filter","Hides ESP for dead characters.","DeadFilter")
makeToggle("Team Check","Only show players on a different team.","TeamCheck")

local distanceCard = CreateCard(combatContainer,"ESP Max Distance","Maximum distance for all enemy visual tools.")
local distanceHolder = Instance.new("Frame")
distanceHolder.BackgroundTransparency = 1
distanceHolder.Position = UDim2.fromOffset(15,63)
distanceHolder.Size = UDim2.new(1,-30,0,40)
distanceHolder.Parent = distanceCard
local distanceBox = CreateInput(distanceHolder,"Distance 1 - 5000",tostring(State.MaxDistance))
distanceBox.FocusLost:Connect(function()
    State.MaxDistance = ClampNumber(distanceBox.Text,1,5000,CONFIG.ESP_MAX_DISTANCE)
    distanceBox.Text = tostring(State.MaxDistance)
end)

local warningCard = CreateCard(combatContainer,"Warning Range","Distance at which Enemy Warning becomes active.")
local warningHolder = Instance.new("Frame")
warningHolder.BackgroundTransparency = 1
warningHolder.Position = UDim2.fromOffset(15,63)
warningHolder.Size = UDim2.new(1,-30,0,40)
warningHolder.Parent = warningCard
local warningBox = CreateInput(warningHolder,"Range 5 - 500",tostring(State.WarningDistance))
warningBox.FocusLost:Connect(function()
    State.WarningDistance = ClampNumber(warningBox.Text,5,500,CONFIG.WARNING_DISTANCE)
    warningBox.Text = tostring(State.WarningDistance)
end)

local resetCard = CreateCard(combatContainer,"Combat Reset","Turn off all combat visual features and clear generated objects.")
local resetHolder = Instance.new("Frame")
resetHolder.BackgroundTransparency = 1
resetHolder.Position = UDim2.fromOffset(15,63)
resetHolder.Size = UDim2.new(1,-30,0,40)
resetHolder.Parent = resetCard
CreateActionButton(resetHolder,"RESET COMBAT VISUALS",function()
    for key,_ in pairs(State) do
        if type(State[key]) == "boolean" and key ~= "Unlocked" then State[key] = false end
    end
    State.DeadFilter = true
    State.TeamCheck = true
    for player, _ in pairs(ESPObjects) do
        if ESPObjects[player] then
            for _, obj in pairs(ESPObjects[player]) do
                if typeof(obj) == "Instance" then pcall(function() obj:Destroy() end) end
            end
        end
    end
    table.clear(ESPObjects)
    Notify("DaMityhicHub","Combat visuals reset.",2)
end)

-- AIMBOT PAGE
local aimCard = CreateCard(AimPage,"Premium Aimbot","Smooth target tracking with FOV, prediction and visibility controls.")
local aimContainer = Instance.new("Frame")
aimContainer.BackgroundTransparency = 1
aimContainer.Position = UDim2.fromOffset(15,64)
aimContainer.Size = UDim2.new(1,-30,0,700)
aimContainer.Parent = aimCard
local aimLayout = Instance.new("UIListLayout")
aimLayout.Padding = UDim.new(0,6)
aimLayout.Parent = aimContainer

local function aimToggle(title,desc,key)
    local c=CreateCard(aimContainer,title,desc)
    local h=Instance.new("Frame")
    h.BackgroundTransparency=1
    h.Position=UDim2.fromOffset(15,63)
    h.Size=UDim2.new(1,-30,0,44)
    h.Parent=c
    return CreateToggle(h,title,State[key],function(v) State[key]=v end)
end

aimToggle("Aimbot","Tracks the nearest valid enemy inside the FOV.","Aimbot")
aimToggle("Visible Only","Ignore targets hidden behind walls.","AimVisibleOnly")

local teamCard=CreateCard(aimContainer,"Target Team","Enter the exact Team name shown on the leaderboard. The Aimbot will target only players whose team is different from this name.")
local teamHolder=Instance.new("Frame")
teamHolder.BackgroundTransparency=1
teamHolder.Position=UDim2.fromOffset(15,63)
teamHolder.Size=UDim2.new(1,-30,0,40)
teamHolder.Parent=teamCard
local teamBox=CreateInput(teamHolder,"Team name from leaderboard","")
local function refreshTeamBox()
    local teamName=getTargetTeamName()
    teamBox.Text=teamName
end
refreshTeamBox()
teamBox.FocusLost:Connect(function()
    State.AimTargetTeam=tostring(teamBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    refreshTeamBox()
    AimTarget=nil
end)

table.insert(Connections, Players.PlayerAdded:Connect(function()
    if State.AimTargetTeam == "" then refreshTeamBox() end
end))
table.insert(Connections, LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if State.AimTargetTeam == "" then
        refreshTeamBox()
        AimTarget=nil
    end
end))

local fovCard=CreateCard(aimContainer,"Aim FOV","Screen-space radius used to acquire targets.")
local fovHolder=Instance.new("Frame"); fovHolder.BackgroundTransparency=1; fovHolder.Position=UDim2.fromOffset(15,63); fovHolder.Size=UDim2.new(1,-30,0,40); fovHolder.Parent=fovCard
local fovBox=CreateInput(fovHolder,"FOV 40 - 900",tostring(State.AimFOV))
fovBox.FocusLost:Connect(function() State.AimFOV=ClampNumber(fovBox.Text,40,900,260); fovBox.Text=tostring(State.AimFOV) end)

local smoothCard=CreateCard(aimContainer,"Aim Smooth","Lower values are smoother; higher values follow faster.")
local smoothHolder=Instance.new("Frame"); smoothHolder.BackgroundTransparency=1; smoothHolder.Position=UDim2.fromOffset(15,63); smoothHolder.Size=UDim2.new(1,-30,0,40); smoothHolder.Parent=smoothCard
local smoothBox=CreateInput(smoothHolder,"Smooth 0.03 - 1",tostring(State.AimSmooth))
smoothBox.FocusLost:Connect(function() State.AimSmooth=ClampNumber(smoothBox.Text,0.03,1,0.12); smoothBox.Text=tostring(State.AimSmooth) end)

local predCard=CreateCard(aimContainer,"Aim Prediction","Predict moving targets to reduce tracking lag.")
local predHolder=Instance.new("Frame"); predHolder.BackgroundTransparency=1; predHolder.Position=UDim2.fromOffset(15,63); predHolder.Size=UDim2.new(1,-30,0,40); predHolder.Parent=predCard
local predBox=CreateInput(predHolder,"Prediction 0 - 0.5",tostring(State.AimPrediction))
predBox.FocusLost:Connect(function() State.AimPrediction=ClampNumber(predBox.Text,0,0.5,0.12); predBox.Text=tostring(State.AimPrediction) end)

-- MOVEMENT PAGE
local moveCard=CreateCard(MovePage,"Premium Movement","WalkSpeed, Fly, Noclip and Infinite Jump.")
local moveContainer=Instance.new("Frame"); moveContainer.BackgroundTransparency=1; moveContainer.Position=UDim2.fromOffset(15,64); moveContainer.Size=UDim2.new(1,-30,0,500); moveContainer.Parent=moveCard
local moveLayout=Instance.new("UIListLayout"); moveLayout.Padding=UDim.new(0,6); moveLayout.Parent=moveContainer
local function moveToggle(title,desc,key)
    local c=CreateCard(moveContainer,title,desc); local h=Instance.new("Frame"); h.BackgroundTransparency=1; h.Position=UDim2.fromOffset(15,63); h.Size=UDim2.new(1,-30,0,44); h.Parent=c
    return CreateToggle(h,title,State[key],function(v) State[key]=v end)
end
moveToggle("WalkSpeed","Apply custom WalkSpeed while enabled.","WalkSpeedEnabled")
local wsCard=CreateCard(moveContainer,"WalkSpeed","Speed range 1 - 1000.")
local wsHolder=Instance.new("Frame"); wsHolder.BackgroundTransparency=1; wsHolder.Position=UDim2.fromOffset(15,63); wsHolder.Size=UDim2.new(1,-30,0,40); wsHolder.Parent=wsCard
local wsBox=CreateInput(wsHolder,"Speed 1 - 1000",tostring(State.WalkSpeed)); wsBox.FocusLost:Connect(function() State.WalkSpeed=ClampNumber(wsBox.Text,1,1000,16); wsBox.Text=tostring(State.WalkSpeed) end)
moveToggle("Fly","Fly using Space/LeftControl on desktop; mobile can use the normal jump control.","Fly")
local flyCard=CreateCard(moveContainer,"Fly Speed","Fly speed range 1 - 300.")
local flyHolder=Instance.new("Frame"); flyHolder.BackgroundTransparency=1; flyHolder.Position=UDim2.fromOffset(15,63); flyHolder.Size=UDim2.new(1,-30,0,40); flyHolder.Parent=flyCard
local flyBox=CreateInput(flyHolder,"Fly speed 1 - 300",tostring(State.FlySpeed)); flyBox.FocusLost:Connect(function() State.FlySpeed=ClampNumber(flyBox.Text,1,300,80); flyBox.Text=tostring(State.FlySpeed) end)
moveToggle("Noclip","Disable character collisions while enabled.","Noclip")
moveToggle("Infinite Jump","Jump again while airborne.","InfiniteJump")

-- UTILITY PAGE
local utilCard=CreateCard(UtilityPage,"Premium Utility","Extra controls for combat sessions.")
local utilContainer=Instance.new("Frame"); utilContainer.BackgroundTransparency=1; utilContainer.Position=UDim2.fromOffset(15,64); utilContainer.Size=UDim2.new(1,-30,0,500); utilContainer.Parent=utilCard
local utilLayout=Instance.new("UIListLayout"); utilLayout.Padding=UDim.new(0,6); utilLayout.Parent=utilContainer
local fovToggleCard=CreateCard(utilContainer,"Camera FOV","Change the local camera FOV.")
local fovToggleHolder=Instance.new("Frame"); fovToggleHolder.BackgroundTransparency=1; fovToggleHolder.Position=UDim2.fromOffset(15,63); fovToggleHolder.Size=UDim2.new(1,-30,0,44); fovToggleHolder.Parent=fovToggleCard
CreateToggle(fovToggleHolder,"Camera FOV",State.FOVEnabled,function(v) State.FOVEnabled=v end)
local camFovCard=CreateCard(utilContainer,"FOV Value","Camera FOV range 40 - 120.")
local camFovHolder=Instance.new("Frame"); camFovHolder.BackgroundTransparency=1; camFovHolder.Position=UDim2.fromOffset(15,63); camFovHolder.Size=UDim2.new(1,-30,0,40); camFovHolder.Parent=camFovCard
local camFovBox=CreateInput(camFovHolder,"FOV 40 - 120",tostring(State.FOV)); camFovBox.FocusLost:Connect(function() State.FOV=ClampNumber(camFovBox.Text,40,120,70); camFovBox.Text=tostring(State.FOV) end)
local perfCard=CreateCard(utilContainer,"Performance","Simple FPS display in the top-left corner.")
local perfHolder=Instance.new("Frame"); perfHolder.BackgroundTransparency=1; perfHolder.Position=UDim2.fromOffset(15,63); perfHolder.Size=UDim2.new(1,-30,0,44); perfHolder.Parent=perfCard
CreateToggle(perfHolder,"FPS Counter",State.FPSCounter,function(v) State.FPSCounter=v end)
local resetMove=CreateCard(utilContainer,"Reset Movement","Restore movement and camera values.")
local resetHolder=Instance.new("Frame"); resetHolder.BackgroundTransparency=1; resetHolder.Position=UDim2.fromOffset(15,63); resetHolder.Size=UDim2.new(1,-30,0,40); resetHolder.Parent=resetMove
CreateActionButton(resetHolder,"RESET MOVEMENT",function() State.WalkSpeedEnabled=false; State.Fly=false; State.Noclip=false; State.InfiniteJump=false; State.FOVEnabled=false; if Humanoid then Humanoid.WalkSpeed=OriginalWalkSpeed end; if Camera then Camera.FieldOfView=OriginalFOV end; Notify("DaMityhicHub","Movement reset.",2) end)

-- ADVANCED PAGE
local advancedCard = CreateCard(AdvancedPage,"Premium Advanced Suite","Additional combat awareness and utility controls.")
local advancedContainer = Instance.new("Frame")
advancedContainer.BackgroundTransparency = 1
advancedContainer.Position = UDim2.fromOffset(15,64)
advancedContainer.Size = UDim2.new(1,-30,0,1900)
advancedContainer.Parent = advancedCard
local advancedLayout = Instance.new("UIListLayout")
advancedLayout.Padding = UDim.new(0,6)
advancedLayout.Parent = advancedContainer

local function advToggle(title,desc,key)
    local c=CreateCard(advancedContainer,title,desc)
    local h=Instance.new("Frame")
    h.BackgroundTransparency=1; h.Position=UDim2.fromOffset(15,63); h.Size=UDim2.new(1,-30,0,44); h.Parent=c
    return CreateToggle(h,title,State[key],function(v) State[key]=v end)
end

advToggle("Off-Screen Arrow","Show direction arrows for enemies outside the screen.","OffscreenArrow")
advToggle("Enemy Radar","Show a compact radar with nearby enemies.","EnemyRadar")
advToggle("Look Direction","Show the enemy facing direction in the info display.","LookDirection")
advToggle("Movement Indicator","Show whether an enemy is moving or stationary.","MovementIndicator")
advToggle("Player Name ESP","Show player names in the combat info.","PlayerNameESP")
advToggle("Head Dot","Show a small marker on enemy heads.","HeadDot")
advToggle("Low Health Alert","Highlight enemies below 25% health.","LowHealthAlert")
advToggle("Distance Color","Change info color based on distance.","DistanceColor")
advToggle("Health Percentage","Show HP as a percentage.","HealthPercent")
advToggle("Enemy Direction","Show a direction indicator in the info.","EnemyDirection")
advToggle("Nearby Enemy Alert","Show a warning when an enemy enters warning range.","NearbyAlert")
advToggle("Team Counter","Show enemy count grouped by team.","TeamCounter")
advToggle("Ping Counter","Show current client ping.","PingCounter")
advToggle("Performance Mode","Reduce ESP update workload.","PerformanceMode")
advToggle("Server Info","Show server/job information.","ServerInfo")
advToggle("Player Counter","Show total player count.","PlayerCounter")

local refreshCard=CreateCard(advancedContainer,"ESP Refresh Rate","Update frequency from 4 to 30 times per second.")
local refreshHolder=Instance.new("Frame"); refreshHolder.BackgroundTransparency=1; refreshHolder.Position=UDim2.fromOffset(15,63); refreshHolder.Size=UDim2.new(1,-30,0,40); refreshHolder.Parent=refreshCard
local refreshBox=CreateInput(refreshHolder,"Rate 4 - 30",tostring(State.ESPRefreshRate)); refreshBox.FocusLost:Connect(function() State.ESPRefreshRate=ClampNumber(refreshBox.Text,4,30,12); refreshBox.Text=tostring(State.ESPRefreshRate) end)

local transCard=CreateCard(advancedContainer,"GUI Transparency","Set interface transparency from 0 to 0.65.")
local transHolder=Instance.new("Frame"); transHolder.BackgroundTransparency=1; transHolder.Position=UDim2.fromOffset(15,63); transHolder.Size=UDim2.new(1,-30,0,40); transHolder.Parent=transCard
local transBox=CreateInput(transHolder,"0 - 0.65",tostring(State.GUITransparency)); transBox.FocusLost:Connect(function() State.GUITransparency=ClampNumber(transBox.Text,0,0.65,0); transBox.Text=tostring(State.GUITransparency) end)

local compactCard=CreateCard(advancedContainer,"Compact GUI","Reduce the main panel footprint.")
local compactHolder=Instance.new("Frame"); compactHolder.BackgroundTransparency=1; compactHolder.Position=UDim2.fromOffset(15,63); compactHolder.Size=UDim2.new(1,-30,0,44); compactHolder.Parent=compactCard
CreateToggle(compactHolder,"Compact GUI",State.GUICompact,function(v) State.GUICompact=v end)

local advancedReset=CreateCard(advancedContainer,"Reset Advanced","Restore all advanced controls to their defaults.")
local advancedResetHolder=Instance.new("Frame"); advancedResetHolder.BackgroundTransparency=1; advancedResetHolder.Position=UDim2.fromOffset(15,63); advancedResetHolder.Size=UDim2.new(1,-30,0,40); advancedResetHolder.Parent=advancedReset
CreateActionButton(advancedResetHolder,"RESET ADVANCED",function()
    State.OffscreenArrow=true; State.EnemyRadar=false; State.LookDirection=false; State.MovementIndicator=false; State.PlayerNameESP=true; State.HeadDot=false; State.LowHealthAlert=false; State.DistanceColor=false; State.HealthPercent=false; State.EnemyDirection=false; State.NearbyAlert=false; State.TeamCounter=false; State.PingCounter=false; State.PerformanceMode=false; State.ServerInfo=false; State.PlayerCounter=false; State.ESPRefreshRate=12; State.GUITransparency=0; State.GUICompact=false
    Notify("DaMityhicHub","Advanced settings reset.",2)
end)

-- DISCOVERY
local discoveryCard = CreateCard(DiscoveryPage,"Combat V2 Premium","Current feature set.")
local discoveryContainer = Instance.new("Frame")
discoveryContainer.BackgroundTransparency = 1
discoveryContainer.Position = UDim2.fromOffset(15,64)
discoveryContainer.Size = UDim2.new(1,-30,0,330)
discoveryContainer.Parent = discoveryCard
local discoveryLayout = Instance.new("UIListLayout")
discoveryLayout.Padding = UDim.new(0,6)
discoveryLayout.Parent = discoveryContainer
for _, text in ipairs({
    "● Player / Health / Armor ESP",
    "● Premium Aimbot + Prediction + FOV",
    "● WalkSpeed / Fly / Noclip / Infinite Jump",
    "● FOV / FPS Utility controls",
    "● Distance / Weapon ESP",
    "● Visible Check",
    "● 2D Box ESP",
    "● Skeleton ESP",
    "● Nearest Target Indicator",
    "● Enemy Warning + Counter",
    "● Dead Filter + Team Check",
    "● Configurable ESP distance",
    "● Radar / Off-Screen / Direction tools",
    "● Health percentage / low-health alerts",
    "● Ping / player / server information",
    "● Performance / refresh-rate controls",
}) do
    CreateStatus(discoveryContainer,text)
end

-- CREDITS
local creditsCard = CreateCard(CreditsPage,"DaMityhicHub","V3 Premium • by Dan SS")
local creditsContainer = Instance.new("Frame")
creditsContainer.BackgroundTransparency = 1
creditsContainer.Position = UDim2.fromOffset(15,65)
creditsContainer.Size = UDim2.new(1,-30,0,130)
creditsContainer.Parent = creditsCard
local creditsLayout = Instance.new("UIListLayout")
creditsLayout.Padding = UDim.new(0,6)
creditsLayout.Parent = creditsContainer
CreateStatus(creditsContainer,"Created by: Dan SS")
CreateStatus(creditsContainer,"Version: V4 Premium • 50+ Features")
CreateActionButton(creditsContainer,"Discord • Get Updates",function()
    local link = "https://discord.gg/zUXgk4XT"
    if setclipboard then
        pcall(function() setclipboard(link) end)
        Notify("DaMityhicHub","Discord link copied.",3)
    else
        Notify("DaMityhicHub","Discord: discord.gg/zUXgk4XT",5)
    end
end,38)

-- SIDEBAR
local SideButtons = {}
local function SelectPage(name)
    for pageName,page in pairs(Pages) do page.Visible = pageName == name end
    for buttonName,data in pairs(SideButtons) do
        local active = buttonName == name
        data.Button.BackgroundColor3 = active and Color3.fromRGB(42,17,21) or C.Panel2
        data.Indicator.BackgroundTransparency = active and 0 or 1
        data.Text.TextColor3 = active and C.White or C.Gray
    end
end

local function CreateSideButton(name,icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,42)
    button.BackgroundColor3 = C.Panel2
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = Sidebar
    Corner(button,9)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(3,22)
    indicator.Position = UDim2.fromOffset(0,10)
    indicator.BackgroundColor3 = C.Red
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    Corner(indicator,3)
    local iconLabel = Instance.new("TextLabel")
    iconLabel.BackgroundTransparency = 1
    iconLabel.Position = UDim2.fromOffset(7,0)
    iconLabel.Size = UDim2.fromOffset(22,42)
    iconLabel.Text = icon
    iconLabel.TextColor3 = C.Gray
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 15
    iconLabel.Parent = button
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Position = UDim2.fromOffset(31,0)
    text.Size = UDim2.new(1,-36,1,0)
    text.Text = name
    text.TextColor3 = C.Gray
    text.Font = Enum.Font.GothamMedium
    text.TextSize = 11
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = button
    button.MouseButton1Click:Connect(function() SelectPage(name) end)
    SideButtons[name] = {Button=button,Indicator=indicator,Text=text}
end

CreateSideButton("Home","⌂")
CreateSideButton("Player","●")
CreateSideButton("Visual","◉")
CreateSideButton("Combat","✦")
CreateSideButton("Aimbot","◎")
CreateSideButton("Movement","↗")
CreateSideButton("Utility","⚙")
CreateSideButton("Advanced","★")
CreateSideButton("Discovery","?")
CreateSideButton("Credits","i")
SelectPage("Home")

-- FLOATING BUTTON
local Floating = Instance.new("TextButton")
Floating.Name = "FloatingM"
Floating.AnchorPoint = Vector2.new(0.5,0.5)
Floating.Position = UDim2.fromScale(0.5,0.5)
Floating.Size = UDim2.fromOffset(58,58)
Floating.BackgroundColor3 = C.Red
Floating.Text = "M"
Floating.TextColor3 = Color3.new(1,1,1)
Floating.Font = Enum.Font.GothamBlack
Floating.TextSize = 25
Floating.AutoButtonColor = false
Floating.Visible = false
Floating.Parent = Gui
Corner(Floating,29)
Stroke(Floating,C.Red2,2,0.1)
Gradient(Floating,C.Red2,Color3.fromRGB(105,10,20),45)
MakeDraggable(Floating)
Floating.MouseButton1Click:Connect(function() Floating.Visible=false;Main.Visible=true end)
HideButton.MouseButton1Click:Connect(function() Main.Visible=false;Floating.Visible=true end)
MakeDraggable(Main,Header)

-- OFFSCREEN INDICATOR GUI
local IndicatorGui = Instance.new("ScreenGui")
IndicatorGui.Name = "DaMityhicHub_Indicators"
IndicatorGui.ResetOnSpawn = false
IndicatorGui.IgnoreGuiInset = true
IndicatorGui.DisplayOrder = 50
IndicatorGui.Parent = PlayerGui

local WarningLabel = Instance.new("TextLabel")
WarningLabel.AnchorPoint = Vector2.new(0.5,0)
WarningLabel.Position = UDim2.new(0.5,0,0,12)
WarningLabel.Size = UDim2.fromOffset(330,34)
WarningLabel.BackgroundColor3 = Color3.fromRGB(65,10,15)
WarningLabel.BackgroundTransparency = 0.1
WarningLabel.TextColor3 = C.Red2
WarningLabel.Font = Enum.Font.GothamBold
WarningLabel.TextSize = 13
WarningLabel.Visible = false
WarningLabel.Parent = IndicatorGui
Corner(WarningLabel,9)
Stroke(WarningLabel,C.Red,1,0.2)

local function createOffscreenArrow()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(30,30)
    label.AnchorPoint = Vector2.new(0.5,0.5)
    label.BackgroundTransparency = 1
    label.Text = "▲"
    label.TextColor3 = C.Red2
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 22
    label.Visible = false
    label.Parent = IndicatorGui
    return label
end

local OffscreenPool = {}
for i=1,20 do OffscreenPool[i] = createOffscreenArrow() end
local TargetMarker = createOffscreenArrow()
TargetMarker.Text = "◆"
TargetMarker.TextColor3 = C.Yellow
TargetMarker.TextSize = 18

local function clearObjectTable(t)
    if not t then return end
    for _, obj in pairs(t) do
        if typeof(obj) == "Instance" then pcall(function() obj:Destroy() end) end
    end
end

local function getHumanoid(player)
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(player)
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if State.TeamCheck then
        local targetTeam = getTargetTeamName()
        -- Team names come directly from Player.Team.Name (the same team
        -- shown by the game's leaderboard/team system).
        if targetTeam ~= "" then
            return player.Team ~= nil and player.Team.Name ~= targetTeam
        end
        if LocalPlayer.Team and player.Team then
            return player.Team ~= LocalPlayer.Team
        end
    end
    return true
end

local function getArmorValue(character)
    local names = {"Armor","Armour","Shield","ShieldHealth","ArmorValue","ArmourValue"}
    for _, name in ipairs(names) do
        local obj = character:FindFirstChild(name, true)
        if obj and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
            return math.floor(obj.Value)
        end
    end
    return nil
end

local function getWeaponName(character)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then return child.Name end
    end
    return "None"
end

local function visibleFromCamera(player)
    local root = getRoot(player)
    if not root or not Character then return false end
    local origin = Camera.CFrame.Position
    local direction = root.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Character}
    local result = workspace:Raycast(origin,direction,params)
    if not result then return true end
    return result.Instance:IsDescendantOf(player.Character)
end

local function getAimScreenPosition(player)
    local root = getRoot(player)
    if not root then return nil end
    local pos,onScreen = Camera:WorldToViewportPoint(root.Position)
    return Vector2.new(pos.X,pos.Y),onScreen,pos.Z
end

local function createBillboard(player)
    local root = getRoot(player)
    if not root then return nil end
    local gui = Instance.new("BillboardGui")
    gui.Name = "DMH_CombatInfo"
    gui.Adornee = root
    gui.Size = UDim2.fromOffset(180,80)
    gui.StudsOffset = Vector3.new(0,3.5,0)
    gui.AlwaysOnTop = true
    gui.Enabled = true
    gui.Parent = IndicatorGui
    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextColor3 = C.White
    label.TextStrokeTransparency = 0.35
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextWrapped = true
    label.Parent = gui
    return {Gui=gui,Label=label}
end

local function createBox()
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = IndicatorGui
    Corner(box,2)
    local stroke = Stroke(box,C.Red2,1.5,0.05)
    return {Frame=box,Stroke=stroke}
end

local function createSkeleton(player)
    local char = player.Character
    if not char then return nil end
    local folder = Instance.new("Folder")
    folder.Name = "DMH_Skeleton"
    folder.Parent = IndicatorGui
    local bones
    if char:FindFirstChild("UpperTorso") then
        bones = {
            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
        }
    else
        bones = {
            {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
            {"Torso","Left Leg"},{"Torso","Right Leg"},
        }
    end
    local parts = {}
    for _, pair in ipairs(bones) do
        local a,b = char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2])
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local att0 = Instance.new("Attachment")
            att0.Parent = a
            local att1 = Instance.new("Attachment")
            att1.Parent = b
            local beam = Instance.new("Beam")
            beam.Attachment0 = att0
            beam.Attachment1 = att1
            beam.Width0 = 0.045
            beam.Width1 = 0.045
            beam.Color = ColorSequence.new(C.Red2)
            beam.FaceCamera = true
            beam.LightEmission = 1
            beam.Parent = folder
            table.insert(parts,att0)
            table.insert(parts,att1)
            table.insert(parts,beam)
        end
    end
    return {Folder=folder,Parts=parts}
end

local function getOrCreateESP(player)
    local data = ESPObjects[player]
    if not data then
        data = {}
        ESPObjects[player] = data
    end
    if not data.Info or not data.Info.Gui or not data.Info.Gui.Parent then data.Info = createBillboard(player) end
    if not data.Box or not data.Box.Frame or not data.Box.Frame.Parent then data.Box = createBox() end
    if not data.Highlight or not data.Highlight.Parent then
        local char = player.Character
        if char then
            local h = Instance.new("Highlight")
            h.Name = "DMH_PlayerESP"
            h.Adornee = char
            h.FillColor = C.Red
            h.OutlineColor = C.Red2
            h.FillTransparency = 0.72
            h.OutlineTransparency = 0.08
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            data.Highlight = h
        end
    end
    if data.Highlight then
        data.Highlight.Enabled = State.PlayerESP and (not State.VisibleCheck or visibleFromCamera(player))
        data.Highlight.FillColor = C.Red
    end
    if State.SkeletonESP and (not data.Skeleton or not data.Skeleton.Folder or not data.Skeleton.Folder.Parent) then data.Skeleton = createSkeleton(player) end
    return data
end

local function clearPlayerESP(player)
    local data = ESPObjects[player]
    if data then
        if data.Info then clearObjectTable(data.Info) end
        if data.Box then clearObjectTable(data.Box) end
        if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
        if data.Skeleton then clearObjectTable(data.Skeleton) end
        if data.HeadDot then pcall(function() data.HeadDot:Destroy() end) end
        ESPObjects[player] = nil
    end
end

local function clearAllESP()
    for player,_ in pairs(ESPObjects) do clearPlayerESP(player) end
    for _, arrow in ipairs(OffscreenPool) do arrow.Visible = false end
end

table.insert(Connections, Players.PlayerRemoving:Connect(clearPlayerESP))

local function trackPlayer(player)
    if player == LocalPlayer then return end
    table.insert(Connections, player.CharacterAdded:Connect(function()
        clearPlayerESP(player)
    end))
end

for _, player in ipairs(Players:GetPlayers()) do
    trackPlayer(player)
end
table.insert(Connections, Players.PlayerAdded:Connect(trackPlayer))

local function nearestEnemy()
    local best,bestDist = nil,math.huge
    if not RootPart then return nil end
    for _,player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local hum = getHumanoid(player)
            local root = getRoot(player)
            if hum and root and hum.Health > 0 then
                local d = (root.Position-RootPart.Position).Magnitude
                if d <= State.MaxDistance and d < bestDist then best,bestDist = player,d end
            end
        end
    end
    return best,bestDist
end

local RadarGui = Instance.new("Frame")
RadarGui.Name="DMH_Radar"
RadarGui.Size=UDim2.fromOffset(150,150)
RadarGui.Position=UDim2.new(1,-170,0,70)
RadarGui.BackgroundColor3=C.Black2
RadarGui.BackgroundTransparency=0.18
RadarGui.Visible=false
RadarGui.Parent=IndicatorGui
Corner(RadarGui,75); Stroke(RadarGui,C.Red2,1,0.25)
local RadarCenter=Instance.new("Frame"); RadarCenter.Size=UDim2.fromOffset(6,6); RadarCenter.Position=UDim2.new(.5,-3,.5,-3); RadarCenter.BackgroundColor3=C.Green; RadarCenter.BorderSizePixel=0; RadarCenter.Parent=RadarGui; Corner(RadarCenter,3)
local RadarDots={}
for i=1,20 do local d=Instance.new("Frame"); d.Size=UDim2.fromOffset(6,6); d.BackgroundColor3=C.Red2; d.BorderSizePixel=0; d.Visible=false; d.Parent=RadarGui; Corner(d,3); RadarDots[i]=d end
local function updateRadar()
    RadarGui.Visible=State.EnemyRadar and Main.Visible
    if not State.EnemyRadar or not RootPart then for _,d in ipairs(RadarDots) do d.Visible=false end return end
    local idx=0
    local range=math.max(50,State.WarningDistance*2)
    local right=RootPart.CFrame.RightVector
    local forward=RootPart.CFrame.LookVector
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and isEnemy(p) then
            local r=getRoot(p); local h=getHumanoid(p)
            if r and h and h.Health>0 then
                local delta=r.Position-RootPart.Position
                local dist=delta.Magnitude
                if dist<=range then
                    idx+=1
                    if RadarDots[idx] then
                        local x=delta:Dot(right)/range
                        local y=-delta:Dot(forward)/range
                        RadarDots[idx].Position=UDim2.new(.5+x*.42,-3,.5+y*.42,-3)
                        RadarDots[idx].Visible=true
                    end
                end
            end
        end
    end
    for i=idx+1,#RadarDots do RadarDots[i].Visible=false end
end
local function getDistanceColor(distance)
    if not State.DistanceColor then return C.White end
    local t=math.clamp(distance/math.max(1,State.MaxDistance),0,1)
    return C.Red2:Lerp(C.Green,t)
end

local function updateESP()
    local enemyCount = 0
    local nearest,nearestDist = nearestEnemy()
    local arrowIndex = 0
    local warningCount = 0

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) then
            local hum = getHumanoid(player)
            local root = getRoot(player)
            local alive = hum and hum.Health > 0
            local valid = root and alive and RootPart and ((root.Position-RootPart.Position).Magnitude <= State.MaxDistance)

            if valid then
                enemyCount += 1
                local data = getOrCreateESP(player)
                if State.HeadDot and root then
                    if not data.HeadDot or not data.HeadDot.Parent then
                        local dot=Instance.new("BillboardGui"); dot.Name="DMH_HeadDot"; dot.Size=UDim2.fromOffset(10,10); dot.StudsOffset=Vector3.new(0,1.4,0); dot.AlwaysOnTop=true; dot.Parent=IndicatorGui
                        local f=Instance.new("Frame"); f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=C.Red2; f.BorderSizePixel=0; f.Parent=dot; Corner(f,5)
                        data.HeadDot=dot
                    end
                    local head=player.Character and player.Character:FindFirstChild("Head")
                    data.HeadDot.Adornee=head
                    data.HeadDot.Enabled=State.HeadDot and head~=nil
                elseif data.HeadDot then data.HeadDot.Enabled=false end
                local distance = (root.Position-RootPart.Position).Magnitude
                local visible = visibleFromCamera(player)
                if data.Highlight then
                    data.Highlight.Enabled = State.PlayerESP and (not State.VisibleCheck or visible)
                    data.Highlight.FillColor = (player == nearest and State.TargetIndicator) and C.Yellow or C.Red
                end
                if distance <= State.WarningDistance then warningCount += 1 end

                if data.Info and data.Info.Label then
                    local lines = {}
                    if State.PlayerNameESP then table.insert(lines,player.Name) end
                    if State.HealthESP then table.insert(lines,"HP: "..math.floor(hum.Health).." / "..math.max(1,math.floor(hum.MaxHealth))) end
                    if State.HealthPercent then table.insert(lines,"HP%: "..math.floor((hum.Health/math.max(1,hum.MaxHealth))*100).."%") end
                    if State.ArmorESP then
                        local armor = getArmorValue(player.Character)
                        if armor ~= nil then table.insert(lines,"Armor: "..armor) end
                    end
                    if State.DistanceESP then table.insert(lines,"Distance: "..math.floor(distance)) end
                    if State.WeaponESP then table.insert(lines,"Weapon: "..getWeaponName(player.Character)) end
                    if #lines == 0 then table.insert(lines,player.Name) end
                    data.Info.Label.Text = table.concat(lines,"\n")
                    data.Info.Label.TextColor3 = (State.LowHealthAlert and hum.Health/math.max(1,hum.MaxHealth) <= 0.25) and C.Yellow or getDistanceColor(distance)
                    if State.MovementIndicator then table.insert(lines, "Move: "..(root.AssemblyLinearVelocity.Magnitude > 2 and "MOVING" or "STILL")) end
                    if State.LookDirection then table.insert(lines, "Facing: "..math.floor(root.Orientation.Y).."°") end
                    if State.EnemyDirection then table.insert(lines, "Dir: "..math.floor(math.deg(math.atan2((root.Position-RootPart.Position).X,(root.Position-RootPart.Position).Z))).."°") end
                    data.Info.Label.Text = table.concat(lines,"\n")
                    data.Info.Gui.Enabled = State.PlayerESP or State.HealthESP or State.HealthPercent or State.ArmorESP or State.DistanceESP or State.WeaponESP or State.PlayerNameESP or State.MovementIndicator or State.LookDirection or State.EnemyDirection
                end

                if data.Box then
                    local frame = data.Box.Frame
                    local pos,onScreen = Camera:WorldToViewportPoint(root.Position)
                    local head = player.Character:FindFirstChild("Head")
                    local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0)) or pos
                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                    local height = math.abs(topPos.Y-bottomPos.Y)
                    local width = math.clamp(height*0.55,12,160)
                    local allowed = onScreen and pos.Z > 0 and (not State.VisibleCheck or visible)
                    frame.Visible = State.BoxESP and allowed
                    if allowed then
                        frame.Position = UDim2.fromOffset(pos.X-width/2, topPos.Y)
                        frame.Size = UDim2.fromOffset(width,height)
                        data.Box.Stroke.Color = (player == nearest and State.TargetIndicator) and C.Yellow or C.Red2
                    end
                end

                if data.Skeleton and data.Skeleton.Folder then
                    data.Skeleton.Folder.Parent = State.SkeletonESP and IndicatorGui or nil
                end

                local screen,onScreen,z = getAimScreenPosition(player)
                if State.OffscreenArrow and not onScreen and z > 0 and arrowIndex < #OffscreenPool then
                    arrowIndex += 1
                    local arrow = OffscreenPool[arrowIndex]
                    arrow.Visible = true
                    local center = Camera.ViewportSize/2
                    local dir = (screen-center)
                    if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector2.new(0,-1) end
                    local radius = math.min(Camera.ViewportSize.X,Camera.ViewportSize.Y)*0.38
                    local p = center + dir*radius
                    p = Vector2.new(math.clamp(p.X,25,Camera.ViewportSize.X-25),math.clamp(p.Y,35,Camera.ViewportSize.Y-25))
                    arrow.Position = UDim2.fromOffset(p.X,p.Y)
                    arrow.Rotation = math.deg(math.atan2(dir.Y,dir.X))+90
                    arrow.TextColor3 = (player == nearest and State.TargetIndicator) and C.Yellow or C.Red2
                end
            else
                if data then
                    if data.Info and data.Info.Gui then data.Info.Gui.Enabled=false end
                    if data.Box and data.Box.Frame then data.Box.Frame.Visible=false end
                    if data.Highlight then data.Highlight.Enabled=false end
                    if data.HeadDot then data.HeadDot.Enabled=false end
                end
                if not alive and State.DeadFilter then
                    clearPlayerESP(player)
                end
            end
        end
    end

    for i=arrowIndex+1,#OffscreenPool do OffscreenPool[i].Visible=false end
    TargetMarker.Visible = false

    enemyStatus.Text = "Enemies: "..enemyCount
    if State.EnemyWarning and warningCount > 0 then
        WarningLabel.Text = "⚠ "..warningCount.." ENEMY"..(warningCount == 1 and "" or "IES").." WITHIN "..math.floor(State.WarningDistance)
        WarningLabel.Visible = true
    else
        WarningLabel.Visible = false
    end

    if nearest and State.TargetIndicator then
        -- Target indicator is visual-only: no camera control and no aiming.
        local root = getRoot(nearest)
        if root then
            local pos,onScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
            if onScreen and pos.Z > 0 then
                -- A small screen marker using the nearest arrow pool slot.
                local marker = TargetMarker
                marker.Visible = true
                marker.Rotation = 0
                marker.Position = UDim2.fromOffset(pos.X,pos.Y)
                marker.TextColor3 = C.Yellow
            end
        end
    else
        TargetMarker.Visible = false
    end
end

local function updatePlayerPage()
    characterStatus.Text = "Character: "..(Character and Character.Name or "None")
    teamStatus.Text = "Team: "..(LocalPlayer.Team and LocalPlayer.Team.Name or "None")
    healthStatus.Text = "Health: "..(Humanoid and math.floor(Humanoid.Health) or 0)
end

-- PREMIUM AIM / MOVEMENT RUNTIME
local AimTarget = nil
local FlyVelocity, FlyGyro
local OriginalCollisions = {}
local TransparencyFrames = {}
for _, obj in ipairs(Gui:GetDescendants()) do
    if obj:IsA("Frame") then
        TransparencyFrames[#TransparencyFrames+1] = obj
        obj:SetAttribute("DMHBaseTransparency", obj.BackgroundTransparency)
    end
end

local FpsLabel = Instance.new("TextLabel")
FpsLabel.BackgroundColor3=C.Black2; FpsLabel.BackgroundTransparency=0.2; FpsLabel.Position=UDim2.fromOffset(12,12); FpsLabel.Size=UDim2.fromOffset(110,28); FpsLabel.TextColor3=C.Green; FpsLabel.Font=Enum.Font.GothamBold; FpsLabel.TextSize=11; FpsLabel.Visible=false; FpsLabel.Parent=IndicatorGui; Corner(FpsLabel,8)
local InfoLabel=Instance.new("TextLabel"); InfoLabel.BackgroundColor3=C.Black2; InfoLabel.BackgroundTransparency=0.2; InfoLabel.Position=UDim2.fromOffset(12,44); InfoLabel.Size=UDim2.fromOffset(250,28); InfoLabel.TextColor3=C.White; InfoLabel.Font=Enum.Font.Gotham; InfoLabel.TextSize=10; InfoLabel.Visible=false; InfoLabel.Parent=IndicatorGui; Corner(InfoLabel,8)

local function getAimPart(player)
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild(State.AimTargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function aimVisible(player,part)
    if not State.AimVisibleOnly then return true end
    if not Character or not part then return false end
    local origin=Camera.CFrame.Position
    local direction=part.Position-origin
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={Character}
    local hit=workspace:Raycast(origin,direction,params)
    return not hit or hit.Instance:IsDescendantOf(player.Character)
end

local function acquireAimTarget()
    if not RootPart or not Camera then return nil end
    local center=Camera.ViewportSize/2
    local best,bestScore=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local hum=getHumanoid(p); local part=getAimPart(p)
            if hum and hum.Health>0 and part and part:IsDescendantOf(workspace) then
                local velocity = part.AssemblyLinearVelocity or Vector3.zero
                local predicted = part.Position + velocity * math.clamp(State.AimPrediction,0,0.5)
                local worldDist=(predicted-RootPart.Position).Magnitude
                if worldDist<=State.AimMaxDistance then
                    local screen,onScreen,z=Camera:WorldToViewportPoint(predicted)
                    if onScreen and z>0 then
                        local screenDist=(Vector2.new(screen.X,screen.Y)-center).Magnitude
                        if screenDist<=State.AimFOV and (not State.AimVisibleOnly or aimVisible(p,part)) and screenDist<bestScore then
                            best,bestScore=p,screenDist
                        end
                    end
                end
            end
        end
    end
    return best
end

local function updateAim()
    if not State.Aimbot then AimTarget=nil; return end
    if not AimTarget then AimTarget=acquireAimTarget() end
    local part=AimTarget and getAimPart(AimTarget)
    local valid=false
    if AimTarget and part then
        local hum=getHumanoid(AimTarget)
        local predictedCheck = part.Position + part.AssemblyLinearVelocity * State.AimPrediction
        local screen,visible,z=Camera:WorldToViewportPoint(predictedCheck)
        valid=hum and hum.Health>0 and visible and z>0 and (Vector2.new(screen.X,screen.Y)-Camera.ViewportSize/2).Magnitude<=State.AimFOV and aimVisible(AimTarget,part)
    end
    if not valid then
        AimTarget=acquireAimTarget()
        part=AimTarget and getAimPart(AimTarget)
    end
    if AimTarget and part then
        local predicted=part.Position + part.AssemblyLinearVelocity*State.AimPrediction
        local desired=CFrame.lookAt(Camera.CFrame.Position,predicted)
        local alpha=math.clamp(State.AimSmooth,0.03,1)
        Camera.CFrame=Camera.CFrame:Lerp(desired,alpha)
    end
end

local function setupFly()
    if not RootPart then return end
    if FlyVelocity then FlyVelocity:Destroy() end
    if FlyGyro then FlyGyro:Destroy() end
    FlyVelocity=Instance.new("BodyVelocity"); FlyVelocity.MaxForce=Vector3.new(1e9,1e9,1e9); FlyVelocity.Velocity=Vector3.zero; FlyVelocity.Parent=RootPart
    FlyGyro=Instance.new("BodyGyro"); FlyGyro.MaxTorque=Vector3.new(1e9,1e9,1e9); FlyGyro.P=9000; FlyGyro.CFrame=Camera.CFrame; FlyGyro.Parent=RootPart
end
local function stopFly()
    if FlyVelocity then FlyVelocity:Destroy(); FlyVelocity=nil end
    if FlyGyro then FlyGyro:Destroy(); FlyGyro=nil end
end

table.insert(Connections, UIS.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    table.clear(OriginalCollisions)
    AimTarget=nil
    stopFly()
    if Camera then OriginalFOV = Camera.FieldOfView end
end))

local fpsAccum,fpsFrames=0,0
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    if not Gui.Parent then return end
    fpsAccum+=dt; fpsFrames+=1
    if fpsAccum>=0.5 then
        local fps=math.floor(fpsFrames/fpsAccum+0.5); fpsAccum=0; fpsFrames=0
        FpsLabel.Text="FPS: "..fps
    end
    FpsLabel.Visible=State.FPSCounter and Main.Visible
    local infoParts={}
    if State.PingCounter then
        local ok,ping=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok then table.insert(infoParts,"Ping: "..math.floor(ping).." ms") end
    end
    if State.PlayerCounter then table.insert(infoParts,"Players: "..#Players:GetPlayers()) end
    if State.ServerInfo then table.insert(infoParts,"Job: "..string.sub(game.JobId,1,8)) end
    InfoLabel.Text=table.concat(infoParts,"  •  ")
    InfoLabel.Visible=Main.Visible and #infoParts>0

    if State.Aimbot then updateAim() else AimTarget=nil end

    if Humanoid then
        if State.WalkSpeedEnabled then Humanoid.WalkSpeed=math.clamp(State.WalkSpeed,1,1000) else Humanoid.WalkSpeed=OriginalWalkSpeed end
    end

    if State.Noclip and Character then
        for _,obj in ipairs(Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                if OriginalCollisions[obj]==nil then OriginalCollisions[obj]=obj.CanCollide end
                obj.CanCollide=false
            end
        end
    else
        for obj,val in pairs(OriginalCollisions) do
            if obj and obj.Parent then obj.CanCollide=val end
        end
        table.clear(OriginalCollisions)
    end

    if State.Fly and RootPart then
        if not FlyVelocity then setupFly() end
        local move=Humanoid and Humanoid.MoveDirection or Vector3.zero
        local vertical=0
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical+=1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertical-=1 end
        local cam=Camera.CFrame
        local dir=Vector3.new(move.X,vertical,move.Z)
        if dir.Magnitude>1 then dir=dir.Unit end
        FlyVelocity.Velocity=dir*State.FlySpeed
        FlyGyro.CFrame=cam
    else
        stopFly()
    end

    if Camera then
        if State.FOVEnabled then Camera.FieldOfView=State.FOV else Camera.FieldOfView=OriginalFOV end
    end
    updateRadar()
    for _,obj in ipairs(TransparencyFrames) do
        if obj and obj.Parent and obj ~= RadarGui then
            local base=obj:GetAttribute("DMHBaseTransparency") or 0
            obj.BackgroundTransparency = State.GUITransparency > 0 and math.clamp(base + State.GUITransparency,0,0.9) or base
        end
    end
    if State.GUICompact then
        Main.Size=UDim2.fromOffset(680,420)
    else
        Main.Size=UDim2.fromOffset(760,470)
    end
end))

-- Main updater
local elapsed = 0
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    if not Gui.Parent then return end
    elapsed += dt
    local interval = State.PerformanceMode and math.max(1/State.ESPRefreshRate, 0.12) or (1/math.max(4,State.ESPRefreshRate))
    if elapsed < interval then return end
    elapsed = 0
    if State.Unlocked then
        updateESP()
        updatePlayerPage()
    end
end))

-- Premium access: no key system
State.Unlocked = true
Main.Visible = true
Floating.Visible = false

-- Clean shutdown
Gui.Destroying:Connect(function()
    State.WalkSpeedEnabled=false
    State.Fly=false
    State.Noclip=false
    State.InfiniteJump=false
    AimTarget=nil
    stopFly()
    if Humanoid then Humanoid.WalkSpeed=OriginalWalkSpeed end
    if Camera then Camera.FieldOfView=OriginalFOV end
    for obj,val in pairs(OriginalCollisions) do
        if obj and obj.Parent then obj.CanCollide=val end
    end
    table.clear(OriginalCollisions)
    table.clear(TransparencyFrames)
    TargetMarker.Visible=false
    RadarGui.Visible=false
    clearAllESP()
    disconnectAll(Connections)
end)

print("DaMityhicHub V4 Premium loaded")
