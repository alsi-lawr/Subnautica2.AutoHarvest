local Config = require("config")
local Logger = require("logger")
local UE = require("ue")
local Player = require("player")
local Harvest = require("harvest")

_G.AutoHarvestGeneration = (_G.AutoHarvestGeneration or 0) + 1
local ThisGeneration = _G.AutoHarvestGeneration

local State = {
	scan_count = 0,
}

local function configure_modules()
	Logger.configure(Config)
end

local function reload_config()
	if not Config.ReloadConfigEachScan then
		return
	end

	package.loaded["config"] = nil
	Config = require("config")
	configure_modules()
end

local function scan()
	State.scan_count = State.scan_count + 1
	reload_config()

	local player = Player.get(Config)
	if not UE.is_usable_object(player) then
		Logger.debug("idle: no player")
		return
	end

	local inventory = Player.inventory(player)
	Harvest.run(player, inventory, Config)
end

configure_modules()

if LoopAsync == nil then
	Logger.error("LoopAsync is nil")
else
	Logger.info(
		"loaded AutoHarvest; interval="
			.. tostring(Config.TickIntervalMilliseconds)
			.. "ms; generation="
			.. tostring(ThisGeneration)
	)

	LoopAsync(Config.TickIntervalMilliseconds, function()
		if ThisGeneration ~= _G.AutoHarvestGeneration then
			Logger.info("stopping stale generation " .. tostring(ThisGeneration))
			return true
		end

		ExecuteInGameThread(scan)

		return false
	end)
end
