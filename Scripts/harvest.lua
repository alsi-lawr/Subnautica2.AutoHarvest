local Logger = require("logger")
local UE = require("ue")
local Spatial = require("spatial")
local Pickup = require("pickup")
local Breakables = require("breakables")

local Harvest = {}

function Harvest.run(player, inventory, config)
	local origin = UE.get_location(player)
	if origin == nil then
		return
	end

	local actors = Spatial.find_candidates(player, config)

	local broken = Breakables.process(player, actors, origin, config)
	local picked = Pickup.process(player, inventory, actors, origin, config)

	Logger.debug(
		"scan actors=" .. tostring(#actors) .. " picked=" .. tostring(picked) .. " broken=" .. tostring(broken)
	)
end

return Harvest
