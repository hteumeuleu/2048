class('Grid').extends()

local kEmptyTile <const> = 0

function Grid:init()

	Grid.super.init(self)
	self.x = (400 - gGridSize) / 2
	self.y = (240 - gGridSize) / 2
	self.width = gGridSize
	self.height = gGridSize
	self.image = self:createBackgroundImage()
	self:draw()
	self:initTiles()
	self:initInputHandlers()
	self.cursor = Cursor()
	return self

end

function Grid:__tostring()
	local p = ""

	for j=1, 4, 1 do

		for i=1, 4, 1 do

			local t = self.tiles[self:getIndex(i, j)]
			if t ~= kEmptyTile and t ~= nil then
				p = p .. t.value
			else
				p = p .. "x"
			end
			p = p ..  "|"

		end
		p = p .. "\n--------\n"

	end

	return p
end

-- update()
--
function Grid:update()

	if self.isAnimating then
		local isStillAnimating = false


		for _, col in ipairs(self.traversals.x) do
			for _, row in ipairs(self.traversals.y) do
				local i = self:getIndex(col, row)
				local tile = self.tiles[i]
				if tile ~= nil and tile ~= kEmptyTile then
					if tile.animator ~= nil then
						if not tile.animator:ended() then
							isStillAnimating = true
						else
							if tile.mustBeRemoved then
								tile:removeAnimator()
								tile:remove()
								self.tiles[i] = kEmptyTile
							elseif tile.mustBeMerged then
								local newCol, newRow = self:getCoordsFromPosition(tile.animatorEndPoint.x, tile.animatorEndPoint.y)
								tile:removeAnimator()
								tile:remove()
								self.tiles[i] = kEmptyTile
								self:addTile(newCol, newRow, tile.value * 2)
							else
								local newCol, newRow = self:getCoordsFromPosition(tile.animatorEndPoint.x, tile.animatorEndPoint.y)
								self:moveTileInArray(i, self:getIndex(newCol, newRow))
							end
						end
					end
				end
			end
		end
		if not isStillAnimating then
			self.isAnimating = false
		end
	end


end

-- draw()
--
-- Draws the Grid background.
function Grid:draw()

	self.image:draw(self.x, self.y)

end

-- initTiles()
--
-- Creates random tiles on initialization.
function Grid:initTiles()
	self.tiles = {
		kEmptyTile, kEmptyTile, kEmptyTile, kEmptyTile,
		kEmptyTile, kEmptyTile, kEmptyTile, kEmptyTile,
		kEmptyTile, kEmptyTile, kEmptyTile, kEmptyTile,
		kEmptyTile, kEmptyTile, kEmptyTile, kEmptyTile
	}
	self:addTile(1, 1, 2)
	self:addTile(1, 2, 2)
	self:addTile(1, 3, 2)
	self:addTile(1, 4, 2)
	self:addTile(2, 1, 4)
	self:addTile(2, 2, 4)
	self:addTile(2, 3, 4)
	self:addTile(2, 4, 4)
	self:addTile(3, 1, 8)
	self:addTile(3, 2, 8)
	self:addTile(3, 3, 8)
	self:addTile(3, 4, 8)
	self:addTile(4, 1, 16)
	self:addTile(4, 2, 16)
	self:addTile(4, 3, 16)
	self:addTile(4, 4, 16)
end

-- moveTile()
--
function Grid:moveTileInArray(fromIndex, toIndex)

	if fromIndex ~= toIndex and fromIndex >= 1 and toIndex <= #self.tiles then
		self.tiles[toIndex] = self.tiles[fromIndex]
		self.tiles[fromIndex] = kEmptyTile
		self:setZIndex(toIndex)
	end

end

-- setZIndex()
function Grid:setZIndex(i)

	if self.tiles[i] ~= nil and self.tiles[i] ~= kEmptyTile then
		local col, row = self:getCoords(i)
		self.tiles[i]:setZIndex(math.max(col, row))
	end

end

-- addTile(col, row, value)
--
-- Creates a tile with `value` displayed at column `col` and row `row` inside the Grid.
function Grid:addTile(col, row, value)

	local t = Tile(value)
	t:moveTo(self:getDrawingPositionAt(col, row))
	local i = self:getIndex(col, row)
	self.tiles[i] = t
	self:setZIndex(i)

end

-- getDrawingPositionAt(col, row)
--
-- Gets the x and y coordinates corresponding to the `col` and `row` index of the Grid.
function Grid:getDrawingPositionAt(col, row)

	return self:getX(col), self:getY(row)

end

-- getX(col)
--
-- Gets the x coordinate corresponding to the `col` index of the Grid.
function Grid:getX(col)

	return self.x + (gGridBorderSize * col) + (gTileSize * (col - 1)) + (gTileSize / 2)

end

-- getY(row)
--
-- Gets the y coordinate corresponding to the `row` index of the Grid.
function Grid:getY(row)

	return self.y + (gGridBorderSize * row) + (gTileSize * (row - 1)) + (gTileSize / 2)

end

function Grid:findFarthestPosition(i, vector)

	local col, row = self:getCoords(i)
	if vector.x == -1 then
		col = 1
	end
	if vector.x == 1 then
		col = 4
	end
	if vector.y == -1 then
		row = 1
	end
	if vector.y == 1 then
		row = 4
	end
	return col, row

end

-- move(direction)
--
-- Apply moves inside the Grid in the direction of the number passed as a parameter.
-- direction can be a value from 1 to 4
-- 1=Up, 2=Right, 3=Down, 4=Left
function Grid:move(direction)

	if not self.isAnimating then

		local vector <const> = self:getVector(direction)
		local traversals = self:buildTraversals(vector)
		self.isAnimating = true
		self.traversals = traversals

		for _, col in ipairs(traversals.x) do
			for _, row in ipairs(traversals.y) do
				local i = self:getIndex(col, row)
				local tile = self.tiles[i]
				if tile ~= nil and tile ~= kEmptyTile then
					local farthestCol, farthestRow = self:findFarthestPosition(i, vector)
					local targetX, targetY = self:getDrawingPositionAt(farthestCol, farthestRow)
					tile:slideTo(targetX, targetY)
					if tile.animator ~= nil then
						tile:setAnimator(tile.animator, false, false)
					end
				end
			end
		end

	end

end

-- getCoordsFromPosition(x, y)
--
function Grid:getCoordsFromPosition(x, y)

	local col = math.ceil((x - self.x) / gMove)
	local row = math.ceil((y - self.y) / gMove)
	return col, row

end

-- getIndex(col, row)
--
function Grid:getIndex(col, row)

	return ((row - 1) * 4) + col

end

-- getCoords(index)
--
function Grid:getCoords(index)

	return math.ceil((index - 1) % 4 + 1), math.ceil(index / 4)

end

-- createImage()
--
-- Creates the background image of the grid.
function Grid:createBackgroundImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		playdate.graphics.setPattern({0x77, 0xFF, 0xDD, 0xFF, 0x77, 0xFF, 0xDD, 0xFF})
		for y=1,4,1
		do
			for x=1,4,1
			do
				local cellX = (gGridBorderSize * x) + (gTileSize * (x - 1))
				local cellY = (gGridBorderSize * y) + (gTileSize * (y - 1))
				playdate.graphics.fillRoundRect(cellX, cellY, gTileSize, gTileSize, gTileRadius)
			end
		end
	playdate.graphics.popContext()
	return img

end


function Grid:getVector(direction)

	local map <const> = {
		playdate.geometry.vector2D.new(0, -1), -- Up
		playdate.geometry.vector2D.new(1, 0), -- Right
		playdate.geometry.vector2D.new(0, 1), -- Down
		playdate.geometry.vector2D.new(-1, 0), -- Left
	}

	return map[direction]

end

function Grid:buildTraversals(vector)

	local traversals = {}
	traversals.x = {}
	traversals.y = {}

	for pos=1, 4, 1 do
		table.insert(traversals.x, pos)
		table.insert(traversals.y, pos)
	end

	local function reverse(item1, item2)
		return item1 > item2
	end

	if (vector.x == 1) then
		table.sort(traversals.x, reverse)
	end
	if (vector.y == 1) then
		table.sort(traversals.y, reverse)
	end

	return traversals

end

-- initInputHandlers()
--
-- Add control handlers.
function Grid:initInputHandlers()

	local gridInputHandlers = {
		AButtonDown = function()
			print(self)
		end,
		leftButtonDown = function()
			self:moveLeft()
		end,
		rightButtonDown = function()
			self:moveRight()
		end,
		upButtonDown = function()
			self:moveUp()
		end,
		downButtonDown = function()
			self:moveDown()
		end,
		cranked = function()
			local abs = playdate.getCrankPosition()
			self.cursor:setAngle(abs)
			self.cursor:add()
			local function moveAfterCrank(abs)
				if abs >= 45 and abs < 135 then
					self:moveRight()
				elseif abs >= 135 and abs < 225 then
					self:moveDown()
				elseif abs >= 225 and abs < 315 then
					self:moveLeft()
				elseif abs >= 315 or abs < 45 then
					self:moveUp()
				end
			end
			if(self.crankTimer ~= nil) then
				self.crankTimer:remove()
			end
			self.crankTimer = playdate.timer.performAfterDelay(100, moveAfterCrank, abs)
		end,
	}
	playdate.inputHandlers.push(gridInputHandlers)

end

-- Shorthand functions for game movements
function Grid:moveLeft()

	self:move(4)

end

function Grid:moveRight()

	self:move(2)

end

function Grid:moveUp()

	self:move(1)

end

function Grid:moveDown()

	self:move(3)

end
