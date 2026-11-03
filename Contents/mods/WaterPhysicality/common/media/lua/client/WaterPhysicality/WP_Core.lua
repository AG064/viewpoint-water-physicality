-- Water Physicality: core. Finds the fixtures that hold water near the player (bathtubs, showers,
-- kitchen sinks) and tracks a smoothed fill level for each. Nothing is drawn here; WP_Water reads
-- WP.fixtures. Cost: one throttled scan per second over a small radius, then arithmetic on the few
-- fixtures in range. No per-frame allocation.

-- Take A Bath And Shower is optional: with it the tubs come from its fluid containers, with Lifestyle:
-- Hobbies they come from the bath and shower actions it runs.
local TABAS_Iso
do
    local ok, mod = pcall(require, "TABAS_Iso")
    if ok then TABAS_Iso = mod end
end
local Data = require("WaterPhysicality/WP_Data")

local WP = {}
WP.RADIUS = 6            -- tiles around the player
WP.SCAN_MS = 1000        -- scan period
WP.FILL_RATE = 0.35      -- fraction of the tub per second while filling
WP.DRAIN_RATE = 0.25     -- fraction per second while draining
WP.LOW_LEVEL = 0.4       -- what a low-water container shows when its amount can't be read
WP.FULL_LEVEL = 1.0
WP.FLOW_HOLD_MS = 2500   -- a tub tap keeps running this long after the water last rose

WP.WATER_NAME = "WP_Water"       -- names of the overlay objects this mod places
WP.FLOW_NAME = "WP_Flow"
WP.STREAM_NAME = "WP_Stream"

WP.fixtures = {}         -- key -> { object, square, kind, slot, level, target, flowUntil }
WP.strays = {}           -- overlay objects found on scanned squares (saved from an earlier session)
WP.lastScan = 0
WP.lastTick = 0

local function propOf(object, name)
    local props = object:getProperties()
    if props and props:has(name) then return props:get(name) end
    return nil
end

-- What a sprite is, worked out once per sprite name: false, or { kind, shower, slot }.
--   kind "bathtub": the faucet half stands for the whole tub (the far half is skipped)
--   kind "shower":  a stand-alone shower
--   kind "sink":    a kitchen / bathroom sink (needs live water to count)
--   shower: the fixture also runs a shower stream (stand-alone shower, or a tub with one)
-- slot: its entry in WP_Data (the models were generated from the fixture's own 3D model).
local profiles = {}

-- Vanilla bathroom fixtures, recognised by sprite and properties, for when neither bath mod owns them.
--   entry.lifestyle: Lifestyle: Hobbies is active. It adds no fluid to its tubs and showers and runs a
--                    timed action while one is in use, which WP_Water follows.
--   entry.vanilla:   nothing adds bathing. The fixture shows water and a stream while a vanilla water action
--                    (washing, filling a container, drinking) runs on it, like a sink.
local function fixtureProfile(object, name, number)
    if not name:find("fixtures_bathroom_01_", 1, true) then return false end
    local lifestyle = LSUseTub ~= nil
    local custom = propOf(object, "CustomName")
    if custom == "Bath" and propOf(object, "GroupName") == "Large Deluxe" then
        local slot = Data.tub[number]
        if slot then return { kind = "bathtub", shower = false, slot = slot, lifestyle = lifestyle or nil, vanilla = not lifestyle or nil } end
    elseif custom == "Shower" then
        local slot = Data.shower[number]
        if slot then return { kind = "shower", shower = true, slot = slot, lifestyle = lifestyle or nil, vanilla = not lifestyle or nil } end
    end
    return false
end

local function profileOf(object, name)
    local number = tonumber(name:match("_(%d+)$"))
    local profile = false
    if number then
        if TABAS_Iso and TABAS_Iso.isBathObject(object) then
            local props = object:getProperties()
            local slot = not (props and props:has("IsGridExtensionTile")) and Data.tub[number] or nil
            if slot then profile = { kind = "bathtub", shower = TABAS_Iso.isShowerObject(object, true), slot = slot } end
        elseif TABAS_Iso and TABAS_Iso.isShowerObject(object, false) then
            local slot = Data.shower[number]
            if slot then profile = { kind = "shower", shower = true, slot = slot } end
        elseif propOf(object, "CustomName") == "Sink" and name:find("sinks_01", 1, true) then
            local slot = Data.sink[number]
            if slot then profile = { kind = "sink", shower = false, slot = slot } end
        end
        if not profile then profile = fixtureProfile(object, name, number) end
    end
    profiles[name] = profile
    return profile
end

-- 0..1 fill ratio and the raw amount of a tub's fluid container.
local function fluidOf(tfc)
    local ok, amount, capacity = pcall(function() return tfc:getAmount(), tfc:getCapacity() end)
    if ok and amount and capacity and capacity > 0 then
        return math.min(1, amount / capacity), amount
    end
    return tfc:isLowWater() and WP.LOW_LEVEL or WP.FULL_LEVEL, nil
end

local function updateTarget(entry, now)
    local object = entry.object
    if entry.lifestyle then
        return      -- WP_Water sets the target from the bath and shower actions
    elseif entry.vanilla then
        entry.hasWater = object:hasWater() and true or false   -- WP_Water shows it while a water action runs
    elseif entry.kind == "bathtub" then
        local tfc = TABAS_Iso.getTfcBaseOnBathObject(object)
        if tfc and tfc:hasFluid() then
            local ratio, amount = fluidOf(tfc)
            entry.target = math.max(ratio, 0.05)
            if amount then
                if entry.lastAmount and amount > entry.lastAmount + 0.0001 then
                    entry.flowUntil = now + WP.FLOW_HOLD_MS
                end
                entry.lastAmount = amount
            end
        else
            entry.target = 0
            entry.lastAmount = nil
        end
    elseif entry.kind == "sink" then
        entry.hasWater = object:hasWater() and true or false   -- WP_Water raises the level while the tap is used
    else
        entry.target = 0
    end
end

function WP.scan()
    local player = getPlayer()
    if not player then return end
    local cell = getCell()
    local now = getTimestampMs()
    local px, py, pz = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    local seen = {}
    local strays = {}
    for x = px - WP.RADIUS, px + WP.RADIUS do
        for y = py - WP.RADIUS, py + WP.RADIUS do
            local square = cell:getGridSquare(x, y, pz)
            if square then
                local objects = square:getObjects()
                for i = 1, objects:size() do
                    local object = objects:get(i - 1)
                    local sprite = object:getSprite()
                    local name = sprite and sprite:getName() or nil
                    if name then
                        if name:sub(1, 9) == "wp_water_" then
                            strays[#strays + 1] = object
                        else
                            local profile = profiles[name]
                            if profile == nil then profile = profileOf(object, name) end
                            if profile then
                                local key = square:getX() .. "," .. square:getY() .. "," .. square:getZ() .. ":" .. name
                                seen[key] = true
                                local entry = WP.fixtures[key]
                                if not entry then
                                    entry = { object = object, square = square, kind = profile.kind, shower = profile.shower,
                                              slot = profile.slot, lifestyle = profile.lifestyle, vanilla = profile.vanilla,
                                              level = 0, target = 0 }
                                    WP.fixtures[key] = entry
                                end
                                updateTarget(entry, now)
                            end
                        end
                    end
                end
            end
        end
    end
    -- drop fixtures that left the scan area
    for key in pairs(WP.fixtures) do
        if not seen[key] then WP.fixtures[key] = nil end
    end
    WP.strays = strays
end

-- Smooths each fixture's level toward its target, so filling and draining animate.
function WP.advance(dt)
    for _, entry in pairs(WP.fixtures) do
        local target = entry.target or 0
        local rate = target > entry.level and WP.FILL_RATE or WP.DRAIN_RATE
        local step = rate * dt
        if entry.level < target then
            entry.level = math.min(target, entry.level + step)
        elseif entry.level > target then
            entry.level = math.max(target, entry.level - step)
        end
    end
end

local function onTick()
    local now = getTimestampMs()
    if WP.lastTick == 0 then WP.lastTick = now end
    local dt = (now - WP.lastTick) / 1000
    WP.lastTick = now
    WP.advance(dt)
    if now - WP.lastScan >= WP.SCAN_MS then
        WP.lastScan = now
        local ok, err = pcall(WP.scan)
        if not ok then print("[WaterPhysicality] scan error: " .. tostring(err)) end
    end
end

Events.OnTick.Add(onTick)
print("[WaterPhysicality] core loaded")

return WP
