class('Cursor').extends(playdate.graphics.sprite)

local kCursorSize <const> = 16
local kCursorRadius <const> = kCursorSize / 2
local kCursorBorderSize <const> = 3
local kImaginaryCircleRadius <const> = 120 - kCursorRadius

function Cursor:init()

	Cursor.super.init(self)
	self.width = kCursorSize
	self.height = kCursorSize
	self:setZIndex(10)
	self:initImage()
	return self

end

-- setAngle(angle)
--
function Cursor:setAngle(angle)

	self.angle = math.rad(angle - 90)
	local x = 200 + math.cos(self.angle) * kImaginaryCircleRadius
	local y = 120 + math.sin(self.angle) * kImaginaryCircleRadius
	print(self.angle, playdate.geometry.point.new(x, y))
	self:moveTo(x, y)

end

-- initImage()
--
-- Creates the image to be drawn with the cursor.
function Cursor:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillCircleInRect(0, 0, self.width, self.height, kCursorRadius)
		-- Foreground
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillCircleInRect(kCursorBorderSize, kCursorBorderSize, self.width - (2 * kCursorBorderSize), self.height - (2 * kCursorBorderSize), kCursorRadius)
	playdate.graphics.popContext()
	self:setImage(img)

end