local Players = game:GetService("Players")

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Ragdoll
        or newState == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupCharacter)
end)

for _, player in Players:GetPlayers() do
    if player.Character then
        setupCharacter(player.Character)
    end
end
