local Logger = require("logger")
local UE = require("ue")
local Statics = require("statics")
local Player = require("player")
local Ownership = require("ownership")
local Fauna = require("fauna")
local Tools = require("tools")

local Pickup = {}

local function is_normal_pickup_candidate(actor, player, config)
	if not config.Pickup.Enabled then
		return false
	end
	if not UE.is_usable_object(actor) then
		return false
	end
	if UE.is_picked_up_or_disabled(actor) then
		return false
	end
	if Ownership.is_owned_by_player(actor, player, config) then
		return false
	end

	return UE.is_actor_allowed(actor, config.Pickup.ActorNames)
end

function Pickup.is_candidate(actor, player, config)
	return is_normal_pickup_candidate(actor, player, config)
		or Fauna.is_candidate(actor, player, config)
		or Tools.is_candidate(actor, player, config)
end

local function should_try_player_pickup_actor(actor, player, config)
	return (config.Fauna.TryPlayerPickupActorFallback and Fauna.is_candidate(actor, player, config))
		or (
			config.Pickup.Tools ~= nil
			and config.Pickup.Tools.TryPlayerPickupActorFallback
			and Tools.is_candidate(actor, player, config)
		)
end

function Pickup.pickup(player, inventory, actor, config)
	if not UE.is_usable_object(actor) then
		return false
	end
	if UE.is_picked_up_or_disabled(actor) then
		return false
	end

	if UE.is_usable_object(inventory) then
		local result = UE.call(inventory, "Pickup", actor, true)

		if result == true then
			Logger.info("picked up " .. tostring(UE.actor_name(actor)))
			return true
		end

		Logger.debug("Inventory.Pickup failed " .. tostring(UE.actor_name(actor)) .. " -> " .. tostring(result))
	end

	if should_try_player_pickup_actor(actor, player, config) then
		Statics.load()

		if UE.is_usable_object(Statics.sn2) then
			local result = UE.call(Statics.sn2, "PlayerPickupActor", player, actor, nil)

			if result == true then
				Logger.info("picked up via PlayerPickupActor " .. tostring(UE.actor_name(actor)))
				return true
			end

			Logger.debug("PlayerPickupActor failed " .. tostring(UE.actor_name(actor)) .. " -> " .. tostring(result))
		end
	end

	return false
end

function Pickup.process(player, inventory, actors, origin, config)
	if not config.Pickup.Enabled then
		return 0
	end
	if Player.inventory_is_full(inventory) then
		return 0
	end

	local picked = 0

	for _, actor in ipairs(actors) do
		if picked >= config.Pickup.MaxPerSweep then
			break
		end
		if Player.inventory_is_full(inventory) then
			break
		end

		if
			UE.within(actor, origin, config.Radius)
			and Pickup.is_candidate(actor, player, config)
			and Pickup.pickup(player, inventory, actor, config)
		then
			picked = picked + 1
		end
	end

	return picked
end

return Pickup
