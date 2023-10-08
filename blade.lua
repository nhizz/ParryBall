```local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes", math.huge)
local Balls = workspace:WaitForChild("Balls", math.huge)

local function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
end

local function IsTarget()
    return Player.Character and Player.Character:FindFirstChild("Highlight")
end

local function Parry()
    Remotes:WaitForChild("ParryButtonPress"):Fire()
end

Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    print("Ball Spawned:", Ball)

    local OldPosition = Ball.Position
    local OldTick = tick()

    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local Distance = (Ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude
            local Velocity = (OldPosition - Ball.Position).Magnitude

            print("Distance:", Distance)
            print("Velocity:", Velocity)
            print("Time:", Distance / Velocity)

            if (Distance / Velocity) <= 10 then
                Parry()
            end
        end

        if (tick() - OldTick >= 1/50) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
end)```
