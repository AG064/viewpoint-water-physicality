-- Registers the Water Physicality model pack with Project Viewpoint, the way the other Viewpoint packs
-- do (the mod id and the manifest inside the mod). Viewpoint lists it under the mod's name in its
-- model pack settings. Registered at boot, and again at game start if the first call was too early.

local MOD_ID = "WaterPhysicality"
local MANIFEST = "media/water/package.properties"
local done = false

local function register()
    if done or not Viewpoint or not Viewpoint.ModelPacks then return end
    local ok, res = pcall(Viewpoint.ModelPacks.register, MOD_ID, MANIFEST)
    if ok and res then
        done = true
        print("[WaterPhysicality] model pack registered with Viewpoint: " .. MANIFEST)
    else
        print("[WaterPhysicality] could not register " .. MANIFEST .. ": " .. tostring(res))
    end
end

Events.OnGameBoot.Add(register)
Events.OnGameStart.Add(register)
