AddCSLuaFile()
urpgb.load = urpgb.load or {}

-- thanks to chessnut for this code (from nutscript)

function urpgb.load.include(fileName, state)
	if (!fileName) then
		error("No file name specified for including.")
	end

	-- Only include server-side if we're on the server.
	if ((state == "server" or fileName:find("sv_")) and SERVER) then
		include(fileName)
	-- Shared is included by both server and client.
	elseif (state == "shared" or fileName:find("sh_")) then
		if (SERVER) then
			-- Send the file to the client if shared so they can run it.
			AddCSLuaFile(fileName)
		end

		include(fileName)
	-- File is sent to client, included on client.
	elseif (state == "client" or fileName:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	end
end

-- Include files based off the prefix within a directory.
function urpgb.load.include_dir(directory, fromLua, recursive)
	local baseDir = "urpgb"
	baseDir = baseDir.."/gamemode/"
	
	if recursive then
		local function AddRecursive(folder)
			local files, folders = file.Find(folder.."/*", "LUA")
			if (!files) then MsgN("Warning! This folder is empty!") return end

			for k, v in pairs(files) do
				urpgb.load.include(folder .. "/" .. v)
			end

			for k, v in pairs(folders) do
				AddRecursive(folder .. "/" .. v)
			end
		end
		AddRecursive((fromLua and "" or baseDir)..directory)
	else
		-- Find all of the files within the directory.
		for k, v in ipairs(file.Find((fromLua and "" or baseDir)..directory.."/*.lua", "LUA")) do
			-- Include the file from the prefix.
			urpgb.load.include(directory.."/"..v)
		end
	end
end

function urpgb.load.begin()
	urpgb.load.include("modules/sv_database.lua")
	
	urpgb.load.include_dir("gui")
	urpgb.load.include_dir("hooks")
	urpgb.load.include_dir("libraries")
	urpgb.load.include_dir("meta_objects")
	
	hook.Run("urpgb_boot_sequence")
end