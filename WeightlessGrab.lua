local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:wait()
local Humanoid = Character:WaitForChild("Humanoid")
local walkSpeed = Humanoid.WalkSpeed
game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger.Disabled = true
_G.dragRangeMin = 5
fivefour = coroutine.wrap(function()
EKey = false
QKey = false
player:GetMouse().KeyDown:connect(function(key)
	if string.lower(key) == "e" then
		EKey = true
	elseif string.lower(key) == "q" then
		QKey = true
	end
end)
player:GetMouse().KeyUp:connect(function(key)
	if string.lower(key) == "e" then
		EKey = false
	elseif string.lower(key) == "q" then
		QKey = false
	end
end)
while wait(0.1) do
	if EKey then
		F = FVal
		FVal = FVal + 1000
		ChangeForce(F+1000)
		print(F)
	end
	if QKey then
		F = FVal
		FVal = FVal - 1000
		ChangeForce(F-1000)
		print(F)
	end
end

end)
fivefour()
local dragPart = Instance.new("Part",game.Players.LocalPlayer.PlayerGui)--game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger.Dragger
dragPart.Size = Vector3.new(0.2,0.2,0.2)
dragPart.BrickColor = BrickColor.new("Really red")
player.CharacterAdded:connect(function()
	Character = player.Character
	Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.Died:connect(function()
		dragPart.Parent = nil
	end)
end)

wait(1)
local dragRangeMax = 10000
local dragRangeMin = _G.dragRangeMin

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local button1Down = false
local dragRange = dragRangeMax
FVal = 80000
local bodyPosition = Instance.new("BodyPosition", dragPart)
bodyPosition.maxForce = Vector3.new(1, 1, 1) * FVal
bodyPosition.D = 1000
bodyPosition.P = 4000
function ChangeForce(F)
if F > 0 then
F = bodyPosition.maxForce.X+F
bodyPosition.maxForce = Vector3.new(1, 1, 1) * F
else
F = bodyPosition.maxForce.X-F
bodyPosition.maxForce = Vector3.new(1, 1, 1) * F
end
end

local bodyGyro = Instance.new("BodyGyro", dragPart) 
bodyGyro.maxTorque = Vector3.new(1, 1, 1) * 200 --4000 -- * 0.000012
bodyGyro.P = 1200
bodyGyro.D = 140 --15

--bodyPosition.P = bodyPosition.P * 1/19
--bodyPosition.D = bodyPosition.D  * 1/19
--bodyGyro.P = bodyGyro.P * 1/19
--bodyGyro.D = bodyGyro.D  * 1/19

local rotateCFrame = CFrame.new()

local weld = Instance.new("Weld", dragPart)

--local interactPermission = require(game.ReplicatedStorage.Interaction.InteractionPermission)
local clientIsDragging = game.ReplicatedStorage.Interaction.ClientIsDragging

local carryAnimationTrack


--------------------------------[[ Drag Main ]]------------------------------------

local draggingPart = false

function click()
	button1Down = true

	local targetObject = game.Players.LocalPlayer:GetMouse().Target
	if not canDrag(targetObject) then
		return
	end
	
	local mouseHit = game.Players.LocalPlayer:GetMouse().Hit.p
	if (mouseHit - Character.Head.Position).magnitude > dragRangeMax then
		return
	end
	
	initializeDrag(targetObject, mouseHit)
	rotateCFrame = CFrame.new()
	
	carryAnimationTrack:Play(0.1, 1, 1)
	
	local dragIsFailing = 0 
	local dragTime = 0
	
	
	while button1Down and canDrag(targetObject) do
		local desiredPos = Character.Head.Position + (game.Players.LocalPlayer:GetMouse().Hit.p - Character.Head.Position).unit * dragRange
		
		local dragRay = Ray.new(Character.Head.Position, desiredPos - Character.Head.Position)
		local part, pos = workspace:FindPartOnRayWithIgnoreList(dragRay, {Character, dragPart, targetObject.Parent})
		
		if part then
			desiredPos = pos
		end
		
		if (camera.CoordinateFrame.p - Character.Head.Position).magnitude > 2 then
			desiredPos = desiredPos + Vector3.new(0, 1.8, 0)
		end
		
		moveDrag(desiredPos)
		bodyGyro.cframe = CFrame.new(dragPart.Position, camera.CoordinateFrame.p) * rotateCFrame
		
		local targParent = findHighestParent(targetObject) or targetObject		
		
		local attemptingToSurf  = false
		for _, check in pairs({{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.7, -2.8, 0)).p, Vector3.new(0, -2, 0))}, 
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, 0)).p, Vector3.new(0, -2, 0))}, 
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, 0)).p, Vector3.new(0, -2, 0))},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, 0)).p, Vector3.new(0, -2, 0))}, 
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(-0.7, -2.8, 0)).p, Vector3.new(0, -2, 0))}, 
							
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, 0.6)).p, Vector3.new(0, -2, 0))}, 
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, 0.6)).p, Vector3.new(0, -2, 0))},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, 0.6)).p, Vector3.new(0, -2, 0))}, 
							
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, -0.6)).p, Vector3.new(0, -2, 0))}, 
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, -0.6)).p, Vector3.new(0, -2, 0))},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.35, -2.8, -0.6)).p, Vector3.new(0, -2, 0))}, 
							
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.5, -0.8, 0)).p, Character.HumanoidRootPart.CFrame.lookVector), State = Enum.HumanoidStateType.Climbing},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(-0.5, -0.8, 0)).p, Character.HumanoidRootPart.CFrame.lookVector), State = Enum.HumanoidStateType.Climbing},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(0.5, -1.3, 0)).p, Character.HumanoidRootPart.CFrame.lookVector), State = Enum.HumanoidStateType.Climbing},
							{Ray = Ray.new((Character.HumanoidRootPart.CFrame * CFrame.new(-0.5, -1.3, 0)).p, Character.HumanoidRootPart.CFrame.lookVector), State = Enum.HumanoidStateType.Climbing}
									
					}) do
		
			local ray = check.Ray
			local part, _ = workspace:FindPartOnRayWithIgnoreList(ray, {Character})
			local op = part
			part = part and findHighestParent(part)
			
			if part and (not check.State or Humanoid:GetState() == check.State) then
				if part == targParent then
					attemptingToSurf = true
				else
					for _, connectedPart in pairs(op:GetConnectedParts(true)) do

						if connectedPart == targetObject--[[targParent]] then
							attemptingToSurf = true
							break
						end
					end
				end

				if attemptingToSurf then
					break
				end
			end
		end
		
		
		
		
		
		local falling = Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.FallingDown--not part1 and not part2
		
		
		if attemptingToSurf then
			dragIsFailing = 0
		elseif falling then
			dragIsFailing = 0
		elseif (dragPart.Position - desiredPos).magnitude > 5 then
			dragIsFailing = 0
		else
			dragIsFailing = 0
		end
		if dragIsFailing > 16 then
			break
		end
		
		
		if dragTime % 10 == 0 and targParent.Parent:FindFirstChild("BedInfo") and targParent.Parent:FindFirstChild("Main") then
			game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.Parent.Scripts.VehicleControl.SetVehicleOwnership:Fire(targParent.Parent.Main)
		end
		
		clientIsDragging:FireServer(targParent.Parent)
		
		wait()
		dragTime = 0
	end
	
	carryAnimationTrack:Stop()
	
	endDrag()
end


function findHighestParent(child)
	if not child or not child.Parent or child.Parent == workspace then
		return nil
	end
	
	local ret = child.Parent:FindFirstChild("Owner") and child
	return findHighestParent(child.Parent) or ret
end



function clickEnded()
	button1Down = false
end

function holdDistanceChanged()
	dragRange = dragRangeMax--[[_G.dragRangeMin + (1 - dist) * (dragRangeMax - _G.dragRangeMin)]]
end


function canDrag(targetObject)
	
	
	if not (targetObject and not targetObject.Anchored and targetObject.Parent and Humanoid.Health > 0) then -- General conditions
		return false
	end
	
	if targetObject.Name == "LeafPart" then
		return false
	end
	
	local originTargetObject = targetObject
	targetObject = findHighestParent(targetObject) or targetObject
	
	bodyGyro.Parent = dragPart
	
	
	--[[if not (targetObject.Parent:FindFirstChild("Owner") or targetObject.Parent.Parent:FindFirstChild("Owner")) then
		return otherDraggable(targetObject, originTargetObject)
	end]]

	if targetObject.Parent:FindFirstChild("Owner") or targetObject.Parent.Parent:FindFirstChild("Owner") then
		return true
	end
	
	if targetObject.Parent:FindFirstChild("TreeClass") then -- Wood class
		return true
	end
	if targetObject.Parent:FindFirstChild("BoxItemName") then -- Shop items
		return true
	end
	if targetObject.Parent:FindFirstChild("PurchasedBoxItemName") then -- Purchased box items
		return true
	end
	if targetObject.Parent:FindFirstChild("Handle") then -- Tool items
		return true
	end
	
	return otherDraggable(targetObject, originTargetObject)
end

function otherDraggable(targetObject, originTargetObject)
	local draggable = targetObject and targetObject.Parent and targetObject.Parent:FindFirstChild("DraggableItem") or originTargetObject and originTargetObject.Parent and originTargetObject.Parent:FindFirstChild("DraggableItem")
	if draggable then -- Other stuff
		if draggable:FindFirstChild("NoRotate") then
			bodyGyro.Parent  = nil
		end
		return true
	end
end

function initializeDrag(targetObject,mouseHit)
	draggingPart = true
	mouse.TargetFilter = targetObject and findHighestParent(targetObject) and findHighestParent(targetObject).Parent or targetObject

	dragPart.CFrame = CFrame.new(mouseHit, camera.CoordinateFrame.p)

	weld.Part0 = dragPart
	weld.Part1 = targetObject
	weld.C0 =  CFrame.new(mouseHit,camera.CoordinateFrame.p):inverse() * targetObject.CFrame
	weld.Parent = dragPart
	
	dragPart.Parent = workspace
end

function endDrag()
	mouse.TargetFilter = nil
	dragPart.Parent = nil
	draggingPart = false
end

--------------------------------[[ Do Prompt ]]------------------------------------


local dragGuiState = ""
function interactLoop()
	while true do
		wait()
		
		local newState = ""
		
		local mouseHit = game.Players.LocalPlayer:GetMouse().Hit.p
		local targetObject = game.Players.LocalPlayer:GetMouse().Target
		
		
		if draggingPart then
			newState = "Dragging"
		elseif canDrag(targetObject) and not button1Down and (mouseHit - Character.Head.Position).magnitude < dragRangeMax then
			newState = "Mouseover"
		end
		
		if true then-- not (newState == dragGuiState) then
			dragGuiState = newState
			setPlatformControls()
			
			if dragGuiState == "" then
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.Visible = false
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.Visible = false
			elseif dragGuiState ==  "Mouseover" then
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.Visible = true
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.Visible = false
			elseif dragGuiState ==  "Dragging" then
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.Visible = false
				game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.Visible = not (bodyGyro.Parent == nil) and (not player:FindFirstChild("IsChatting") or player.IsChatting.Value < 1)
			end
		end
		
	end
end


--------------------------------[[ Drag Moving ]]------------------------------------


function moveDrag(pos)
	bodyPosition.position = pos
end
local rotateSpeedReduce = 0.036

local lastRotateTick
function crotate(amount, speed)

	if not draggingPart then
		if not player:FindFirstChild("IsChatting") or player.IsChatting.Value < 2 then
			Humanoid.WalkSpeed = walkSpeed
		end
		return
	end
	
	if Humanoid.WalkSpeed > 1 then
		walkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = 0
	end
	
	lastRotateTick = tick()
	local thisRotateTick = lastRotateTick
	
	while draggingPart and amount.magnitude > 0 and lastRotateTick == thisRotateTick do
		rotateCFrame = CFrame.Angles(0, -amount.X * rotateSpeedReduce, 0) * CFrame.Angles(amount.Y * rotateSpeedReduce, 0, 0) * rotateCFrame
		wait()
	end
	
	if amount.magnitude == 0 then
		if not player:FindFirstChild("IsChatting") or  player.IsChatting.Value < 2 then
			Humanoid.WalkSpeed = walkSpeed
		end
	end
end

--------------------------------[[ User Input ]]------------------------------------

wait(1)

carryAnimationTrack = Humanoid:LoadAnimation(game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger:WaitForChild("CarryItem"))

--input = require(game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.Parent:WaitForChild("Scripts"):WaitForChild("UserInput"))

game.Players.LocalPlayer:GetMouse().Button1Down:connect(function()
	click()
	holdDistanceChanged()
end)
game.Players.LocalPlayer:GetMouse().Button1Up:connect(function()
	clickEnded()
end)
--input.ClickBegan(click, holdDistanceChanged)
--input.ClickEnded(clickEnded)

--input.Rotate(crotate)


function setPlatformControls()
		game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.PlatformButton.Image = game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.PlatformButton.PC.Value
		game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanDrag.PlatformButton.KeyLabel.Text = "CLICK"
		game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.PlatformButton.Image = game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.PlatformButton.PC.Value
		game.Players.LocalPlayer.PlayerGui.ItemDraggingGUI.CanRotate.PlatformButton.KeyLabel.Text = "SHIFT + WASD"
end


interactLoop()
