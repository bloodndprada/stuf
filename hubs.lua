--// Player Lock-On GUI
--// Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Settings
local FOV_RADIUS = 180
local LOCK_DISTANCE = 1000
local TARGET_PART = "HumanoidRootPart"
local LOCK_ENABLED = false
local CURRENT_TARGET = nil

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LockOnGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(270, 300)
Main.Position = UDim2.new(0, 25, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "PLAYER LOCK-ON"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

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

local PartButton = Instance.new("TextButton")
PartButton.Size = UDim2.new(1, -30, 0, 42)
PartButton.Position = UDim2.fromOffset(15, 107)
PartButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PartButton.Text = "PART: HumanoidRootPart"
PartButton.TextColor3 = Color3.new(1, 1, 1)
PartButton.TextSize = 14
PartButton.Font = Enum.Font.Gotham
PartButton.Parent = Main

Instance.new("UICorner", PartButton).CornerRadius = UDim.new(0, 8)

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

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(1, -30, 0, 42)
TeleportButton.Position = UDim2.fromOffset(15, 205)
TeleportButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
TeleportButton.Text = "TELEPORT TO TARGET"
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.TextSize = 14
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.Parent = Main

Instance.new("UICorner", TeleportButton).CornerRadius = UDim.new(0, 8)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -30, 0, 30)
FOVLabel.Position = UDim2.fromOffset(15, 255)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV_RADIUS
FOVLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FOVLabel.TextSize = 13
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Main

--// FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.fromOffset(FOV_RADIUS * 2, FOV_RADIUS * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Thickness = 2
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Transparency = 0.15
CircleStroke.Parent = FOVCircle

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

--// Target parts
local Parts = {
	"HumanoidRootPart",
	"Head",
	"UpperTorso",
	"LowerTorso"
}

local PartIndex = 1

PartButton.MouseButton1Click:Connect(function()
	PartIndex += 1

	if PartIndex > #Parts then
		PartIndex = 1
	end

	TARGET_PART = Parts[PartIndex]
	PartButton.Text = "PART: " .. TARGET_PART
end)

--// Find closest player inside FOV
local function GetClosestPlayer()
	local closestPlayer = nil
	local closestDistance = FOV_RADIUS

	local viewportSize = Camera.ViewportSize
	local screenCenter = Vector2.new(
		viewportSize.X / 2,
		viewportSize.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then

			local character = player.Character
			if character then

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local part = character:FindFirstChild(TARGET_PART)

				if humanoid and humanoid.Health > 0 and part then

					local screenPosition, visible =
						Camera:WorldToViewportPoint(part.Position)

					if visible and screenPosition.Z > 0 then

						local distanceFromCenter =
							(Vector2.new(
								screenPosition.X,
								screenPosition.Y
							) - screenCenter).Magnitude

						local worldDistance =
							(Camera.CFrame.Position - part.Position).Magnitude

						if distanceFromCenter <= closestDistance
							and worldDistance <= LOCK_DISTANCE then

							closestDistance = distanceFromCenter
							closestPlayer = player
						end
					end
				end
			end
		end
	end

	return closestPlayer
end

--// Lock button
LockButton.MouseButton1Click:Connect(function()
	LOCK_ENABLED = not LOCK_ENABLED

	if LOCK_ENABLED then
		LockButton.Text = "LOCK: ON"
		CircleStroke.Color = Color3.fromRGB(80, 255, 120)
	else
		LockButton.Text = "LOCK: OFF"
		CircleStroke.Color = Color3.fromRGB(255, 255, 255)
		CURRENT_TARGET = nil
		TargetLabel.Text = "TARGET: None"
	end
end)

--// Teleport
TeleportButton.MouseButton1Click:Connect(function()
	if not CURRENT_TARGET then
		return
	end

	local character = CURRENT_TARGET.Character
	local myCharacter = LocalPlayer.Character

	if not character or not myCharacter then
		return
	end

	local targetPart = character:FindFirstChild(TARGET_PART)
	local root = myCharacter:FindFirstChild("HumanoidRootPart")

	if targetPart and root then
		root.CFrame =
			targetPart.CFrame * CFrame.new(0, 3, 4)
	end
end)

--// Update
RunService.RenderStepped:Connect(function()

	-- Keep circle centered on screen
	local viewportSize = Camera.ViewportSize

	FOVCircle.Position = UDim2.fromOffset(
		viewportSize.X / 2,
		viewportSize.Y / 2
	)

	if LOCK_ENABLED then

		CURRENT_TARGET = GetClosestPlayer()

		if CURRENT_TARGET then
			TargetLabel.Text =
				"TARGET: " .. CURRENT_TARGET.DisplayName
		else
			TargetLabel.Text = "TARGET: None"
		end

	end
end)

--// Optional keyboard toggle
UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		LOCK_ENABLED = not LOCK_ENABLED

		if LOCK_ENABLED then
			LockButton.Text = "LOCK: ON"
			CircleStroke.Color = Color3.fromRGB(80, 255, 120)
		else
			LockButton.Text = "LOCK: OFF"
			CircleStroke.Color = Color3.fromRGB(255, 255, 255)
			CURRENT_TARGET = nil
			TargetLabel.Text = "TARGET: None"
		end
	end
end)