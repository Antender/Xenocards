function love.load()
	keyPressed = nil
	handsSizes = {0, 0}
	decksSizes = {0, 0}
	hands = {{}, {}}
	targets = {}
	nextCard = 1
	nextX = 0
	nextY = 0
	UIgrid = {{}, {}} --[1] — X, [2] — Y.
	UIanchors = {{1, 1}, {6, 5}}
	BGgrid = {}
	recalculateBGgrid = false
	recalculateUIgrid = false
	background = love.graphics.newImage("background.png")
	cardsAtlas = love.graphics.newImage("cardsAtlas.png")
	backgroundSpriteBatch = love.graphics.newSpriteBatch(background, 50, "dynamic")
	cardsSpriteMetaTable = newSpriteMetaTable(cardsAtlas, 59, 81, 117, 0, 0)
	cardsSpriteBatch = love.graphics.newSpriteBatch(cardsAtlas, 12, "dynamic")
	love.window.setMode( 1680, 1049, {borderless = true} )
	windowWidth = love.window.getWidth()
	windowHeight = love.window.getHeight()
	setUIgrid()
	setBGgrid()
	BGcompose()
	deal()
end

function love.update(dt)
	if love.keyboard.isDown( "z" ) then
		restart()
	elseif love.keyboard.isDown( "escape" ) then
		love.event.quit()

	--A horrendous horde of gruesome regular expressions stormed through here. There's gotta be a better way.
	elseif love.keyboard.isDown( "1" ) then
		keyPressed = "1"
	elseif love.keyboard.isDown( "2" ) then
		keyPressed = "2"
	elseif love.keyboard.isDown( "3" ) then
		keyPressed = "3"
	elseif love.keyboard.isDown( "4" ) then
		keyPressed = "4"
	elseif love.keyboard.isDown( "5" ) then
		keyPressed = "5"
	elseif love.keyboard.isDown( "6" ) then
		keyPressed = "6"
	elseif love.keyboard.isDown( "7" ) then
		keyPressed = "7"
	elseif love.keyboard.isDown( "8" ) then
		keyPressed = "8"
	elseif love.keyboard.isDown( "q" ) then
		keyPressed = "q"
	elseif love.keyboard.isDown( "w" ) then
		keyPressed = "w"
	elseif love.keyboard.isDown( "e" ) then
		keyPressed = "e"
	elseif love.keyboard.isDown( "r" ) then
		keyPressed = "r"
	elseif love.keyboard.isDown( "t" ) then
		keyPressed = "t"
	elseif love.keyboard.isDown( "y" ) then
		keyPressed = "y"
	elseif love.keyboard.isDown( "u" ) then
		keyPressed = "u"
	elseif love.keyboard.isDown( "i" ) then
		keyPressed = "i"

	elseif (not love.keyboard.isDown( "1" )) and keyPressed == "1" then
		playCard(1, 1, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "2" )) and keyPressed == "2" then
		playCard(1, 2, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "3" )) and keyPressed == "3" then
		playCard(1, 3, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "4" )) and keyPressed == "4" then
		playCard(1, 4, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "5" )) and keyPressed == "5" then
		playCard(1, 1, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "6" )) and keyPressed == "6" then
		playCard(1, 2, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "7" )) and keyPressed == "7" then
		playCard(1, 3, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "8" )) and keyPressed == "8" then
		playCard(1, 4, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "q" )) and keyPressed == "q" then
		playCard(2, 1, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "w" )) and keyPressed == "w" then
		playCard(2, 2, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "e" )) and keyPressed == "e" then
		playCard(2, 3, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "r" )) and keyPressed == "r" then
		playCard(2, 4, 1)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "t" )) and keyPressed == "t" then
		playCard(2, 1, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "y" )) and keyPressed == "y" then
		playCard(2, 2, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "u" )) and keyPressed == "u" then
		playCard(2, 3, 2)
		keyPressed = nil
	elseif (not love.keyboard.isDown( "i" )) and keyPressed == "i" then
		playCard(2, 4, 2)
		keyPressed = nil
	end
end

function love.draw()
	UIcompose()
	love.graphics.draw(backgroundSpriteBatch, 0, 0)
	love.graphics.draw(cardsSpriteBatch, 0, 0)
end

function setUIgrid()
	for i = 1, 7 do
		UIgrid[1][i] = windowWidth / 7 * i - 40
		if i < 7 then
			UIgrid[2][i] = windowHeight / 6 * i - 107
		end
	end
end

function setBGgrid()
	local x = 0
	local y = 0
	while x < windowWidth and y < windowHeight do
		table.insert(BGgrid, {x, y})
		x = x + background:getWidth()
		
		if x > windowWidth then
			x = 0
			y = y + background:getHeight()
		end
	end
end

function newSpriteMetaTable(atlas, spriteCount, spriteWidth, spriteHeight, paddingHorizontal, paddingVertical)
	--This function is meant to be explicitly strict for now
	local x_offset = 0
	local y_offset = 0
	local cardsSpriteMetaTable = {}
	local spriteCountHorizontal = atlas:getWidth() / (spriteWidth + paddingHorizontal)
	local spriteCountVertical = atlas:getHeight() / (spriteHeight + paddingVertical)
	local quad = nil
	local spriteMeta = nil

	if ({math.modf(spriteCountHorizontal)})[2] ~= 0 or ({math.modf(spriteCountVertical)})[2] ~= 0 then
		love.window.showMessageBox("Error", "Atlas is corrupted: size multiplicity mismatch", "error", true)
		love.event.quit()
	else
		for i = 0, spriteCount do
			x_offset = (i % spriteCountHorizontal) * (spriteWidth + paddingHorizontal)
			y_offset = ({math.modf(i / spriteCountHorizontal)})[1] * (spriteHeight + paddingVertical)
			quad = love.graphics.newQuad(x_offset, y_offset, spriteWidth, spriteHeight, ({atlas:getDimensions()})[1], ({atlas:getDimensions()})[2])
			spriteMeta = {quad, 0, 0}
			table.insert(cardsSpriteMetaTable, spriteMeta)
		end
	end
	
	return cardsSpriteMetaTable
end

function deal()
	local deck1 = {}
	local deck2 = {}
	local randomIndex = nil

	--Populate
	for i = 1, 52 do
		deck1[i] = i
	end

	--Shuffle
	for i = 1, 52 do
		randomIndex = love.math.random(i, 52)
		j = deck1[i]
		deck1[i] = deck1[randomIndex]
		deck1[randomIndex] = j
	end

	--Split
	for i = 1, 26 do
		deck2[i] = deck1[i]
		deck1[i] = deck1[i + 26]
		deck1[i + 26] = nil
	end

	decks = {deck1, deck2}
	decksSizes = {26, 26}
	
	for i = 1, 2 do
		for j = 1, 4 do
			drawCard(i, j)
		end
	end
	
	handsSizes = {4, 4}
	
	resolve()
end

function popDeck(player)
	local card = decks[player][decksSizes[player]]
	
	if decksSizes[player] > 0 then
		table.remove(decks[player], decksSizes[player])
		decksSizes[player] = decksSizes[player] - 1
	else
		card = 59
	end
	return card
end

function playCard(player, position, target)
	if isValid(player, position, target) then
		targets[target] = hands[player][position]
		handsSizes[player] = handsSizes[player] - 1
		drawCard(player, position)
		isGameOver()
		
		if isStalemate() then
			resolve()
		end
	end
end

function isGameOver()
	local condition = false --false — none, 1 — first, 2 — second, 3 — both players win(draw).
	
	if handsSizes[1] == 0 and handsSizes[2] == 0 then
		condition = 3
	elseif handsSizes[1] == 0 then
		condition = 1
	elseif handsSizes[2] == 0 then
		condition = 2
	end
	
	if condition ~= false then --Placeholder for a return.
		gameOver(condition)
	end
end

function gameOver(condition)
	local message

	if condition == false then --Need to put a switch instead.
		message = "I AM ERROR"
	elseif condition == 1 then
		message = "First player won!"
	elseif condition == 2 then
		message = "Second player won!"
	elseif condition == 3 then
		message = "It's a draw!"
	end

	love.window.showMessageBox("Game Over", message, "info", true) --Needs to visually resolve first.
	restart()
end

function isStalemate()
	local invalidity = true

	for i = 1, 2 do
		for j = 1, 4 do
			for k = 1, 2 do
				if isValid(i, j, k) then
					invalidity = false
				end
			end
		end
	end
	return invalidity
end

function drawCard(player, position)
	local card = popDeck(player)
	
	if card ~= 59 then
		handsSizes[player] = handsSizes[player] + 1
	end
	
	hands[player][position] = card
end

function resolve()
	local candidates = {}

	for i = 1, 2 do
		if decksSizes[i] == 0 then
			for j = 1, 4 do
				if hands[i][j] ~= 59 then
					candidates[i] = hands[i][j]
					hands[i][j] = 59
					handsSizes[i] = handsSizes[i] - 1
					isGameOver()
					break --Might be causing an unknown bug.
				end
			end
		else
		candidates[i] = popDeck(i)
		end
	end

	targets[1] = candidates[2]
	targets[2] = candidates[1]

	if isStalemate() then
		resolve()
	end
end

function isValid(player, position, target)
	local validity = nil

	if hands[player][position] == 59 then
		validity = false
	else
		local difference = math.abs(hands[player][position] % 13 - targets[target] % 13)
		validity = difference == 1 or difference == 12
	end
	
	return validity
end

function restart()
	deal()
end

function BGcompose()
	if recalculateBGgrid then
		setBGgrid()
	end
	
	for i = 1, #BGgrid do
	backgroundSpriteBatch:add(unpack(BGgrid[i]))
	end
end

function UIcompose()
	local sprite
	
	if recalculateUIgrid then
		setUIgrid()
	end

	cardsSpriteBatch:clear()

	--Decks
	for i = 1, 2 do
		if decksSizes[i] > 0 then
			sprite = 53
		else
			sprite = 59
		end

		cardsSpriteMetaTable[sprite][2] = UIgrid[1][UIanchors[i][1]]
		cardsSpriteMetaTable[sprite][3] = UIgrid[2][UIanchors[i][2]]
		cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[sprite]))
	end

	--Hands
	for i = 1, 4 do
		for j = 1, 2 do
			cardsSpriteMetaTable[hands[j][i]][2] = UIgrid[1][i + 1]
			cardsSpriteMetaTable[hands[j][i]][3] = UIgrid[2][j * 2]
			cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[hands[j][i]]))
		end
	end
	
	--Targets
	for i = 1, 2 do
		cardsSpriteMetaTable[targets[i]][2] = UIgrid[1][i + 2]
		cardsSpriteMetaTable[targets[i]][3] = UIgrid[2][3]
		cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[targets[i]]))
	end
end
