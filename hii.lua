local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local FOV = 180
local MIN_FOV = 50
local MAX_FOV = 500
local targetPart = "HumanoidRootPart"

local locked = false
local target = nil

local parts = {
	"HumanoidRootPart",
	"Head",
	"UpperTorso",
	"LowerTorso"
}

local partIndex = 1

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LockOnGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 330)
frame.Position = UDim2.new(0, 25, .5, -165)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "LOCK ON"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(1,-30,0,40)
lockButton.Position = UDim2.fromOffset(15,55)
lockButton.Text = "LOCK: OFF"
lockButton.TextColor3 = Color3.new(1,1,1)
lockButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
lockButton.Parent = frame

Instance.new("UICorner",lockButton).CornerRadius = UDim.new(0,8)

local partButton = Instance.new("TextButton")
partButton.Size = UDim2.new(1,-30,0,40)
partButton.Position = UDim2.fromOffset(15,105)
partButton.Text = "PART: "..targetPart
partButton.TextColor3 = Color3.new(1,1,1)
partButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
partButton.Parent = frame

Instance.new("UICorner",partButton).CornerRadius = UDim.new(0,8)

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1,-30,0,35)
targetLabel.Position = UDim2.fromOffset(15,150)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "TARGET: None"
targetLabel.TextColor3 = Color3.fromRGB(200,200,200)
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = frame

local teleport = Instance.new("TextButton")
teleport.Size = UDim2.new(1,-30,0,40)
teleport.Position = UDim2.fromOffset(15,190)
teleport.Text = "TELEPORT TO TARGET"
teleport.TextColor3 = Color3.new(1,1,1)
teleport.BackgroundColor3 = Color3.fromRGB(60,100,180)
teleport.Parent = frame

Instance.new("UICorner",teleport).CornerRadius = UDim.new(0,8)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1,-30,0,25)
fovLabel.Position = UDim2.fromOffset(15,240)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: "..FOV
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1,-30,0,8)
slider.Position = UDim2.fromOffset(15,275)
slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
slider.Parent = frame

Instance.new("UICorner",slider).CornerRadius = UDim.new(1,0)

local knob = Instance.new("TextButton")
knob.Size = UDim2.fromOffset(18,18)
knob.AnchorPoint = Vector2.new(.5,.5)
knob.Text = ""
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = slider

Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

local function updateSlider(x)
	local percent = math.clamp(
		(x-slider.AbsolutePosition.X)/slider.AbsoluteSize.X,
		0,1
	)

	FOV = math.floor(
		MIN_FOV+(MAX_FOV-MIN_FOV)*percent
	)

	fovLabel.Text = "FOV: "..FOV
	knob.Position = UDim2.new(percent,0,.5,0)
end

updateSlider(slider.AbsolutePosition.X + slider.AbsoluteSize.X *
	((FOV-MIN_FOV)/(MAX_FOV-MIN_FOV)))

local dragging = false

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
	end
end)

slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		updateSlider(input.Position.X)
		dragging = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- FOV circle
local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(.5,.5)
circle.BackgroundTransparency = 1
circle.Parent = gui

Instance.new("UICorner",circle).CornerRadius = UDim.new(1,0)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.new(1,1,1)
stroke.Parent = circle

local function getPart(plr)
	local char = plr.Character
	if not char then return nil end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end

	return char:FindFirstChild(targetPart)
		or char:FindFirstChild("HumanoidRootPart")
end

local function findTarget()
	local center = Vector2.new(
		camera.ViewportSize.X/2,
		camera.ViewportSize.Y/2
	)

	local closest
	local closestDistance = FOV

	for _,plr in Players:GetPlayers() do
		if plr ~= player then
			local part = getPart(plr)

			if part then
				local pos, visible =
					camera:WorldToViewportPoint(part.Position)

				if visible and pos.Z > 0 then
					local distance = (
						Vector2.new(pos.X,pos.Y)-center
					).Magnitude

					if distance <= closestDistance then
						closestDistance = distance
						closest = plr
					end
				end
			end
		end
	end

	return closest
end

-- Lock
lockButton.MouseButton1Click:Connect(function()
	locked = not locked

	if locked then
		target = findTarget()
		lockButton.Text = "LOCK: ON"
		stroke.Color = Color3.fromRGB(80,255,120)
	else
		target = nil
		lockButton.Text = "LOCK: OFF"
		targetLabel.Text = "TARGET: None"
		stroke.Color = Color3.new(1,1,1)
	end
end)

-- Change part
partButton.MouseButton1Click:Connect(function()
	partIndex += 1

	if partIndex > #parts then
		partIndex = 1
	end

	targetPart = parts[partIndex]
	partButton.Text = "PART: "..targetPart
end)

-- Teleport
teleport.MouseButton1Click:Connect(function()
	if not target then return end

	local targetCharacter = target.Character
	local myCharacter = player.Character

	if not targetCharacter or not myCharacter then return end

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

	if targetRoot and myRoot then
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0,3,4)
	end
end)

-- Maintain target
RunService.RenderStepped:Connect(function()

	camera = workspace.CurrentCamera

	circle.Size = UDim2.fromOffset(FOV*2,FOV*2)
	circle.Position = UDim2.fromOffset(
		camera.ViewportSize.X/2,
		camera.ViewportSize.Y/2
	)

	if not locked then return end

	-- IMPORTANT:
	-- Do NOT constantly choose a new target.
	-- Keep the current target until it becomes invalid.

	if target then
		local part = getPart(target)

		if part then
			targetLabel.Text = "TARGET: "..target.DisplayName
		else
			target = nil
		end
	end

	if not target then
		target = findTarget()
	end

	if target then
		targetLabel.Text = "TARGET: "..target.DisplayName
	else
		targetLabel.Text = "TARGET: None"
	end
end)

-- Q toggle
UserInputService.InputBegan:Connect(function(input,processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.Q then
		lockButton:Activate()
	end
end)