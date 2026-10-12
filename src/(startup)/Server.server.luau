local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerState = require(ServerScriptService.server.core.PlayerState)
local PlotService = require(ServerScriptService.server.feature.plot.PlotService)

local initializing: { [Player]: boolean } = {}
local initialized: { [Player]: boolean } = {}

PlotService:Init()

local function OnPlayerAdded(player: Player)
	if initializing[player] or initialized[player] then
		return
	end

	initializing[player] = true

	local success, result = pcall(function()
		return PlayerState.Init(player)
	end)

	initializing[player] = nil

	if not success or not result then
		warn(
			("[Server] Failed to initialize PlayerState for %s: %s"):format(player.Name, tostring(result))
		)

		if player.Parent == Players then
			player:Kick("Failed to load your data. Please rejoin.")
		end

		return
	end

	if player.Parent ~= Players then
		return
	end

	initialized[player] = true

	PlotService:PlayerAdded(player)

	if not PlotService:GetPlot(player) then
		initialized[player] = nil
	end
end

local function OnPlayerRemoving(player: Player)
	if initialized[player] then
		PlotService:PlayerRemoving(player)
	end

	initialized[player] = nil
	initializing[player] = nil
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

for _, player in Players:GetPlayers() do
	task.spawn(OnPlayerAdded, player)
end