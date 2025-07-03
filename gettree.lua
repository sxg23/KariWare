local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local humanoid = localPlayer.Character:WaitForChild("Humanoid")

local originalPosition = localPlayer.Character.HumanoidRootPart.Position

local maxTreesToChop = 3 -- Set how many trees to chop
local treesChopped = 0

local function doChop(cutEventInstance, chopTable)
	local remoteProxy = ((game:GetService("ReplicatedStorage")):WaitForChild("Interaction")):WaitForChild("RemoteProxy")
	remoteProxy:FireServer(cutEventInstance, chopTable)
end

local function tp(x, y, z)
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
	else
		print("Character or HumanoidRootPart not found.")
	end
end

local logModels = workspace:FindFirstChild("LogModels")

for _, v in ipairs(workspace:GetDescendants()) do
	if treesChopped >= maxTreesToChop then
		break
	end
	if v:IsA("Model") and v:FindFirstChild("TreeClass") then
		-- Skip if inside LogModels
		if logModels and v:IsDescendantOf(logModels) then
			-- Skip this iteration
		else
			local model = v
			local treeClass = model:FindFirstChild("TreeClass")
			if treeClass and treeClass.Value == "Frost" then
				local cutTree = model:FindFirstChild("CutEvent")
				-- Find axe in Backpack or Character
				local axe = localPlayer.Backpack:FindFirstChild("Tool") or (localPlayer.Character and localPlayer.Character:FindFirstChild("Tool"))
				local owner = model:FindFirstChild("Owner")
				local isOwnedByPlayer = owner and (owner.Value == nil or owner.Value == localPlayer.Name)
				-- Only chop if there's a WoodSection and not already cut
				if isOwnedByPlayer and axe and cutTree and model:FindFirstChild("WoodSection") and not model:FindFirstChild("RootCut") then
					local chopTable = {
						tool = axe,
						faceVector = Vector3.new(1, 0, 0),
						height = 0.4,
						sectionId = 1,
						hitPoints = 10.2,
						cooldown = .3,
						cuttingClass = "Axe"
					}
					print(treeClass.Value)
					local chopped = false
					while model:FindFirstChild("WoodSection") and not model:FindFirstChild("RootCut") do
						local woodSection = model:FindFirstChild("WoodSection")
						if woodSection and woodSection.ID.Value == 1 then
							tp(woodSection.Position.X, woodSection.Position.Y, woodSection.Position.Z)
							task.wait(.1)
							localPlayer.Character.HumanoidRootPart.Anchored = true
							task.wait(1)
							doChop(cutTree, chopTable)
							task.wait(0.5)
							chopped = true
						else
							print("WoodSection not found.")
							break
						end
					end
					localPlayer.Character.HumanoidRootPart.Anchored = false
					if chopped then
						treesChopped = treesChopped + 1
					end
					--tp(originalPosition.X, originalPosition.Y, originalPosition.Z)
					-- teleportNewLogAndDrag() -- Function not defined, so commented out to prevent errors
				else
					print("Missing CutEvent, Axe tool, not owned by player, or tree already cut.")
				end
			end
		end
	end
end
