local Logger = require("logger")
local UE = require("ue")
local Statics = require("statics")

local Breakables = {}

function Breakables.is_candidate(actor, config)
	if not config.Break.Enabled then
		return false
	end
	if not UE.is_usable_object(actor) then
		return false
	end

	return UE.is_actor_allowed(actor, config.Break.ActorNames)
end

local function breakable_data(actor)
	Statics.load()

	if not UE.is_usable_object(Statics.breakable_data) then
		return nil
	end

	local data = UE.call(Statics.breakable_data, "GetBreakableDataForActor", actor)
	if UE.is_usable_object(data) then
		return UE.unwrap(data)
	end

	return nil
end

local function is_breakable_resource(data)
	if not UE.is_usable_object(data) then
		return false
	end

	local hits = UE.number_value(UE.safe("NumHitsToBreak", function()
		return UE.unwrap(data).NumHitsToBreak
	end, nil))

	if hits == nil then
		Logger.debug("break skipped: NumHitsToBreak is not numeric for " .. tostring(UE.name_of(data)))
		return false
	end

	return hits > 0
end

function Breakables.break_one(player, actor, config)
	if not Breakables.is_candidate(actor, config) then
		return false
	end

	Statics.load()

	if not UE.is_usable_object(Statics.breakable) then
		return false
	end

	local data = breakable_data(actor)
	if not is_breakable_resource(data) then
		return false
	end

	local result = UE.call(Statics.breakable, "BreakBreakableNoAbility", player, actor)

	if result == true then
		Logger.info("broke " .. tostring(UE.actor_name(actor)))
		return true
	end

	Logger.debug("break failed " .. tostring(UE.actor_name(actor)) .. " -> " .. tostring(result))
	return false
end

function Breakables.process(player, actors, origin, config)
	if not config.Break.Enabled then
		return 0
	end

	local broken = 0

	for _, actor in ipairs(actors) do
		if broken >= config.Break.MaxPerSweep then
			break
		end

		if UE.within(actor, origin, config.Radius) and Breakables.break_one(player, actor, config) then
			broken = broken + 1
		end
	end

	return broken
end

return Breakables
