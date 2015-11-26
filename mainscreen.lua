--imports
local imports
local background

--locals
local pos = {}
--functions
local function draw()
	background.draw()
	love.graphics.draw(startButton,pos.x,pos.y)
end

local function update(dt)
end

local function containsButton(x,y)
	return x >= pos.x and x <= (pos.x + 324) and y >= pos.y and y <= (pos.y + 117)
end

local function mousepressed(x,y,button)
	if containsButton(x,y) then
		imports.switchGamescreen()
	end
end

local function keyreleased(button)
	if button == "escape" then
		love.event.quit()
	end
end

--export
local mainscreen = {}
function mainscreen.load(_imports)
	imports = _imports
	background = dofile("gamescreen/background.lua")
	background.load(nil)
	startButton = love.graphics.newImage("mainscreen/start.png")
	local windowMode = imports.getWindowMode()
	pos.x = windowMode.x / 2 - 324 / 2
	pos.y = windowMode.y / 2 - 117 / 2
	love.update = update
	love.draw = draw
	love.mousepressed = mousepressed
	love.keyreleased = keyreleased
end

return mainscreen