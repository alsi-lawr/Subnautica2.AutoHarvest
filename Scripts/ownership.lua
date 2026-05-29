local UE = require("ue")

local Ownership = {}

function Ownership.owner(actor)
	actor = UE.unwrap(actor)
	if not UE.is_usable_object(actor) then
		return nil
	end

	local owner = UE.safe("actor.Owner", function()
		return actor.Owner
	end, nil)

	if UE.is_usable_object(owner) then
		return UE.unwrap(owner)
	end

	owner = UE.call(actor, "GetOwner")
	if UE.is_usable_object(owner) then
		return UE.unwrap(owner)
	end

	return nil
end

function Ownership.is_owned_by_player(actor, player, config)
	if not config.Pickup.SkipPlayerOwnedOrAttached then
		return false
	end
	if not UE.is_usable_object(actor) or not UE.is_usable_object(player) then
		return false
	end

	local owner = Ownership.owner(actor)
	if UE.is_usable_object(owner) and UE.name_of(owner) == UE.name_of(player) then
		return true
	end

	local name = UE.actor_name(actor)
	return UE.contains(name, ".InventoryComponent") or UE.contains(name, ".InventoryRouterComponent")
end

return Ownership
