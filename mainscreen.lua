--imports
local imports
local background
local input
--locals
local pos = {}
--functions
local function draw()
	background.draw()
	love.graphics.draw(startButton, pos.x, pos.y)
	love.graphics.draw(multiplayerButton, pos.x, pos.y + 70)
end

local function update(dt)
end

--exports
local exports = {}

function exports.load(_imports)
	imports = _imports
	background = dofile("common/background.lua")
	background.load(nil)
	input = dofile("mainscreen/input.lua")
	input.load({
		switchGamescreen = imports.switchGamescreen,
		containsButton = containsButton})
	startButton = love.graphics.newImage("mainscreen/start.png")
    multiplayerButton = love.graphics.newImage("mainscreen/start.png")
	local windowMode = imports.getWindowMode()
	pos.x = windowMode.x / 2 - 324 / 2
	pos.y = windowMode.y / 2 - 117 / 2
	love.update = update
	love.draw = draw
end

return exports