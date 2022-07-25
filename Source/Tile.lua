class('Tile').extends(playdate.graphics.sprite)

local kTileCollisionGroup = 1

function Tile:init(value)

	Tile.super.init(self)
	self.value = value
	self.width = gTileSize
	self.height = gTileSize
	self:initImage()
	self:setCollideRect(gGridBorderSize / 2 * -1, gGridBorderSize / 2 * -1, self.width + gGridBorderSize, self.height + gGridBorderSize)
	self:setTag(value)
	self:setGroups({kTileCollisionGroup})
	self:setCollidesWithGroups({kTileCollisionGroup})
	self:add()
	return self

end

function Tile:__tostring()
	return "Tile[" .. self.value .. "]"
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

-- slideTo(x, y)
--
-- x and y: the actual x and y position to draw at (in pixels)
--
-- Returns the actualX and actualY the tile ends up at,
-- and a boolean indicating whether the Tile has merged with another or not.
function Tile:slideTo(x, y)

	self:removeAnimator()
	self.animator = nil
	local merged = false
	local otherTile = nil
	local useAnimator = false
	local actualX, actualY, collisions, length
	if not useAnimator then
		self.animatorStartPoint = playdate.geometry.point.new(self.x, self.y)
		actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	else
		actualX, actualY, collisions, length = self:checkCollisions(x, y)
	end
	if length > 0 then
		for _, collision in ipairs(collisions) do
			local overlap = (collision.type == playdate.graphics.sprite.kCollisionTypeOverlap)
			local sprite = collision.sprite
			local other = collision.other
			if overlap then
				merged = true
				otherTile = other
				-- return actualX, actualY, merged, otherTile
			end
		end
	end
	if useAnimator or true then
		-- Animation
		self.animatorEndPoint = playdate.geometry.point.new(actualX, actualY)
		self.animator = playdate.graphics.animator.new(100, self.animatorStartPoint, self.animatorEndPoint)
		-- self:setAnimator(animator)
	end
	return actualX, actualY, merged, otherTile

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
