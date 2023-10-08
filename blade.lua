local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local Balls = workspace:WaitForChild("Balls", 9e9)

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

local pingValue = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000

Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    print("Ball Spawned:", Ball)

    local OldPosition = Ball.Position
    local OldTick = tick()

     Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local NewPosition = Ball.Position
            if NewPosition ~= OldPosition then
                local CameraFocusPosition = workspace.CurrentCamera.Focus.Position
                local Distance = (NewPosition - CameraFocusPosition).Magnitude
                local Velocity = (OldPosition - NewPosition).Magnitude
                local pingAcc = Velocity * pingValue

                if (Distance / Velocity - pingAcc) <= 8 then
                    Parry()
                end

                OldPosition = NewPosition
            end
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
        end
    end)
end)
