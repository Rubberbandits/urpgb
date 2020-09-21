urpgb = urpgb or {}
urpgb.character = urpgb.character or {}
urpgb.character.vars = urpgb.character.vars or {}

function urpgb.character.get_constructor()
	local constructor = {}
	for _,data in next, urpgb.character.vars do
		constructor[data.key] = data.default
	end
	
	return constructor
end

-- ОЧЕНЬ ПЛОХО
function urpgb.character.get_insert_query()
	local query = "INSERT INTO urpgb_characters ("
	local count = 1
	for k,v in next, urpgb.character.vars do
		if count != table.Count(urpgb.character.vars) then
			query = query..k..", "
		else
			query = query..k
		end
		
		count = count + 1
	end
	query = query..") VALUES ("
	count = 1
	for k,v in next, urpgb.character.vars do
		if count != table.Count(urpgb.character.vars) then
			query = query.."?, "
		else
			query = query.."?"
		end
		
		count = count + 1
	end
	query = query..");"
	
	return query
end

function urpgb.character.create_var(data)
	urpgb.character.vars[data.key] = data
end

urpgb.character.create_var({
	key = "steam_id",
	default = "",
	data_type = "VARCHAR (256)",
})

urpgb.character.create_var({
	key = "name",
	default = "Unconnected",
	data_type = "VARCHAR (256)",
})

urpgb.character.create_var({
	key = "data",
	default = {},
	data_type = "VARCHAR (8192) DEFAULT '{}'",
})

/*
	Networking
*/

if CLIENT then
	local function urpgb_character_set_var(len)
		
	end
	net.Receive("urpgb_character_set_var", urpgb_character_set_var)
end