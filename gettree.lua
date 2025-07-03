local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local humanoid = localPlayer.Character:WaitForChild("Humanoid")

local originalPosition = localPlayer.Character.HumanoidRootPart.Position

local function doChop(cutEventInstance, chopTable)
	local remoteProxy = ((game:GetService("ReplicatedStorage")):WaitForChild("Interaction")):WaitForChild("RemoteProxy")
	remoteProxy:FireServer(cutEventInstance, chopTable)
end

local function tp(x, y, z)
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
	else
		warn("Character or HumanoidRootPart not found.")
	end
end

for _, v in pairs(workspace:GetChildren()) do
	if v.Name == "TreeRegion" and v:FindFirstChild("Model") then
		local model = v.Model
		local treeClass = model:FindFirstChild("TreeClass")
		if model:FindFirstChild("RootCut") == nil and treeClass and treeClass.Value == "Frost" then
			local cutTree = model:FindFirstChild("CutEvent")
			-- Find axe in Backpack or Character
			local axe = localPlayer.Backpack:FindFirstChild("Tool") or (localPlayer.Character and localPlayer.Character:FindFirstChild("Tool"))
			local owner = model:FindFirstChild("Owner")
			local isOwnedByPlayer = owner and (owner.Value == nil or owner.Value == localPlayer.Name)
			if isOwnedByPlayer and axe and cutTree then
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
				while model:FindFirstChild("WoodSection") and not model:FindFirstChild("RootCut") do
					local woodSection = model:FindFirstChild("WoodSection")
					if woodSection then
						tp(woodSection.Position.X, woodSection.Position.Y, woodSection.Position.Z)
						task.wait(.1)
						localPlayer.Character.HumanoidRootPart.Anchored = true
						task.wait(1)
						doChop(cutTree, chopTable)
						task.wait(0.5)
					else
						warn("WoodSection not found.")
						break
					end
				end
				localPlayer.Character.HumanoidRootPart.Anchored = false
				--tp(originalPosition.X, originalPosition.Y, originalPosition.Z)

				-- Wait for the log to appear in LogModels and teleport its WoodSection
				local function teleportNewLogAndDrag()
					local found = false
					local logToDrag = nil
					for i = 1, 100 do -- Try for up to ~10 seconds
						task.wait(0.1)
						for _, log in pairs(workspace.LogModels:GetChildren()) do
							if log.ClassName == "Model" and log:FindFirstChild("WoodSection") then
								local logOwner = log:FindFirstChild("Owner")
								if logOwner and logOwner.Value == localPlayer.Name then
									logToDrag = log
									found = true
									break
								end
							end
						end
						if found then break end
					end
					if not found or not logToDrag then
						warn("No owned log found in LogModels after chopping.")
						return
					end
					-- Drag the log until both player and log are at originalPosition
					local draggingRemote = game:GetService("ReplicatedStorage").Interaction.ClientIsDragging
					local woodSection = logToDrag:FindFirstChild("WoodSection")
					if not woodSection then warn("Log missing WoodSection"); return end
					-- Set PrimaryPart if not already set
					if not logToDrag.PrimaryPart then
						local success = pcall(function()
							logToDrag.PrimaryPart = woodSection
						end)
						if not success then
							warn("Failed to set PrimaryPart for log.")
						end
					end
					while (localPlayer.Character.HumanoidRootPart.Position - originalPosition).magnitude > 1 or (woodSection.Position - originalPosition).magnitude > 1 do
						draggingRemote:FireServer(logToDrag)
						if logToDrag.PrimaryPart then
							logToDrag:SetPrimaryPartCFrame(CFrame.new(originalPosition.X, originalPosition.Y, originalPosition.Z) * CFrame.Angles(0, math.rad(180), 0))
						else
							woodSection.CFrame = CFrame.new(originalPosition.X, originalPosition.Y, originalPosition.Z) * CFrame.Angles(0, math.rad(180), 0)
						end
						task.wait(0.1)
					end
					print("Log and player at original position!")
				end
				teleportNewLogAndDrag()
			else
				warn("Missing CutEvent, Axe tool, or not owned by player.")
			end
		end
	end
end
