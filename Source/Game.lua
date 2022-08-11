class('Game').extends()

function Game:init()

	Game.super.init(self)
	self.startTiles = 2
	self.cursor = Cursor()

	-- Background drawing callback.
	-- Because we use a sprite, we need to have this callback.
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			playdate.graphics.setClipRect(x, y, width, height)
				self:drawTitle()
				self.grid:draw()
			playdate.graphics.clearClipRect()
		end
	)

	self:initInputHandlers()
	self:setup()

	return self

end

-- update()
--
function Game:update()

	self.grid:update()

end

-- restart()
--
function Game:restart()

	self:setup()

end

-- setup()
--
function Game:setup()

	self.over = false
	self.won = false
	self.keepPlaying = false
	self.grid = Grid()
	self:addStartTiles()

end

-- addStartTiles()
--
function Game:addStartTiles()

	for i=1, self.startTiles, 1 do
		self.grid:addRandomTile()
	end

end

-- hasAvailableMoves()
--
function Game:hasAvailableMoves()

	return self.grid:hasAvailableMatches()

end

-- drawTitle()
--
function Game:drawTitle()

	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	local font = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
	playdate.graphics.setFont(font)
	playdate.graphics.drawTextInRect("*2048*", 8, 8 + (50 - font:getHeight()) / 2, 144, font:getHeight(), nil, nil, kTextAlignment.center)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)

end

-- initInputHandlers()
--
-- Add control handlers.
function Game:initInputHandlers()

	local gameInputHandlers = {
		AButtonDown = function()
			print(self.grid)
		end,
		leftButtonDown = function()
			self:moveLeft()
		end,
		rightButtonDown = function()
			self:moveRight()
		end,
		upButtonDown = function()
			self:moveUp()
		end,
		downButtonDown = function()
			self:moveDown()
		end,
		cranked = function()
			local abs = playdate.getCrankPosition()
			self.cursor:setAngle(abs)
			self.cursor:add()
			local function hideCursorCallback()
				self.cursor:remove()
			end
			local function afterCrankCallback(abs)
				if abs >= 45 and abs < 135 then
					self:moveRight()
				elseif abs >= 135 and abs < 225 then
					self:moveDown()
				elseif abs >= 225 and abs < 315 then
					self:moveLeft()
				elseif abs >= 315 or abs < 45 then
					self:moveUp()
				end
				self.hideCursorTimer = playdate.timer.performAfterDelay(1000, hideCursorCallback)
			end
			if(self.hideCursorTimer ~= nil) then
				self.hideCursorTimer:remove()
			end
			if(self.crankTimer ~= nil) then
				self.crankTimer:remove()
			end
			self.crankTimer = playdate.timer.performAfterDelay(100, afterCrankCallback, abs)
		end,
	}
	playdate.inputHandlers.push(gameInputHandlers)

end

-- Shorthand functions for game movements
function Game:moveUp() 		self.grid:move(1) end
function Game:moveRight() 	self.grid:move(2) end
function Game:moveDown() 	self.grid:move(3) end
function Game:moveLeft()	self.grid:move(4) end