class('Points').extends(playdate.graphics.sprite)

function Points:init(value)

	Points.super.init(self)
	self.value = value
	self.text = "+" .. value
	local textWidth, textHeight = playdate.graphics.getTextSize(self.text, gFontFullCircle)
	self.width = textWidth + 8
	self.height = textHeight
	self:drawImage()
	self:add()
	self:moveTo(54, 44)
	return self

end

-- drawImage()
--
function Points:drawImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, 4)
		-- Text
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawText("+" .. self.value, 4, 3)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.popContext()
	self:setImage(img)

end