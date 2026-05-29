local UE = require("ue")

local Statics = {
	loaded = false,
	inventory = nil,
	breakable_data = nil,
	breakable = nil,
	kismet = nil,
	sn2 = nil,
}

function Statics.load()
	if Statics.loaded then
		return
	end
	Statics.loaded = true

	Statics.inventory = UE.static_default("/Script/UWEInventory.Default__UWEInventoryStatics")
	Statics.breakable_data = UE.static_default("/Script/UWEBreakable.Default__UWEBreakableData")
	Statics.breakable = UE.static_default("/Script/UWEBreakable.Default__UWEBreakableStatics")
	Statics.kismet = UE.static_default("/Script/Engine.Default__KismetSystemLibrary")
	Statics.sn2 = UE.static_default("/Script/Subnautica2.Default__SN2Statics")
end

return Statics
