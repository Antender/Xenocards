function love.load()
	gameOver = {state = 0, message = "I AM ERROR"}
	testing = {state = false, tries = 0, moves = 0, matches = 0, dumbness = ""}
	handsSizes = {0, 0}
	decksSizes = {0, 0}
	hands = {{}, {}}
	targets = {}
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
	keys = {
 	{"1",true,{1,1,1}},
	{"2",true,{1,2,1}},
	{"3",true,{1,3,1}},
	{"4",true,{1,4,1}},
	{"5",true,{1,1,2}},
	{"6",true,{1,2,2}},
	{"7",true,{1,3,2}},
	{"8",true,{1,4,2}},
	{"q",true,{2,1,1}},
	{"w",true,{2,2,1}},
	{"e",true,{2,3,1}},
	{"r",true,{2,4,1}},
	{"t",true,{2,1,2}},
	{"y",true,{2,2,2}},
	{"u",true,{2,3,2}},
	{"i",true,{2,4,2}}
	}
end


function love.update(dt)
	if love.keyboard.isDown("z") then
		restart()
	elseif love.keyboard.isDown("escape") then
		love.event.quit()
	elseif love.keyboard.isDown("x") then
		testing.state = not testing.state
		windowMode.borderless = not windowMode.borderless
		love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
	end
	
	if testing.state then
		dumbAutoplay()
	end

	for k, v in pairs(keys) do
		if love.keyboard.isDown(v[1]) then
			if v[2] then
				playCard(unpack(v[3]))
				v[2] = false
			end
		else
			v[2] = true
		end
	end
end

function love.draw()
	UIcompose()
	love.graphics.draw(backgroundSpriteBatch, 0, 0)
	love.graphics.draw(cardsSpriteBatch, 0, 0)
	if testing.state then
		testing.dumbness = string.format("%.f", ((testing.tries - testing.moves) / testing.tries * 100))
		love.window.setTitle("Tries:" .. testing.tries .. " Moves:" .. testing.moves .. " Matches:" .. testing.matches .. " Dumbness:" .. testing.dumbness .. "%") --Possibly instable.
	end
end

function dumbAutoplay()
	playCard(love.math.random(2), love.math.random(4), love.math.random(2))
	testing.tries = testing.tries + 1
end

function isCardHovered(x, y, cardCoordinates)
	return (x >= cardCoordinates.x and y >= cardCoordinates.y and x <= (cardCoordinates.x + 80) and y <= (cardCoordinates.y + 117))
end

function love.mousepressed(x, y, button)
	for player = 1, 2 do
		for position = 1, 4 do
			if isCardHovered(x, y, UIanchors.hands[player][position]) then
				if button == "l" then
					playCard(player, position, 1)
				elseif button == "r" then
					playCard(player, position, 2)
				end
			end
		end
	end
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

function checkGameOver() --0 — none, 1 — first, 2 — second, 3 — both players win(draw).
	if handsSizes[1] == 0 and handsSizes[2] == 0 then
		gameOver.state = 3
		gameOver.message = "It's a draw!"
	elseif handsSizes[1] == 0 then
		gameOver.state = 1
		gameOver.message = "First player won!"
	elseif handsSizes[2] == 0 then
		gameOver.state = 2
		gameOver.message = "Second player won!"
	end

	if gameOver.state ~= 0 then --This need to be elsewhere but major issues were encountered.
		endGame()
	end
end

function endGame()
	if testing.state then
		testing.matches = testing.matches + 1
	else
		love.window.showMessageBox("Game Over", gameOver.message, "info", true) --Needs to visually resolve first.
	end

	restart()
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

	targets[1] = candidates[2]
	targets[2] = candidates[1]

	if isStalemate() then
		resolve()
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

function restart()
	gameOver = {state = 0, message = "I AM ERROR"}
	deal()
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
