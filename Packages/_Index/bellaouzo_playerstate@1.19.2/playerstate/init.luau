local playerState = script:FindFirstChild("PlayerState")
 
local PlayerStateServer = require(playerState:FindFirstChild("PlayerStateServer"))
local PlayerStateClient = require(playerState:FindFirstChild("PlayerStateClient"))
 
type Server = PlayerStateServer.PlayerStateServer
type Client = PlayerStateClient.PlayerStateClient
 
export type PlayerStateModule = {
    Server: Server,
    Client: Client,
}
 
local module = {
    Server = PlayerStateServer,
    Client = PlayerStateClient,
}

return (module :: any) :: PlayerStateModule