local CollectionService = game:GetService("CollectionService")

local PlotSpawnAllocator = {}

local TAG_NAME = "PlotSpawn"

function PlotSpawnAllocator.IsAvailable(spawn: Instance): boolean
	if not spawn:IsA("BasePart") then
		return false
	end

	if not CollectionService:HasTag(spawn, TAG_NAME) then
		return false
	end

	return spawn:GetAttribute("Occupied") ~= true
end

function PlotSpawnAllocator.Claim(): BasePart?
	for _, instance in CollectionService:GetTagged(TAG_NAME) do
		if not PlotSpawnAllocator.IsAvailable(instance) then
			continue
		end

		instance:SetAttribute("Occupied", true)

		return instance
	end

	return nil
end

function PlotSpawnAllocator.Release(spawn: BasePart)
	if not spawn:IsA("BasePart") then
		return
	end

	if not CollectionService:HasTag(spawn, TAG_NAME) then
		return
	end

	spawn:SetAttribute("Occupied", false)
end

return PlotSpawnAllocator