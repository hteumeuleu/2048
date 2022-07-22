class('Grid').extends()

function Grid:init()

	Grid.super.init(self)
	self.x = (400 - gGridSize) / 2
	self.y = (240 - gGridSize) / 2
	self.width = gGridSize
	self.height = gGridSize
	self.image = self:createBackgroundImage()
	self:draw()
	self.tiles = {}
	self:initTiles()
	self:initInputHandlers()
	return self

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
	self:addTile(2, 3, 16)
	self:addTile(3, 1, 4)
	self:addTile(1, 1, 2)
	self:addTile(1, 4, 2)
end

-- initInputHandlers()
--
-- Add control handlers.
function Grid:initInputHandlers()

	local gridInputHandlers = {
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

-- addTile(col, row, value)
--
-- Creates a tile with `value` displayed at column `col` and row `row` inside the Grid.
function Grid:addTile(col, row, value)

	local t = Tile(col, row, value)
	t:moveTo(self:getDrawingPositionAt(col, row))
	table.insert(self.tiles, t)

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

-- sortTilesArray()
--
-- `xDir` and `yDir` are Integers equal either to -1 or 1
function Grid:sortTilesArray(xDir, yDir)

	table.sort(self.tiles, function (tile1, tile2)
		if not tile1 or not tile2 then
			return false
		end
		local tile1Col, tile1Row = tile1:getCoords()
		local tile2Col, tile2Row = tile2:getCoords()
		if xDir ~= 0 then
			return (tile1Col * xDir) > (tile2Col * xDir)
		elseif yDir ~= 0 then
			return (tile1Row * yDir) > (tile2Row * yDir)
		else
			return false
		end
	end)

end

-- move(xTarget, yTarget)
--
-- Apply moves inside the Grid in the direction of `colTarget` and `rowTarget`.
-- `colTarget` and `rowTarget` can be either 1 (left or up), 4 (right or down) or 0 (no movement).
function Grid:move(colTarget, rowTarget)

	for i, tile in ipairs(self.tiles) do

		if tile ~= nil then

			local currentCol, currentRow = tile:getCoords()
			local currentColTarget = colTarget
			if currentColTarget == 0 then
				currentColTarget = currentCol
			end
			local currentRowTarget = rowTarget
			if currentRowTarget == 0 then
				currentRowTarget = currentRow
			end
			local x, y = self:getDrawingPositionAt(currentColTarget, currentRowTarget)
			local success, newValue, otherTile = tile:slideTo(x, y)
			if (not success) and newValue and otherTile then
				local newCol, newRow = otherTile:getCoords()
				for j, t in ipairs(self.tiles) do
					if t == tile or t == otherTile then
						self.tiles[j]:remove() -- Remote sprite from display
						self.tiles[j] = nil -- Remote Tile from array
					end
				end
				local newTile = self:addTile(newCol, newRow, newValue)
			else
				self.tiles[i]:setCoords(currentColTarget, currentRowTarget)
			end

		end
	end

end

-- Shorthand functions for game movements
function Grid:moveLeft()

	self:sortTilesArray(-1, 0)
	self:move(1, 0)

end

function Grid:moveRight()

	self:sortTilesArray(1, 0)
	self:move(4, 0)

end

function Grid:moveUp()

	self:sortTilesArray(0, -1)
	self:move(0, 1)

end

function Grid:moveDown()

	self:sortTilesArray(0, 1)
	self:move(0, 4)

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
