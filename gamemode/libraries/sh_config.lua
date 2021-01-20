urpgb = urpgb or {}
urpgb.config = urpgb.config or {}
urpgb.config.data = urpgb.config.data or {}
urpgb.config.main = urpgb.config.main or {}

function urpgb.config.read(config)
	local data = file.Read(engine.ActiveGamemode().."/configs/"..config..".json")

	if !data then
		urpgb.debug.log(Color(255,0,0), "Cannot find configuration file '%s'\n", config)
		return
	end

	urpgb.config.data[config] = util.JSONToTable(data)
	hook.Run("urpgb_config_loaded", config, urpgb.config.data[config])
	return true
end

function urpgb.config.write(config)
	if !urpgb.config.data[config] then
		urpgb.config.data[config] = {}
		urpgb.debug.log(Color(0,255,0), "Creating configuration file '%s'\n", config)
	end

	if !file.IsDir(engine.ActiveGamemode().."/configs", "DATA") then
		file.CreateDir(engine.ActiveGamemode().."/configs")
	end

	file.Write(engine.ActiveGamemode().."/configs/"..config..".json", util.TableToJSON(urpgb.config.data[config]))
	hook.Run("urpgb_config_saved", config)
end

function urpgb.config.get(key, default, config)
	if !config then
		config = "main"
	end

	return urpgb.config.data[config] and urpgb.config.data[config][key] or default or (urpgb.config[config] and urpgb.config[config][key] and urpgb.config[config][key].default)
end

function urpgb.config.set(key, value, config, no_save)
	if !config then
		config = "main"
	end

	if !urpgb.config.data[config] then
		urpgb.config.data[config] = {}
	end

	urpgb.config.data[config][key] = value

	if urpgb.config[config] and urpgb.config[config][key] and urpgb.config[config][key].on_change then
		urpgb.config[config][key].on_change(nil, key, urpgb.config[config][key].current_value, value)
		urpgb.config[config][key].current_value = value
	end

	if !no_save then
		urpgb.config.write(config)
	end
end

function urpgb.config.create_entry(key, default, config, on_change, can_set)
	if !config then config = "main" end

	if !urpgb.config[config] then
		urpgb.config[config] = {}
	end

	if !urpgb.config.data[config] then
		urpgb.config.data[config] = {}
	end

	urpgb.config.data[config][key] = default
	urpgb.config[config][key] = {
		current_value = default, 
		default = default,
		on_change = on_change or function(ply, key, old_value, new_value)

		end,
		can_set = can_set or function(ply, key, value)
			return true
		end
	}
end

hook.Add("urpgb_boot_sequence", "urpgb_config_load", function()
	urpgb.load.include_dir("config")

	hook.Run("urpgb_load_config")
end)

hook.Add("ShutDown", "urpgb_config_save", function()
	hook.Run("urpgb_save_config")
end)

function GM:urpgb_load_config()  
	if !file.Exists(engine.ActiveGamemode().."/configs/main.json", "DATA") then
		urpgb.config.write("main")
	end

	local files, dirs = file.Find(engine.ActiveGamemode().."/configs/*.json", "DATA")
	for _,file in ipairs(files) do
		urpgb.config.read(string.StripExtension(file))
	end
end

function GM:urpgb_save_config()
	for config,key in ipairs(urpgb.config.data) do
		urpgb.config.write(config)
	end
end