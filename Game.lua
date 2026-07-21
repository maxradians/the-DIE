-- services
local TweenService = game:GetService("TweenService")
local players = game:GetService("Players")

-- variables
local TweenInfo = TweenInfo.new(2)

local mapCount = 3

local mapTime = 210

local update
local check

local function startGame()
	
	local map = game.ReplicatedStorage:FindFirstChild(math.random(1, mapCount)):Clone()
	map.Parent = game.Workspace.map
	map:PivotTo(game.Workspace.map_spawn.CFrame)
	
	for _, player in pairs(players:GetPlayers()) do
		
		player.PlayerGui.HUD.Announcer.Text = "Game will start soon."
		
	end
	
	task.wait(3)
	
	for _, player in pairs(players:GetPlayers()) do

		player.PlayerGui.HUD.Announcer.Text = "Map: "..map:FindFirstChild("map_name").Value

	end
	
	task.wait(3)
	
	for _, player in pairs(players:GetPlayers()) do
		
		player.Team = game.Teams.Hunted
		player.TeamColor = game.Teams.Hunted.TeamColor
		player.Character.Flashlight.Enabled = true
		player.Character:PivotTo(map.player_spawn.CFrame)
		game.Workspace.hunted.Value += 1
		
		player.PlayerGui.HUD.Frame.BackgroundTransparency = 0
		
		player.PlayerGui.HUD.Announcer.Text = "The Die will arrive in 30 seconds."
		
		local fade_out = TweenService:Create(player.PlayerGui.HUD.Frame, TweenInfo, {BackgroundTransparency = 1})
		
		fade_out:Play()

	end
	
	game.Workspace.start:Play()
	
	local die = players:GetPlayers()[math.random(1, #players:GetPlayers())]
	
	if die then
		
		die.Team = game.Teams["The Die"]
		die.TeamColor = game.Teams["The Die"].TeamColor
		die.Character.Flashlight.Enabled = true
		die.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = false
		
		die.Character:FindFirstChildOfClass("Humanoid").JumpHeight *= 3.5
		die.Character:FindFirstChild("speed_bonus").Value = 5
		die.Character:FindFirstChild("sprint_speed").Value += 5
		
		die.CameraMode = Enum.CameraMode.Classic
		die.CameraMinZoomDistance = die.CameraMaxZoomDistance
		
		die.Character:PivotTo(game.Workspace.die_box.die_spawn.CFrame)
		game.Workspace.killers.Value += 1
		if game.Workspace.debug.Value == false then
			game.Workspace.hunted.Value -= 1
		end
		
		local mesh = game.ReplicatedStorage.DieMesh:Clone()
		mesh.Parent = die.Character
		for _, part in pairs(die.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Parent.Name ~= "DieMesh"  then
				part.Transparency = 1
			end
		end
		
	end
	
	task.wait(20)
	
	for _, player in pairs(players:GetPlayers()) do
		player.PlayerGui.HUD.Announcer.Text = "Run! The Die will arrive in 10 seconds."
	end
	
	for _, door in pairs(map:GetDescendants()) do
		if door.Name == "spawn_door" then
			door:Destroy()
		end
	end
	
	task.wait(10)
	
	for _, player in pairs(players:GetPlayers()) do
		player.PlayerGui.HUD.Announcer.Text = "The Die has arrived. Good luck."
	end
	
	game.Workspace.arrival:Play()
	
	die.Character:PivotTo(map.player_spawn.CFrame)
	
	task.wait(2)
	
	for _, player in pairs(players:GetPlayers()) do
		player.PlayerGui.HUD.Announcer.Visible = false
		player.PlayerGui.HUD.Timer.Visible = true
	end
	
	update()
	
end

update = function()
	while task.wait(1) do
		if game.Workspace.timer.Value > 0 then
			game.Workspace.timer.Value -= 1
		else
			
			task.wait(1)
			
			for _, player in pairs(players:GetPlayers()) do
				player.PlayerGui.HUD.Announcer.Visible = true
				player.PlayerGui.HUD.Timer.Visible = false
			end
			
			if game.Workspace.hunted.Value > 0 or game.Workspace.killers.Value <= 0 then
				for _, player in pairs(players:GetPlayers()) do
					player.PlayerGui.HUD.Announcer.Text = "The hunted have won."
				end
			else
				for _, player in pairs(players:GetPlayers()) do
					player.PlayerGui.HUD.Announcer.Text = "The Die has won."
				end
			end
			
			task.wait(3)
			
			for _, mapItem in pairs(game.Workspace.map:GetDescendants()) do
				mapItem:Destroy()
			end
			
			for _, player in pairs(players:GetPlayers()) do
				player.Team = game.Teams.Lobby
				player.TeamColor = game.Teams.Lobby.TeamColor
				player.Character:FindFirstChildOfClass("Humanoid").Health = 0
				player.PlayerGui.HUD.Announcer.Text = "Game will start soon."
				player.CameraMode = Enum.CameraMode.LockFirstPerson
				player.CameraMinZoomDistance = 0.5
			end
			
			task.wait(7)
			
			game.Workspace.timer.Value = mapTime
			
			if #game.Players:GetPlayers() > game.Workspace.min.Value then
			
				startGame()
			
			else
				
				check()
				
			end
			
		end
	end
end

check = function()

while task.wait(0.1) do
	if #players:GetPlayers() < game.Workspace.min.Value then
		print("Not enough players!")
		
		for _, player in pairs(game.Players:GetPlayers()) do
			if player ~= nil and player.PlayerGui and player.PlayerGui:FindFirstChild("HUD") then
				player.PlayerGui.HUD.Announcer.Text = "Not enough players! Waiting for more players to join."
			end
		end
		
	else
		
		task.wait(1)
		startGame()
		
		break
		
	end
end
	
end

check()
