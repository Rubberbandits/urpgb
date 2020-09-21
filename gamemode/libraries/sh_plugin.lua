AddCSLuaFile();

/*
	New method for plugins:
	
	Instead of detouring hook.Call, we can simply loop through all functions in our gamemode table after loading them
	and adding them with hook.Add to the gamemode table.
*/

urpgb = urpgb or {}
urpgb.plugin = urpgb.plugin or {}
urpgb.plugin.index = urpgb.plugin.index or {}
local OldHookCall = hook.Call

function hook.Call(event_name, gamemode, ...)
	/*
		Returning any value besides nil from the hook's function will stop other hooks of the same event down the loop 
		from being executed. Only return a value when absolutely necessary and when you know what you are doing.
		
		It WILL break other addons.
	*/

	// First, we'll call all plugin hooks first.
	if gamemode then
		for _,plugin in next, urpgb.plugin.index do
			if !plugin[event_name] then continue end
			local result = plugin[event_name](plugin, ...)
			
			if result != nil then
				return result
			end
		end
	end
	
	// then we'll call old hook.Call.
	
	local result = OldHookCall(event_name, gamemode or gmod.GetGamemode(), ...)
	if result != nil then
		return result
	end
end

hook.Add("urpgb_boot_sequence", "urpgb.load_plugins", function()
	local plugin_files, plugin_dirs = file.Find(GM.FolderName.."/plugins/*", "LUA", "namedesc")
	if #plugin_files > 0 then
		for k,v in next, plugin_files do
			PLUGIN = {}
		
			urpgb.load.include(v)
			
			urpgb.plugin.index[string.StripExtension(v)] = PLUGIN
		end
	end
	if #plugin_dirs > 0 then
		for k,v in next, plugin_dirs do
			PLUGIN = {}
		
			urpgb.load.include_dir(GM.FolderName.."/plugins/"..v, true, true)
			
			urpgb.plugin.index[v] = PLUGIN
		end
	end
end)