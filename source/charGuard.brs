' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: September 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' **  Guards Original AI code ported from: https://github.com/SimonHung/LodeRunner_TotalRecall
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateGuard(level as object, guardPos as object) as object
    this = {}
    'Constants
    this.const = m.const
    'Properties
    this.charType = "guard"
    this.hasGold = 0
    this.inHole = false
    this.originalAI = true 'flag switch between the original AI or simple AI
    'Methods
    this.update = update_guard
    this.startLevel = start_level_guard
    this.tryDropGold = try_drop_gold_guard
    this.bestMove = best_move_guard
    this.scanFloor = scan_floor_guard
    this.scanDown = scan_down_guard
    this.scanUp = scan_up_guard
    'Initialize level variables
    this.startLevel(level, guardPos)
    return ImplementActor(this)
End Function

Sub start_level_guard(level as object, guardPos as object)
    m.level = level
    m.blockX = guardPos.x
    m.blockY = guardPos.y
    m.offsetX = 0
    m.offsetY = 0
    m.charAction = "runLeft"
    m.frameName = "guard_03"
    m.frame = 1
End Sub

Sub update_guard(runnerPos as object)
    x = m.blockX
    y = m.blockY
    curTile = m.level.map[x][y]
    hladr = (m.level.gold = 0)
    upTile = invalid
    downTile = invalid
    leftTile = invalid
    rightTile = invalid
    if y > 0 then upTile = m.level.map[x][y-1]
    if y < m.const.TILES_Y-1 then downTile = m.level.map[x][y+1]
    if x > 0 then leftTile = m.level.map[x-1][y]
    if x < m.const.TILES_X-1 then rightTile = m.level.map[x+1][y]
    if curTile.hole or m.inHole
        'Release gold
        if curTile.hole and m.hasGold > 0
            m.level.map[m.blockX][m.blockY-1].base = m.const.MAP_GOLD
            m.level.map[m.blockX][m.blockY-1].bitmap = "gold"
            m.level.map[m.blockX][m.blockY-1].redraw = true
            m.hasGold = -10
        end if
        'Process Guard in Hole
        if m.offsetY = 0 and not m.inHole
            print "fall into hole"
            m.inHole = true
            m.charAction = m.charAction.Replace("fall", "shake")
            m.frame = 0
        else if left(m.charAction, 5) = "shake"
            print "shaking", m.frame
            actionArray = m.animations.sequence.Lookup(m.charAction)
            if m.frame = actionArray.Count() - 1
                print "end of shake"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
        end if
        if m.charAction = "runUpDown"
            if curTile.hole
                print "raising from hole"
                m.offsetX = 0
                m.offsetY -= m.const.MOVE_Y
                if m.offsetY < 0
                    m.blockY--
                    m.offsetY += m.const.TILE_HEIGHT
                end if
            else
                m.offsetX = 0
                m.offsetY -= m.const.MOVE_Y
                if m.offsetY <= 0
                    m.offsetY = 0
                    if not IsBarrier(leftTile) and (x > runnerPos.x or IsBarrier(rightTile))
                        m.charAction = "runLeft"
                        m.frame = 0
                    else if not IsBarrier(rightTile)
                        m.charAction = "runRight"
                        m.frame = 0
                    end if
                end if
            end if
        end if
        if m.charAction = "runLeft"
            m.offsetX -= m.const.MOVE_X
            if m.offsetX < 0
                m.blockX--
                m.offsetX += m.const.TILE_WIDTH
                m.inHole = false
            end if
        else if m.charAction = "runRight"
            m.offsetX += m.const.MOVE_X
            if m.offsetX >= m.const.TILE_WIDTH / 2
                m.blockX++
                m.offsetX -= m.const.TILE_WIDTH
                m.inHole = false
            end if
        end if
        m.state = m.STATE_MOVE
    else if m.originalAI
        if m.state = m.STATE_FALL or m.level.status = m.const.LEVEL_STARTUP
            m.move(m.const.ACT_NONE)
        else
            nextAction = m.bestMove(runnerPos)
            if nextAction = m.const.ACT_UP and not upTile.guard
                m.move(nextAction)
            else if nextAction = m.const.ACT_DOWN and not downTile.guard
                m.move(nextAction)
            else if nextAction = m.const.ACT_LEFT and not leftTile.guard
                m.move(nextAction)
            else if nextAction = m.const.ACT_RIGHT and not rightTile.guard
                m.move(nextAction)
            else
                m.move(m.const.ACT_NONE)
            end if
        end if
    else 'Simple AI for animation validation (deprecated)
        if m.state = m.STATE_FALL or m.inHole or m.level.status = m.const.LEVEL_STARTUP
            m.move(m.const.ACT_NONE)
        else if y > runnerPos.y and IsLadder(curTile, hladr) and not upTile.guard
            m.move(m.const.ACT_UP)
        else if y < runnerPos.y and IsLadder(downTile, hladr) and not downTile.guard
            m.move(m.const.ACT_DOWN)
        else if y < runnerPos.y and curTile.base = m.const.MAP_BAR and not IsFloor(downTile)
            m.move(m.const.ACT_DOWN)
        else if y < runnerPos.y and IsLadder(curTile, hladr) and not IsFloor(downTile)
            m.move(m.const.ACT_DOWN)
        else if x > runnerPos.x and not leftTile.guard
            m.move(m.const.ACT_LEFT)
        else if x < runnerPos.x and not rightTile.guard
            m.move(m.const.ACT_RIGHT)
        else
            m.move(m.const.ACT_NONE)
        end if
    end if
    'Update guard tile
    if m.blockX <> x or m.blockY <> y
        m.level.map[x][y].guard = false
        m.level.map[m.blockX][m.blockY].guard = true
    end if
    'Update animation frame
    m.frameUpdate()
End Sub

Sub try_drop_gold_guard()
    if m.hasGold > 1
        m.hasGold--
    else if m.hasGold = 1
        curTile = m.level.map[m.blockX][m.blockY]
        downTile = invalid
        if m.blockY < m.const.TILES_Y - 1
            downTile = m.level.map[m.blockX][m.blockY + 1]
        end if
        if IsEmpty(curTile) and IsFloor(downTile, true, false)
            m.level.map[m.blockX][m.blockY].base = m.const.MAP_GOLD
            m.level.map[m.blockX][m.blockY].bitmap = "gold"
            m.level.map[m.blockX][m.blockY].redraw = true
            m.hasGold = -1
        end if
    else if m.hasGold < 0
        m.hasGold++
    end if
End Sub

Function best_move_guard(runnerPos as object) as integer
	x = m.blockX
	y = m.blockY
	runnerX = runnerPos.x
	runnerY = runnerPos.y
    maxTileY = m.const.TILES_Y - 1
	map = m.level.map
	if y = runnerY or (runnerY = maxTileY and y = maxTileY - 1)
		while x <> runnerX
			if y < m.const.TILES_Y - 1
				downTile = map[x][y + 1]
			else
				downTile = invalid
			end if
			curTile = map[x][y]
			if IsLadder(curTile, false) or IsFloor(downTile, true) or IsBar(curTile) or IsBar(downTile) or IsGold(downTile)
				if x < runnerX
					x++
				else if x > runnerX
					x--
				end if
			else
				exit while
			end if
		end while
		if x = runnerX
			if m.blockX < runnerX
				nextMove = m.const.ACT_RIGHT
			else if m.blockX > runnerX
				nextMove = m.const.ACT_LEFT
            else
                nextMove = m.const.ACT_LEFT
			end if
			return nextMove
		end if
	end if
	return m.scanFloor(runnerPos)
End Function

Function scan_floor_guard(runnerPos as object) as integer
	x = m.blockX
	y = m.blockY
    maxTileX = m.const.TILES_X - 1
    maxTileY = m.const.TILES_Y - 1
	map = m.level.map
	guardAI = {curRating: 255, bestRating: 255, bestPath: m.const.ACT_NONE}
	'Calculate left limit
	guardAI.leftEnd = m.blockX
	while guardAI.leftEnd > 0
		curTile = map[guardAI.leftEnd - 1][y]
		if curTile.act = m.const.MAP_BLOCK or curTile.act = m.const.MAP_SOLID then exit while
		downTile = map[guardAI.leftEnd - 1][y + 1]
		if IsLadder(curTile, false) or IsBar(curTile) or y >= maxTileY or y < maxTileY and IsFloor(downTile, true, false)
			guardAI.leftEnd--
		else
			guardAI.leftEnd--
			exit while
		end if
	end while
	'Calculate right limit
	guardAI.rightEnd = m.blockX
	while guardAI.rightEnd < maxTileX
		curTile = map[guardAI.rightEnd + 1][y]
		if curTile.act = m.const.MAP_BLOCK or curTile.act = m.const.MAP_SOLID then exit while
		downTile = map[guardAI.rightEnd + 1][y + 1]
		if IsLadder(curTile, false) or isBar(curTile) or y >= maxTileY or y < maxTileY and IsFloor(downTile, true, false)
			guardAI.rightEnd++
		else
			guardAI.rightEnd++
			exit while
		end if
	end while
	'Scan from current position
	downTile = map[x][y + 1]
	if y < maxTileY and downTile.base <> m.const.MAP_BLOCK and downTile.base <> m.const.MAP_SOLID
		m.scanDown(x, m.const.ACT_DOWN, guardAI, runnerPos)
	end if
	if map[x][y].base = m.const.MAP_LADDR
		m.scanUp(x, m.const.ACT_UP, guardAI, runnerPos)
	end if
	'Scan left and right
	curPath = m.const.ACT_LEFT
	x = guardAI.leftEnd
	while true
		if x = m.blockX
			if curPath = m.const.ACT_LEFT and guardAI.rightEnd <> m.blockX
				curPath = m.const.ACT_RIGHT
				x = guardAI.rightEnd
			else
				exit while
			end if
		end if
		if y < maxTileY
            downTile = map[x][y + 1]
            if downTile.base <> m.const.MAP_BLOCK and downTile.base <> m.const.MAP_SOLID
			    m.scanDown(x, curPath, guardAI, runnerPos)
            end if
		end if
		if map[x][y].base = m.const.MAP_LADDR
			m.scanUp(x, curPath, guardAI, runnerPos)
		end if
		if curPath = m.const.ACT_LEFT then x++ else x--
	end while
	return guardAI.bestPath
End Function

Sub scan_down_guard(x as integer, curPath as integer, guardAI as object, runnerPos as object)
	runnerX = runnerPos.x
	runnerY = runnerPos.y
    maxTileX = m.const.TILES_X - 1
    maxTileY = m.const.TILES_Y - 1
	map = m.level.map
	y = m.blockY
	while y < maxTileY and map[x][y + 1].base <> m.const.MAP_BLOCK and map[x][y + 1].base <> m.const.MAP_SOLID
		if map[x][y].base <> m.const.MAP_EMPTY and map[x][y].base <> m.const.MAP_HLADR
			if x > 0
				downTile = map[x - 1][y + 1]
				if IsFloor(downTile, true, false) or map[x - 1][y].base = m.const.MAP_BAR
					if y >= runnerY then exit while
				end if
			end if
			if x < maxTileX
				downTile = map[x + 1][y + 1]
				if IsFloor(downTile, true, false) or map[x + 1][y].base = m.const.MAP_BAR
					if y >= runnerY then exit while
				end if
			end if
		end if
		y++
	end while
	if y = runnerY
		curRating = Abs(m.blockX - x)
	else if (y > runnerY)
		curRating = y - runnerY + 200
	else
		curRating = runnerY - y + 100
	end if
	if curRating < guardAI.bestRating
		guardAI.bestRating = curRating
		guardAI.bestPath = curPath
	end if
End Sub

Sub scan_up_guard(x as integer, curPath as integer, guardAI as object, runnerPos as object)
	runnerX = runnerPos.x
	runnerY = runnerPos.y
	map = m.level.map
	y = m.blockY
	while y > 0 and map[x][y].base = m.const.MAP_LADDR
		y--
		if x > 0
			downTile = map[x - 1][y + 1]
			if IsFloor(downTile, true, false) or map[x - 1][y].base = m.const.MAP_BAR
				if y <= runnerY then exit while
			end if
		end if
		if x < m.const.TILES_X - 1
			downTile = map[x + 1][y + 1]
			if IsFloor(downTile, true, false) or map[x + 1][y].base = m.const.MAP_BAR
				if y <= runnerY then exit while
			end if
		end if
	end while
	if y = runnerY
		curRating = Abs(m.blockX - x)
	else if y > runnerY
		curRating = y - runnerY + 200
	else
		curRating = runnerY - y + 100
	end if
	if curRating < guardAI.bestRating
		guardAI.bestRating = curRating
		guardAI.bestPath = curPath
	end if
End Sub
