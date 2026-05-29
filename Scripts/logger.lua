local Logger = {
	prefix = "[AutoHarvest] ",
	config = nil,
}

function Logger.configure(config)
	Logger.config = config
end

local function should_log()
	return Logger.config == nil or Logger.config.Log == true
end

local function should_debug()
	return Logger.config ~= nil and Logger.config.Debug == true
end

local function write(level, message)
	print(Logger.prefix .. "[" .. level .. "] " .. tostring(message) .. "\n")
end

function Logger.error(message)
	if should_log() then
		write("ERROR", message)
	end
end

function Logger.info(message)
	if should_log() then
		write("INFO", message)
	end
end

function Logger.debug(message)
	if should_debug() then
		write("VERBOSE", message)
	end
end

return Logger
