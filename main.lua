--imports
local screen
--locals
local windowMode
--functions
local function getWindowMode()
	return windowMode
end

local switchMainscreen

local switchGamescreen = function()
	screen = dofile("gamescreen.lua")
	screen.load({
		getWindowMode = getWindowMode,
		switchMainscreen = switchMainscreen})
end

switchMainscreen = function()
	screen = dofile("mainscreen.lua")
	screen.load({
		getWindowMode = getWindowMode,
		switchGamescreen = switchGamescreen})
end

function love.load()
	windowMode = {x = 800, y = 480, borderless = true}
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
	switchMainscreen()
end