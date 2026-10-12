local ServerStorage = game:GetService("ServerStorage")

local PlotBuilder = {}

local ROTATE_ATTRIBUTE = "Rotate180"
local PLAYER_PLOTS_FOLDER = "PlayerPlots"

function PlotBuilder.Build(id: string, player: Player, spawn: BasePart): Model
	assert(spawn:IsA("BasePart"), "[PlotBuilder] Spawn must be a BasePart")

	local template = ServerStorage
		:WaitForChild("Assets")
		:WaitForChild("Plots")
		:WaitForChild("DefaultPlot")

	assert(
		template:IsA("Model"),
		"[PlotBuilder] DefaultPlot must be a Model"
	)

	local playerPlots = workspace:WaitForChild(PLAYER_PLOTS_FOLDER)

	local model: Model? = nil

	local success, result = pcall(function()
		model = template:Clone()

		local plotModel = model :: Model

		plotModel.Name = `Plot_{id}`
		plotModel:SetAttribute("Id", id)
		plotModel:SetAttribute("OwnerUserId", player.UserId)

		local rotation = CFrame.identity

		if spawn:GetAttribute(ROTATE_ATTRIBUTE) == true then
			rotation = CFrame.Angles(0, math.rad(180), 0)
		end

		plotModel:PivotTo(spawn.CFrame * rotation)
		plotModel.Parent = playerPlots

		return plotModel
	end)

	if not success then
		if model then
			model:Destroy()
		end

		error(`[PlotBuilder] Failed to build plot: {result}`, 2)
	end

	return result :: Model
end

return PlotBuilder
