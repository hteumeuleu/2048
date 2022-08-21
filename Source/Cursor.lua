class('Cursor').extends(playdate.graphics.sprite)

local kCursorSize <const> = 24
local kCursorRadius <const> = kCursorSize / 2
local kCursorBorderSize <const> = 2
local kImaginaryCircleRadius <const> = 120 - kCursorRadius

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

-- function Cursor:add()

-- 	Cursor.super:add(self)
-- 	self:setScale(1)

-- end

function Cursor:update()

	Cursor.super:update(self)

	if self.hideAnimator ~= nil then
		if not self.hideAnimator:ended() then
			self:setScale(self.hideAnimator:currentValue())
		else
			print("remove")
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

	local polygon = playdate.geometry.polygon.new(400 - gGridSize + kCursorRadius, kCursorRadius, 400 - kCursorRadius, kCursorRadius, 400 - kCursorRadius, 240 - kCursorRadius, 400 - gGridSize + kCursorRadius, 240 - kCursorRadius)
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
		local offset = 2
		-- Shadow
		-- playdate.graphics.setPattern({0x77, 0xFF, 0xDD, 0xFF, 0x77, 0xFF, 0xDD, 0xFF})
		-- playdate.graphics.fillCircleInRect(0 + offset, 0 + (offset * 2), self.width - (offset * 2), self.height - (offset * 2), kCursorRadius)
		-- Inside
		-- playdate.graphics.setPattern({0x77, 0xFF, 0xDD, 0xFF, 0x77, 0xFF, 0xDD, 0xFF})
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillCircleInRect(0, 0, self.width, self.height, kCursorRadius)
		-- Outline
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setLineWidth(kCursorBorderSize)
		playdate.graphics.drawCircleInRect(0 + offset, 0, self.width - (offset * 2), self.height - (offset * 2), kCursorRadius)
	playdate.graphics.popContext()
	self:setImage(img)

end