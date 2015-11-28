--imports
local imports
local background
local cards
local logic
--locals
local state = 0 
	--States: 0 - in progress, 1 - first player won, 2 - second player won, 3 - draw, 4 - restart
local winMessage = "I AM ERROR"
local testing = {state = false, tries = 0, moves = 0, matches = 0, dumbness = ""}
local windowMode
	
--functions 
local function dumbAutoplay()
	logic.playCard(love.math.random(2), love.math.random(4), love.math.random(2))
	testing.tries = testing.tries + 1
end

local function enableTesting()
	testing.state = not testing.state
	windowMode.borderless = not windowMode.borderless
	love.window.setMode(windowMode.x, windowMode.y, {borderless = windowMode.borderless})
end

local function increaseMoves()
	if testing.state then
		testing.moves = testing.moves + 1
	end
end

local function setState(newstate)
	state = newstate
end

local function setWinMessage(message)
	winMessage = message
end

local function update(dt)
	if testing.state then
		dumbAutoplay()
	end
	
	if state == 4 then
		if testing.state then
			testing.matches = testing.matches + 1
		else
			love.window.showMessageBox("Game Over", winMessage, "info", true)
		end

		logic.deal()
	end
end

local function draw()
	background.draw()
	cards.draw()
	if state == 1 or state == 2 or state == 3 then
		state = 4
	end
	if testing.state then
		testing.dumbness = string.format("%.f", ((testing.tries - testing.moves) / testing.tries * 100))
		love.window.setTitle("Tries:" .. testing.tries .. " Moves:" .. testing.moves .. " Matches:" .. testing.matches .. " Dumbness:" .. testing.dumbness .. "%") --Possibly instable.
	end
end
--exports
local exports = {}

function exports.load(_imports)
	imports = _imports
	input = dofile("gamescreen/input.lua")
	background = dofile("common/background.lua")
	cards = dofile("gamescreen/cards.lua")
	logic = dofile("gamescreen/logic.lua")
	input.load({
		deal = logic.deal,
		enableTesting = enableTesting,
		playCard = logic.playCard,
		isCardHovered = cards.isCardHovered,
		switchMainscreen = imports.switchMainscreen})
	background.load(nil)
	cards.load({
		getDecksSizes = logic.getDecksSizes,
		getHands = logic.getHands,
		getTargets = logic.getTargets})
	logic.load({
		setGamescreenState = setState,
		setWinMessage = setWinMessage,
		increaseMoves = increaseMoves,
	})	
	love.update = update
	love.draw = draw
	windowMode = imports.getWindowMode()
end

return exports
