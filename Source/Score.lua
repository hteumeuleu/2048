class('Score').extends(playdate.graphics.sprite)

function Score:init()

	Score.super.init(self)
	self.value = 0
	self.width = 56
	self.height = 32
	self:initImage()
	self:setCollisionsEnabled(false)
	self:moveTo(356, 24)
	self:add()
	return self

end

function Score:addToValue(value)

	self.value = self.value + value

end

function Score:update()

	self:initImage()

end

-- initImage()
--
function Score:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, gTileRadius)
		-- Text
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawTextInRect("SCORE", 0, 2, self.width, self.height, nil, nil, kTextAlignment.center)
		playdate.graphics.drawTextInRect("" .. self.value, 0, 16, self.width, self.height, nil, nil, kTextAlignment.center)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.popContext()
	self:setImage(img)

end