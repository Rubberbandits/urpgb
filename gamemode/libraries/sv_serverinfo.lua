urpgb = urpgb or {}
urpgb.server = urpgb.server or {}
urpgb.server.host_names = {
	"haha cool server",
	"stop looking at me",
	"nothing to see here, move along",
	"this is not a roleplay server",
	"i hate tnb",
	"cool roleplay server",
	"bad roleplay server",
	"why does it keep changing?",
}
urpgb.server.game_descriptions = {
	"stalker roleplay",
	"tnb",
	"bad roleplay",
	"flexevent",
	"100 Rads",
	"this isnt a gamemode",
	"ronjon",
	"good roleplay",
}

function urpgb.server.setname(name)
	RunConsoleCommand("hostname", name)
end

function urpgb.server.set_game_description(description)
	urpgb.server.game_description = description
end

function urpgb.server.get_game_description()
	return urpgb.server.game_description or urpgb.schema.loaded.name
end

function GM:GetGameDescription()
	return urpgb.server.get_game_description()
end

hook.Add("Think", "urpgb_rotate_hostname", function()
	if urpgb.server.host_names then
		if !urpgb.server.last_hostname_time then
			urpgb.server.last_hostname_time = CurTime()
		end

		if CurTime() - urpgb.server.last_hostname_time >= 5 then
			urpgb.server.setname(table.Random(urpgb.server.host_names))
			urpgb.server.set_game_description(table.Random(urpgb.server.game_descriptions))
		end
	end
end)