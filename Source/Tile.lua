class('Tile').extends(playdate.graphics.sprite)

local kTileCollisionGroup = 1
local kTileSecretId = 1

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
	self.secretId = kTileSecretId
	kTileSecretId = kTileSecretId + 1
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
	local kTileHeightOffset = 0
	if self.value >= 2048 then
		kTileHeightOffset = 10
	elseif self.value >= 1024 then
		kTileHeightOffset = 9
	elseif self.value >= 512 then
		kTileHeightOffset = 8
	elseif self.value >= 256 then
		kTileHeightOffset = 7
	elseif self.value >= 128 then
		kTileHeightOffset = 6
	elseif self.value >= 64 then
		kTileHeightOffset = 5
	elseif self.value >= 32 then
		kTileHeightOffset = 4
	elseif self.value >= 16 then
		kTileHeightOffset = 3
	elseif self.value >= 8 then
		kTileHeightOffset = 2
	elseif self.value >= 4 then
		kTileHeightOffset = 1
	end
	local kTileBorderSize = 2
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, gTileRadius)
		-- Foreground
		local innerTileWidth = self.width - (2 * kTileBorderSize)
		local innerTileHeight = self.height - (2 * kTileBorderSize) - kTileHeightOffset
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(kTileBorderSize, kTileBorderSize, self.width - (2 * kTileBorderSize), innerTileHeight, gTileRadius)
		local font = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
		local fontHeight = font:getHeight()
		local arbitraryValueToFixFontHeightWeirdness = 2
		local textY = (innerTileHeight - fontHeight) / 2 + kTileBorderSize + arbitraryValueToFixFontHeightWeirdness
		playdate.graphics.drawTextInRect("*" .. self.value .. "*", 0, textY, self.width, self.height, nil, nil, kTextAlignment.center)
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

	self.animator = nil
	self.animatorStartPoint = playdate.geometry.point.new(self.x, self.y)
	local actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	if length > 0 then
		for _, collision in ipairs(collisions) do
			local overlap = (collision.type == playdate.graphics.sprite.kCollisionTypeOverlap)
			local sprite = collision.sprite
			local other = collision.other
			if overlap then
				sprite.mustBeRemoved = true
				other.mustBeMerged = true
			end
		end
	end
	self.animatorEndPoint = playdate.geometry.point.new(actualX, actualY)
	self.animator = playdate.graphics.animator.new(100, self.animatorStartPoint, self.animatorEndPoint)
	return actualX, actualY

end

-- collisionResponse()
--
-- Sets the collision response in case of a collision.
-- If we hit another similar Tile, we want them to overlap.
-- Otherwise we want the Tile to be blocked (freeze).
function Tile:collisionResponse(other)


	if other.mustBeRemoved or other.mustBeMerged then
		return playdate.graphics.sprite.kCollisionTypeFreeze
	end
	if other:getTag() == self:getTag() then
		return playdate.graphics.sprite.kCollisionTypeOverlap
	else
		return playdate.graphics.sprite.kCollisionTypeFreeze
	end

end
