local Logger = require("logger")
local UE = require("ue")
local Statics = require("statics")
local CandidateLists = require("candidate_lists")

local Spatial = {}

function Spatial.find_candidates(player, config)
	Statics.load()

	if not config.Spatial.Enabled then
		return {}
	end
	if not UE.is_usable_object(Statics.kismet) then
		return {}
	end

	local origin = UE.get_location(player)
	if origin == nil then
		return {}
	end

	local out_actors = {}
	local ignored = { player }

	local ok, result = pcall(function()
		return Statics.kismet:SphereOverlapActors(
			player,
			origin,
			config.Radius,
			config.Spatial.ObjectTypes,
			nil,
			ignored,
			out_actors
		)
	end)

	if not ok then
		Logger.debug("SphereOverlapActors failed: " .. tostring(result))
		return {}
	end

	local kept = {}
	local seen = {}
	local allowed_names = CandidateLists.spatial_actor_names(config)

	for _, raw_actor in ipairs(out_actors) do
		local actor = UE.unwrap(raw_actor)

		if UE.is_usable_object(actor) and UE.is_actor_allowed(actor, allowed_names) then
			local key = UE.actor_name(actor)

			if not seen[key] then
				seen[key] = true
				kept[#kept + 1] = actor
			end
		end
	end

	Logger.debug("spatial scan raw=" .. tostring(#out_actors) .. " kept=" .. tostring(#kept))
	return kept
end

return Spatial
