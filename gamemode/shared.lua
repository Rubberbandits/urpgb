urpgb = urpgb or {}

include("sh_load.lua")

urpgb.load.begin()

hook.Run("urpgb_loading_complete")

function GM:OnReloaded()
	hook.Run("urpgb_auto_refresh")
end