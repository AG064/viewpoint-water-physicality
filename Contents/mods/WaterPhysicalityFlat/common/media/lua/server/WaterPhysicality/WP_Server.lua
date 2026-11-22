-- Water Physicality: server side. Only relays "a player is using this fixture" (a tap, or a Lifestyle bath or shower)
-- to the other players near it, so they can show the water too. Nothing is stored and nothing in the world is changed.

if not isServer() then return end

local MAX_DISTANCE = 12        -- a player can only announce a fixture near them
local RELAY_DISTANCE = 60      -- ...and only players this close are told (they could see it)
local MIN_GAP_MS = 250         -- per player, starts and stops apart, so a client can't flood the others
local MODES = { tap = true, fill = true, use = true, shower = true }
local lastSeen = {}

local function onClientCommand(module, command, player, args)
    if module ~= "WaterPhysicality" or command ~= "tap" or type(args) ~= "table" then return end
    local x, y, z = tonumber(args.x), tonumber(args.y), tonumber(args.z)
    if not x or not y or not z then return end
    if math.abs(player:getX() - x) > MAX_DISTANCE or math.abs(player:getY() - y) > MAX_DISTANCE then return end
    local on = args.on and true or false
    local now = getTimestampMs()
    -- a stop right after a heartbeat must not be dropped, so starts and stops are throttled apart
    local senderId = player:getOnlineID()
    local key = senderId .. (on and "+" or "-")
    if lastSeen[key] and now - lastSeen[key] < MIN_GAP_MS then return end
    lastSeen[key] = now
    local mode = MODES[args.mode] and args.mode or "tap"
    local message = { x = x, y = y, z = z, on = on, mode = mode }
    local players = getOnlinePlayers()
    if not players then return end
    for i = 0, players:size() - 1 do
        local other = players:get(i)
        -- not back to the sender: its own echo would keep its tap running after it stopped
        if other and other:getOnlineID() ~= senderId
            and math.abs(other:getX() - x) <= RELAY_DISTANCE and math.abs(other:getY() - y) <= RELAY_DISTANCE then
            sendServerCommand(other, "WaterPhysicality", "tap", message)
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
