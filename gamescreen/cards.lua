--imports
local imports
--locals
local atlas = love.graphics.newImage("gamescreen/atlas.png")
local anchors = {
	decks = {}, 
	hands = {{},{}}, 
	targets = {}}
local spriteMetaTable
local spriteBatch = love.graphics.newSpriteBatch(atlas, 12, "dynamic")
local recalculateAnchors = false
local windowWidth, windowHeight

--functions
local function newSpriteMetaTable(atlas, spriteCount, spriteWidth, spriteHeight, paddingHorizontal, paddingVertical)
	--This function is meant to be explicitly strict for now.
	local x_offset = 0
	local y_offset = 0
	local spriteMetaTable = {}
	local horizontalCount = atlas:getWidth() / (spriteWidth + paddingHorizontal)
	local verticalCount = atlas:getHeight() / (spriteHeight + paddingVertical)
	local quad = nil
	local spriteMeta = nil

	if ({math.modf(horizontalCount)})[2] ~= 0 or ({math.modf(verticalCount)})[2] ~= 0 then
		love.window.showMessageBox("Error", "Atlas is corrupted: size multiplicity mismatch", "error", true)
		love.event.quit()
	else
		for sprite = 0, spriteCount do
			x_offset = (sprite % horizontalCount) * (spriteWidth + paddingHorizontal)
			y_offset = ({math.modf(sprite / horizontalCount)})[1] * (spriteHeight + paddingVertical)
			quad = love.graphics.newQuad(x_offset, y_offset, spriteWidth, spriteHeight, ({atlas:getDimensions()})[1], ({atlas:getDimensions()})[2])
			spriteMeta = {quad, 0, 0}
			table.insert(spriteMetaTable, spriteMeta)
		end
	end
	
	return spriteMetaTable
end

local function setupAnchors()
	local grid = dofile("common/grid.lua").new(windowWidth, windowHeight,6,3,0,0)
	
	local xshift = (windowWidth / 6 - 81) / 2
	local yshift = (windowHeight / 3 - 117) / 2
	
	anchors.decks[1] = {x = grid.x[6] + xshift, y = grid.y[3] + yshift}
	anchors.decks[2] = {x = grid.x[1] + xshift, y = grid.y[1] + yshift}
	anchors.hands[2][1] = {x = grid.x[2] + xshift, y = grid.y[1] + yshift}
	anchors.hands[2][2] = {x = grid.x[3] + xshift, y = grid.y[1] + yshift}
	anchors.hands[2][3] = {x = grid.x[4] + xshift, y = grid.y[1] + yshift}
	anchors.hands[2][4] = {x = grid.x[5] + xshift, y = grid.y[1] + yshift}
	anchors.hands[1][1] = {x = grid.x[2] + xshift, y = grid.y[3] + yshift}
	anchors.hands[1][2] = {x = grid.x[3] + xshift, y = grid.y[3] + yshift}
	anchors.hands[1][3] = {x = grid.x[4] + xshift, y = grid.y[3] + yshift}
	anchors.hands[1][4] = {x = grid.x[5] + xshift, y = grid.y[3] + yshift}
	anchors.targets[1] = {x = grid.x[3] + xshift, y = grid.y[2] + yshift}
	anchors.targets[2] = {x = grid.x[4] + xshift, y = grid.y[2] + yshift}
end

local function drawCard(sprite,pos)
	spriteMetaTable[sprite][2] = pos.x
	spriteMetaTable[sprite][3] = pos.y
	spriteBatch:add(unpack(spriteMetaTable[sprite]))
end

local function compose()
	local sprite
	if recalculateAnchors then
		setupAnchors()
	end
	spriteBatch:clear()
	--Decks
	for deck = 1, 2 do
		if imports.getDecksSizes()[deck] > 0 then
			sprite = 53
		else
			sprite = 59
		end
		drawCard(sprite,anchors.decks[deck])
	end
	--Hands
	for player = 1, 2 do
		for position = 1, 4 do
			drawCard(imports.getHands()[player][position],anchors.hands[player][position])
		end
	end
	--Targets
	for target = 1, 2 do
		drawCard(imports.getTargets()[target],anchors.targets[target])
	end
end

--exports
local exports = {}

function exports.load(_imports)
	imports = _imports
	spriteMetaTable = newSpriteMetaTable(atlas, 59, 81, 117, 0, 0)
	windowWidth, windowHeight = love.window.getDimensions()
	setupAnchors()
end

function exports.draw()
	compose()
	love.graphics.draw(spriteBatch, 0, 0)
end

function exports.isCardHovered(x, y, player, position)
	cardCoordinates = anchors.hands[player][position];
	return (x >= cardCoordinates.x and y >= cardCoordinates.y and x <= (cardCoordinates.x + 80) and y <= (cardCoordinates.y + 117))
end

return exports
