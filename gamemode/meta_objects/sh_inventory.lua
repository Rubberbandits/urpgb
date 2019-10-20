urpgb = urpgb or {}
urpgb.inventory = urpgb.inventory or {}
urpgb.inventory.cache = urpgb.inventory.cache or {}

local inventory = {}
inventory.__tostring = function(self)
	return "inventory ["..self.id.."]"
end
inventory.__call = function(self)

end

urpgb.inventory.object = inventory

hook.Add("urpgb_auto_refesh", "inventory_object_refresh", function()

end)