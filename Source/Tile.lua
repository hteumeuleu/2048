class('Tile').extends(playdate.graphics.sprite)

local kTileSize <const> = 50
local kTileRadius <const> = 4

function Tile:init(x, y, value)

	Tile.super.init(self)
	self.xInGrid = x
	self.yInGrid = y
	self.value = value
	self.width = kTileSize
	self.height = kTileSize
	self:initImage()
	self:setCollideRect(0, 0, self.width, self.height)
	self:setTag(value)
	self:add()

end

function Tile:initImage()

	local img = playdate.graphics.image.new(self.width, self.height)
	playdate.graphics.pushContext(img)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(0, 0, kTileSize, kTileSize, kTileRadius)
		playdate.graphics.drawTextInRect("*" .. self.value .. "*", 0, 16, self.width, self.height, nil, nil, kTextAlignment.center)
	playdate.graphics.popContext()
	self:setImage(img)

end
