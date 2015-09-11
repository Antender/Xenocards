function newSpriteMetaTable(atlas, spriteCount, spriteWidth, spriteHeight, paddingHorizontal, paddingVertical)
	--This function is meant to be explicitly strict for now
	x_offset = 0
	y_offset = 0
	spriteMetaTable = {}
	spriteCountHorizontal = atlas:getWidth() / (spriteWidth + paddingHorizontal)
	spriteCountVertical = atlas:getHeight() / (spriteHeight + paddingVertical)

	if ({math.modf(spriteCountHorizontal)})[2] ~= 0 or ({math.modf(spriteCountVertical)})[2] ~= 0 then
		love.window.showMessageBox("Error", "Atlas is corrupted: size multiplicity mismatch", "error", true)
		love.event.quit()
	else
		for i = 0, spriteCount do
			x_offset = (i % spriteCountHorizontal) * (spriteWidth + paddingHorizontal)
			y_offset = ({math.modf(i / spriteCountHorizontal)})[1] * (spriteHeight + paddingVertical)
			quad = love.graphics.newQuad(x_offset, y_offset, spriteWidth, spriteHeight, ({atlas:getDimensions()})[1], ({atlas:getDimensions()})[2])
			spriteMeta = {quad, 0, 0}
			table.insert(spriteMetaTable, spriteMeta)
		end
	end
	
	return spriteMetaTable
end

function love.load()
	nextCard = 1
	nextX = 0
	nextY = 0
	windowWidth = love.window.getWidth()
	windowHeight = love.window.getHeight()
	atlas = love.graphics.newImage("cardsAtlas.png")
	spriteMetaTable = newSpriteMetaTable(atlas, 58, 81, 117, 0, 0)
	spriteBatch = love.graphics.newSpriteBatch(atlas, 58, "dynamic")
	love.window.setMode( 1680, 1049, {borderless = true} )
	deal()
end

function love.update(dt)
	if love.keyboard.isDown( "r" ) then
		restart()
	elseif love.keyboard.isDown( "escape" ) then
		love.event.quit()
	end
end

function deal()
	deck = {}

	--Populate
	for i = 1, 52 do
		deck[i] = i
	end
	--Shuffle
	for i = 1, 52 do
		randomIndex = love.math.random(i, 52)
		j = deck[i]
		deck[i] = deck[randomIndex]
		deck[randomIndex] = j
	end
	
end

function restart()
	nextCard = 1
	spriteBatch:clear()
	nextX = 0
	nextY = 0
	deal()
end

function love.draw()
	if (nextCard <= 52) then
		spriteMetaTable[deck[nextCard]][2] = nextX * 81
		spriteMetaTable[deck[nextCard]][3] = nextY * 117
		spriteBatch:add(unpack(spriteMetaTable[deck[nextCard]]))
		love.graphics.draw(spriteBatch, 0, 0)

		nextX = nextX + 1
		
		if(nextX > 12) then
			nextX = 0
			nextY = nextY + 1
		end
		
		nextCard = nextCard + 1
	else
		love.graphics.draw(spriteBatch, 0, 0)
	end
end