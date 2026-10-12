local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Index = Packages:WaitForChild("_Index")
local Package = Index:WaitForChild("bellaouzo_playerstate@1.19.2")

local PlayerState = Package:WaitForChild("playerstate"):WaitForChild("PlayerState")

return require(PlayerState:WaitForChild("PlayerStateServer"))