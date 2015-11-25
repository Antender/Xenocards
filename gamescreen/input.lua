--imports
local imports

--locals
local keys

--functions
local function keyboardpressed(button, dorepeat)
	if button == "z" then
		imports.deal()
	elseif button == "escape" then
		love.event.quit()
	elseif button == "x" then
		imports.enableTesting()
	else
		for _, buttonInfo in pairs(keys) do
			if button == buttonInfo[1] then
				imports.playCard(unpack(buttonInfo[2]))
			end
		end
	end
end

local function mousepressed(x, y, button)
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
local input = {}

function input.load(_imports)
	imports = _imports
	keys = {
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
	love.keypressed = keyboardpressed
	love.mousepressed = mousepressed
end

return input