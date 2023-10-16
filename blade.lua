local Debug = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes", math.huge)
local Balls = workspace:WaitForChild("Balls", math.huge)
local isBallMoving = false
local Threshold = 9

local function print(...)
    if Debug then
        warn(...)
    end
end

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

local function SpamParry()
    Remotes:WaitForChild("ParryButtonPress"):Fire()
end

local FKeyPressed = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        FKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        FKeyPressed = false
    end
end)

Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    print("Ball Spawned:", Ball)

    local OldPosition = Ball.Position
    local OldTick = tick()

    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local Distance = (Ball.Position - game.Players.LocalPlayer.Character.HumanoidRootPart).Magnitude
            local Velocity = (OldPosition - Ball.Position).Magnitude
            local pingValue = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
            local pingAcc = Velocity * pingValue

            if Velocity > 0 then
                isBallMoving = true
            end

            if isBallMoving then
                if pingValue * ((Distance + pingAcc) / (Velocity + pingAcc)) <= (Threshold + (pingAcc * 10)) then
                    Parry()
                end
            end
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
end)

RunService.Heartbeat:Connect(function()
        if FKeyPressed and IsTarget() then
            SpamParry()
        end
    end)
