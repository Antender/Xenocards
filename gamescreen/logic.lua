--imports
local imports

--locals
local handsSizes = {0, 0}
local decksSizes = {0, 0}
local hands = {{59, 59, 59, 59}, {59, 59, 59 ,59}}
local targets = {59, 59}

--functions
local function popDeck(player)
	local card = decks[player][decksSizes[player]]
	
	if decksSizes[player] > 0 then
		table.remove(decks[player], decksSizes[player])
		decksSizes[player] = decksSizes[player] - 1
	else
		card = 59
	end
	return card
end

local function checkGameOver()
	if handsSizes[1] == 0 then
		if handsSizes[2] == 0 then
			imports.setGamescreenState(1)
			imports.setWinMessage("It's a draw!")
		else
			imports.setGamescreenState(2)
			imports.setWinMessage("First player won!")
		end
	elseif handsSizes[2] == 0 then
		imports.setGamescreenState(3)
		imports.setWinMessage("Second player won!")
	end
	
	imports.increaseMatches()
end

local function isValid(player, position, target)
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

local function isStalemate()
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

local function drawCard(player, position)
	local card = popDeck(player)
	
	if card ~= 59 then
		handsSizes[player] = handsSizes[player] + 1
	end
	
	hands[player][position] = card
end

local function resolve()
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

--export
local logic = {}

function logic.playCard(player, position, target)
	if isValid(player, position, target) then
	
		imports.increaseMoves()
		
		targets[target] = hands[player][position]
		handsSizes[player] = handsSizes[player] - 1
		drawCard(player, position)
		checkGameOver()
		
		if isStalemate() then
			resolve()
		end
	end
end

function logic.load(_imports)
	imports = _imports
	logic.deal()
end

function logic.getDecksSizes()
	return decksSizes
end

function logic.getHands()
	return hands
end

function logic.getTargets()
	return targets
end

function logic.deal()
	imports.setGamescreenState(0)
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

return logic