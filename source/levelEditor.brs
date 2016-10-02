' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: October 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Sub EditCustomLevel(levelId as integer)
    Sleep(250) ' Give time to Roku clear list screen from memory
    m.mainScreen.Clear(m.colors.black)
    m.mainScreen.SwapBuffers()
    map = m.custom.levels.Lookup("level-" + zeroPad(levelId, 3))
    this = {number: levelId, gold: 0, repeat: false, const: m.const, loadMap: load_map, saveMap: save_map}
    this.bitmaps = ["", "brick", "solid", "ladder", "rope", "trap", "hladder", "gold"]
    this.tileType = m.const.MAP_BLOCK
    this.map = this.LoadMap(map)
    blockX = 0
    blockY = 0
    showHelp = true
    showSaved = false
    while true
        m.mainScreen.Clear(m.colors.black)
        DrawCustomLevel(this, blockX, blockY)
        DrawCanvasGrid(blockX, blockY)
        if showHelp
            ShowEditorHelp()
            showHelp = false
            key = -1
        else if showSaved
            ShowSavedMessage()
            showSaved = false
            key = -1
        else
            m.mainScreen.SwapBuffers()
        	key = wait(0, m.port)
        end if
		if key = m.code.BUTTON_LEFT_PRESSED
            if blockX > 0 then blockX-- else blockX = m.const.TILES_X - 1
        else if key = m.code.BUTTON_RIGHT_PRESSED
            if blockX < m.const.TILES_X - 1 then blockX++ else blockX = 0
        else if key = m.code.BUTTON_UP_PRESSED
            if blockY > 0 then blockY-- else blockY = m.const.TILES_Y - 1
        else if key = m.code.BUTTON_DOWN_PRESSED
            if blockY < m.const.TILES_Y - 1 then blockY++ else blockY = 0
        else if key = m.code.BUTTON_INFO_PRESSED
            m.custom.levels.AddReplace("level-" + zeroPad(levelId, 3), this.saveMap())
            showSaved = true
        else if key = m.code.BUTTON_A_PRESSED
            showHelp = true
        else if key = m.code.BUTTON_FAST_FORWARD_PRESSED
            this.tileType++
            if this.tileType > m.const.MAP_GUARD then this.tileType = m.const.MAP_EMPTY
        else if key = m.code.BUTTON_REWIND_PRESSED
            this.tileType--
            if this.tileType < 0 then this.tileType = m.const.MAP_GUARD
        else if key = m.code.BUTTON_PLAY_PRESSED
            this.repeat = not this.repeat
        else if key = m.code.BUTTON_BACK_PRESSED
            exit while
        end if
        if key = m.code.BUTTON_SELECT_PRESSED or this.repeat
            if this.tileType = m.const.MAP_RUNNR
                this.map[blockX][blockY].base = m.const.MAP_EMPTY
                this.map[blockX][blockY].bitmap = ""
                this.map[blockX][blockY].guard = false
                this.runner = {x: blockX, y: blockY}
            else if this.tileType = m.const.MAP_GUARD
                if not this.map[blockX][blockY].guard
                    this.map[blockX][blockY].base = m.const.MAP_EMPTY
                    this.map[blockX][blockY].bitmap = ""
                    this.map[blockX][blockY].guard = true
                    if this.guards.Count() = m.const.MAX_GUARDS
                        last = m.const.MAX_GUARDS - 1
                        this.map[this.guards[last].x][this.guards[last].y].guard = false
                    end if
                end if
            else
                this.map[blockX][blockY].base = this.tileType
                this.map[blockX][blockY].bitmap = this.bitmaps[this.tileType]
                this.map[blockX][blockY].guard = false
            end if
        end if
	end while
End Sub

Sub DrawCustomLevel(level as object, blockX, blockY)
    if not m.isOpenGL
        Sleep(250) ' Give time to Roku clear list screen from memory
        m.mainScreen.Clear(m.colors.black)
    end if
    LoadGameSprites(m.settings.spriteMode)
    bmp = CreateObject("roBitmap", {width:m.gameWidth, height:m.gameHeight, alphaenable:true})
    'Draw Title'
    x = 0
    y = m.const.TILE_HEIGHT
    WriteText(m.gameTop, padCenter("CUSTOM LEVEL EDITOR", m.const.TILES_X), x, y)
    'Draw level
    level.guards = []
    for ty = m.const.TILES_Y-1 to 0 step -1
        for tx = m.const.TILES_X-1 to 0 step -1
            tile = level.map[tx][ty]
            tileRegion = invalid
            if tx = blockX and ty = blocky
                if level.tileType = m.const.MAP_RUNNR
                    tileRegion = m.regions.runner.Lookup("runner_00")
                else if level.tileType = m.const.MAP_GUARD
                    tileRegion = m.regions.guard.Lookup("guard_03")
                else
                    tileRegion = m.regions.tiles.Lookup(level.bitmaps[level.tileType])
                end if
            else if level.runner <> invalid and tx = level.runner.x and ty = level.runner.y
                tileRegion = m.regions.runner.Lookup("runner_00")
            else if tile.base = m.const.MAP_HLADR
                tileRegion = m.regions.tiles.Lookup("hladder")
            else if tile.base = m.const.MAP_TRAP
                tileRegion = m.regions.tiles.Lookup("trap")
            else if tile.guard
                tileRegion = m.regions.guard.Lookup("guard_03")
                if level.guards.Count() < m.const.MAX_GUARDS
                    level.guards.Push({x: tx, y: ty})
                end if
            else if tile.bitmap <> invalid
                tileRegion = m.regions.tiles.Lookup(tile.bitmap)
            end if
            if tileRegion <> invalid
                x = tx * m.const.TILE_WIDTH
                y = ty * m.const.TILE_HEIGHT
                bmp.DrawObject(x, y, tileRegion)
            end if
        next
    next
    bmp.Finish()
    m.gameScreen.DrawObject(0, 0, bmp)
    x = 0
    y = m.const.TILES_Y * m.const.TILE_HEIGHT
    ground = m.regions.tiles.Lookup("ground")
    for i = 0 to m.const.TILES_X
        m.gameScreen.DrawObject(i * m.const.TILE_WIDTH, y, ground)
    next
    y += m.const.GROUND_HEIGHT
    for i = m.const.MAP_BLOCK to m.const.MAP_GUARD
        x = (i - 1) * 2 * m.const.TILE_WIDTH
        if i = m.const.MAP_RUNNR
            tileRegion = m.regions.runner.Lookup("runner_00")
        else if i = m.const.MAP_GUARD
            tileRegion = m.regions.guard.Lookup("guard_03")
        else
            tileRegion = m.regions.tiles.Lookup(level.bitmaps[i])
        end if
        m.gameScreen.DrawObject(x, y, tileRegion)
    next
    if level.tileType > m.const.MAP_EMPTY
        x = (level.tileType - 1) * 2 * m.const.TILE_WIDTH
        y = m.const.TILES_Y * m.const.TILE_HEIGHT + m.const.GROUND_HEIGHT
        m.gameScreen.DrawLine(x, y, x + m.const.TILE_WIDTH, y, &hFFD80080)
        m.gameScreen.DrawLine(x, y, x, y + m.const.TILE_HEIGHT, &hFFD80080)
        m.gameScreen.DrawLine(x + m.const.TILE_WIDTH, y, x + m.const.TILE_WIDTH, y + m.const.TILE_HEIGHT-1, &hFFD80080)
        m.gameScreen.DrawLine(x + m.const.TILE_WIDTH, y + m.const.TILE_HEIGHT-1, x, y + m.const.TILE_HEIGHT-1, &hFFD80080)
    end if
    x = m.const.TILE_WIDTH * 19
    WriteText(m.gameScreen, "LEVEL " + zeroPad(level.number, 3), x, y)
    if level.repeat
        WriteText(m.gameBottom, padCenter("REPEAT ON", m.const.TILES_X), 0, 0)
    end if
End Sub

Sub DrawCanvasGrid(blockX as integer, blockY as integer)
    bmp = CreateObject("roBitmap", {width:m.gameWidth, height:m.gameHeight, alphaenable:true})
    for tx = 0 to m.const.TILES_X
        x = tx * m.const.TILE_WIDTH
        if tx = m.const.TILES_X then x--
        y = m.const.TILES_Y * m.const.TILE_HEIGHT
        bmp.DrawLine(x, 0, x, y, &hFFD80080)
    next
    for ty = 0 to m.const.TILES_Y
        x = m.const.TILES_X * m.const.TILE_WIDTH
        y = ty * m.const.TILE_HEIGHT
        bmp.DrawLine(0, y, x, y, &hFFD80080)
    next
    x = blockX * m.const.TILE_WIDTH
    y = blockY * m.const.TILE_HEIGHT
    bmp.DrawRect(x, y, m.const.TILE_WIDTH + 1, m.const.TILE_HEIGHT + 1, &hFFD80050)
    bmp.Finish()
    m.gameScreen.DrawObject(0, 0, bmp)
End Sub

Function save_map() as object
    levelArray = []
    for y = 0 to m.const.TILES_Y - 1
        line = ""
        for x = 0 to m.const.TILES_X - 1
            if m.runner <> invalid and x = m.runner.x and y = m.runner.y
                line += "&" 'Player
            else if m.map[x][y].guard
                line += "0" 'Guard
            else if m.map[x][y].base = m.const.MAP_BLOCK
                line += "#" 'Normal Brick
            else if m.map[x][y].base = m.const.MAP_SOLID
                line += "@" 'Solid Brick
            else if m.map[x][y].base = m.const.MAP_LADDR
                line += "H" 'Ladder
            else if m.map[x][y].base = m.const.MAP_BAR
                line += "-" 'Line of rope
            else if m.map[x][y].base = m.const.MAP_TRAP
                line += "X" 'False brick
            else if m.map[x][y].base = m.const.MAP_HLADR
                line += "S" 'Ladder appears at end of level
            else if m.map[x][y].base = m.const.MAP_GOLD
                line += "$" 'Gold chest
            else
                line += " " 'empty
            end if
        next
        levelArray.Push(line)
    next
    return levelArray
End Function

Sub ShowEditorHelp()
    bmpHelp = CreateObject("roBitmap", "pkg:/images/control_editor.png")
    centerX = Cint((m.mainScreen.GetWidth() - bmpHelp.GetWidth()) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - bmpHelp.GetHeight()) / 2)
    m.mainScreen.DrawObject(centerX, centerY, bmpHelp)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(7000, m.port)
        if key = invalid or key < 100 then exit while
    end while
End Sub

Sub ShowSavedMessage()
    text = "SAVED"
    x = Cint((m.gameWidth - (m.const.TILE_WIDTH * Len(text))) / 2)
    y = Cint((m.gameHeight - m.const.TILE_HEIGHT) / 2)
    m.gameScreen.DrawRect(x - 6, y, (m.const.TILE_WIDTH * Len(text)) + 6, m.const.TILE_HEIGHT + 3, m.colors.black)
    WriteText(m.gameScreen, text, x, y)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(2000, m.port)
        if key = invalid or key < 100 then exit while
    end while
End Sub
