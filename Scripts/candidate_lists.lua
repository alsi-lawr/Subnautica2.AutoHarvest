local UE = require("ue")

local CandidateLists = {}

function CandidateLists.spatial_actor_names(config)
	local names = {}

	if config.Pickup.Enabled then
		UE.append_all(names, config.Pickup.ActorNames)

		if config.Pickup.Tools ~= nil and config.Pickup.Tools.Enabled then
			UE.append_all(names, config.Pickup.Tools.ActorNames)
		end
	end

	if config.Fauna.Enabled then
		UE.append_all(names, config.Fauna.ActorNames)
	end

	if config.Break.Enabled then
		UE.append_all(names, config.Break.ActorNames)
	end

	return names
end

return CandidateLists
