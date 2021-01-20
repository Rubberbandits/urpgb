urpgb = urpgb or {}
urpgb.config = urpgb.config or {}

urpgb.database.auth_info.primary = {}
urpgb.database.auth_info.primary.host = "localhost"
urpgb.database.auth_info.primary.username = "root"
urpgb.database.auth_info.primary.password = ""
urpgb.database.auth_info.primary.database = "test"
urpgb.database.auth_info.primary.on_success = function(db)
	local data = urpgb.database.query("primary", "SHOW TABLES LIKE 'urpgb_characters';")
	if #data == 0 then
		local character_table = {}
		for k,v in next, urpgb.character.vars do
			character_table[#character_table + 1] = { v.key, v.data_type }
		end
		
		urpgb.database.create_table("primary", "urpgb_characters", character_table)
		urpgb.database.create_table("primary", "urpgb_items", {
			{ "CharID", "INT NOT NULL" },
		})
		
		urpgb.debug.log(Color(0,255,0), "Running initial setup for primary database...\n")
	end
end