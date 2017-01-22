--exports
local exports = {}

function exports.new(windowWidth, windowHeight, xcount, ycount, xshift, yshift)
	local grid = {x = {}, y = {}}
	
	local grid.xcell = xshift
	local grid.ycell = yshift
	local grid.xinterval = windowWidth / xcount
	local grid.yinterval = windowHeight / ycount
	
	for column = 1, xcount + 1 do
		grid.x[column] = grid.xcell
		grid.xcell = grid.xcell + grid.xinterval
	end
	
	for column = 1, ycount + 1 do
		grid.y[column] = grid.ycell
		grid.ycell = grid.ycell + grid.yinterval
	end
	
    setmetatable(grid,self)
    self.__index = self
	return grid
end

function exports:contains(x,y,xcell,ycell, )
    return x >= self.x[xcell] and x <= self.x[xcell+1] and y >= self.y[ycell] and y <= self.y[ycell+1] 
end

return exports