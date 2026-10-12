local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.janitor)
local IdGenerator = require(ReplicatedStorage.shared.core.utility.IdGenerator)

local PlotBuilder = require(ServerScriptService.server.feature.plot.builder.PlotBuilder)
local PlotSpawnAllocator = require(ServerScriptService.server.feature.plot.modules.PlotSpawnAllocator)

local SPAWN_OFFSET = Vector3.new(0, 5, 0)
local ROOT_PART_TIMEOUT = 5

local Plot = {}
Plot.__index = Plot

export type Plot = typeof(setmetatable({} :: {
    Id: string,
    Player: Player,
    Model: Model,
    SpawnPart: BasePart,
    PlayerSpawnPart: BasePart,

    _janitor: any,
    _destroyed: boolean,
}, Plot))

function Plot.New(player: Player): Plot
    local id = IdGenerator.Generate()
    local spawnPart = PlotSpawnAllocator.Claim()

    if not spawnPart then
        error("[Plot] No available plot spawns", 2)
    end

    local model: Model? = nil

    local success, playerSpawnResult = pcall(function()
        model = PlotBuilder.Build(id, player, spawnPart)

        local plotModel = model :: Model

        local playerSpawnPart = plotModel:FindFirstChild(
            "PlayerSpawn",
            true
        )

        assert(
            playerSpawnPart and playerSpawnPart:IsA("BasePart"),
            ("[Plot] Plot %s requires a PlayerSpawn BasePart"):format(
                plotModel:GetFullName()
            )
        )

        return playerSpawnPart
    end)

    if not success then
        if model then
            model:Destroy()
        end

        PlotSpawnAllocator.Release(spawnPart)

        error(
            ("[Plot] Failed to create plot for %s: %s"):format(
                player.Name,
                tostring(playerSpawnResult)
            ),
            2
        )
    end

    local self = setmetatable({
        Id = id,
        Player = player,
        Model = model :: Model,
        SpawnPart = spawnPart,
        PlayerSpawnPart = playerSpawnResult :: BasePart,

        _janitor = Janitor.new(),
        _destroyed = false,
    }, Plot)

    return self
end

function Plot:_TeleportCharacter(character: Model)
    if self._destroyed then
        return
    end

    local rootPart = character:WaitForChild(
        "HumanoidRootPart",
        ROOT_PART_TIMEOUT
    )

    if not rootPart or not rootPart:IsA("BasePart") then
        return
    end

    if self._destroyed then
        return
    end

    local spawnCFrame = self.PlayerSpawnPart.CFrame + SPAWN_OFFSET

    character:PivotTo(
        spawnCFrame * CFrame.Angles(0, math.rad(180), 0)
    )
end

function Plot:SpawnPlayer()
    if self._destroyed then
        return
    end

    self._janitor:Remove("CharacterAdded")

    local connection = self.Player.CharacterAdded:Connect(function(character)
        self:_TeleportCharacter(character)
    end)

    self._janitor:Add(connection, "Disconnect", "CharacterAdded")

    local character = self.Player.Character

    if character then
        self:_TeleportCharacter(character)
    end
end

function Plot:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true

    self._janitor:Destroy()

    self.Model:Destroy()

    PlotSpawnAllocator.Release(self.SpawnPart)
end

return Plot