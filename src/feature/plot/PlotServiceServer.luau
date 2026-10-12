local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Janitor = require(ReplicatedStorage.Packages.janitor)

local PlayerState = require(ServerScriptService.server.core.PlayerState)
local Plot = require(ServerScriptService.server.feature.plot.class.Plot)

local PlotService = {}
PlotService.__index = PlotService

type PlotInstance = Plot.Plot

local plots: { [Player]: PlotInstance } = {}
local janitor = Janitor.new()
local initialized = false

function PlotService:Init()
	if initialized then
		return
	end

	initialized = true
end

function PlotService:GetPlot(player: Player): PlotInstance?
	return plots[player]
end

function PlotService:GetPlots(): { PlotInstance }
	local result: { PlotInstance } = {}

	for _, plot in plots do
		table.insert(result, plot)
	end

	return result
end

function PlotService:PlayerAdded(player: Player)
	if not initialized then
		warn("[PlotService] Cannot create plot before initialization")
		return
	end

	if plots[player] then
		return
	end

	local success, result = pcall(function()
		return Plot.New(player)
	end)

	if not success then
		warn(
			("[PlotService] Failed to create plot for %s: %s"):format(
				player.Name,
				tostring(result)
			)
		)

		if player.Parent then
			player:Kick("No plot available. Please rejoin in a moment.")
		end

		return
	end

	local plot = result :: PlotInstance

	-- The player may have left while the plot was being created.
	if not player.Parent then
		plot:Destroy()
		return
	end

	plots[player] = plot

	local stateSuccess, stateError = pcall(function()
		PlayerState.SetPath(player, "session.plotId", plot.Id)
	end)

	if not stateSuccess then
		warn(
			("[PlotService] Failed to set plot ID for %s: %s"):format(
				player.Name,
				tostring(stateError)
			)
		)

		self:PlayerRemoving(player)
		return
	end

	plot:SpawnPlayer()
end

function PlotService:PlayerRemoving(player: Player)
	local plot = plots[player]

	if not plot then
		return
	end

	plots[player] = nil

	local success, err = pcall(function()
		plot:Destroy()
	end)

	if not success then
		warn(
			("[PlotService] Failed to destroy plot for %s: %s"):format(
				player.Name,
				tostring(err)
			)
		)
	end

	local stateSuccess, stateError = pcall(function()
		PlayerState.SetPath(player, "session.plotId", nil)
	end)

	if not stateSuccess then
		warn(
			("[PlotService] Failed to clear plot ID for %s: %s"):format(
				player.Name,
				tostring(stateError)
			)
		)
	end
end

function PlotService:Destroy()
	for player in plots do
		self:PlayerRemoving(player)
	end

	janitor:Destroy()
	initialized = false
end

return PlotService