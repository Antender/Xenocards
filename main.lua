local screen
local windowMode

local function getWindowMode()
	return windowMode
end

function love.load()
	windowMode = {x = 800, y = 480, borderless = true}
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
	switchMainscreen()
end

function switchMainscreen()
	screen = dofile("mainscreen.lua")
	screen.load({
		getWindowMode = getWindowMode,
		switchGamescreen = switchGamescreen})
end

function switchGamescreen()
	screen = dofile("gamescreen.lua")
	screen.load({
		getWindowMode = getWindowMode,
		switchMainscreen = switchMainscreen})
end