local Config = {}

-- Runtime.
Config.TickIntervalMilliseconds = 3000
Config.Radius = 1000.0
Config.ReloadConfigEachScan = true

-- Logging.
Config.Log = true
Config.Debug = false

-- Player lookup.
Config.PlayerClasses = {
	"BP_Character_01_C",
	"SN2PlayerCharacter",
	"BP_PlayerCharacter_C",
	"PlayerCharacter",
	"Character",
}

Config.Spatial = {
	Enabled = true,
	ObjectTypes = { 0 },
}

Config.Pickup = {
	Enabled = true,
	MaxPerSweep = 1,
	SkipPlayerOwnedOrAttached = true,

	ActorNames = {
		-- Spawned loose resources.
		"BP_WorldPopSpawnedTitanium",
		"BP_WorldPopSpawnedCopper",
		"BP_WorldPopSpawnedSilver",
		"BP_WorldPopSpawnedQuartz",
		"BP_WorldPopSpawnedSulfurLoose",

		-- Loose pickup items.
		"BP_MedKit",
		"BP_AcidAnemone_MedigelSac",
		"BP_MetalSalvage",
		"BP_Salt",
		"BP_LuciferRotsac",
		"BP_WiringKit",
		"BP_Food",
		"BP_CrabFeces",
		"BP_Silver",
	},

	Tools = {
		Enabled = false,
		TryPlayerPickupActorFallback = true,

		ActorNames = {
			"BP_Flares",
		},
	},
}

Config.Fauna = {
	Enabled = false,

	TryPlayerPickupActorFallback = true,

	ActorNames = {
		"BP_WaterSlug",
		"BP_Halfmoon",
	},
}

Config.Break = {
	Enabled = true,
	MaxPerSweep = 1,

	ActorNames = {
		"BP_ResourceNode",
	},
}

return Config
