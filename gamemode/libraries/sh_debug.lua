urpgb = urpgb or {}
urpgb.debug = urpgb.debug or {}
urpgb.debug.slot = urpgb.debug.slot or 0

urpgb.debug.enabled = true

if SERVER then
	util.AddNetworkString("urpgb.send_debug")
else
	net.Receive("urpgb.send_debug", function(len)
		local col = net.ReadColor()
		local str = net.ReadString()

		urpgb.debug.log(col, str)
	end)
end

function urpgb.debug.log(color, str, ...)
	if !urpgb.debug.enabled then return end

	MsgC(color, string.format(str, ...))

	if SERVER then
		net.Start("urpgb.send_debug")
			net.WriteColor(color)
			net.WriteString(string.format(str, ...))
		net.Broadcast()
	end
end