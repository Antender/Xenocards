--imports
local imports

local function mousepressed(x,y,button)
	if imports.containsButton(x,y) then
		imports.switchGamescreen()
	end
end

local function keyreleased(button)
	if button == "escape" then
		love.event.quit()
	end
end

--exports
local exports = {}

function exports.load(_imports)
	imports = _imports
	love.mousepressed = mousepressed
	love.keyreleased = keyreleased
end

return exports