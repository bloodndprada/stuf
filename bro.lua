--// PLAYER LOCK-ON GUI
--// Roblox Studio - StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local FOV_RADIUS = 180
local MIN_FOV = 50
local MAX_FOV = 500

local LOCK_DISTANCE = 1000
local LOCK_ENABLED = false
local CURRENT_TARGET = nil

local TARGET_PARTS = {
	"HumanoidRootPart",
	"Head",
	"UpperTorso",
	"LowerTorso"
}

local PART_INDEX = 1
local TARGET_PART = TARGET_PARTS[PART_INDEX]

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LockOnGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(285, 360)
Main.Position = UDim2.new(0, 25, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "PLAYER LOCK-ON"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

--==================================================
-- LOCK BUTTON
--==================================================

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(1, -30, 0, 42)
LockButton.Position = UDim2.fromOffset(15, 55)
LockButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
LockButton.Text = "LOCK: OFF"
LockButton.TextColor3 = Color3.new(1, 1, 1)
LockButton.TextSize = 15
LockButton.Font = Enum.Font.GothamBold
LockButton.Parent = Main

Instance.new("UICorner", LockButton).CornerRadius = UDim.new(0, 8)

--==================================================
-- PART SELECTOR
--==================================================

local PartButton = Instance.new("TextButton")
PartButton.Size = UDim2.new(1, -30, 0, 42)
PartButton.Position = UDim2.fromOffset(15, 107)
PartButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PartButton.Text = "PART: " .. TARGET_PART
PartButton.TextColor3 = Color3.new(1, 1, 1)
PartButton.TextSize = 14
PartButton.Font = Enum.Font.Gotham
PartButton.Parent = Main

Instance.new("UICorner", PartButton).CornerRadius = UDim.new(0, 8)

--==================================================
-- TARGET LABEL
--==================================================

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -30, 0, 35)
TargetLabel.Position = UDim2.fromOffset(15, 159)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "TARGET: None"
TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetLabel.TextSize = 14
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = Main

--==================================================
-- TELEPORT
--==================================================

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(1, -30, 0, 42)
TeleportButton.Position = UDim2.fromOffset(15, 202)
TeleportButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
TeleportButton.Text = "TELEPORT TO TARGET"
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.TextSize = 14
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.Parent = Main

Instance.new("UICorner", TeleportButton).CornerRadius = UDim.new(0, 8)

--==================================================
-- FOV LABEL
--==================================================

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -30, 0, 25)
FOVLabel.Position = UDim2.fromOffset(15, 254)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV_RADIUS
FOVLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Main

--==================================================
-- FOV SLIDER
--==================================================

local SliderBackground = Instance.new("Frame")
SliderBackground.Size = UDim2.new(1, -30, 0, 8)
SliderBackground.Position = UDim2.fromOffset(15, 285)
SliderBackground.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
SliderBackground.BorderSizePixel = 0
SliderBackground.Parent = Main

Instance.new("UICorner", SliderBackground).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(
	(FOV_RADIUS - MIN_FOV) / (MAX_FOV - MIN_FOV),
	0,
	1,
	0
)
SliderFill.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBackground

Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.fromOffset(18, 18)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(
	(FOV_RADIUS - MIN_FOV) / (MAX_FOV - MIN_FOV),
	0,
	0.5,
	0
)
SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
SliderKnob.Text = ""
SliderKnob.Parent = SliderBackground

Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local draggingSlider = false

local function SetFOVFromX(x)
	local absoluteX = SliderBackground.AbsolutePosition.X
	local width = SliderBackground.AbsoluteSize.X

	local percent = math.clamp(
		(x - absoluteX) / width,
		0,
		1
	)

	FOV_RADIUS = math.floor(
		MIN_FOV + ((MAX_FOV - MIN_FOV) * percent)
	)

	FOVLabel.Text = "FOV: " .. FOV_RADIUS

	SliderFill.Size = UDim2.new(percent, 0, 1, 0)
	SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
end

SliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingSlider = true
	end
end)

SliderBackground.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SetFOVFromX(input.Position.X)
		draggingSlider = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not draggingSlider then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		SetFOVFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingSlider = false
	end
end)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(
	FOV_RADIUS * 2,
	FOV_RADIUS * 2
)
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Thickness = 2
CircleStroke.Transparency = 0.15
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Parent = FOVCircle

--==================================================
-- PART SELECTION
--==================================================

PartButton.MouseButton1Click:Connect(function()

	PART_INDEX += 1

	if PART_INDEX > #TARGET_PARTS then
		PART_INDEX = 1
	end

	TARGET_PART = TARGET_PARTS[PART_INDEX]

	PartButton.Text = "PART: " .. TARGET_PART

	-- Force target refresh
	CURRENT_TARGET = nil
end)

--==================================================
-- TARGET VALIDATION
--==================================================

local function GetTargetPart(player)

	local character = player.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	local part = character:FindFirstChild(TARGET_PART)

	-- Fallback so locking doesn't completely fail
	if not part then
		part = character:FindFirstChild("HumanoidRootPart")
	end

	return part
end

--==================================================
-- GET CLOSEST TARGET
--==================================================

local function GetClosestPlayer()

	local closestPlayer = nil
	local closestScreenDistance = FOV_RADIUS

	local viewport = Camera.ViewportSize

	local center = Vector2.new(
		viewport.X / 2,
		viewport.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local part = GetTargetPart(player)

			if part then

				local screenPosition, onScreen =
					Camera:WorldToViewportPoint(part.Position)

				if onScreen and screenPosition.Z > 0 then

					local screenPoint = Vector2.new(
						screenPosition.X,
						screenPosition.Y
					)

					local distanceFromCenter =
						(screenPoint - center).Magnitude

					local distanceFromPlayer =
						(Camera.CFrame.Position - part.Position).Magnitude

					if distanceFromCenter <= FOV_RADIUS
						and distanceFromPlayer <= LOCK_DISTANCE then

						if distanceFromCenter < closestScreenDistance then

							closestScreenDistance =
								distanceFromCenter

							closestPlayer = player
						end
					end
				end
			end
		end
	end

	return closestPlayer
end

--==================================================
-- LOCK BUTTON
--==================================================

local function ToggleLock()

	LOCK_ENABLED = not LOCK_ENABLED

	if LOCK_ENABLED then

		LockButton.Text = "LOCK: ON"
		CircleStroke.Color =
			Color3.fromRGB(80, 255, 120)

		CURRENT_TARGET = GetClosestPlayer()

	else

		LockButton.Text = "LOCK: OFF"
		CircleStroke.Color =
			Color3.fromRGB(255, 255, 255)

		CURRENT_TARGET = nil
		TargetLabel.Text = "TARGET: None"
	end
end

LockButton.MouseButton1Click:Connect(ToggleLock)

--==================================================
-- TELEPORT
--==================================================

TeleportButton.MouseButton1Click:Connect(function()

	if not CURRENT_TARGET then
		return
	end

	local targetCharacter =
		CURRENT_TARGET.Character

	local myCharacter =
		LocalPlayer.Character

	if not targetCharacter or not myCharacter then
		return
	end

	local targetPart =
		GetTargetPart(CURRENT_TARGET)

	local root =
		myCharacter:FindFirstChild("HumanoidRootPart")

	if targetPart and root then

		root.CFrame =
			targetPart.CFrame *
			CFrame.new(0, 3, 4)
	end
end)

--==================================================
-- MAIN UPDATE
--==================================================

RunService.RenderStepped:Connect(function()

	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local viewport = Camera.ViewportSize

	-- Center FOV circle
	FOVCircle.Position = UDim2.fromOffset(
		viewport.X / 2,
		viewport.Y / 2
	)

	-- Live FOV size
	FOVCircle.Size = UDim2.fromOffset(
		FOV_RADIUS * 2,
		FOV_RADIUS * 2
	)

	if LOCK_ENABLED then

		-- Keep existing target if it is still valid
		local keepTarget = false

		if CURRENT_TARGET then

			local part =
				GetTargetPart(CURRENT_TARGET)

			if part then

				local screenPosition, onScreen =
					Camera:WorldToViewportPoint(
						part.Position
					)

				if onScreen and screenPosition.Z > 0 then

					local center = Vector2.new(
						viewport.X / 2,
						viewport.Y / 2
					)

					local screenDistance =
						(
							Vector2.new(
								screenPosition.X,
								screenPosition.Y
							) - center
						).Magnitude

					if screenDistance <= FOV_RADIUS then
						keepTarget = true
					end
				end
			end
		end

		-- Find a new target if current target isn't valid
		if not keepTarget then
			CURRENT_TARGET = GetClosestPlayer()
		end

		if CURRENT_TARGET then

			TargetLabel.Text =
				"TARGET: " ..
				CURRENT_TARGET.DisplayName

		else

			TargetLabel.Text =
				"TARGET: None"
		end
	end
end)

--==================================================
-- Q KEY
--==================================================

UserInputService.InputBegan:Connect(function(
	input,
	processed
)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		ToggleLock()
	end
end)