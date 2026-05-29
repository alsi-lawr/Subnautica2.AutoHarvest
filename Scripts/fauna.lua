local UE = require("ue")
local Ownership = require("ownership")

local Fauna = {}

function Fauna.is_candidate(actor, player, config)
	if not config.Fauna.Enabled then
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

	return UE.is_actor_allowed(actor, config.Fauna.ActorNames)
end

return Fauna
