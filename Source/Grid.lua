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
	self:print()
	return self

end

-- print()
--
function Grid:print()

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

	print(p)

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
	self:addTile(2, 3, 16)
	self:addTile(3, 1, 4)
	self:addTile(1, 1, 2)
	self:addTile(1, 4, 2)
end

-- moveTile()
--
function Grid:moveTileInArray(fromCol, fromRow, toCol, toRow)

	local fromIndex = self:getIndex(fromCol, fromRow)
	local toIndex = self:getIndex(toCol, toRow)
	self.tiles[toIndex] = self.tiles[fromIndex]
	self.tiles[fromIndex] = kEmptyTile

end

-- addTile(col, row, value)
--
-- Creates a tile with `value` displayed at column `col` and row `row` inside the Grid.
function Grid:addTile(col, row, value)

	local t = Tile(value)
	t:moveTo(self:getDrawingPositionAt(col, row))
	local i = self:getIndex(col, row)
	self.tiles[i] = t

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

-- move(colTarget, rowTarget)
--
-- Apply moves inside the Grid in the direction of `colTarget` and `rowTarget`.
-- `colTarget` and `rowTarget` can be either 1 (left or up), 4 (right or down) or 0 (no movement).
function Grid:move(colTarget, rowTarget)

	local dirX = 1
	local dirY = 1
	local colStart = 1
	local rowStart = 1
	if colTarget ~= 0 then
		colStart = colTarget
	end
	if rowTarget ~= 0 then
		rowStart = rowTarget
	end
	local colStop = 4
	local rowStop = 4
	if colStart == 4 then
		colStop = 1
		dirX = -1
	end
	if rowStart == 4 then
		rowStop = 1
		dirY = -1
	end

	for col=colStart, colStop, dirX do
		for row=rowStart, rowStop, dirY do
			local tile = self.tiles[self:getIndex(col, row)]

			if tile ~= nil and tile ~= kEmptyTile then

				local currentCol, currentRow = self:getCoordsFromTile(tile)
				local newCol = colTarget
				if newCol == 0 then
					newCol = currentCol
				end
				local newRow = rowTarget
				if newRow == 0 then
					newRow = currentRow
				end
				if currentCol ~= newCol or currentRow ~= newRow then
					local currentX = tile.x
					local currentY = tile.y
					local targetX, targetY = self:getDrawingPositionAt(newCol, newRow)
					local actualX, actualY, merged, otherTile = tile:slideTo(targetX, targetY)
					if merged then
						for j, t in ipairs(self.tiles) do
							if t == tile or t == otherTile then
								self.tiles[j]:remove() -- Remote sprite from display
								self.tiles[j] = kEmptyTile -- Remote Tile from array
							end
						end
						local newValue = otherTile.value * 2
						local newTile = self:addTile(newCol, newRow, newValue)
					elseif actualX ~= currentX or actualY ~= currentY then
						if actualX ~= targetX then
							newCol = newCol + dirX * math.floor((targetX - actualX) / gMove)
						end
						if actualY ~= targetY then
							newRow = newRow + dirY * math.floor((targetY - actualY) / gMove)
						end
						self:moveTileInArray(currentCol, currentRow, newCol, newRow)
					end
				end

			end

		end
	end

	self:print()

end

-- getCoordsFromPosition(x, y)
--
function Grid:getCoordsFromPosition(x, y)

	local col = (x - self.x) / gMove
	local row = (y - self.y) / gMove
	return col, row

end

-- getCoordsFromTile(tile)
--
function Grid:getCoordsFromTile(tile)

	for i, t in ipairs(self.tiles) do

		if tile == t then
			return self:getCoords(i)
		end

	end

	return nil

end

-- getIndex(col, row)
--
function Grid:getIndex(col, row)

	return ((row - 1) * 4) + col

end

-- getCoords(index)
--
function Grid:getCoords(index)

	return math.ceil(index % 4), math.ceil(index / 4)

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

-- Shorthand functions for game movements
function Grid:moveLeft()

	self:move(1, 0)

end

function Grid:moveRight()

	self:move(4, 0)

end

function Grid:moveUp()

	self:move(0, 1)

end

function Grid:moveDown()

	self:move(0, 4)

end
