-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Global ESP Ayarı
getgenv().ESP_ON = true -- artık başka scriptten açıp kapatabiliriz
local Box_Color = Color3.fromRGB(0, 255, 50)
local Box_Thickness = 1.4
local Team_Check = false
local red = Color3.fromRGB(227, 52, 52)
local green = Color3.fromRGB(88, 217, 24)

-- Utility Functions
local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Box_Color
    line.Thickness = Box_Thickness
    line.Transparency = 1
    return line
end

local function IsBehindWall(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return true end
    local origin = camera.CFrame.Position
    local direction = character.HumanoidRootPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character, character}
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, params)
    if result then
        if result.Instance:IsDescendantOf(character) then
            return false
        else
            return true
        end
    end
    return false
end

-- Create ESP for a player
local function CreateESP(targetPlayer)
    local lines = {}
    for i = 1, 12 do
        lines[i] = NewLine()
    end

    RunService.RenderStepped:Connect(function()
        if not getgenv().ESP_ON then
            for _, line in pairs(lines) do
                line.Visible = false
            end
            return
        end

        local char = targetPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and targetPlayer ~= player then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local Size = Vector3.new(2,3,1.5)
                local Top1 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                local Top2 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                local Top3 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                local Top4 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)
                local Bottom1 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                local Bottom2 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                local Bottom3 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                local Bottom4 = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                -- Top
                lines[1].From, lines[1].To = Vector2.new(Top1.X, Top1.Y), Vector2.new(Top2.X, Top2.Y)
                lines[2].From, lines[2].To = Vector2.new(Top2.X, Top2.Y), Vector2.new(Top3.X, Top3.Y)
                lines[3].From, lines[3].To = Vector2.new(Top3.X, Top3.Y), Vector2.new(Top4.X, Top4.Y)
                lines[4].From, lines[4].To = Vector2.new(Top4.X, Top4.Y), Vector2.new(Top1.X, Top1.Y)

                -- Bottom
                lines[5].From, lines[5].To = Vector2.new(Bottom1.X, Bottom1.Y), Vector2.new(Bottom2.X, Bottom2.Y)
                lines[6].From, lines[6].To = Vector2.new(Bottom2.X, Bottom2.Y), Vector2.new(Bottom3.X, Bottom3.Y)
                lines[7].From, lines[7].To = Vector2.new(Bottom3.X, Bottom3.Y), Vector2.new(Bottom4.X, Bottom4.Y)
                lines[8].From, lines[8].To = Vector2.new(Bottom4.X, Bottom4.Y), Vector2.new(Bottom1.X, Bottom1.Y)

                -- Sides
                lines[9].From, lines[9].To = Vector2.new(Bottom1.X, Bottom1.Y), Vector2.new(Top1.X, Top1.Y)
                lines[10].From, lines[10].To = Vector2.new(Bottom2.X, Bottom2.Y), Vector2.new(Top2.X, Top2.Y)
                lines[11].From, lines[11].To = Vector2.new(Bottom3.X, Bottom3.Y), Vector2.new(Top3.X, Top3.Y)
                lines[12].From, lines[12].To = Vector2.new(Bottom4.X, Bottom4.Y), Vector2.new(Top4.X, Top4.Y)

                local behindWall = IsBehindWall(char)
                for _, line in pairs(lines) do
                    line.Color = behindWall and Color3.fromRGB(255,0,0) or Box_Color
                    line.Visible = true
                end

                if Team_Check then
                    local color = targetPlayer.TeamColor == player.TeamColor and green or red
                    for _, line in pairs(lines) do
                        line.Color = color
                    end
                end
            else
                for _, line in pairs(lines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
    end)
end

-- Apply ESP to existing players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        CreateESP(plr)
    end
end

-- Apply ESP to new players
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateESP(plr)
        end)
    end
end)

print("3D Box ESP scripti aktif! Aç/kapa için getgenv().ESP_ON = true/false kullanabilirsiniz.")
