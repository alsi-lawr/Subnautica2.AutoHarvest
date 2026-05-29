local UE = require("ue")
local Ownership = require("ownership")

local Tools = {}

function Tools.is_candidate(actor, player, config)
	if config.Pickup.Tools == nil or not config.Pickup.Tools.Enabled then
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

	return UE.is_actor_allowed(actor, config.Pickup.Tools.ActorNames)
end

return Tools
