class('Score').extends(playdate.graphics.sprite)

function Score:init(text, y)

	Score.super.init(self)
	self.previousValue = 0
	self.value = 0
	self.width = 56
	self.height = 32
	self.text = string.lower(text)
	self:drawImage()
	self:setCollisionsEnabled(false)
	self:moveTo(356, y)
	self:add()
	return self

end

function Score:load()

	local data = playdate.datastore.read(self.text)
	if data ~= nil then
		self.value = data[1]
		self:checkMaxValue()
	end

end

function Score:save()

	playdate.datastore.write({self.value, "I didn't bother to make this any obfuscated, but that's not a reason for you to cheat here. Enjoy the game at your own pace."}, self.text)

end

function Score:getValue()

	return self.value

end

function Score:setValue(value)

	self.value = value
	self:checkMaxValue()

end

function Score:addToValue(value)

	self.value = self.value + value
	self:checkMaxValue()

end

function Score:update()

	if self.value ~= self.previousValue then
		self:drawImage()
		self.previousValue = self.value
	end

end

function Score:checkMaxValue()

	if self.value > 999999 then
		self.value = 999999
	end

end

-- initImage()
--
function Score:drawImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		-- Background
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, self.width, self.height, gTileRadius)
		-- Text
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawTextInRect(string.upper(self.text), 0, 2, self.width, self.height, nil, nil, kTextAlignment.center)
		playdate.graphics.drawTextInRect("" .. self.value, 0, 16, self.width, self.height, nil, nil, kTextAlignment.center)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.popContext()
	self:setImage(img)

end