class('Tile').extends(playdate.graphics.sprite)

function Tile:init(col, row, value)

	Tile.super.init(self)
	self.value = value
	self.width = gTileSize
	self.height = gTileSize
	self:initImage()
	self:setCoords(col, row)
	self:setCollideRect(gGridBorderSize / 2 * -1, gGridBorderSize / 2 * -1, self.width + gGridBorderSize, self.height + gGridBorderSize)
	self:setTag(value)
	self:add()
	return self

end

-- initImage()
--
-- Creates the image to be drawn with the tile.
-- It's a simple RoundRect but with a slight offset to give an height effect depending on the Tile value.
function Tile:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	local kTileHeightOffset = math.floor(self.value / 4)
	local kTileBorderSize = 2
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, gTileRadius)
		-- Foreground
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(kTileBorderSize, kTileBorderSize, self.width - (2 * kTileBorderSize), self.height - (2 * kTileBorderSize) - kTileHeightOffset, gTileRadius)
		playdate.graphics.drawTextInRect("*" .. self.value .. "*", 0, 16 - kTileHeightOffset, self.width, self.height, nil, nil, kTextAlignment.center)
	playdate.graphics.popContext()
	self:setImage(img)

end

-- getCoords()
--
-- Get the coordinates in terms of rows and columns inside the Grid.
function Tile:getCoords()

	return self.col, self.row

end


-- setCoords(col, row)
--
-- Set the coordinates in terms of rows and columns inside the Grid.
-- x and y are Integer values ranging from 1 to 4.
function Tile:setCoords(col, row)

	self.col = col
	self.row = row
	self:setZIndex(math.max(col, row))

end

-- slideTo(coordsX, coordsY, x, y)
--
-- x and y: the actual x and y position to draw at (in pixels)
--
-- Returns true if the Tile was moved at the expected position.
-- Returns false otherwise. If the Tile overlapped another Tile with the same value,
-- also returns the value of the new tile to create in place, as well as the other tile merged with.
function Tile:slideTo(x, y)

	local actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	if length > 0 then
		-- coordsX = coordsX + ((actualX - x) / gMove)
		-- coordsY = coordsY + ((actualY - y) / gMove)
		for _, collision in ipairs(collisions) do
			if collision.other:getTag() == self:getTag() then
				return false, self.value * 2, collision.other
			end
		end
		-- self:setCoords(coordsX, coordsY)
		return false
	end
	-- self:setCoords(coordsX, coordsY)
	return true

end

-- collisionResponse()
--
-- Sets the collision response in case of a collision.
-- If we hit another similar Tile, we want them to overlap.
-- Otherwise we want the Tile to be blocked (freeze).
function Tile:collisionResponse(other)

	if other:getTag() == self:getTag() then
		return playdate.graphics.sprite.kCollisionTypeOverlap
	else
		return playdate.graphics.sprite.kCollisionTypeFreeze
	end

end
