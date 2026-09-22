local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local enabled = false
local teamCheck = false
local target = nil
local MAX_DISTANCE = 300

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HeadLockGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- BOTÓN LOCK
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(130,45)
button.Position = UDim2.new(1,-145,1,-70)
button.Text = "LOCK OFF"
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.BackgroundColor3 = Color3.fromRGB(35,35,35)
button.TextColor3 = Color3.new(1,1,1)
button.BorderSizePixel = 0
button.Parent = gui

Instance.new("UICorner",button).CornerRadius = UDim.new(0,10)

-- BOTÓN TEAM CHECK
local teamButton = Instance.new("TextButton")
teamButton.Size = UDim2.fromOffset(130,45)
teamButton.Position = UDim2.new(1,-145,1,-120)
teamButton.Text = "TEAM CHECK: OFF"
teamButton.TextSize = 15
teamButton.Font = Enum.Font.GothamBold
teamButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
teamButton.TextColor3 = Color3.new(1,1,1)
teamButton.BorderSizePixel = 0
teamButton.Parent = gui

Instance.new("UICorner",teamButton).CornerRadius = UDim.new(0,10)

-- BOLITA
local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(8,8)
dot.Position = UDim2.new(0.5,-4,0.5,-4)
dot.BackgroundColor3 = Color3.new(1,1,1)
dot.BorderSizePixel = 0
dot.Parent = gui

Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

-- BUSCAR OBJETIVO
local function getTarget()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local closest
	local closestDistance = MAX_DISTANCE

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then

			-- TEAM CHECK
			local sameTeam = other.Team == player.Team

			if not teamCheck or not sameTeam then
				local head = other.Character:FindFirstChild("Head")
				local humanoid = other.Character:FindFirstChildOfClass("Humanoid")

				if head and humanoid and humanoid.Health > 0 then
					local distance = (root.Position - head.Position).Magnitude

					if distance < closestDistance then
						closestDistance = distance
						closest = other
					end
				end
			end
		end
	end

	return closest
end

-- LOCK ON/OFF
button.Activated:Connect(function()
	enabled = not enabled

	if enabled then
		target = getTarget()
		button.Text = "LOCK ON"
		button.BackgroundColor3 = Color3.fromRGB(0,170,70)
		dot.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		target = nil
		button.Text = "LOCK OFF"
		button.BackgroundColor3 = Color3.fromRGB(35,35,35)
		dot.BackgroundColor3 = Color3.new(1,1,1)
	end
end)

-- TEAM CHECK ON/OFF
teamButton.Activated:Connect(function()
	teamCheck = not teamCheck

	if teamCheck then
		teamButton.Text = "TEAM CHECK: ON"
		teamButton.BackgroundColor3 = Color3.fromRGB(0,170,70)
	else
		teamButton.Text = "TEAM CHECK: OFF"
		teamButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
	end

	-- Buscar nuevamente para aplicar el filtro
	if enabled then
		target = getTarget()
	end
end)

-- CÁMARA
RunService:BindToRenderStep(
	"RivalsHeadLock",
	Enum.RenderPriority.Camera.Value + 100,
	function()

		if not enabled then return end

		-- Si el objetivo es de tu equipo, buscar otro
		if target and teamCheck and target.Team == player.Team then
			target = getTarget()
		end

		local character = target and target.Character
		local head = character and character:FindFirstChild("Head")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not head or not humanoid or humanoid.Health <= 0 then
			target = getTarget()
			return
		end

		camera = workspace.CurrentCamera
		if not camera then return end

		local cameraPosition = camera.CFrame.Position

		camera.CFrame = CFrame.lookAt(
			cameraPosition,
			head.Position
		)
	end
)
