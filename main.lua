local gamescreen
local windowMode

local function getWindowMode()
	return windowMode
end

function love.load()
	windowMode = {x = 800, y = 480, borderless = true}
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
	gamescreen = dofile("gamescreen.lua")
	gamescreen.load({getWindowMode = getWindowMode})
end



