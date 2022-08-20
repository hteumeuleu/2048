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
	self:setCollisionsEnabled(false)
	return self

end

-- setAngle(angle)
--
function Cursor:setAngle(angle)

	self.angle = math.rad(angle - 90)
	local x = 400 - (gGridSize / 2) + math.cos(self.angle) * kImaginaryCircleRadius
	local y = 120 + math.sin(self.angle) * kImaginaryCircleRadius
	self:moveTo(x, y)

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