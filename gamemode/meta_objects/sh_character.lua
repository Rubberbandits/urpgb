urpgb = urpgb or {}
urpgb.character = urpgb.character or {}
urpgb.character.cache = urpgb.character.cache or {}
urpgb.character.virtual = urpgb.character.virtual or {}
urpgb.character.object = urpgb.character.object or {}

urpgb.character.object.is_character = true
urpgb.character.object.__index = urpgb.character.object
urpgb.character.object.__tostring = function(self)
	return "character ["..self.id or "0".."]"
end

function urpgb.character.object:new(data)
	local character = urpgb.character.get_constructor()
	local data = data or {}
	setmetatable(character, urpgb.character.object)
	
	table.Merge(character, data)
	
	for k,v in next, character do
		if !isfunction(v) then
			character["get_"..k] = function(self)
				return self:get_var(k, self[k])
			end
			character["set_"..k] = function(self, value, var, network)
				self[k] = value
				
				if var then
					self:set_var(k, value, nil, network)
				end
			end
		end
	end
	
	if data.id then
		urpgb.character.cache[data.id] = character
	else
		urpgb.character.virtual[#urpgb.character.virtual + 1] = character
	end
	
	return character
end

function urpgb.character.object:get_owner()
	return self.owner
end

function urpgb.character.object:get_id()
	return self.id
end

function urpgb.character.object:set_var(key, value, no_save, network)
	self.data[key] = value

	if SERVER then
		if network then
			netstream.Start(self:get_owner(), "urpgb_character_set_var", key, value)
		end
		
		if !no_save then
			self:save("data", self.data)
		end
	end
end

function urpgb.character.object:get_var(key, fallback)
	return self.data[key] or fallback
end

if SERVER then
	function urpgb.character.object:save(key, value)
		urpgb.database.commit_data("primary", string.format("UPDATE urpgb_characters SET %s = ? WHERE id = ?;", key), value, self:get_id())
	end
	
	function urpgb.character.object:commit()
		local query = urpgb.character.get_insert_query()
		local arguments = {}
		for k,v in next, urpgb.character.vars do
			arguments[#arguments + 1] = self["get_"..k](self)
		end
		
		local result = urpgb.database.query("primary", query, unpack(arguments))
		self.id = result.last_insert
	end
end

setmetatable(urpgb.character.object, {__call = urpgb.character.object.new})