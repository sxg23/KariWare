local a = game.PlaceId
if a == 13822889 then 
    if not game:IsLoaded() then game.Loaded:Wait() end
        wait()
        for i, lt2tree in ipairs(game.workspace:GetChildren()) do
            if lt2tree.Name == "TreeRegion" then
                for a, b in ipairs(lt2tree:GetDescendants()) do
                    b:FindFirstChild("TreeClass") do
                        if b.TreeClass.Value == "Spooky" then
                            local halloweentree = true
                            wait()
                            print("found spook tree")
                        else
                        if b.TreeClass.Value == "SpookyGlow" then
                            local halloweentree = true
                            wait()
                            print("found sinister tree")
                            break
            			else
                            local halloweentree = false
                            if halloweentree == false then 
                                local PlaceID = game.PlaceId
                                local AllIDs = {}
                                local foundAnything = ""
                                local actualHour = os.date("!*t").hour
                                local Deleted = false
                                local File = pcall(function()
                                    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
                                end)
                                if not File then
                                    table.insert(AllIDs, actualHour)
                                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                                end
                                function TPReturner()
                                    local Site;
                                    if foundAnything == "" then
                                        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
                                    else
                                        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
                                    end
                                    local ID = ""
                                    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                                        foundAnything = Site.nextPageCursor
                                    end
                                    local num = 0;
                                    for i,v in pairs(Site.data) do
                                        local Possible = true
                                        ID = tostring(v.id)
                                        if tonumber(v.maxPlayers) > tonumber(v.playing) then
                                            for _,Existing in pairs(AllIDs) do
                                                if num ~= 0 then
                                                    if ID == tostring(Existing) then
                                                        Possible = false
                                                    end
                                                else
                                                    if tonumber(actualHour) ~= tonumber(Existing) then
                                                        local delFile = pcall(function()
                                                            delfile("NotSameServers.json")
                                                            AllIDs = {}
                                                            table.insert(AllIDs, actualHour)
                                                        end)
                                                    end
                                                end
                                                num = num + 1
                                            end
                                            if Possible == true then
                                                table.insert(AllIDs, ID)
                                                wait()
                                                pcall(function()
                                                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                                                    wait()
                                                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                                                end)
                                                wait(4)
                                            end
                                        end
                                    end
                                end
                                
                                function Teleport()
                                    while wait() do
                                        pcall(function()
                                            TPReturner()
                                            if foundAnything ~= "" then
                                                TPReturner()
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end