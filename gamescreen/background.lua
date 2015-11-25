--imports
local imports

--locals
local backgroundImage = love.graphics.newImage("gamescreen/background.png")
local grid = {}
local spriteBatch = love.graphics.newSpriteBatch(backgroundImage, 50, "dynamic")
local windowHeight, windowWidth
local recalculateGrid = false

--functions
local function calculateGrid()
	local x = 0
	local y = 0
	while y < windowHeight do
		table.insert(grid, {x, y})
		x = x + backgroundImage:getWidth()
		
		if x >= windowWidth then
			x = 0
			y = y + backgroundImage:getHeight()
		end
	end
end

--export
local background = {}

function background.load(_imports)
	imports = _imports
	windowHeight, windowWidth = love.graphics.getDimensions()
	calculateGrid()
end

local function compose()
	if recalculateGrid then
		calculateGrid()
	end
	
	for tile = 1, #grid do
		spriteBatch:add(unpack(grid[tile]))
	end
end

function background.draw()
	compose()
	love.graphics.draw(spriteBatch, 0, 0)
end

return background