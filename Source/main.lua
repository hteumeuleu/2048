import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

local kGridSize <const> = 240
local kGridBorderSize <const> = 8
local kGridCellSize <const> = (kGridSize - (kGridBorderSize * 5)) / 4
local kGridRadius <const> = 4
local kGridCellRadius <const> = 2
local kGridX <const> = (400 - kGridSize) / 2
local kGridY <const> = (240 - kGridSize) / 2

playdate.graphics.clear(playdate.graphics.kColorBlack)
-- Draw outer grid.
playdate.graphics.setColor(playdate.graphics.kColorBlack)
playdate.graphics.fillRoundRect(kGridX, kGridY, kGridSize, kGridSize, kGridRadius)
-- Draw cells.
playdate.graphics.setColor(playdate.graphics.kColorWhite)
for y=1,4,1
do
	for x=1,4,1
	do
		local cellX = kGridX + (kGridBorderSize * x) + (kGridCellSize * (x - 1))
		local cellY = kGridY + (kGridBorderSize * y) + (kGridCellSize * (y - 1))
		playdate.graphics.fillRoundRect(cellX, cellY, kGridCellSize, kGridCellSize, kGridCellRadius)
		if x == 1 and y == 4 then
			playdate.graphics.drawTextInRect("*2*", cellX, cellY + 16, kGridCellSize, kGridCellSize, nil, nil, kTextAlignment.center)
		end
	end
end

-- playdate.update()
--
function playdate.update()

	playdate.timer.updateTimers()

end