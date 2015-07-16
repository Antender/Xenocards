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
			x_offset = (i % (spriteCountHorizontal)) * (spriteWidth + paddingHorizontal)
			y_offset = ({math.modf(i / (spriteCountHorizontal))})[1] * (spriteHeight + paddingVertical)
			print(x_offset / spriteWidth, y_offset / spriteHeight)
			quad = love.graphics.newQuad(x_offset, y_offset, spriteWidth, spriteHeight, atlas:getDimensions())
			spriteMeta = {quad, 0, 0}
			table.insert(spriteMetaTable, spriteMeta)
		end
	end
	
	return spriteMetaTable
end

function love.load()
	nextCard = 1
	windowWidth = love.window.getWidth()
	windowHeight = love.window.getHeight()
	atlas = love.graphics.newImage("cardsAtlas.png")
	spriteMetaTable = newSpriteMetaTable(atlas, 58, 81, 117, 0, 0)
	spriteBatch = love.graphics.newSpriteBatch(atlas, 58, "dynamic")
end

function love.update(dt)
	if love.keyboard.isDown( "r" ) then
		nextCard = 1
		spriteBatch:clear()
	elseif love.keyboard.isDown( "escape" ) then
		love.event.quit()
	end
end

function love.draw()
	spriteMetaTable[nextCard][2] = love.math.random(windowWidth - 73)
	spriteMetaTable[nextCard][3] = love.math.random(windowHeight - 98)
	spriteBatch:add(unpack(spriteMetaTable[nextCard]))
	love.graphics.draw(spriteBatch, 0, 0)
	if (nextCard <= 58) then
		nextCard = nextCard + 1
	else
		spriteBatch:clear()
		nextCard = 1
	end
end