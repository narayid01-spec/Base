--// =========================================================
--// MazHub V4 Ultra
--// UI 2.0 | Mobile Friendly | Single LocalScript
--// =========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
	KEY = "MAZHUBV4",

	WALK_MIN = 1,
	WALK_MAX = 1000,

	FLY_MIN = 1,
	FLY_MAX = 1000,

	AIM_DEFAULT = 250,
	AIM_MIN = 1,
	AIM_MAX = 2000,

	AIM_V2_FOV = 350,
	AIM_V2_SMOOTHNESS = 0.18,

	ESP_UPDATE = 0.25
}

--============================================================
-- STATE
--============================================================

local OriginalCanCollide = {}

local State = {
	Unlocked = false,

	WalkSpeed = 16,
	WalkSpeedEnabled = false,

	FlySpeed = 100,
	Flying = false,

	Noclip = false,
	InfiniteJump = false,

	PlayerESP = false,

	AutoAimV1 = false,

	YourTeam = "",
	AimDistance = CONFIG.AIM_DEFAULT,

	VerticalFly = 0,

	CurrentTarget = nil,

	OriginalWalkSpeed = 16
}

local AimLockV2 = {
	Enabled = false,
	YourTeam = "",
	MaxDistance = CONFIG.AIM_DEFAULT,
	FOVRadius = CONFIG.AIM_V2_FOV,
	Smoothness = CONFIG.AIM_V2_SMOOTHNESS,

	Target = nil,
	TargetPart = nil,

	LastRetarget = 0,

	Highlight = nil
}

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local RootPart

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid", 10)
	RootPart = char:WaitForChild("HumanoidRootPart", 10)

	if Humanoid then
		State.OriginalWalkSpeed = Humanoid.WalkSpeed
		State.WalkSpeedEnabled = false
	end

	State.Flying = false
	State.VerticalFly = 0
	State.CurrentTarget = nil
	OriginalCanCollide = {}

	AimLockV2.Target = nil
	AimLockV2.TargetPart = nil

	if AimLockV2.Highlight then
		AimLockV2.Highlight:Destroy()
		AimLockV2.Highlight = nil
	end
end

if LocalPlayer.Character then
	task.spawn(SetupCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)

--============================================================
-- GUI ROOT
--============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "MazHubV4Ultra"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--============================================================
-- COLORS
--============================================================

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
	Yellow = Color3.fromRGB(255, 200, 65)
}

--============================================================
-- UTILITY
--============================================================

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
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function Gradient(parent, color1, color2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2)
	})
	g.Rotation = rotation or 0
	g.Parent = parent
	return g
end

local function Tween(obj, props, duration)
	TweenService:Create(
		obj,
		TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props
	):Play()
end

local function ClampNumber(value, min, max, fallback)
	local n = tonumber(value)

	if not n then
		return fallback
	end

	return math.clamp(n, min, max)
end

local function Notify(title, text, duration)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 3
		})
	end)
end

--============================================================
-- DRAG SYSTEM
--============================================================

local function MakeDraggable(object, handle)
	handle = handle or object

	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

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
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		object.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
end

--============================================================
-- MAIN GUI
--============================================================

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

local MainGradient = Gradient(
	Main,
	Color3.fromRGB(12, 12, 15),
	Color3.fromRGB(7, 7, 9),
	90
)

--============================================================
-- HEADER
--============================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 66)
Header.BackgroundColor3 = C.Panel
Header.Parent = Main

Corner(Header, 14)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = C.Red
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

Gradient(
	HeaderLine,
	C.Red,
	Color3.fromRGB(100, 10, 20),
	0
)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(44, 44)
Logo.Position = UDim2.fromOffset(12, 11)
Logo.BackgroundColor3 = C.Red
Logo.Parent = Header

Corner(Logo, 12)

local LogoGradient = Gradient(
	Logo,
	C.Red2,
	Color3.fromRGB(125, 12, 22),
	45
)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.BackgroundTransparency = 1
LogoText.Text = "M"
LogoText.TextColor3 = Color3.new(1, 1, 1)
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 25
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(68, 9)
Title.Size = UDim2.new(1, -150, 0, 26)
Title.Text = "MazHub"
Title.TextColor3 = C.White
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(69, 34)
Version.Size = UDim2.new(1, -150, 0, 18)
Version.Text = "V4 Ultra  •  Premium Control"
Version.TextColor3 = C.Gray
Version.Font = Enum.Font.Gotham
Version.TextSize = 11
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.fromOffset(38, 38)
HideButton.Position = UDim2.new(1, -50, 0, 14)
HideButton.BackgroundColor3 = C.Panel2
HideButton.Text = "—"
HideButton.TextColor3 = C.White
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 19
HideButton.AutoButtonColor = false
HideButton.Parent = Header

Corner(HideButton, 10)
Stroke(HideButton, C.Gray2, 1, 0.55)

--============================================================
-- SIDEBAR
--============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.fromOffset(8, 76)
Sidebar.Size = UDim2.new(0, 102, 1, -86)
Sidebar.BackgroundColor3 = C.Panel
Sidebar.Parent = Main

Corner(Sidebar, 12)
Stroke(Sidebar, Color3.fromRGB(45, 45, 50), 1, 0.6)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 5)
SidePadding.PaddingRight = UDim.new(0, 5)
SidePadding.Parent = Sidebar

--============================================================
-- CONTENT
--============================================================

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(118, 76)
Content.Size = UDim2.new(1, -128, 1, -86)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function CreatePage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = C.Red
	page.CanvasSize = UDim2.new()
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Content

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 2)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	Pages[name] = page

	return page
end

local HomePage = CreatePage("Home")
local PlayerPage = CreatePage("Player")
local VisualPage = CreatePage("Visual")
local CombatPage = CreatePage("Combat")
local MovementPage = CreatePage("Movement")
local CreditsPage = CreatePage("Credits")
local DiscoveryPage = CreatePage("Discovery")

--============================================================
-- CARD
--============================================================

local function CreateCard(parent, title, subtitle)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -2, 0, 90)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = C.Panel
	card.Parent = parent

	Corner(card, 11)
	Stroke(card, Color3.fromRGB(45, 45, 52), 1, 0.5)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.fromOffset(3, 55)
	accent.Position = UDim2.fromOffset(0, 17)
	accent.BackgroundColor3 = C.Red
	accent.BorderSizePixel = 0
	accent.Parent = card

	Corner(accent, 2)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(15, 10)
	titleLabel.Size = UDim2.new(1, -25, 0, 22)
	titleLabel.Text = title
	titleLabel.TextColor3 = C.White
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	local subLabel = Instance.new("TextLabel")
	subLabel.BackgroundTransparency = 1
	subLabel.Position = UDim2.fromOffset(15, 34)
	subLabel.Size = UDim2.new(1, -25, 0, 35)
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

--============================================================
-- BUTTON
--============================================================

local function CreateActionButton(parent, text, callback, height)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, height or 40)
	button.BackgroundColor3 = C.Panel2
	button.Text = text
	button.TextColor3 = C.White
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 12
	button.AutoButtonColor = false
	button.Parent = parent

	Corner(button, 9)
	Stroke(button, Color3.fromRGB(50, 50, 57), 1, 0.45)

	button.MouseEnter:Connect(function()
		Tween(button, {
			BackgroundColor3 = Color3.fromRGB(34, 20, 23)
		}, 0.12)
	end)

	button.MouseLeave:Connect(function()
		Tween(button, {
			BackgroundColor3 = C.Panel2
		}, 0.12)
	end)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return button
end

--============================================================
-- TOGGLE
--============================================================

local function CreateToggle(parent, title, initial, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 44)
	button.BackgroundColor3 = C.Panel2
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = parent

	Corner(button, 9)
	Stroke(button, Color3.fromRGB(48, 48, 55), 1, 0.5)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -78, 1, 0)
	label.Text = title
	label.TextColor3 = C.White
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	local pill = Instance.new("Frame")
	pill.Size = UDim2.fromOffset(48, 24)
	pill.Position = UDim2.new(1, -58, 0.5, -12)
	pill.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	pill.Parent = button

	Corner(pill, 20)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.fromOffset(18, 18)
	circle.Position = UDim2.fromOffset(3, 3)
	circle.BackgroundColor3 = C.Gray2
	circle.Parent = pill

	Corner(circle, 20)

	local enabled = initial == true

	local function Refresh()
		if enabled then
			Tween(pill, {BackgroundColor3 = C.DarkRed}, 0.15)
			Tween(circle, {
				Position = UDim2.new(1, -21, 0, 3),
				BackgroundColor3 = C.Red2
			}, 0.15)
		else
			Tween(pill, {BackgroundColor3 = Color3.fromRGB(45,45,50)}, 0.15)
			Tween(circle, {
				Position = UDim2.fromOffset(3,3),
				BackgroundColor3 = C.Gray2
			}, 0.15)
		end
	end

	Refresh()

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		Refresh()

		if callback then
			callback(enabled)
		end
	end)

	return {
		Button = button,

		Set = function(value)
			enabled = value
			Refresh()

			if callback then
				callback(enabled)
			end
		end,

		Get = function()
			return enabled
		end
	}
end

--============================================================
-- INPUT
--============================================================

local function CreateInput(parent, placeholder, defaultText)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 40)
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

	Corner(box, 9)
	Stroke(box, Color3.fromRGB(55, 55, 62), 1, 0.35)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = box

	return box
end

--============================================================
-- STATUS
--============================================================

local function CreateStatus(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundColor3 = C.Black2
	label.Text = text
	label.TextColor3 = C.Gray
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.Parent = parent

	Corner(label, 8)

	return label
end

--============================================================
-- HOME
--============================================================

do
	local hero = Instance.new("Frame")
	hero.Size = UDim2.new(1, -2, 0, 125)
	hero.BackgroundColor3 = C.Panel
	hero.Parent = HomePage

	Corner(hero, 12)
	Stroke(hero, C.DarkRed, 1, 0.3)

	Gradient(
		hero,
		Color3.fromRGB(28, 13, 16),
		Color3.fromRGB(15, 15, 18),
		0
	)

	local h1 = Instance.new("TextLabel")
	h1.BackgroundTransparency = 1
	h1.Position = UDim2.fromOffset(17, 16)
	h1.Size = UDim2.new(1, -34, 0, 28)
	h1.Text = "Welcome to MazHub"
	h1.TextColor3 = C.White
	h1.Font = Enum.Font.GothamBold
	h1.TextSize = 19
	h1.TextXAlignment = Enum.TextXAlignment.Left
	h1.Parent = hero

	local h2 = Instance.new("TextLabel")
	h2.BackgroundTransparency = 1
	h2.Position = UDim2.fromOffset(18, 47)
	h2.Size = UDim2.new(1, -36, 0, 42)
	h2.Text = "V4 Ultra • Compact control hub\nBuilt for mobile & desktop."
	h2.TextColor3 = C.Gray
	h2.Font = Enum.Font.Gotham
	h2.TextSize = 11
	h2.TextWrapped = true
	h2.TextXAlignment = Enum.TextXAlignment.Left
	h2.Parent = hero

	local status = CreateStatus(hero, "●  SYSTEM READY")
	status.Position = UDim2.new(0, 17, 1, -38)
	status.Size = UDim2.new(1, -34, 0, 26)
	status.TextColor3 = C.Green
	status.BackgroundColor3 = Color3.fromRGB(12, 28, 20)

	local info = CreateCard(
		HomePage,
		"Quick Info",
		"Use the sidebar to access Player, Visual, Combat, Movement and Credits."
	)
end

--============================================================
-- PLAYER
--============================================================

do
	local card = CreateCard(
		PlayerPage,
		"Player Status",
		"Current character information and quick controls."
	)

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Position = UDim2.fromOffset(15, 64)
	container.Size = UDim2.new(1, -30, 0, 106)
	container.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	local status = CreateStatus(container, "Character: Loading...")
	local teamStatus = CreateStatus(container, "Team: None")
	local healthStatus = CreateStatus(container, "Health: --")

	task.spawn(function()
		while Gui.Parent do
			task.wait(0.25)
			if status.Parent then
				status.Text = "Character: " .. (Character and Character.Name or "None")
				teamStatus.Text = "Team: " .. (LocalPlayer.Team and LocalPlayer.Team.Name or "None")
				healthStatus.Text = "Health: " .. (Humanoid and math.floor(Humanoid.Health) or 0)
			end
		end
	end)
end

--============================================================
-- VISUAL
--============================================================

do
	local card = CreateCard(
		VisualPage,
		"Player ESP",
		"Shows only the player's body shape. No names or distance labels."
	)

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Position = UDim2.fromOffset(15, 64)
	container.Size = UDim2.new(1, -30, 0, 45)
	container.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Parent = container

	local espToggle

	local function CreateESPForPlayer(player)
		if player == LocalPlayer then
			return
		end

		if not State.PlayerESP then
			return
		end

		local char = player.Character
		if not char then
			return
		end

		if char:FindFirstChild("MazHub_PlayerESP") then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "MazHub_PlayerESP"
		highlight.Adornee = char
		highlight.FillColor = C.Red
		highlight.FillTransparency = 0.72
		highlight.OutlineColor = C.Red2
		highlight.OutlineTransparency = 0.1
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char
	end

	local function ClearESP()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local old = player.Character:FindFirstChild("MazHub_PlayerESP")
				if old then
					old:Destroy()
				end
			end
		end
	end

	espToggle = CreateToggle(
		container,
		"Player ESP",
		false,
		function(enabled)
			State.PlayerESP = enabled

			if enabled then
				for _, player in ipairs(Players:GetPlayers()) do
					CreateESPForPlayer(player)
				end
			else
				ClearESP()
			end
		end
	)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			CreateESPForPlayer(player)
		end)
	end)
end

--============================================================
-- COMBAT
--============================================================

local YourTeamBox
local AimDistanceBox
local CombatTargetText
local V1Toggle
local V2Toggle

do
	local teamCard = CreateCard(
		CombatPage,
		"Target Team",
		"Type your team name, for example: Blue. Players on your team are ignored."
	)

	local teamContainer = Instance.new("Frame")
	teamContainer.BackgroundTransparency = 1
	teamContainer.Position = UDim2.fromOffset(15, 63)
	teamContainer.Size = UDim2.new(1, -30, 0, 40)
	teamContainer.Parent = teamCard

	YourTeamBox = CreateInput(
		teamContainer,
		"Your Team",
		""
	)

	YourTeamBox.FocusLost:Connect(function()
		State.YourTeam = YourTeamBox.Text
		AimLockV2.YourTeam = YourTeamBox.Text
	end)

	local rangeCard = CreateCard(
		CombatPage,
		"Aim Distance",
		"Maximum world distance used for target selection."
	)

	local rangeContainer = Instance.new("Frame")
	rangeContainer.BackgroundTransparency = 1
	rangeContainer.Position = UDim2.fromOffset(15, 63)
	rangeContainer.Size = UDim2.new(1, -30, 0, 40)
	rangeContainer.Parent = rangeCard

	AimDistanceBox = CreateInput(
		rangeContainer,
		"Distance 1 - 2000",
		tostring(CONFIG.AIM_DEFAULT)
	)

	AimDistanceBox.FocusLost:Connect(function()
		local value = ClampNumber(
			AimDistanceBox.Text,
			CONFIG.AIM_MIN,
			CONFIG.AIM_MAX,
			CONFIG.AIM_DEFAULT
		)

		State.AimDistance = value
		AimLockV2.MaxDistance = value

		AimDistanceBox.Text = tostring(value)
	end)

	local v1Card = CreateCard(
		CombatPage,
		"Auto AIM V1",
		"Automatically targets the nearest valid enemy."
	)

	local v1Container = Instance.new("Frame")
	v1Container.BackgroundTransparency = 1
	v1Container.Position = UDim2.fromOffset(15, 63)
	v1Container.Size = UDim2.new(1, -30, 0, 45)
	v1Container.Parent = v1Card

	V1Toggle = CreateToggle(
		v1Container,
		"Auto AIM V1",
		false,
		function(enabled)
			State.AutoAimV1 = enabled

			if enabled and AimLockV2.Enabled then
				AimLockV2.Enabled = false

				if V2Toggle then
					V2Toggle.Set(false)
				end
			end
		end
	)

	local v2Card = CreateCard(
		CombatPage,
		"AIM Lock V2",
		"Smooth camera lock with FOV-based target selection."
	)

	local v2Container = Instance.new("Frame")
	v2Container.BackgroundTransparency = 1
	v2Container.Position = UDim2.fromOffset(15, 63)
	v2Container.Size = UDim2.new(1, -30, 0, 45)
	v2Container.Parent = v2Card

	V2Toggle = CreateToggle(
		v2Container,
		"AIM Lock V2",
		false,
		function(enabled)
			AimLockV2.Enabled = enabled

			if enabled then
				State.AutoAimV1 = false

				if V1Toggle then
					V1Toggle.Set(false)
				end
			else
				AimLockV2.Target = nil
				AimLockV2.TargetPart = nil
			end
		end
	)

	local targetCard = CreateCard(
		CombatPage,
		"Target Status",
		"Current automatically selected target."
	)

	local targetContainer = Instance.new("Frame")
	targetContainer.BackgroundTransparency = 1
	targetContainer.Position = UDim2.fromOffset(15, 63)
	targetContainer.Size = UDim2.new(1, -30, 0, 30)
	targetContainer.Parent = targetCard

	CombatTargetText = CreateStatus(targetContainer, "Target: None")
	CombatTargetText.Size = UDim2.fromScale(1, 1)
end

--============================================================
-- MOVEMENT
--============================================================

local WalkSpeedBox
local FlySpeedBox
local WalkToggle
local FlyToggle
local NoclipToggle
local InfiniteToggle

do
	local walkCard = CreateCard(
		MovementPage,
		"WalkSpeed",
		"Maximum 1000. OFF restores the character's original speed."
	)

	local walkContainer = Instance.new("Frame")
	walkContainer.BackgroundTransparency = 1
	walkContainer.Position = UDim2.fromOffset(15, 62)
	walkContainer.Size = UDim2.new(1, -30, 0, 91)
	walkContainer.Parent = walkCard

	local walkLayout = Instance.new("UIListLayout")
	walkLayout.Padding = UDim.new(0, 6)
	walkLayout.Parent = walkContainer

	WalkSpeedBox = CreateInput(
		walkContainer,
		"WalkSpeed 1 - 1000",
		"16"
	)

	WalkToggle = CreateToggle(
		walkContainer,
		"Enable WalkSpeed",
		false,
		function(enabled)
			State.WalkSpeedEnabled = enabled

			if not enabled and Humanoid then
				Humanoid.WalkSpeed = State.OriginalWalkSpeed
			end
		end
	)

	WalkSpeedBox.FocusLost:Connect(function()
		State.WalkSpeed = ClampNumber(
			WalkSpeedBox.Text,
			CONFIG.WALK_MIN,
			CONFIG.WALK_MAX,
			State.WalkSpeed
		)

		WalkSpeedBox.Text = tostring(State.WalkSpeed)

		if State.WalkSpeedEnabled and Humanoid then
			Humanoid.WalkSpeed = State.WalkSpeed
		end
	end)

	local flyCard = CreateCard(
		MovementPage,
		"Fly",
		"Mobile: joystick controls horizontal movement + ▲ / ▼ for vertical."
	)

	local flyContainer = Instance.new("Frame")
	flyContainer.BackgroundTransparency = 1
	flyContainer.Position = UDim2.fromOffset(15, 62)
	flyContainer.Size = UDim2.new(1, -30, 0, 91)
	flyContainer.Parent = flyCard

	local flyLayout = Instance.new("UIListLayout")
	flyLayout.Padding = UDim.new(0, 6)
	flyLayout.Parent = flyContainer

	FlySpeedBox = CreateInput(
		flyContainer,
		"Fly Speed 1 - 1000",
		"100"
	)

	FlyToggle = CreateToggle(
		flyContainer,
		"Enable Fly",
		false,
		function(enabled)
			State.Flying = enabled
		end
	)

	FlySpeedBox.FocusLost:Connect(function()
		State.FlySpeed = ClampNumber(
			FlySpeedBox.Text,
			CONFIG.FLY_MIN,
			CONFIG.FLY_MAX,
			State.FlySpeed
		)

		FlySpeedBox.Text = tostring(State.FlySpeed)
	end)

	local utilityCard = CreateCard(
		MovementPage,
		"Movement Utilities",
		"Noclip and Infinite Jump."
	)

	local utilityContainer = Instance.new("Frame")
	utilityContainer.BackgroundTransparency = 1
	utilityContainer.Position = UDim2.fromOffset(15, 62)
	utilityContainer.Size = UDim2.new(1, -30, 0, 95)
	utilityContainer.Parent = utilityCard

	local utilityLayout = Instance.new("UIListLayout")
	utilityLayout.Padding = UDim.new(0, 6)
	utilityLayout.Parent = utilityContainer

	NoclipToggle = CreateToggle(
		utilityContainer,
		"Noclip",
		false,
		function(enabled)
			State.Noclip = enabled
		end
	)

	InfiniteToggle = CreateToggle(
		utilityContainer,
		"Infinite Jump",
		false,
		function(enabled)
			State.InfiniteJump = enabled
		end
	)
end

--============================================================
-- DISCOVERY
--============================================================

do
	local card = CreateCard(
		DiscoveryPage,
		"MazHub Discovery",
		"Quick overview of the available V4 Ultra modules."
	)

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Position = UDim2.fromOffset(15, 63)
	container.Size = UDim2.new(1, -30, 0, 210)
	container.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	CreateStatus(container, "● Player ESP  — body highlight only")
	CreateStatus(container, "● Auto AIM V1  — nearest enemy")
	CreateStatus(container, "● AIM Lock V2  — smooth FOV targeting")
	CreateStatus(container, "● WalkSpeed  — 1 to 1000")
	CreateStatus(container, "● Fly  — 1 to 1000 + mobile vertical controls")
	CreateStatus(container, "● Noclip  — collision toggle")
	CreateStatus(container, "● Infinite Jump  — jump request support")
	CreateStatus(container, "● Key System  — MAZHUBV4")
end

--============================================================
-- CREDITS
--============================================================

do
	local card = CreateCard(
		CreditsPage,
		"MazHub V4 Ultra",
		"UI 2.0"
	)

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Position = UDim2.fromOffset(15, 65)
	container.Size = UDim2.new(1, -30, 0, 130)
	container.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	CreateStatus(container, "Created by: adamhdhbbb")
	CreateStatus(container, "UI / Script: BaconPro90258")

	local discord = CreateActionButton(
		container,
		"Discord • Get Updates",
		function()
			local link = "https://discord.gg/zUXgk4XT"

			if setclipboard then
				pcall(function()
					setclipboard(link)
				end)

				Notify("MazHub", "Discord link copied.", 3)
			else
				Notify("MazHub", "Discord: discord.gg/zUXgk4XT", 5)
			end
		end,
		38
	)

	discord.TextColor3 = C.Red2
end

--============================================================
-- SIDEBAR BUTTONS
--============================================================

local SideButtons = {}

local function SelectPage(name)
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end

	for buttonName, data in pairs(SideButtons) do
		local active = buttonName == name

		if active then
			Tween(data.Button, {
				BackgroundColor3 = Color3.fromRGB(42, 17, 21)
			}, 0.15)

			Tween(data.Indicator, {
				BackgroundTransparency = 0
			}, 0.15)

			data.Text.TextColor3 = C.White
		else
			Tween(data.Button, {
				BackgroundColor3 = C.Panel2
			}, 0.15)

			Tween(data.Indicator, {
				BackgroundTransparency = 1
			}, 0.15)

			data.Text.TextColor3 = C.Gray
		end
	end
end

local function CreateSideButton(name, icon)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 42)
	button.BackgroundColor3 = C.Panel2
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = Sidebar

	Corner(button, 9)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(3, 22)
	indicator.Position = UDim2.fromOffset(0, 10)
	indicator.BackgroundColor3 = C.Red
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Parent = button

	Corner(indicator, 3)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Position = UDim2.fromOffset(7, 0)
	iconLabel.Size = UDim2.fromOffset(22, 42)
	iconLabel.Text = icon
	iconLabel.TextColor3 = C.Gray
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 15
	iconLabel.Parent = button

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Position = UDim2.fromOffset(31, 0)
	text.Size = UDim2.new(1, -36, 1, 0)
	text.Text = name
	text.TextColor3 = C.Gray
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 11
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = button

	button.MouseButton1Click:Connect(function()
		SelectPage(name)
	end)

	SideButtons[name] = {
		Button = button,
		Indicator = indicator,
		Text = text
	}
end

CreateSideButton("Home", "⌂")
CreateSideButton("Player", "●")
CreateSideButton("Visual", "◉")
CreateSideButton("Combat", "✦")
CreateSideButton("Movement", "↗")
CreateSideButton("Discovery", "?")
CreateSideButton("Credits", "i")

SelectPage("Home")

--============================================================
-- FLOATING M BUTTON
--============================================================

local Floating = Instance.new("TextButton")
Floating.Name = "FloatingM"
Floating.AnchorPoint = Vector2.new(0.5, 0.5)
Floating.Position = UDim2.fromScale(0.5, 0.5)
Floating.Size = UDim2.fromOffset(58, 58)
Floating.BackgroundColor3 = C.Red
Floating.Text = "M"
Floating.TextColor3 = Color3.new(1,1,1)
Floating.Font = Enum.Font.GothamBlack
Floating.TextSize = 25
Floating.AutoButtonColor = false
Floating.Visible = false
Floating.Parent = Gui

Corner(Floating, 29)
Stroke(Floating, C.Red2, 2, 0.1)

Gradient(
	Floating,
	C.Red2,
	Color3.fromRGB(105, 10, 20),
	45
)

MakeDraggable(Floating)

Floating.MouseButton1Click:Connect(function()
	Floating.Visible = false
	Main.Visible = true
end)

HideButton.MouseButton1Click:Connect(function()
	Main.Visible = false
	Floating.Visible = true
end)

MakeDraggable(Main, Header)

--============================================================
-- MOBILE FLY BUTTONS
--============================================================

local FlyControls = Instance.new("Frame")
FlyControls.Name = "FlyControls"
FlyControls.AnchorPoint = Vector2.new(1, 1)
FlyControls.Position = UDim2.new(1, -18, 1, -25)
FlyControls.Size = UDim2.fromOffset(65, 132)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = Gui

local FlyLayout = Instance.new("UIListLayout")
FlyLayout.Padding = UDim.new(0, 7)
FlyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
FlyLayout.Parent = FlyControls

local UpButton = Instance.new("TextButton")
UpButton.Size = UDim2.fromOffset(58, 58)
UpButton.BackgroundColor3 = C.Panel
UpButton.Text = "▲"
UpButton.TextColor3 = C.White
UpButton.Font = Enum.Font.GothamBold
UpButton.TextSize = 22
UpButton.AutoButtonColor = false
UpButton.Parent = FlyControls

Corner(UpButton, 16)
Stroke(UpButton, C.Red, 1.5, 0.2)

local DownButton = Instance.new("TextButton")
DownButton.Size = UDim2.fromOffset(58, 58)
DownButton.BackgroundColor3 = C.Panel
DownButton.Text = "▼"
DownButton.TextColor3 = C.White
DownButton.Font = Enum.Font.GothamBold
DownButton.TextSize = 22
DownButton.AutoButtonColor = false
DownButton.Parent = FlyControls

Corner(DownButton, 16)
Stroke(DownButton, C.Red, 1.5, 0.2)

UpButton.MouseButton1Down:Connect(function()
	State.VerticalFly = 1
end)

UpButton.MouseButton1Up:Connect(function()
	if State.VerticalFly == 1 then
		State.VerticalFly = 0
	end
end)

DownButton.MouseButton1Down:Connect(function()
	State.VerticalFly = -1
end)

DownButton.MouseButton1Up:Connect(function()
	if State.VerticalFly == -1 then
		State.VerticalFly = 0
	end
end)

--============================================================
-- FLY VELOCITY
--============================================================

local FlyVelocity

local function StartFly()
	if not RootPart then
		return
	end

	if FlyVelocity then
		FlyVelocity:Destroy()
	end

	FlyVelocity = Instance.new("BodyVelocity")
	FlyVelocity.Name = "MazHubFlyVelocity"
	FlyVelocity.MaxForce = Vector3.new(
		math.huge,
		math.huge,
		math.huge
	)
	FlyVelocity.P = 9000
	FlyVelocity.Velocity = Vector3.zero
	FlyVelocity.Parent = RootPart

	if UIS.TouchEnabled then
		FlyControls.Visible = true
	end
end

local function StopFly()
	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	State.VerticalFly = 0
	FlyControls.Visible = false
end

--============================================================
-- DESKTOP FLY INPUT
--============================================================

UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space then
		State.VerticalFly = 1
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		State.VerticalFly = -1
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space and State.VerticalFly == 1 then
		State.VerticalFly = 0
	elseif input.KeyCode == Enum.KeyCode.LeftControl and State.VerticalFly == -1 then
		State.VerticalFly = 0
	end
end)

--============================================================
-- INFINITE JUMP
--============================================================

UIS.JumpRequest:Connect(function()
	if State.InfiniteJump and Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--============================================================
-- TEAM
--============================================================

local function GetTeam(player)
	if not player then
		return ""
	end

	if player.Team then
		return player.Team.Name
	end

	return ""
end

local function IsEnemy(player, ownTeam)
	if not player or player == LocalPlayer then
		return false
	end

	local humanoid = player.Character
		and player.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	local playerTeam = GetTeam(player)

	if ownTeam ~= "" then
		return playerTeam ~= ownTeam
	end

	if LocalPlayer.Team then
		return playerTeam ~= LocalPlayer.Team.Name
	end

	return true
end

--============================================================
-- BODY PART
--============================================================

local function GetAimPart(player)
	if not player.Character then
		return nil
	end

	return player.Character:FindFirstChild("UpperTorso")
		or player.Character:FindFirstChild("Torso")
		or player.Character:FindFirstChild("HumanoidRootPart")
end

--============================================================
-- V1 TARGET
--============================================================

local function FindV1Target()
	if not RootPart then
		return nil
	end

	local ownTeam = State.YourTeam

	if ownTeam == "" and LocalPlayer.Team then
		ownTeam = LocalPlayer.Team.Name
	end

	local best
	local bestDistance = State.AimDistance

	for _, player in ipairs(Players:GetPlayers()) do
		if IsEnemy(player, ownTeam) then
			local part = GetAimPart(player)

			if part then
				local distance = (RootPart.Position - part.Position).Magnitude

				if distance <= bestDistance then
					bestDistance = distance
					best = player
				end
			end
		end
	end

	return best
end

--============================================================
-- V2 TARGET
--============================================================

local function ClearV2Target()
	AimLockV2.Target = nil
	AimLockV2.TargetPart = nil

	if AimLockV2.Highlight then
		AimLockV2.Highlight:Destroy()
		AimLockV2.Highlight = nil
	end
end

local function SetV2Target(player)
	if AimLockV2.Target == player then
		return
	end

	if AimLockV2.Highlight then
		AimLockV2.Highlight:Destroy()
		AimLockV2.Highlight = nil
	end

	AimLockV2.Target = player
	AimLockV2.TargetPart = GetAimPart(player)

	if player and player.Character then
		local h = Instance.new("Highlight")
		h.Name = "MazHub_AimTarget"
		h.Adornee = player.Character
		h.FillColor = C.Red
		h.FillTransparency = 0.85
		h.OutlineColor = C.Red2
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = player.Character

		AimLockV2.Highlight = h
	end
end

local function V2Retarget()
	if not RootPart then
		ClearV2Target()
		return
	end

	local ownTeam = AimLockV2.YourTeam

	if ownTeam == "" and LocalPlayer.Team then
		ownTeam = LocalPlayer.Team.Name
	end

	local bestPlayer
	local bestPart
	local bestScore = math.huge

	local viewport = Camera.ViewportSize
	local center = Vector2.new(
		viewport.X / 2,
		viewport.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do
		if IsEnemy(player, ownTeam) then
			local part = GetAimPart(player)

			if part then
				local worldDistance =
					(RootPart.Position - part.Position).Magnitude

				if worldDistance <= AimLockV2.MaxDistance then
					local screenPoint, visible =
						Camera:WorldToViewportPoint(part.Position)

					if visible and screenPoint.Z > 0 then
						local screenDistance =
							(Vector2.new(
								screenPoint.X,
								screenPoint.Y
							) - center).Magnitude

						if screenDistance <= AimLockV2.FOVRadius then
							local score =
								(screenDistance * 0.7)
								+ (worldDistance * 0.3)

							if score < bestScore then
								bestScore = score
								bestPlayer = player
								bestPart = part
							end
						end
					end
				end
			end
		end
	end

	if bestPlayer then
		SetV2Target(bestPlayer)
		AimLockV2.TargetPart = bestPart
	else
		ClearV2Target()
	end
end

--============================================================
-- AIM V1
--============================================================

local function AimV1()
	if not State.AutoAimV1 then
		return
	end

	local target = State.CurrentTarget

	if not target
		or not target.Parent
		or not IsEnemy(target, State.YourTeam) then

		target = FindV1Target()
		State.CurrentTarget = target
	end

	if target then
		local part = GetAimPart(target)

		if part then
			Camera.CFrame = CFrame.lookAt(
				Camera.CFrame.Position,
				part.Position
			)
		else
			State.CurrentTarget = nil
		end
	end
end

--============================================================
-- AIM V2
--============================================================

local function AimV2(deltaTime)
	if not AimLockV2.Enabled then
		return
	end

	local target = AimLockV2.Target
	local part = target and GetAimPart(target)

	if not target
		or not target.Parent
		or not part
		or not IsEnemy(
			target,
			AimLockV2.YourTeam
		) then

		ClearV2Target()
		return
	end

	AimLockV2.TargetPart = part

	local desired = CFrame.lookAt(
		Camera.CFrame.Position,
		part.Position
	)

	local alpha =
		1 - math.exp(
			-AimLockV2.Smoothness * 60 * deltaTime
		)

	Camera.CFrame = Camera.CFrame:Lerp(
		desired,
		math.clamp(alpha, 0, 1)
	)
end

--============================================================
-- PLAYER EVENTS
--============================================================

Players.PlayerRemoving:Connect(function(player)
	if State.CurrentTarget == player then
		State.CurrentTarget = nil
	end

	if AimLockV2.Target == player then
		ClearV2Target()
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player:GetPropertyChangedSignal("Team"):Connect(function()
			if AimLockV2.Target == player then
				ClearV2Target()
			end

			if State.CurrentTarget == player then
				State.CurrentTarget = nil
			end
		end)
	end
end

--============================================================
-- KEY SYSTEM
--============================================================

local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeySystem"
KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
KeyFrame.Position = UDim2.fromScale(0.5, 0.5)
KeyFrame.Size = UDim2.new(0.85, 0, 0, 285)
KeyFrame.BackgroundColor3 = C.Black
KeyFrame.BackgroundTransparency = 0.04
KeyFrame.Parent = Gui

local KeyConstraint = Instance.new("UISizeConstraint")
KeyConstraint.MinSize = Vector2.new(300, 260)
KeyConstraint.MaxSize = Vector2.new(430, 350)
KeyConstraint.Parent = KeyFrame

Corner(KeyFrame, 15)
Stroke(KeyFrame, C.Red, 1.5, 0.15)

Gradient(
	KeyFrame,
	Color3.fromRGB(17, 9, 11),
	Color3.fromRGB(7, 7, 9),
	90
)

local KeyHeader = Instance.new("Frame")
KeyHeader.Size = UDim2.new(1, 0, 0, 70)
KeyHeader.BackgroundColor3 = C.Panel
KeyHeader.Parent = KeyFrame

Corner(KeyHeader, 15)

local KeyLogo = Instance.new("Frame")
KeyLogo.Size = UDim2.fromOffset(43, 43)
KeyLogo.Position = UDim2.fromOffset(14, 13)
KeyLogo.BackgroundColor3 = C.Red
KeyLogo.Parent = KeyHeader

Corner(KeyLogo, 11)

local KeyLogoText = Instance.new("TextLabel")
KeyLogoText.Size = UDim2.fromScale(1,1)
KeyLogoText.BackgroundTransparency = 1
KeyLogoText.Text = "M"
KeyLogoText.TextColor3 = Color3.new(1,1,1)
KeyLogoText.Font = Enum.Font.GothamBlack
KeyLogoText.TextSize = 24
KeyLogoText.Parent = KeyLogo

local KeyTitle = Instance.new("TextLabel")
KeyTitle.BackgroundTransparency = 1
KeyTitle.Position = UDim2.fromOffset(68, 11)
KeyTitle.Size = UDim2.new(1, -80, 0, 24)
KeyTitle.Text = "MazHub"
KeyTitle.TextColor3 = C.White
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 20
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Parent = KeyHeader

local KeySub = Instance.new("TextLabel")
KeySub.BackgroundTransparency = 1
KeySub.Position = UDim2.fromOffset(69, 37)
KeySub.Size = UDim2.new(1, -80, 0, 18)
KeySub.Text = "V4 Ultra • Premium Version"
KeySub.TextColor3 = C.Red2
KeySub.Font = Enum.Font.GothamMedium
KeySub.TextSize = 10
KeySub.TextXAlignment = Enum.TextXAlignment.Left
KeySub.Parent = KeyHeader

local KeyBody = Instance.new("Frame")
KeyBody.BackgroundTransparency = 1
KeyBody.Position = UDim2.fromOffset(15, 84)
KeyBody.Size = UDim2.new(1, -30, 1, -96)
KeyBody.Parent = KeyFrame

local KeyLayout = Instance.new("UIListLayout")
KeyLayout.Padding = UDim.new(0, 8)
KeyLayout.Parent = KeyBody

local KeyBox = CreateInput(
	KeyBody,
	"Enter MazHub Key",
	""
)

local GetKeyButton = CreateActionButton(
	KeyBody,
	"GET KEY • COPY DISCORD",
	function()
		local link = "https://discord.gg/zUXgk4XT"

		if setclipboard then
			pcall(function()
				setclipboard(link)
			end)

			Notify("MazHub", "Discord link copied.", 3)
		else
			Notify("MazHub", "Discord: discord.gg/zUXgk4XT", 5)
		end
	end
)

local PasteButton = CreateActionButton(
	KeyBody,
	"PASTE KEY",
	function()
		if getclipboard then
			local success, result = pcall(getclipboard)

			if success and result then
				KeyBox.Text = result
				Notify("MazHub", "Key pasted.", 2)
			end
		else
			Notify("MazHub", "Clipboard API not available.", 3)
		end
	end
)

local UnlockButton = CreateActionButton(
	KeyBody,
	"UNLOCK MAZHUB",
	function()
		if KeyBox.Text == CONFIG.KEY then
			State.Unlocked = true

			KeyFrame.Visible = false
			Main.Visible = true

			Notify(
				"MazHub V4 Ultra",
				"Unlocked successfully.",
				3
			)
		else
			Notify(
				"MazHub",
				"Wrong key.",
				3
			)

			pcall(function()
				LocalPlayer:Kick("MazHub: Wrong Key")
			end)
		end
	end
)

UnlockButton.BackgroundColor3 = C.DarkRed
Stroke(UnlockButton, C.Red, 1, 0.2)

MakeDraggable(KeyFrame, KeyHeader)

--============================================================
-- INITIAL VISIBILITY
--============================================================

Main.Visible = false
Floating.Visible = false
KeyFrame.Visible = true

--============================================================
-- MAIN LOOP
--============================================================

local espTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)

	--========================================================
	-- CHARACTER CHECK
	--========================================================

	if not Character
		or not Character.Parent
		or not Humanoid
		or Humanoid.Health <= 0
		or not RootPart
		or not RootPart.Parent then

		StopFly()
		return
	end

	--========================================================
	-- WALKSPEED
	--========================================================

	if State.WalkSpeedEnabled then
		if Humanoid.WalkSpeed ~= State.WalkSpeed then
			Humanoid.WalkSpeed = State.WalkSpeed
		end
	else
		if Humanoid.WalkSpeed ~= State.OriginalWalkSpeed then
			Humanoid.WalkSpeed = State.OriginalWalkSpeed
		end
	end

	--========================================================
	-- NOCLIP
	--========================================================

	if State.Noclip then
		for _, obj in ipairs(Character:GetDescendants()) do
			if obj:IsA("BasePart") then
				if OriginalCanCollide[obj] == nil then
					OriginalCanCollide[obj] = obj.CanCollide
				end
				obj.CanCollide = false
			end
		end
	else
		for obj, original in pairs(OriginalCanCollide) do
			if obj and obj.Parent then
				obj.CanCollide = original
			end
			OriginalCanCollide[obj] = nil
		end
	end

	--========================================================
	-- FLY
	--========================================================

	if State.Flying then

		if not FlyVelocity or not FlyVelocity.Parent then
			StartFly()
		end

		if FlyVelocity then
			local move = Humanoid.MoveDirection

			local vertical = Vector3.new(
				0,
				State.VerticalFly,
				0
			)

			FlyVelocity.Velocity =
				(move * State.FlySpeed)
				+ (vertical * State.FlySpeed)
		end

	else
		if FlyVelocity then
			StopFly()
		end
	end

	--========================================================
	-- AIM V1
	--========================================================

	if State.AutoAimV1 and not AimLockV2.Enabled then
		AimV1()
	end

	--========================================================
	-- AIM V2 RETARGET
	--========================================================

	if AimLockV2.Enabled then

		if os.clock() - AimLockV2.LastRetarget >= 0.05 then
			AimLockV2.LastRetarget = os.clock()
			V2Retarget()
		end

		AimV2(deltaTime)
	end

	--========================================================
	-- ESP
	--========================================================

	espTimer += deltaTime

	if espTimer >= CONFIG.ESP_UPDATE then
		espTimer = 0

		if State.PlayerESP then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					local char = player.Character

					if char and not char:FindFirstChild("MazHub_PlayerESP") then
						local highlight = Instance.new("Highlight")
						highlight.Name = "MazHub_PlayerESP"
						highlight.Adornee = char
						highlight.FillColor = C.Red
						highlight.FillTransparency = 0.72
						highlight.OutlineColor = C.Red2
						highlight.OutlineTransparency = 0.1
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.Parent = char
					end
				end
			end
		end
	end

	--========================================================
	-- TARGET UI
	--========================================================

	local target =
		AimLockV2.Enabled
		and AimLockV2.Target
		or State.CurrentTarget

	if target and target.Parent then
		CombatTargetText.Text =
			"Target:  " .. target.DisplayName

		CombatTargetText.TextColor3 = C.Green
	else
		CombatTargetText.Text = "Target:  None"
		CombatTargetText.TextColor3 = C.Gray
	end
end)

--============================================================
-- TEAM TEXT UPDATE
--============================================================

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	if YourTeamBox and YourTeamBox.Text == "" then
		AimLockV2.YourTeam = GetTeam(LocalPlayer)
	end
end)

--============================================================
-- CLEANUP WHEN GUI IS RESET
--============================================================

Gui.Destroying:Connect(function()
	StopFly()
	ClearV2Target()
end)

print("MazHub V4 Ultra UI 2.0 loaded.")
