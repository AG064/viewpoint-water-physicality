-- Water Physicality: server side. Only relays "a player's sink tap is running" to every client, so
-- the others can show the stream too. Nothing is stored and nothing in the world is changed.

if not isServer() then return end

local MAX_DISTANCE = 12        -- a player can only announce a sink near them
local MIN_GAP_MS = 250         -- per player, so a client can't flood the others
local lastSeen = {}

local function onClientCommand(module, command, player, args)
    if module ~= "WaterPhysicality" or command ~= "tap" or type(args) ~= "table" then return end
    local x, y, z = tonumber(args.x), tonumber(args.y), tonumber(args.z)
    if not x or not y or not z then return end
    if math.abs(player:getX() - x) > MAX_DISTANCE or math.abs(player:getY() - y) > MAX_DISTANCE then return end
    local now = getTimestampMs()
    local id = player:getOnlineID()
    if lastSeen[id] and now - lastSeen[id] < MIN_GAP_MS then return end
    lastSeen[id] = now
    sendServerCommand("WaterPhysicality", "tap", { x = x, y = y, z = z, on = args.on and true or false })
end

Events.OnClientCommand.Add(onClientCommand)
