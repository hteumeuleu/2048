import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/animator"
import "Game"
import "Grid"
import "Tile"
import "Cursor"

gGridSize = 240
gGridRadius = 4
gGridBorderSize = 8
gTileSize = 50
gTileRadius = 2
gMove = gGridBorderSize + gTileSize

local game = Game()

-- Background drawing callback.
-- Because we use a sprite, we need to have this callback.
playdate.graphics.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
		playdate.graphics.setClipRect(x, y, width, height)
			game.grid:draw()
		playdate.graphics.clearClipRect()
	end
)

-- playdate.update()
--
function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	game:update()

end