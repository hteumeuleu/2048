class('Tile').extends(playdate.graphics.sprite)

local kTileCollisionGroup = 1
local kTileSecretId = 1

-- Tile
--
-- A single game’s tile within the Grid.
function Tile:init(value)

	Tile.super.init(self)
	self.value = value
	self.isNew = true
	self:setSize(gTileSize, gTileSize)
	self:setTag(log2(value))
	self:initImage()
	self:setCollideRect(gGridBorderSize / 2 * -1, gGridBorderSize / 2 * -1, self.width + gGridBorderSize, self.height + gGridBorderSize)
	self:setGroups({kTileCollisionGroup})
	self:setCollidesWithGroups({kTileCollisionGroup})
	self:add()
	self.secretId = kTileSecretId
	kTileSecretId = kTileSecretId + 1
	self.animators = {}
	return self

end

-- __tostring()
--
function Tile:__tostring()
	return self.secretId .. "[" .. self.value .. "]"
end

-- update()
--
function Tile:update()

	self:updateCustomAnimators()

end

-- initImage()
--
-- Creates the image to be drawn with the tile.
-- It's a simple RoundRect but with a slight offset to give an height effect depending on the Tile value.
function Tile:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	local kTileHeightOffset = math.floor(map(log2(self.value) - 1, 0, 10, 0, 5))
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
		if self:getTag() >= 14 then
			playdate.graphics.setFontTracking(-2)
		end
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

	local previousX = self.x
	local previousY = self.y
	local actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	if actualX ~= previousX or actualY ~= previousY then
		self.moved = true
	end
	if length > 0 then
		for _, collision in ipairs(collisions) do
			local overlap = (collision.type == playdate.graphics.sprite.kCollisionTypeOverlap)
			if overlap then
				local sprite = collision.sprite
				local other = collision.other
				sprite.mustBeRemoved = true
				other.mustBeMerged = true
			end
		end
	end
	self.animator = nil
	self.animatorStartPoint = playdate.geometry.point.new(previousX, previousY)
	self.animatorEndPoint = playdate.geometry.point.new(actualX, actualY)
	self.animator = playdate.graphics.animator.new(100, self.animatorStartPoint, self.animatorEndPoint)
	self:setAnimator(self.animator, false, false)
	return actualX, actualY

end

-- collisionResponse()
--
-- Sets the collision response in case of a collision.
-- If we hit another similar Tile, we want them to overlap.
-- Otherwise we want the Tile to be blocked (freeze).
function Tile:collisionResponse(other)

	if other.mustBeRemoved or other.mustBeMerged or other:getTag() ~= self:getTag() then
		return playdate.graphics.sprite.kCollisionTypeFreeze
	else
		return playdate.graphics.sprite.kCollisionTypeOverlap
	end

end

-- addCustomAnimator()
--
function Tile:addCustomAnimator(animator, type, callback)

	if animator ~= nil and not animator:ended() then
		-- Check if animator is not applied yet
		for key, value in ipairs(self.animators) do
			if value.animator == animator then
				return animator
			end
		end
		-- Create data object
		local animatorData = {}
		animatorData.animator = animator
		animatorData.type = type
		animatorData.callback = callback
		table.insert(self.animators, animatorData)
		-- Apply animator directly if it's for moving the tile
		if type == nil or type == "move" then
			self:setAnimator(animator, false, false)
		end
	end

end

-- removeCustomAnimator(animator)
--
function Tile:removeCustomAnimator(animator)

	for key, value in ipairs(self.animators) do
		if value.type == nil or value.type == "move" then
			self:removeAnimator()
			table.remove(self.animators, key)
		elseif value.animator == animator then
			table.remove(self.animators, key)
		end
	end

end

-- updateCustomAnimators()
--
function Tile:updateCustomAnimators()

	for key, value in ipairs(self.animators) do
		if value.animator:ended() then
			-- Callback function if animation has ended
			if value.callback ~= nil and type(value.callback) == "function" then
				value.callback(self)
			end
			-- Reset to initial value after animation
			if value.type == "scale" then
				local initialValue = 1
				if value.animator.reverses == true then
					initialValue = value.animator:valueAtTime(0)
				else
					initialValue = value.animator:valueAtTime(value.animator.duration)
				end
				self:setScale(initialValue)
			end
			self:removeCustomAnimator(value.animator)
		end
		-- Animation update
		if not value.animator:ended() then
			-- Scale
			if value.type == "scale" then
				self:setScale(value.animator:currentValue())
			end
		end
	end

end

-- isAnimating()
--
function Tile:isAnimating()

	local isAnimating = false
	for key, value in ipairs(self.animators) do
		if not value.animator:ended() then
			isAnimating = true
		end
	end
	return isAnimating

end