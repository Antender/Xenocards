local input
function love.load()
    input = dofile("input.lua")
	input.load({
		deal = deal,
		enableTesting = enableTesting,
		playCard = playCard,
		isCardHovered = isCardHovered})
	gameState = 0 
	--States: 0 - game, 1 - draw, 2 - first player won, 3 - second player won, 4 - restart
	winMessage = "I AM ERROR"
	testing = {state = false, tries = 0, moves = 0, matches = 0, dumbness = ""}
	handsSizes = {0, 0}
	decksSizes = {0, 0}
	hands = {{59, 59, 59, 59}, {59, 59, 59 ,59}}
	targets = {59, 59}
	nextCard = 1
	nextX = 0
	nextY = 0
	UIanchors = {decks = {}, hands = {{},{}}, targets = {}}
	BGgrid = {}
	recalculateBGgrid = false
	recalculateUIgrid = false
	windowMode = {x = 800, y = 480, borderless = true}
	background = love.graphics.newImage("background.png")
	cardsAtlas = love.graphics.newImage("cardsAtlas.png")
	backgroundSpriteBatch = love.graphics.newSpriteBatch(background, 50, "dynamic")
	cardsSpriteMetaTable = newSpriteMetaTable(cardsAtlas, 59, 81, 117, 0, 0)
	cardsSpriteBatch = love.graphics.newSpriteBatch(cardsAtlas, 12, "dynamic")
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
	windowWidth, windowHeight = love.graphics.getDimensions()
	setUIanchors()
	setBGgrid()
	BGcompose()
	deal()
end

function love.update(dt)
	if testing.state then
		dumbAutoplay()
	end
	if gameState == 4 then
		if not testing.state then
			love.window.showMessageBox("Game Over", winMessage, "info", true)
		end
		deal()
	end
end

function enableTesting()
	testing.state = not testing.state
	windowMode.borderless = not windowMode.borderless
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
end

function love.draw()
	UIcompose()
	love.graphics.draw(backgroundSpriteBatch, 0, 0)
	love.graphics.draw(cardsSpriteBatch, 0, 0)
	if gameState == 1 or gameState == 2 or gameState == 3 then
		gameState = 4
	end
	if testing.state then
		testing.dumbness = string.format("%.f", ((testing.tries - testing.moves) / testing.tries * 100))
		love.window.setTitle("Tries:" .. testing.tries .. " Moves:" .. testing.moves .. " Matches:" .. testing.matches .. " Dumbness:" .. testing.dumbness .. "%") --Possibly instable.
	end
end

function dumbAutoplay()
	playCard(love.math.random(2), love.math.random(4), love.math.random(2))
	testing.tries = testing.tries + 1
end

function isCardHovered(x, y, player, position)
	cardCoordinates = UIanchors.hands[player][position];
	return (x >= cardCoordinates.x and y >= cardCoordinates.y and x <= (cardCoordinates.x + 80) and y <= (cardCoordinates.y + 117))
end

function setUIanchors()
	local UIgrid = {x = {}, y = {}}
	
	local xshift = (windowWidth / 6 - 81) / 2
	local yshift = (windowHeight / 3 - 117) / 2
	
	for column = 1, 6 do
		UIgrid.x[column] = windowWidth / 6 * (column - 1) + xshift
	end
	for column = 1, 3 do
		UIgrid.y[column] = windowHeight / 3 * (column - 1) + yshift
	end
	
	UIanchors.decks[1] = {x = UIgrid.x[6], y = UIgrid.y[3]}
	UIanchors.decks[2] = {x = UIgrid.x[1], y = UIgrid.y[1]}
	UIanchors.hands[2][1] = {x = UIgrid.x[2], y = UIgrid.y[1]}
	UIanchors.hands[2][2] = {x = UIgrid.x[3], y = UIgrid.y[1]}
	UIanchors.hands[2][3] = {x = UIgrid.x[4], y = UIgrid.y[1]}
	UIanchors.hands[2][4] = {x = UIgrid.x[5], y = UIgrid.y[1]}
	UIanchors.hands[1][1] = {x = UIgrid.x[2], y = UIgrid.y[3]}
	UIanchors.hands[1][2] = {x = UIgrid.x[3], y = UIgrid.y[3]}
	UIanchors.hands[1][3] = {x = UIgrid.x[4], y = UIgrid.y[3]}
	UIanchors.hands[1][4] = {x = UIgrid.x[5], y = UIgrid.y[3]}
	UIanchors.targets[1] = {x = UIgrid.x[3], y = UIgrid.y[2]}
	UIanchors.targets[2] = {x = UIgrid.x[4], y = UIgrid.y[2]}
end

function setBGgrid()
	local x = 0
	local y = 0
	while y < windowHeight do
		table.insert(BGgrid, {x, y})
		x = x + background:getWidth()
		
		if x >= windowWidth then
			x = 0
			y = y + background:getHeight()
		end
	end
end

function newSpriteMetaTable(atlas, spriteCount, spriteWidth, spriteHeight, paddingHorizontal, paddingVertical)
	--This function is meant to be explicitly strict for now.
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
		for sprite = 0, spriteCount do
			x_offset = (sprite % spriteCountHorizontal) * (spriteWidth + paddingHorizontal)
			y_offset = ({math.modf(sprite / spriteCountHorizontal)})[1] * (spriteHeight + paddingVertical)
			quad = love.graphics.newQuad(x_offset, y_offset, spriteWidth, spriteHeight, ({atlas:getDimensions()})[1], ({atlas:getDimensions()})[2])
			spriteMeta = {quad, 0, 0}
			table.insert(cardsSpriteMetaTable, spriteMeta)
		end
	end
	
	return cardsSpriteMetaTable
end

function deal()
	gameState = 0
	local deck1 = {}
	local deck2 = {}
	local randomIndex = nil

	--Populate
	for card = 1, 52 do
		deck1[card] = card
	end

	--Shuffle
	for card = 1, 52 do
		randomIndex = love.math.random(card, 52)
		j = deck1[card]
		deck1[card] = deck1[randomIndex]
		deck1[randomIndex] = j
	end

	--Split
	for card = 1, 26 do
		deck2[card] = deck1[card]
		deck1[card] = deck1[card + 26]
		deck1[card + 26] = nil
	end

	decks = {deck1, deck2}
	decksSizes = {26, 26}
	
	for player = 1, 2 do
		for position = 1, 4 do
			drawCard(player, position)
		end
	end
	
	targets = {popDeck(1), popDeck(2)}
	handsSizes = {4, 4}
	
	if isStalemate() then
		resolve()
	end
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
		
		if testing.state then
			testing.moves = testing.moves + 1
		end
			
		targets[target] = hands[player][position]
		handsSizes[player] = handsSizes[player] - 1
		drawCard(player, position)
		checkGameOver()
		
		if isStalemate() then
			resolve()
		end
	end
end

function checkGameOver()
	if handsSizes[1] == 0 then
		if handsSizes[2] == 0 then
			gameState = 1
			winMessage = "It's a draw!"
		else
			gameState = 2
			winMessage = "First player won!"
		end
	elseif handsSizes[2] == 0 then
		gameState = 3
		winMessage = "Second player won!"
	end
	
	if testing.state and (gameState == 1 or gameState == 2 or gameState == 3) then
		testing.matches = testing.matches + 1
	end
end

function isStalemate()
	local invalidity = true

	for player = 1, 2 do
		for position = 1, 4 do
			for target = 1, 2 do
				if isValid(player, position, target) then
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
	if handsSizes[1] ~= 0 and handsSizes[2] then 
	local candidates = {}

	for player = 1, 2 do
		if decksSizes[player] == 0 then
			for position = 1, 4 do
				if hands[player][position] ~= 59 then
					candidates[player] = hands[player][position]
					hands[player][position] = 59
					handsSizes[player] = handsSizes[player] - 1
					checkGameOver()
					break
				end
			end
		else
		candidates[player] = popDeck(player)
		end
	end

	if candidates[2] ~= nil then
		targets[1] = candidates[2]
	end
	if candidates[1] ~= nil then
		targets[2] = candidates[1]
	end

	if isStalemate() then
		resolve()
	end
	end
end

function isValid(player, position, target)
	local validity = nil
	local difference = nil
	
	if hands[player][position] == 59 then
		validity = false
	else
		difference = math.abs(hands[player][position] % 13 - targets[target] % 13)
		validity = difference == 1 or difference == 12
	end
	
	return validity
end

function BGcompose()
	if recalculateBGgrid then
		setBGgrid()
	end
	
	for tile = 1, #BGgrid do
	backgroundSpriteBatch:add(unpack(BGgrid[tile]))
	end
end

function UIcompose()
	local sprite
	
	if recalculateUIanchors then
		setUIanchors()
	end

	cardsSpriteBatch:clear()

	--Decks
	for deck = 1, 2 do
		if decksSizes[deck] > 0 then
			sprite = 53
		else
			sprite = 59
		end

		cardsSpriteMetaTable[sprite][2] = UIanchors.decks[deck].x
		cardsSpriteMetaTable[sprite][3] = UIanchors.decks[deck].y
		cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[sprite]))
	end

	--Hands
	for player = 1, 2 do
		for position = 1, 4 do
			cardsSpriteMetaTable[hands[player][position]][2] = UIanchors.hands[player][position].x
			cardsSpriteMetaTable[hands[player][position]][3] = UIanchors.hands[player][position].y
			cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[hands[player][position]]))
		end
	end
	
	--Targets
	for target = 1, 2 do
		cardsSpriteMetaTable[targets[target]][2] = UIanchors.targets[target].x
		cardsSpriteMetaTable[targets[target]][3] = UIanchors.targets[target].y
		cardsSpriteBatch:add(unpack(cardsSpriteMetaTable[targets[target]]))
	end
end
