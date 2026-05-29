local UE = require("ue")

local Player = {}

function Player.get(config)
	for _, class_name in ipairs(config.PlayerClasses) do
		local player = UE.find_first(class_name)
		if player ~= nil and UE.get_location(player) ~= nil then
			return player
		end
	end

	return nil
end

function Player.inventory(player)
	player = UE.unwrap(player)
	if not UE.is_usable_object(player) then
		return nil
	end

	local direct = UE.safe("player.InventoryComponent", function()
		return player.InventoryComponent
	end, nil)

	if UE.is_usable_object(direct) then
		return UE.unwrap(direct)
	end

	return UE.find_first("UWEInventoryComponent")
end

function Player.inventory_is_full(inventory)
	return UE.is_usable_object(inventory) and UE.call(inventory, "IsFull") == true
end

return Player
