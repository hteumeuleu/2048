class('Grid').extends()

local kEmptyTile <const> = 0

-- Grid
--
-- The game’s grid, containing the tiles.
function Grid:init(game)

	Grid.super.init(self)
	self.game = game
	self.x = (400 - gGridSize)
	self.y = (240 - gGridSize) / 2
	self.width = gGridSize
	self.height = gGridSize
	self.image = self:createBackgroundImage()
	self:draw()
	self:initTiles()
	return self

end

-- __tostring()
--
-- Outputs an ASCII art grid to the terminal.
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

	if self.shakeAnimator ~= nil and not self.shakeAnimator:ended() then
		playdate.display.setOffset(self.shakeAnimator:currentValue().x, self.shakeAnimator:currentValue().y)
	end
	if self.isAnimating then
		local isStillAnimating = false
		local hasMoved = false

		for _, col in ipairs(self.traversals.x) do
			for _, row in ipairs(self.traversals.y) do
				local i = self:getIndex(col, row)
				local tile = self.tiles[i]
				if tile ~= nil and tile ~= kEmptyTile then
					if tile.moved or tile.mustBeMerged then
						hasMoved = true
					end
					if tile:isAnimating() then
						isStillAnimating = true
					end
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
								local newValue = tile.value * 2
								tile:removeAnimator()
								tile:remove()
								self.tiles[i] = kEmptyTile
								self:addTile(newCol, newRow, newValue)
								self.game.score:addToValue(newValue)
								self.game.score:update()
								if self.game.score:getValue() > self.game.bestScore:getValue() then
									self.game.bestScore:setValue(self.game.score:getValue())
									self.game.bestScore:update()
								end
							elseif not tile.isNew then
								local newCol, newRow = self:getCoordsFromPosition(tile.animatorEndPoint.x, tile.animatorEndPoint.y)
								self:moveTileInArray(i, self:getIndex(newCol, newRow))
							end
						end
					end
				end
			end
		end
		if not isStillAnimating then
			self.traversals = nil
			self.isAnimating = false
			if hasMoved then
				self:addRandomTile()
			end
		end
	end

end

-- draw()
--
-- Draws the Grid’s background.
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
end

-- moveTileInArray()
--
-- Moves a tile’s representation within the `self.tiles` array.
-- This does not move a tile on screen. Just in data.
function Grid:moveTileInArray(fromIndex, toIndex)

	if fromIndex ~= toIndex and fromIndex >= 1 and fromIndex <= #self.tiles and toIndex >= 1 and toIndex <= #self.tiles then
		self.tiles[toIndex] = self.tiles[fromIndex]
		self.tiles[fromIndex] = kEmptyTile
	end

end

-- setZIndex()
--
-- Update the tile at `i` ZIndex.
function Grid:setZIndex(i)

	if self.tiles[i] ~= nil and self.tiles[i] ~= kEmptyTile then
		local col, row = self:getCoords(i)
		self.tiles[i]:setZIndex(math.max(col, row))
	end

end

-- addTile(col, row, value)
--
-- Creates a tile with `value` displayed at column `col` and row `row` inside the Grid.
-- `random` is a boolean used to play a slightly different animation between a new tile (generated at each round — `true`) and a new tile (from a merge — `false`).
function Grid:addTile(col, row, value, random)

	if self:hasAvailableCells() then
		-- Create new tile with the new value
		local t = Tile(value)
		-- Move it to its col and row position on screen
		t:moveTo(self:getDrawingPositionAt(col, row))
		-- Get new index to place new tile in array
		local i = self:getIndex(col, row)
		-- If there's already a tile there we properly remove it
		if self.tiles[i] ~= nil and self.tiles[i] ~= kEmptyTile then
			self.tiles[i]:removeAnimator()
			self.tiles[i]:remove()
			self.tiles[i] = kEmptyTile
		end
		-- We set the new tile at this index
		self.tiles[i] = t
		-- We add a scale animator for this new tile
		if random == true then
			local scaleAnimator = playdate.graphics.animator.new(100, 0.8, 1, playdate.easingFunctions.linear, 100)
			scaleAnimator.reverses = false
			self.tiles[i]:addAnimator(scaleAnimator, "scale")
		else
			local scaleAnimator = playdate.graphics.animator.new(100, 1, 1.08, playdate.easingFunctions.linear)
			scaleAnimator.reverses = true
			self.tiles[i]:addAnimator(scaleAnimator, "scale")
		end
	end

end

-- addRandomTile()
--
function Grid:addRandomTile()

	if self:hasAvailableCells() then
		math.randomseed(playdate.getSecondsSinceEpoch())
		local value = math.random()
		if value < 0.9 then
			value = 2
		else
			value = 4
		end
		local col, row = self:getCoords(self:getRandomAvailableCell())
		self:addTile(col, row, value, true)
	end

end

-- getRandomAvailableCell()
--
-- Return the index of a random available cell within `self.tile`.
function Grid:getRandomAvailableCell()

	local cells = self:getAvailableCells()
	if cells ~= nil and #cells > 0 then
		math.randomseed(playdate.getSecondsSinceEpoch())
		return cells[math.random(1, #cells)]
	end

end

-- getAvailableCells()
--
-- Returns an array of indexes of available cells within `self.tiles`.
function Grid:getAvailableCells()

	local cells = {}
	for i, cell in ipairs(self.tiles) do
		if cell == kEmptyTile then
			table.insert(cells, i)
		end
	end
	return cells

end

-- hasAvailableCells()
--
function Grid:hasAvailableCells()

	return #self:getAvailableCells() > 0

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

-- findFarthestPosition()
--
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

		self:prepareTiles()
		local vector <const> = self:getVector(direction)
		self.traversals = self:buildTraversals(vector)
		local hasMoved = false

		for _, col in ipairs(self.traversals.x) do
			for _, row in ipairs(self.traversals.y) do
				local i = self:getIndex(col, row)
				local tile = self.tiles[i]
				if tile ~= nil and tile ~= kEmptyTile then
					tile:setZIndex(col * vector.x + row * vector.y)
					local farthestCol, farthestRow = self:findFarthestPosition(i, vector)
					local targetX, targetY = self:getDrawingPositionAt(farthestCol, farthestRow)
					tile:slideTo(targetX, targetY)
					if tile.moved or tile.mustBeMerged then
						hasMoved = true
					end
				end
			end
		end

		if hasMoved then
			self.isAnimating = true
		else
			self:shake(vector)
		end

	end

end

-- prepareTiles()
--
function Grid:prepareTiles()

	for _, tile in ipairs(self.tiles) do
		if tile ~= nil and tile ~= kEmptyTile then
			tile:setScale(1)
			tile.moved = false
			tile.isNew = false
			tile.animators = {}
			tile.animator = nil
			tile.mustBeRemoved = nil
			tile.mustBeMerged = nil
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

	if col >= 1 and col <= 4 and row >= 1 and row <= 4 then
		return ((row - 1) * 4) + col
	end
	return -1

end

-- getCoords(index)
--
function Grid:getCoords(index)

	return math.ceil((index - 1) % 4 + 1), math.ceil(index / 4)

end

-- createBackgroundImage()
--
-- Creates the background image of the grid.
function Grid:createBackgroundImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.width, 6)
		playdate.graphics.setPattern({0x77, 0xFF, 0xDD, 0xFF, 0x77, 0xFF, 0xDD, 0xFF})
		for y=1,4,1
		do
			for x=1,4,1
			do
				local cellX = (gGridBorderSize * x) + (gTileSize * (x - 1))
				local cellY = (gGridBorderSize * y) + (gTileSize * (y - 1))
				playdate.graphics.fillRoundRect(cellX, cellY, gTileSize, gTileSize, 3)
			end
		end
	playdate.graphics.popContext()
	return img

end

-- getVector()
--
-- Returns a `vector2D` representing the direction of the movement.
function Grid:getVector(direction)

	local map <const> = {
		playdate.geometry.vector2D.new(0, -1), -- Up
		playdate.geometry.vector2D.new(1, 0), -- Right
		playdate.geometry.vector2D.new(0, 1), -- Down
		playdate.geometry.vector2D.new(-1, 0), -- Left
	}

	return map[direction]

end

-- buildTraversals()
--
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

-- hasAvailableMatches()
--
-- Check for available matches between tiles (more expensive check)
function Grid:hasAvailableMatches()

	if self:hasAvailableCells() then
		return true
	end
	local tile, x, y
	for x=1, 4, 1 do
		for y=1, 4, 1 do
			tile = self.tiles[self:getIndex(x, y)]
			if tile ~= nil and tile ~= kEmptyTile then
				for direction=1, 4, 1 do
					local vector = self:getVector(direction)
					local other = self.tiles[self:getIndex(x + vector.x, y + vector.y)]
					if other ~= nil and other ~= kEmptyTile then
						if other.value == tile.value then
							return true -- These two tiles can be merged
						end
					end
				end

			end
		end
	end
	return false

end

-- shake()
--
function Grid:shake(vector)

	local startPoint = playdate.geometry.point.new(vector.x * -1, vector.y * -1)
	local endPoint = playdate.geometry.point.new(vector.x * 1, vector.y * 1)
	self.shakeAnimator = playdate.graphics.animator.new(100, startPoint, endPoint, playdate.easingFunctions.inBounce, 100)
	self.shakeAnimator.reverses = true
	self.shakeAnimator.repeatCount = 2

end

-- serialize()
--
function Grid:serialize()
	local p = ""
	for j=1, 4, 1 do
		for i=1, 4, 1 do
			local t = self.tiles[self:getIndex(i, j)]
			if t ~= kEmptyTile and t ~= nil then
				p = p .. t.value
			else
				p = p .. "x"
			end
			if not (j == 4 and i == 4) then
				p = p ..  ","
			end
		end
	end
	return p
end