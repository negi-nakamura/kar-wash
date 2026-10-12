local HttpService = game:GetService("HttpService")

local IdGenerator = {}

function IdGenerator.Generate(): string
	return HttpService:GenerateGUID(false)
end

return IdGenerator