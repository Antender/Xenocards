--imports
local imports

--locals
local input = {}
input.gamescreen = {}

function input.load(_imports)
	imports = _imports
	input.gamescreen.keys = {
 		{"1",{1,1,1}},
		{"2",{1,2,1}},
		{"3",{1,3,1}},
		{"4",{1,4,1}},
		{"5",{1,1,2}},
		{"6",{1,2,2}},
		{"7",{1,3,2}},
		{"8",{1,4,2}},
		{"q",{2,1,1}},
		{"w",{2,2,1}},
		{"e",{2,3,1}},
		{"r",{2,4,1}},
		{"t",{2,1,2}},
		{"y",{2,2,2}},
		{"u",{2,3,2}},
		{"i",{2,4,2}}}
	input.gamescreen.switch()
end

function input.gamescreen.switch()
	love.keypressed = input.gamescreen.keyboardpressed
	love.mousepressed = input.gamescreen.mousepressed
end

function input.gamescreen.keyboardpressed(button, dorepeat)
	if button == "z" then
		imports.deal()
	elseif button == "escape" then
		love.event.quit()
	elseif button == "x" then
		imports.enableTesting()
	else
		for _, buttonInfo in pairs(input.gamescreen.keys) do
			if button == v[1] then
				imports.playCard(unpack(v[2]))
			end
		end
	end
end

function input.gamescreen.mousepressed(x, y, button)
	for player = 1, 2 do
		for position = 1, 4 do
			if imports.isCardHovered(x, y, player, position) then
				if button == "l" then
					imports.playCard(player, position, 1)
				elseif button == "r" then
					imports.playCard(player, position, 2)
				end
			end
		end
	end
end

--export
return input