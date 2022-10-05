import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/animator"
import "Utils"
import "Game"
import "Grid"
import "Tile"
import "Cursor"
import "Score"

gFontFullCircle = playdate.graphics.font.new("fonts/font-full-circle")
gGridSize = 240
gGridRadius = 4
gGridBorderSize = 8
gTileSize = 50
gTileRadius = 2
gMove = gGridBorderSize + gTileSize

playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)

local game = Game()

-- playdate.update()
--
function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	game:update()

end