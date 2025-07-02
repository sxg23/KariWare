local walkspeedToggled = false
local flyToggled = false
local flySpeed = 25
local Players = game.Players:GetPlayers()
local walkSpeed = 16
local Jheight = 50

local function doWalkSpeed()
       local players = game:GetService('Players')

        local function bypassWalkSpeed()
            if getgenv().executed then
                print('Walkspeed Already Bypassed - Applying Settings Changes')
                if not walkspeedToggled then
                    return
                end
            else
                getgenv().executed = true
                print('Walkspeed Bypassed')

                local mt = getrawmetatable(game)
                setreadonly(mt, false)

                local oldindex = mt.__index
                mt.__index = newcclosure(function(self, b)
                    if b == 'WalkSpeed' then
                        return 16
                    end
                    return oldindex(self, b)
                end)
            end
        end


        bypassWalkSpeed()

        players.LocalPlayer.CharacterAdded:Connect(function(char)
            bypassWalkSpeed()
            char:WaitForChild('Humanoid').WalkSpeed = walkSpeed
        end)

        while walkspeedToggled and wait() do
            players.LocalPlayer.Character:WaitForChild('Humanoid').WalkSpeed = walkSpeed
        end
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
end

local function runFly()
    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')
    local UserInputService = game:GetService('UserInputService')
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

    local flying = false
    local bv, bg

    local function startFly()
        if flying then
            return
        end
        flying = true

        bv = Instance.new('BodyVelocity')
        bv.Velocity = Vector3.new()
        bv.MaxForce = Vector3.new(1, 1, 1) * 1e9
        bv.Parent = HumanoidRootPart

        bg = Instance.new('BodyGyro')
        bg.CFrame = HumanoidRootPart.CFrame
        bg.MaxTorque = Vector3.new(1, 1, 1) * 1e9
        bg.P = 10 ^ 5
        bg.Parent = HumanoidRootPart

        RunService.RenderStepped:Connect(function()
            if not flying then
                return
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                dir = dir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                dir = dir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                dir = dir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                dir = dir + cam.CFrame.RightVector
            end
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.zero
            end
            bg.CFrame = cam.CFrame
        end)
    end

    local function stopFly()
        flying = false
        if bv then
            bv:Destroy()
        end
        if bg then
            bg:Destroy()
        end
    end

    -- Toggle fly mode with "E" key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if flyToggled and input.KeyCode == Enum.KeyCode.Q then
            if flying then
                stopFly()
            else
                startFly()
            end
        end

        if flyToggled == false then
            stopFly()
        end
    end)
end
