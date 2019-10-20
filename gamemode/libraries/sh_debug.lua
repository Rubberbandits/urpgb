urpgb = urpgb or {}
urpgb.debug = urpgb.debug or {}

urpgb.debug.enabled = true

function urpgb.debug.log(color, str, ...)
	if !urpgb.debug.enabled then return end
	
	MsgC(color, string.format(str, ...))
end