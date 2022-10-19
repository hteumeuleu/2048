class('Game').extends()

-- Game
--
-- The main class running the game.
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
	if not self:hasAvailableMoves() and not self.gameOverIsOnScreen then
		self:drawGameOverScreen()
	end

end

-- setup()
--
-- Init game variables and a new grid when a new game is started.
function Game:setup()

	self.gameOverIsOnScreen = false
	self.restartTimer = nil
	self.restartTimerDuration = 1000
	self.restartTimerAngle = 1
	self.restartTimerCooldownAngle = 1
	self.score = Score("Score", 1)
	self.bestScore = Score("Best", 2)
	self.bestScore:load()
	self.grid = Grid(self)
	self:cancelRestartTimer()
	if self:hasSave() then
		self:addStartTilesFromSave()
	else
		self:addStartTiles()
	end
	self:setBackgroundDrawingCallback()

end

-- startRestartTimer()
--
-- Starts a timer before restarting a new game.
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

-- restart()
--
function Game:restart()

	playdate.graphics.sprite.removeAll()
	self:setup()

end

-- setBackgroundDrawingCallback()
--
function Game:setBackgroundDrawingCallback()

	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			playdate.graphics.setClipRect(x, y, width, height)
				self:drawButton()
				self.grid:draw()
			playdate.graphics.clearClipRect()
		end
	)

end

-- addStartTiles()
--
function Game:addStartTiles()

	for i=1, self.startTiles, 1 do
		self.grid:addRandomTile()
	end

end

-- addStartTilesFromSave()
--
function Game:addStartTilesFromSave()

	local data = playdate.datastore.read("save")
	local hasAddedTiles = false
	local addedTiles = 0
	if data ~= nil then
		local tiles = split(data[1], ",")
		for i=1, #tiles, 1 do
			local value = tiles[i]
			if value ~= "x" then
				local col = math.ceil((i - 1) % 4 + 1)
				local row = math.ceil(i / 4)
				self.grid:addTile(col, row, value)
				addedTiles += 1
			end
		end
		local score = data[2]
		if data[2] ~= nil then
			self.score:setValue(data[2])
			self.score:update()
		end
		playdate.datastore.delete("save")
	end
	if addedTiles < self.startTiles then
		self:addStartTiles()
	end

end

-- hasAvailableMoves()
--
function Game:hasAvailableMoves()

	return self.grid:hasAvailableMatches()

end

-- drawButton()
--
-- Draw the “New Game” button.
function Game:drawButton()

	local defaultFont = playdate.graphics.getSystemFont()
	local defaultFontHeight = defaultFont:getHeight()

	if self.restartTimer ~= nil or self.restartCooldownTimer ~= nil then
		playdate.graphics.setLineWidth(2)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeCentered)
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

-- drawGameOverScreen()
--
function Game:drawGameOverScreen()

	self.gameOverIsOnScreen = true
	local gameoverImage = playdate.graphics.image.new(gGridSize, gGridSize)
	local gameover = playdate.graphics.sprite.new()
	function gameover:draw()
		local img = playdate.graphics.image.new(self.width, self.height)
		playdate.graphics.pushContext(img)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.fillRect(0, 0, self.width, self.height)
		playdate.graphics.popContext()
		img:drawFaded(0, 0, 0.8, playdate.graphics.image.kDitherTypeDiagonalLine)
		-- Text
		local w = (gTileSize * 2.5 + gGridBorderSize * 2)
		local x = math.floor((gGridSize - w) / 2)
		local y = math.floor((gGridSize - gTileSize) / 2)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(x, y, w, gTileSize, gGridRadius + 2)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.drawRoundRect(x + 4, y + 4, w - 8, gTileSize - 8, gGridRadius)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		y = math.floor((gGridSize - gFontFullCircle:getHeight()) / 2)
		playdate.graphics.setFont(gFontFullCircle)
		playdate.graphics.drawTextInRect("GAME OVER", 0, y, gGridSize, gGridSize, nil, nil, kTextAlignment.center)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	end
	gameover:setCenter(0, 0)
	gameover:setSize(gGridSize, gGridSize)
	gameover:moveTo(400 - gGridSize, 240 - gGridSize)
	gameover:setZIndex(9999)
	playdate.timer.performAfterDelay(500, function()
		gameover:add()
	end)

end

-- save()
--
function Game:save()

	playdate.datastore.write({self.grid:serialize(), self.score:getValue()}, "save")

end

-- hasSave()
--
function Game:hasSave()

	local data = playdate.datastore.read("save")
	return data ~= nil

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
			if self:hasAvailableMoves() then
				self:moveLeft()
			end
		end,
		rightButtonDown = function()
			if self:hasAvailableMoves() then
				self:moveRight()
			end
		end,
		upButtonDown = function()
			if self:hasAvailableMoves() then
				self:moveUp()
			end
		end,
		downButtonDown = function()
			if self:hasAvailableMoves() then
				self:moveDown()
			end
		end,
		cranked = function(change, acceleratedChange)
			if math.abs(change) > 0.005 and self:hasAvailableMoves() then
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
			end
		end,
	}
	playdate.inputHandlers.push(gameInputHandlers)

end

-- Shorthand functions for game movements
function Game:moveUp() 		self.grid:move(1) end
function Game:moveRight() 	self.grid:move(2) end
function Game:moveDown() 	self.grid:move(3) end
function Game:moveLeft()	self.grid:move(4) end