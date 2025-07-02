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

local Library = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Library.lua'
    )
)()
Library.Theme = 'Dark'
local Flags = Library.Flags

local Window = Library:Window({
    Text = 'KariWare v1 | Lumber Tycoon 2 | Test Build',
})

local Tab = Window:Tab({
    Text = 'Self',
})

local Tab2 = Window:Tab({
    Text = 'World',
})

local Tab3 = Window:Tab({
    Text = 'Plot',
})

local Tab4 = Window:Tab({
    Text = 'Settings',
})

local Section = Tab:Section({
    Text = 'Movement',
    Opened = true,
})

local Section2 = Tab:Section({
    Text = 'Player',
    Side = 'Right',
    Opened = false,
})

local Section3 = Tab3:Section({
    Text = 'Buttons2',
})
local Section4 = Tab4:Section({
    Text = 'Server',
    Opened = true,
})
Section4:Button({
    Text = 'Rejoin',
    Callback = function()
        game:GetService('TeleportService'):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game:GetService('Players').LocalPlayer
        )
    end,
})

Section4:Button({
    Text = 'Leave',
    Callback = function()
        game:Shutdown()
    end,
})

Section:Toggle({
    Text = 'Walk Speed',
    Callback = function(value)
        walkspeedToggled = value -- change to false then execute again to turn off
        doWalkSpeed()
    end,
})

Section:Slider({
    Text = 'Speed',
    Default = 16,
    Minimum = 16,
    Maximum = 100,
    Callback = function(value)
        walkSpeed = value
    end,
})

Section:Toggle({
    Text = 'Jump Height',
    Callback = function(value)
        Enabled = value -- change to false then execute again to turn off
        Speed = JHeight -- change speed to the number you want
        local players = game:GetService('Players')

        local function bypassJumpHeight()
            if getgenv().executed then
                print('JumpHeight Already Bypassed - Applying Settings Changes')
                if not Enabled then
                    return
                end
            else
                getgenv().executed = true
                print('JumpHeight Bypassed')

                local mt = getrawmetatable(game)
                setreadonly(mt, false)

                local oldindex = mt.__index
                mt.__index = newcclosure(function(self, b)
                    if b == 'JumpHeight' then
                        return 50
                    end
                    return oldindex(self, b)
                end)
            end
        end

        bypassJumpHeight()

        players.LocalPlayer.CharacterAdded:Connect(function(char)
            bypassJumpHeight()
            char:WaitForChild('Humanoid').JumpHeight = JHeight
        end)

        while Enabled and wait() do
            players.LocalPlayer.Character:WaitForChild('Humanoid').JumpHeight =
                JHeight
        end
        game.Players.LocalPlayer.Character.Humanoid.JumpHeight = 50
    end,
})

Section:Slider({
    Text = 'Height',
    Default = 50,
    Minimum = 50,
    Maximum = 100,
    Callback = function(value)
        JHeight = value
    end,
})

Section:Toggle({
    Text = 'Fly',
    Callback = function(value)
        flyToggled = value
        runFly()
    end,
})

Section:Slider({
    Text = 'Speed',
    Default = 25,
    Minimum = 16,
    Maximum = 200,
    Callback = function(value)
        flySpeed = value
    end,
})
--[[
Section2:Button({
    Text = 'Kick',
    Callback = function()
        warn('Kick.')
    end,
})

Section2:Keybind({
    Text = 'Press',
    Default = Enum.KeyCode.Z,
    Callback = function()
        warn('Pressed.')
    end,
})

Section2:Input({
    Text = 'Lil Input',
    Callback = function(txt)
        warn(txt)
    end,
})
]]
--
Section2:Button({
    Text = 'Kill',
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end,
})
--[[
local drop = Section:Dropdown({
    Text = 'Choose',
    List = { 'Idk', 'Test' },
    Callback = function(v)
        warn(v)
    end,
})

Section:Toggle({
    Text = 'Farm',
    Callback = function(bool)
        warn(bool)
    end,
})

Section:Button({
    Text = 'Refresh Dropdown',
    Callback = function()
        drop:Remove('Test')
        wait(2)
        drop:Add('123')
    end,
})
]]
--
Tab:Select()
