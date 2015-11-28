--exports
local exports = {}

function exports.new(windowWidth, windowHeight, xcount, ycount, xshift, yshift)
	local grid = {x = {}, y = {}}
	
	local xcell = xshift
	local ycell = yshift
	local xinterval = windowWidth / xcount
	local yinterval = windowHeight / ycount
	
	for column = 1, xcount do
		grid.x[column] = xcell
		xcell = xcell + xinterval
	end
	
	for column = 1, ycount do
		grid.y[column] = ycell
		ycell = ycell + yinterval
	end
	
	return grid
end
return exports