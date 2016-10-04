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
    Sleep(500) ' Give time to Roku clear list screen from memory
    m.mainScreen.Clear(m.colors.black)
    m.mainScreen.SwapBuffers()
    map = m.custom.levels.Lookup("level-" + zeroPad(levelId, 3))
    this = {number: levelId, gold: 0, repeat: false, const: m.const, loadMap: load_map, saveMap: save_map}
    this.bitmaps = ["", "brick", "solid", "ladder", "rope", "trap", "hladder", "gold"]
    this.tileType = m.const.MAP_BLOCK
    this.map = this.LoadMap(map)
    this.cursor = { x: 0, y: 0, type: -1 }
    this.control = GetControl(m.const.CONTROL_VERTICAL)
    if m.isOpenGL then speed = 100 else speed = 50
    showHelp = true
    showSaved = false
    forceRedraw = true
    m.mainScreen.Clear(m.colors.black)
    LoadGameSprites(m.settings.spriteMode)
    DrawCanvasGrid(this)
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            key = event.GetInt()
            if key = m.code.BUTTON_INFO_PRESSED
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
                if this.repeat then UpdateTile(this)
            else if key = m.code.BUTTON_INSTANT_REPLAY_PRESSED
                if this.runner <> invalid
                    saveOldMap = m.custom.levels.Lookup("level-" + zeroPad(levelId, 3))
                    m.custom.levels.AddReplace("level-" + zeroPad(levelId, 3), this.saveMap())
                    DestroyEditor(this)
                    m.currentLevel = this.number
                    ResetGame()
                    m.runner.health = 1
                    PlayGame(true)
                    DrawCanvasGrid(this)
                    forceRedraw = true
                    m.custom.levels.AddReplace("level-" + zeroPad(levelId, 3), saveOldMap)
                    this.control.reset()
                else
                    ShowMessage("ADD RUNNER ON MAP TO TEST")
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                DestroyEditor(this)
                exit while
            else if key = m.code.BUTTON_SELECT_PRESSED
                UpdateTile(this)
            else
                this.control.update(key)
            end if
        else if event = invalid
            ticks = m.clock.TotalMilliseconds()
            if ticks > speed
                DrawCustomLevel(this, forceRedraw)
                UpdateCursor(this, forceRedraw)
                forceRedraw = false
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                DrawEditorStatus(this)
                if showHelp
                    ShowEditorHelp()
                    showHelp = false
                else if showSaved
                    ShowMessage("SAVED")
                    showSaved = false
                end if
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
            end if
        end if
	end while
End Sub

Sub DrawCustomLevel(level as object, forceRedraw = false as boolean)
    'Draw level
    level.guards = []
    for ty = m.const.TILES_Y-1 to 0 step -1
        for tx = m.const.TILES_X-1 to 0 step -1
            tile = level.map[tx][ty]
            if tile.redraw or forceRedraw
                tileRegion = invalid
                if level.runner <> invalid and tx = level.runner.x and ty = level.runner.y
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
                    if tile.sprite = invalid
                        tile.sprite = m.compositor.NewSprite(x, y, tileRegion, m.const.TILES_Z)
                    else
                        tile.sprite.SetRegion(tileRegion)
                        tile.sprite.MoveTo(x, y)
                    end if
                else if tile.sprite <> invalid
                    tile.sprite.Remove()
                    tile.sprite = invalid
                end if
                tile.redraw = false
            end if
        next
    next
End Sub

Sub DrawEditorStatus(level as object)
    'Draw Title
    x = 0
    y = m.const.TILE_HEIGHT
    WriteText(m.gameTop, padCenter("CUSTOM LEVEL EDITOR", m.const.TILES_X), x, y)
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
    m.gameBottom.Clear(m.colors.black)
    if level.repeat
        WriteText(m.gameBottom, padCenter("REPEAT ON", m.const.TILES_X), 0, 0)
    end if
End Sub

Sub UpdateCursor(level as object, forceRedraw = false as boolean)
    blockX = level.cursor.x
    blockY = level.cursor.y
    if level.control.left
        if blockX > 0 then blockX-- else blockX = m.const.TILES_X - 1
    else if level.control.right
        if blockX < m.const.TILES_X - 1 then blockX++ else blockX = 0
    else if level.control.up
        if blockY > 0 then blockY-- else blockY = m.const.TILES_Y - 1
    else if level.control.down
        if blockY < m.const.TILES_Y - 1 then blockY++ else blockY = 0
    end if
    if level.cursor.x <> blockX or level.cursor.y <> blockY or level.tileType <> level.cursor.type or forceRedraw
        bmpWidth = m.const.TILE_WIDTH + 1
        bmpHeight = m.const.TILE_HEIGHT + 1
        bmp = CreateObject("roBitmap", {width:bmpWidth , height:bmpHeight, alphaenable:true})
        if level.tileType = m.const.MAP_RUNNR
            tileRegion = m.regions.runner.Lookup("runner_00")
        else if level.tileType = m.const.MAP_GUARD
            tileRegion = m.regions.guard.Lookup("guard_03")
        else
            tileRegion = m.regions.tiles.Lookup(level.bitmaps[level.tileType])
        end if
        bmp.DrawRect(0, 0, bmpWidth, bmpWidth, &hFF)
        if tileRegion <> invalid then bmp.DrawObject(0, 0, tileRegion)
        x = blockX * m.const.TILE_WIDTH
        y = blockY * m.const.TILE_HEIGHT
        bmp.DrawRect(0, 0, bmpWidth, bmpWidth, &hFFD80050)
        rgn = CreateObject("roRegion", bmp, 0, 0, bmpWidth, bmpHeight)
        if level.cursor.sprite = invalid
            level.cursor.sprite = m.compositor.NewSprite(x, y, rgn, m.const.CHARS_Z)
        else
            level.cursor.sprite.SetRegion(rgn)
            level.cursor.sprite.MoveTo(x, y)
        end if
        level.cursor.x = blockX
        level.cursor.y = blockY
        level.cursor.type = level.tileType
        if level.repeat then UpdateTile(level)
    end if
End Sub

Sub UpdateTile(level as object)
    blockX = level.cursor.x
    blockY = level.cursor.y
    if level.tileType = m.const.MAP_RUNNR
        if level.runner <> invalid
            level.map[level.runner.x][level.runner.y].redraw = true
        end if
        level.map[blockX][blockY].base = m.const.MAP_EMPTY
        level.map[blockX][blockY].bitmap = ""
        level.map[blockX][blockY].guard = false
        level.runner = {x: blockX, y: blockY}
    else if level.tileType = m.const.MAP_GUARD
        if not level.map[blockX][blockY].guard
            level.map[blockX][blockY].base = m.const.MAP_EMPTY
            level.map[blockX][blockY].bitmap = ""
            level.map[blockX][blockY].guard = true
            if level.guards.Count() = m.const.MAX_GUARDS
                last = m.const.MAX_GUARDS - 1
                level.map[level.guards[last].x][level.guards[last].y].guard = false
                level.map[level.guards[last].x][level.guards[last].y].redraw = true
            end if
        end if
    else
        level.map[blockX][blockY].base = level.tileType
        level.map[blockX][blockY].bitmap = level.bitmaps[level.tileType]
        level.map[blockX][blockY].guard = false
    end if
    level.map[blockX][blockY].redraw = true
End Sub

Sub DrawCanvasGrid(level as object)
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
    bmp.Finish()
    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
    if level.grid <> invalid then level.grid.Remove()
    level.grid = m.compositor.NewSprite(0, 0, rgn, m.const.TILES_Z + 1)
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
    bmpHelp.SetAlphaEnable(true)
    centerX = Cint((m.gameScreen.GetWidth() - bmpHelp.GetWidth()) / 2)
    centerY = Cint((m.gameScreen.GetHeight() - bmpHelp.GetHeight()) / 2)
    m.gameScreen.DrawObject(centerX, centerY, bmpHelp)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(21000, m.port)
        if key = invalid or key < 100 then exit while
    end while
End Sub

Sub ShowMessage(text as string)
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

Sub DestroyEditor(level as object)
    if level.grid <> invalid
        level.grid.Remove()
        level.grid = invalid
    end if
    for ty = m.const.TILES_Y-1 to 0 step -1
        for tx = m.const.TILES_X-1 to 0 step -1
            if level.map[tx][ty].sprite <> invalid
                level.map[tx][ty].sprite.Remove()
                level.map[tx][ty].sprite = invalid
            end if
        next
    next
    if level.cursor.sprite <> invalid
        level.cursor.sprite.Remove()
        level.cursor.sprite = invalid
    end if
End Sub
