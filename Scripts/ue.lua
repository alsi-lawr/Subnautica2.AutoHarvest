local Logger = require("logger")

local UE = {}

function UE.pcall_or_nil(fn)
	local ok, result = pcall(fn)
	if ok then
		return result
	end
	return nil
end

function UE.unwrap(value)
	if value == nil then
		return nil
	end

	local unwrapped = UE.pcall_or_nil(function()
		if value.get ~= nil then
			return value:get()
		end
		return nil
	end)

	if unwrapped ~= nil then
		return unwrapped
	end
	return value
end

function UE.name_of(obj)
	obj = UE.unwrap(obj)
	if obj == nil then
		return nil
	end

	local full = UE.pcall_or_nil(function()
		if obj.GetFullName ~= nil then
			return obj:GetFullName()
		end
		return nil
	end)

	if full ~= nil then
		return full
	end

	local short = UE.pcall_or_nil(function()
		if obj.GetName ~= nil then
			return obj:GetName()
		end
		return nil
	end)

	if short ~= nil then
		return short
	end

	return tostring(obj)
end

function UE.actor_name(actor)
	return UE.name_of(actor) or ""
end

function UE.is_usable_object(obj)
	obj = UE.unwrap(obj)
	if obj == nil then
		return false
	end

	local name = UE.name_of(obj)
	if name == nil then
		return false
	end

	local text = tostring(name)
	if text == "nil" then
		return false
	end
	if string.find(string.lower(text), "nullptr", 1, true) then
		return false
	end
	if string.find(string.lower(text), "fweakobjectptr", 1, true) then
		return false
	end

	return true
end

function UE.safe(label, fn, fallback)
	local ok, result = pcall(fn)
	if ok then
		return result
	end

	Logger.debug(tostring(label) .. ": " .. tostring(result))
	return fallback
end

function UE.call(obj, method_name, ...)
	obj = UE.unwrap(obj)
	if not UE.is_usable_object(obj) then
		return nil
	end

	local args = { ... }

	return UE.safe("call " .. tostring(method_name), function()
		local method = obj[method_name]
		if method == nil then
			return nil
		end
		return method(obj, table.unpack(args))
	end, nil)
end

function UE.contains(text, needle)
	if text == nil or needle == nil then
		return false
	end
	return string.find(string.lower(tostring(text)), string.lower(tostring(needle)), 1, true) ~= nil
end

function UE.contains_any(text, patterns)
	if patterns == nil then
		return false
	end

	for _, pattern in ipairs(patterns) do
		if UE.contains(text, pattern) then
			return true
		end
	end

	return false
end

function UE.append_all(target, source)
	if source == nil then
		return
	end

	for _, value in ipairs(source) do
		target[#target + 1] = value
	end
end

function UE.static_default(path)
	local obj = UE.safe("StaticFindObject " .. path, function()
		return StaticFindObject(path)
	end, nil)

	return UE.unwrap(obj)
end

function UE.find_first(class_name)
	local obj = UE.safe("FindFirstOf " .. class_name, function()
		return FindFirstOf(class_name)
	end, nil)

	if UE.is_usable_object(obj) then
		return UE.unwrap(obj)
	end
	return nil
end

function UE.get_location(actor)
	actor = UE.unwrap(actor)
	if not UE.is_usable_object(actor) then
		return nil
	end

	return UE.safe("get_location", function()
		if actor.K2_GetActorLocation ~= nil then
			return actor:K2_GetActorLocation()
		end
		if actor.GetActorLocation ~= nil then
			return actor:GetActorLocation()
		end

		local root = UE.unwrap(actor.RootComponent)
		if UE.is_usable_object(root) and root.K2_GetComponentLocation ~= nil then
			return root:K2_GetComponentLocation()
		end

		return nil
	end, nil)
end

function UE.distance_squared(a, b)
	if a == nil or b == nil then
		return nil
	end

	local dx = (a.X or a.x or 0.0) - (b.X or b.x or 0.0)
	local dy = (a.Y or a.y or 0.0) - (b.Y or b.y or 0.0)
	local dz = (a.Z or a.z or 0.0) - (b.Z or b.z or 0.0)

	return dx * dx + dy * dy + dz * dz
end

function UE.within(actor, origin, radius)
	local loc = UE.get_location(actor)
	local d2 = UE.distance_squared(loc, origin)
	return d2 ~= nil and d2 <= radius * radius
end

function UE.number_value(value)
	value = UE.unwrap(value)

	if type(value) == "number" then
		return value
	end

	local parsed = tonumber(tostring(value))
	if parsed ~= nil then
		return parsed
	end

	return nil
end

function UE.bool_value(value)
	value = UE.unwrap(value)
	return value == true or value == 1
end

function UE.bool_prop(obj, prop)
	local value = UE.safe(prop, function()
		return UE.unwrap(obj)[prop]
	end, false)

	return UE.bool_value(value)
end

function UE.is_destroyed_or_pending_kill(actor)
	actor = UE.unwrap(actor)
	if not UE.is_usable_object(actor) then
		return true
	end

	if UE.bool_prop(actor, "bActorIsBeingDestroyed") then
		return true
	end
	if UE.call(actor, "IsActorBeingDestroyed") == true then
		return true
	end
	if UE.call(actor, "IsPendingKill") == true then
		return true
	end
	if UE.call(actor, "IsValidLowLevel") == false then
		return true
	end

	return false
end

function UE.is_picked_up_or_disabled(actor)
	actor = UE.unwrap(actor)
	if not UE.is_usable_object(actor) then
		return true
	end
	if UE.bool_prop(actor, "bHasBeenPickedUp") then
		return true
	end
	if UE.bool_prop(actor, "PickupDisabled") then
		return true
	end
	if UE.is_destroyed_or_pending_kill(actor) then
		return true
	end
	return false
end

function UE.is_actor_allowed(actor, names)
	return UE.contains_any(UE.actor_name(actor), names)
end

return UE
