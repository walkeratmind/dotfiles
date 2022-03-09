

-- Apparently the name of this module is given as an argument when it is
-- required, and apparently we get that argument with three dots.
local module_name = ... or "config"

require("config.telescope")
require("config.debugger")

P = function(v)
	print(vim.inspect(v))
	return v
end

if pcall(require, "plenary") then
	RELOAD = require("plenary.reload").reload_module

	R = function(name)
		RELOAD(name)
		return require(name)
	end
end
