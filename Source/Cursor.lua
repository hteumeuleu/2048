class('Cursor').extends(playdate.graphics.sprite)

local kCursorSize <const> = 16
local kCursorRadius <const> = kCursorSize / 2
local kCursorBorderSize <const> = 2

function Cursor:init()

	Cursor.super.init(self)
	self.width = kCursorSize
	self.height = kCursorSize
	self:setZIndex(10)
	self:initImage()
	self:initAnimator()
	self:setCollisionsEnabled(false)
	return self

end

function Cursor:addCircleAnimation()

	self.circleAnimator = playdate.graphics.animator.new(500, 0, 100)

end

function Cursor:resetCircleAnimation()

	if self.circleAnimator ~= nil then
		self.circleAnimator:reset()
	else
		self:addCircleAnimation()
	end

end

function Cursor:update()

	Cursor.super:update(self)

	if self.circleAnimator ~= nil and not self.circleAnimator:ended() then
		self:initImage()
	end

	if self.hideAnimator ~= nil then
		if not self.hideAnimator:ended() then
			self:setScale(self.hideAnimator:currentValue())
		else
			self:remove()
		end
	end
end

-- setAngle(angle)
--
function Cursor:setAngle(angle)

	local p = self.animator:valueAtTime(angle + 45)
	self:moveTo(p)

end

-- show
--
function Cursor:show()

	self.hideAnimator = nil
	self:setScale(1)
	self:add()

end

-- hide
--
function Cursor:hide()

	if self.hideAnimator ~= nil then
		self.hideAnimator:reset()
	else
		self.hideAnimator = playdate.graphics.animator.new(300, 1, 0, playdate.easingFunctions.inOutCubic)
	end

end

-- initAnimator
--
function Cursor:initAnimator()

	local offset = 2
	local polygon = playdate.geometry.polygon.new(400 - gGridSize + kCursorRadius + offset, kCursorRadius + offset, 400 - kCursorRadius - offset, kCursorRadius + offset, 400 - kCursorRadius - offset, 240 - kCursorRadius - offset, 400 - gGridSize + kCursorRadius + offset, 240 - kCursorRadius - offset)
	polygon:close()
	self.animator = playdate.graphics.animator.new(360, {polygon}, playdate.easingFunctions.linear)
	self.animator.repeatCount = -1

end

-- initImage()
--
-- Creates the image to be drawn with the cursor.
function Cursor:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		local offset = 0
		-- Inside
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillCircleInRect(0, 0, self.width, self.height, kCursorRadius)
		-- Outline
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setLineWidth(kCursorBorderSize)
		playdate.graphics.drawCircleInRect(0 + offset, 0, self.width - (offset * 2), self.height - (offset * 2), kCursorRadius)
		-- Inner Circle
		if self.circleAnimator ~= nil and not self.circleAnimator:ended() then
			local innerCircleRadius = kCursorRadius - (offset * 2)
			local r = self.circleAnimator:currentValue() * innerCircleRadius / 100
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.fillCircleAtPoint(self.width / 2, self.height / 2 - offset, r)
		end
	playdate.graphics.popContext()
	self:setImage(img)

end