urpgb = urpgb or {}
urpgb.item = urpgb.item or {}
urpgb.item.cache = urpgb.item.cache or {}

local item = {}
item.__tostring = function(self)
	return "item ["..self.id.."]"
end
item.__call = function(self)

end

urpgb.item.object = item

hook.Add("urpgb_auto_refesh", "item_object_refresh", function()

end)