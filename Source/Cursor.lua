class('Cursor').extends(playdate.graphics.sprite)

local kCursorSize <const> = 48
local kCursorRadius <const> = kCursorSize / 2
local kCursorBorderSize <const> = 2
local kCursorOffset <const> = 2

-- Cursor
--
-- Sprite shown while using the crank.
function Cursor:init()

	Cursor.super.init(self)
	self.width = gGridSize
	self.height = gGridSize
	self.point = playdate.geometry.point.new(0, 0)
	self:setZIndex(10)
	self:drawImage()
	self:initAnimator()
	self:setCollisionsEnabled(false)
	self:moveTo(400 - (gGridSize / 2), 240 - (gGridSize / 2))
	return self

end

-- update()
--
function Cursor:update()

	Cursor.super:update(self)
	-- if self.hideAnimator ~= nil and self.hideAnimator:ended() then
	-- 	self:remove()
	-- end

	if self.hideAnimator ~= nil then
		if not self.hideAnimator:ended() then
			self:drawImage()
			-- self:setScale(self.hideAnimator:currentValue())
		else
			self:remove()
		end
	end
end

-- setAngle(angle)
--
function Cursor:setAngle(angle)

	self.point = self.animator:valueAtTime(angle + 45)
	self:drawImage()

end

-- show()
--
function Cursor:show()

	self.hideAnimator = nil
	self:add()

end

-- hide()
--
function Cursor:hide()

	if self.hideAnimator ~= nil then
		self.hideAnimator:reset()
	else
		self.hideAnimator = playdate.graphics.animator.new(300, 1, 0, playdate.easingFunctions.inOutCubic)
	end

end

-- initAnimator()
--
-- Creates a polygon used within an animator to represent the path of the Cursor around the grid.
function Cursor:initAnimator()

	local polygon = playdate.geometry.polygon.new(kCursorOffset, kCursorOffset, gGridSize - kCursorOffset, kCursorOffset, gGridSize - kCursorOffset, gGridSize - kCursorOffset, kCursorOffset, gGridSize - kCursorOffset)
	polygon:close()
	self.animator = playdate.graphics.animator.new(360, {polygon}, playdate.easingFunctions.linear)
	self.animator.repeatCount = -1

end

-- drawImage()
--
-- Draws the image of the cursor.
function Cursor:drawImage()

	local mask = playdate.graphics.image.new(gGridSize, gGridSize, playdate.graphics.kColorBlack)
	playdate.graphics.pushContext(mask)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		local dynamicRadius = kCursorRadius
		if self.hideAnimator ~= nil then
			if not self.hideAnimator:ended() then
				dynamicRadius = map(self.hideAnimator:currentValue(), 1, 0, kCursorRadius, 1)
			else
				dynamicRadius = 0
			end
		end
		playdate.graphics.fillCircleAtPoint(self.point.x, self.point.y, dynamicRadius)
	playdate.graphics.popContext()

	local img = playdate.graphics.image.new(gGridSize, gGridSize, playdate.graphics.kColorClear)
	playdate.graphics.pushContext(img)
		playdate.graphics.setStencilImage(mask)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.drawRoundRect(kCursorOffset, kCursorOffset, gGridSize - (2 * kCursorOffset), gGridSize - (2 * kCursorOffset), 4)
	playdate.graphics.popContext()

	self:setImage(img)

end