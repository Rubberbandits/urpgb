urpgb = urpgb or {}
urpgb.schema = urpgb.schema or {}
urpgb.schema.loaded = urpgb.schema.loaded or {}

function urpgb.schema.load()
	SCHEMA = {}
	urpgb.load.include_dir(engine.ActiveGamemode().."/schema", true, true)
	urpgb.schema.loaded = SCHEMA
	SCHEMA = nil

	hook.Run("urpgb_schema_loaded")
end

hook.Add("urpgb_boot_sequence", "urpgb.load_schema", urpgb.schema.load)