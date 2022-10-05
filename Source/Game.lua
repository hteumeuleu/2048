class('Game').extends()

function Game:init()

	Game.super.init(self)
	self.startTiles = 2
	self.cursor = Cursor()
	self:initInputHandlers()
	self:setup()

	return self

end

-- update()
--
function Game:update()

	self.grid:update()
	if self.restartTimer ~= nil or self.restartCooldownTimer ~= nil then
		self:drawButton()
	end

end

-- cancelRestartTimer()
--
function Game:cancelRestartTimer()

	if self.restartTimer ~= nil then
		self.restartTimer:remove()
		self.restartTimer = nil
		local timerDuration = self.restartTimerDuration / 2
		self.restartCooldownTimer = playdate.timer.new(timerDuration)
	end

end

-- startRestartTimer()
--
function Game:startRestartTimer()


	if self.restartCooldownTimer ~= nil then
		self.restartCooldownTimer:remove()
		self.restartCooldownTimer = nil
	end
	local timerDuration = self.restartTimerDuration
	self.restartTimer = playdate.timer.new(timerDuration, function()
		self:restart()
		self.restartTimerAngle = 1
		self.restartTimerCooldownAngle = 1
	end)

end



-- restart()
--
function Game:restart()

	playdate.graphics.sprite.removeAll()
	self:setup()

end

-- setBackgroundDrawingCallback()
--
function Game:setBackgroundDrawingCallback()

	-- Background drawing callback.
	-- Because we use a sprite, we need to have this callback.
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			playdate.graphics.setClipRect(x, y, width, height)
				self:drawVirtualScreen()
				self:drawButton()
				self.grid:draw()
			playdate.graphics.clearClipRect()
		end
	)

end

-- setup()
--
function Game:setup()

	self.over = false
	self.won = false
	self.keepPlaying = false
	self.restartTimer = nil
	self.restartTimerDuration = 1000
	self.restartTimerAngle = 1
	self.restartTimerCooldownAngle = 1
	self.grid = Grid()
	self:cancelRestartTimer()
	self:addStartTiles()
	self:setBackgroundDrawingCallback()

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

-- drawButton()
--
function Game:drawButton()

	local defaultFont = playdate.graphics.getSystemFont()
	local defaultFontHeight = defaultFont:getHeight()

	if self.restartTimer ~= nil or self.restartCooldownTimer ~= nil then
		playdate.graphics.setLineWidth(2)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		local circleY = 240 - (gGridBorderSize / 2) - defaultFontHeight
		local circleRadius = 12
		local endAngle = 1
		if self.restartTimer ~= nil then
			endAngle = map(self.restartTimer.currentTime, 0, self.restartTimer.duration, self.restartTimerCooldownAngle, 360)
			self.restartTimerAngle = endAngle
		elseif self.restartCooldownTimer ~= nil then
			endAngle = map(self.restartCooldownTimer.currentTime, 0, self.restartCooldownTimer.duration, self.restartTimerAngle, 1)
			self.restartTimerCooldownAngle = endAngle
		end
		playdate.graphics.drawArc(8 + (circleRadius / 2) + 3, circleY + (circleRadius / 2) + 3, circleRadius, 0, endAngle)
	end

	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.setFont(defaultFont)
		playdate.graphics.drawText("Ⓐ", 8, 240 - (gGridBorderSize / 2) - defaultFontHeight)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawText(string.upper("New Game"), 32, 240 - (gGridBorderSize / 2) - defaultFont:getHeight() + 2)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)

end

-- drawVirtualScreen()
--
function Game:drawVirtualScreen()

	playdate.graphics.setPattern({0x0, 0x0, 0x8, 0x10, 0x20, 0x40, 0x80, 0x0})
	playdate.graphics.fillRoundRect(gGridBorderSize, gGridBorderSize + 50 + gGridBorderSize, 144, 144, 4)

	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		local font = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
		playdate.graphics.setFont(font)
		playdate.graphics.drawTextInRect("*2048*", 8, 8 + 50 + 8 + (144 - font:getHeight()) / 2, 144, font:getHeight(), nil, nil, kTextAlignment.center)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)

end

-- initInputHandlers()
--
-- Add control handlers.
function Game:initInputHandlers()

	local gameInputHandlers = {
		BButtonDown = function()
			print(self.grid)
		end,
		AButtonUp = function()
			self:cancelRestartTimer()
		end,
		AButtonDown = function()
			self:startRestartTimer()
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
			self.cursor:show()
			local function hideCursorCallback()
				self.cursor:hide()
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
			-- Growing circle animation
			self.cursor:resetCircleAnimation()
			-- Remove the timer to hide the cursor
			if(self.hideCursorTimer ~= nil) then
				self.hideCursorTimer:remove()
			end
			-- Remove the timer that executes the action
			if(self.crankTimer ~= nil) then
				self.crankTimer:remove()
			end
			self.crankTimer = playdate.timer.performAfterDelay(500, afterCrankCallback, abs)
		end,
	}
	playdate.inputHandlers.push(gameInputHandlers)

end

-- Shorthand functions for game movements
function Game:moveUp() 		self.grid:move(1) end
function Game:moveRight() 	self.grid:move(2) end
function Game:moveDown() 	self.grid:move(3) end
function Game:moveLeft()	self.grid:move(4) end