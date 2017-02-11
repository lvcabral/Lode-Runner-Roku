' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: February 2017
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function PlayGame(testMode = false as boolean) as boolean
    'Clear screen (needed for non-OpenGL devices)
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Initialize flags and aux variables
    m.guardsMoves = [[0, 0, 0], [0, 1, 1], [1, 1, 1], [1, 2, 1], [1, 2, 2], [2, 2, 2], [2, 2, 3]]
    if m.isOpenGL
        m.gameSpeeds = [60, 40, 20, 15, 10]
    else
        m.gameSpeeds = [40, 25, 15, 10, 5]
    end if
    m.speed = m.gameSpeeds[m.settings.speed]
    m.gameOver = false
    m.statusRedraw = true
    'Game Loop
    id = -1
    m.clock.Mark()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent" or id > 0
            'Handle Remote Control events
            if id < 0 then id = event.GetInt()
            if id = m.code.BUTTON_BACK_PRESSED
                StopAudio()
                DestroyChars()
                DestroyStage()
                exit while
            else if id = m.code.BUTTON_INSTANT_REPLAY_PRESSED
                m.runner.alive = false
            else if id = m.code.BUTTON_PLAY_PRESSED
                PauseGame()
            else if id = m.code.BUTTON_INFO_PRESSED
                if m.runner.health < m.const.LIMIT_HEALTH
                    m.runner.health++
                    m.runner.usedCheat = true
                end if
            else if ControlNextLevel(id) and not testMode
                NextLevel()
                m.runner.usedCheat = true
            else if ControlPreviousLevel(id) and not testMode
                PreviousLevel()
                m.runner.usedCheat = true
            else
                m.runner.cursors.update(id)
            end if
            id = -1
        else if event = invalid
            'Game screen process
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                'Update sprites
                RunnerUpdate()
                if m.level.redraw then DrawLevel() else RedrawTiles()
                GuardsUpdate()
                SoundUpdate()
                'Paint Screen
                if m.level.status = m.const.LEVEL_STARTUP and not m.gameOver
                    id = LevelStartup()
                end if
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                DrawStatusBar()
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                'Check runner death
                if not m.gameOver
                    if not m.runner.alive
                        PlaySound("dead")
                        Sleep(800)
                        m.runner.health--
                        if m.runner.health > 0
                            ResetGame()
                            SaveGame()
                        else
                            m.gameOver = true
                        end if
                    else if testMode
                        m.gameOver = m.runner.success
                    else
                        m.gameOver = CheckLevelSuccess()
                    end if
                end if
                if m.gameOver
                    changed = false
                    StopAudio()
                    if not testMode
                        GameOver()
                        changed = CheckHighScores()
                    end if
                    DestroyChars()
                    DestroyStage()
                    return changed
                end if
            end if
        end if
    end while
    return false
End Function

Function LevelStartup() as integer
    if m.isOpenGL
        m.statusRedraw = true
        for i = 0 to 255 step 5
            hexcolor = &hFF - i
            width = m.gameScreen.GetWidth()
            height = m.gameScreen.GetHeight() - 32
            bmpFront = GetPaintedBitmap(hexcolor, width, height, true)
            rgnFront = CreateObject("roRegion", bmpFront, 0, 0, width, height)
            if m.level.front = invalid
                m.level.front = m.compositor.NewSprite(0, 0, rgnFront, 100)
            else
                m.level.front.SetRegion(rgnFront)
            end if
            m.compositor.DrawAll()
            DrawStatusBar()
            m.mainScreen.SwapBuffers()
        next
        m.level.front.Remove()
    end if
    while true
        key = wait(200, m.port)
        m.runner.sprite.SetDrawableFlag(not m.runner.sprite.GetDrawableFlag())
		if key <> invalid and key < 100 then exit while
        m.compositor.DrawAll()
        DrawStatusBar()
        m.mainScreen.SwapBuffers()
	end while
    m.runner.sprite.SetDrawableFlag(true)
    m.level.status = m.const.LEVEL_PLAYING
    return key
End Function

Function CheckLevelSuccess() as boolean
    finish = false
    if m.runner.success
        PlaySound("pass")
        points = 100
        for s = points to m.const.SCORE_COMPLETE step points
            AddScore(points)
            m.compositor.DrawAll()
            DrawStatusBar()
            m.mainScreen.SwapBuffers()
            Sleep(60)
        next
        if m.currentLevel < m.maps.levels.total
            if m.runner.health < m.const.LIMIT_HEALTH then m.runner.health++
            NextLevel()
            if m.gameOver then finish = true else SaveGame()
        else
            finish = true
        end if
    end if
    return finish
End Function

Sub PauseGame()
    text = "PAUSED"
    x = Cint((m.gameWidth - (m.const.TILE_WIDTH * Len(text))) / 2)
    y = Cint((m.gameHeight - m.const.TILE_HEIGHT) / 2)
    m.gameScreen.DrawRect(x - 6, y, (m.const.TILE_WIDTH * Len(text)) + 6, m.const.TILE_HEIGHT + 3, m.colors.black)
    WriteText(m.gameScreen, text, x, y)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(0, m.port)
        if key = m.code.BUTTON_PLAY_PRESSED then exit while
    end while
End Sub

Sub GameOver()
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    bmp = CreateObject("roBitmap", "pkg:/assets/images/" + GetSpriteFolder(spriteMode) + "/game-over.png")
    x = Cint((m.gameWidth - bmp.GetWidth()) / 2)
    y = Cint((m.gameHeight - bmp.GetHeight()) / 2)
    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
    sprite = m.compositor.NewSprite(x, y, rgn, 100)
    m.compositor.DrawAll()
    DrawStatusBar()
    m.mainScreen.SwapBuffers()
    while true
        key = wait(5000, m.port)
		if key = invalid or key < 100 then exit while
	end while
    sprite.Remove()
    ClearSavedGame()
End Sub

Sub RunnerUpdate()
    m.runner.update()
    rnRegion = m.regions.runner.Lookup(m.runner.frameName)
    if rnRegion <> invalid
        x = (m.runner.blockX * m.const.TILE_WIDTH) + m.runner.offsetX
        y = (m.runner.blockY * m.const.TILE_HEIGHT) + m.runner.offsetY
        if m.runner.sprite = invalid
            m.runner.sprite = m.compositor.NewSprite(x, y, rnRegion, m.const.CHARS_Z)
            m.runner.sprite.SetData("runner")
        else
            m.runner.sprite.SetRegion(rnRegion)
            m.runner.sprite.MoveTo(x, y)
            'Check collision with guards
            if not m.immortal
                guardSprite = m.runner.sprite.CheckCollision()
                if guardSprite <> invalid and guardSprite.GetY() <= m.runner.sprite.GetY()
                    m.runner.alive = false
                end if
            end if
        end if
    end if
End Sub

Sub GuardsUpdate()
    guardsCount = m.guards.Count()
    if guardsCount = 0 then return
    if m.nextMoves = 2 then m.nextMoves = 0 else m.nextMoves++
    if m.level.status = m.const.LEVEL_STARTUP
        movesCount = guardsCount
    else
        movesCount = m.guardsMoves[guardsCount][m.nextMoves]
    end if
    while movesCount > 0
        if m.nextGuard = guardsCount - 1 then m.nextGuard = 0 else m.nextGuard++
        guard = m.guards[m.nextGuard]
        if not guard.alive
            for ty = 0 to m.const.TILES_Y-1
                guard.blockX = Rnd(m.const.TILES_X) - 1
                guard.blockY = ty
                if m.level.map[guard.blockX][ty].base = m.const.MAP_EMPTY
                    guard.charAction = "reborn"
                    guard.frame = 0
                    guard.alive = true
                    guard.inHole = false
                    exit for
                end if
            next
        end if
        if not m.stopGuards
			runnerPos = {x: m.runner.blockX, y: m.runner.blockY, offsetX: m.runner.offsetX}
			guard.update(runnerPos)
		end if
        gdRegion = m.regions.guard.Lookup(guard.frameName)
        if gdRegion <> invalid
            x = (guard.blockX * m.const.TILE_WIDTH) + guard.offsetX
            y = (guard.blockY * m.const.TILE_HEIGHT) + guard.offsetY
            if guard.sprite = invalid
                guard.sprite = m.compositor.NewSprite(x, y, gdRegion, m.const.CHARS_Z)
                guard.sprite.SetData("guard")
            else
                guard.sprite.SetRegion(gdRegion)
                guard.sprite.MoveTo(x, y)
            end if
        end if
        movesCount--
    end while
End Sub

Sub DrawLevel()
    'Clear old sprites
    DestroyStage()
    'Draw level
    for ty = m.const.TILES_Y-1 to 0 step -1
		for tx = m.const.TILES_X-1 to 0 step -1
            tile = m.level.map[tx][ty]
            if tile.bitmap <> invalid
                tileRegion = m.regions.tiles.Lookup(tile.bitmap)
                if tileRegion <> invalid
                    x = tx * m.const.TILE_WIDTH
                    y = ty * m.const.TILE_HEIGHT
                    tile.sprite = m.compositor.NewSprite(x, y, tileRegion, m.const.TILES_Z)
                    tile.sprite.SetMemberFlags(0)
                    tile.sprite.SetData(tile.bitmap)
                    if tile.base = m.const.MAP_HLADR
                        if m.level.gold = 0 then tile.act = m.const.MAP_LADDR
                        tile.sprite.SetDrawableFlag(m.level.gold = 0)
                    end if
                end if
            end if
        next
    next
    m.level.redraw = false
End Sub

Sub RedrawTiles()
    for ty = m.const.TILES_Y-1 to 0 step -1
		for tx = m.const.TILES_X-1 to 0 step -1
            tile = m.level.map[tx][ty]
            if tile.bitmap <> invalid
                if tile.hole
                    actionArray = m.holeAnimations.sequence.Lookup(tile.bitmap)
                    frameName = "hole_" + zeroPad(actionArray[tile.frame])
                    tile.frame++
                    if tile.frame = actionArray.Count()
                        if tile.bitmap = "fillHole"
                            tile.bitmap = "brick"
                            tile.act = m.const.MAP_BLOCK
                            tile.hole = false
                            tile.guard = false
                            print "hole filled"
                            'Check runner death
                            if m.runner.blockX = tx and m.runner.blockY = ty
                                m.runner.alive = false
                            end if
                            'Check guards death
                            if m.guards <> invalid and m.guards.Count() > 0
                                for each guard in m.guards
                                    if guard.blockX = tx and guard.blockY = ty
                                        guard.alive = false
                                        AddScore(m.const.SCORE_DIES)
                                        exit for
                                    end if
                                next
                            end if
                        else
                            print "start fill"
                            tile.bitmap = "fillHole"
                        end if
                        tile.frame = 0
					else if tile.bitmap <> "fillHole" and m.level.map[tx][ty - 1].guard
						tile.bitmap = "brick"
						tile.act = m.const.MAP_BLOCK
						tile.hole = false
						tile.guard = false
                        frameName = "hole_19"
						StopSound()
						print "digging aborted"
                    end if
                    tileRegion = m.regions.hole.Lookup(frameName)
                    if tileRegion <> invalid
                        if tile.sprite <> invalid then tile.sprite.Remove()
                        x = tx * m.const.TILE_WIDTH
                        y = ty * m.const.TILE_HEIGHT
                        yOff = tileRegion.GetHeight() - 22
                        tile.sprite = m.compositor.NewSprite(x, y - yOff, tileRegion, m.const.CHARS_Z + 1)
                        tile.sprite.SetMemberFlags(0)
                        tile.sprite.SetData(tile.bitmap)
                    end if
                else if tile.redraw or ShowHiddenLadder(tile)
                    if tile.sprite <> invalid then tile.sprite.Remove()
                    tileRegion = m.regions.tiles.Lookup(tile.bitmap)
                    if tileRegion <> invalid
                        x = tx * m.const.TILE_WIDTH
                        y = ty * m.const.TILE_HEIGHT
                        tile.sprite = m.compositor.NewSprite(x, y, tileRegion, m.const.TILES_Z)
                        tile.sprite.SetMemberFlags(0)
                        tile.sprite.SetData(tile.bitmap)
                        if tile.base = m.const.MAP_HLADR
                            if m.level.gold = 0 then tile.act = m.const.MAP_LADDR
                            tile.sprite.SetDrawableFlag(m.level.gold = 0)
                        end if
                    end if
                end if
            else
                if tile.sprite <> invalid then tile.sprite.Remove()
            end if
            tile.redraw = false
        next
    next
End Sub

Sub DestroyChars()
    if m.runner <> invalid
        if m.runner.sprite <> invalid
            m.runner.sprite.Remove()
            m.runner.sprite = invalid
        end if
        m.runner = invalid
    end if
    if m.guards <> invalid and m.guards.Count() > 0
        for each guard in m.guards
            if guard.sprite <> invalid
                guard.sprite.Remove()
                guard.sprite = invalid
            end if
        next
        m.guards.Clear()
    end if
End Sub

Sub DestroyStage()
    g = GetGlobalAA()
    for ty = g.const.TILES_Y-1 to 0 step -1
        for tx = g.const.TILES_X-1 to 0 step -1
            if g.level.map[tx][ty].sprite <> invalid
                g.level.map[tx][ty].sprite.Remove()
                g.level.map[tx][ty].sprite = invalid
            end if
        next
    next
End Sub

Function ShowHiddenLadder(tile as object) as boolean
    return tile.base = m.const.MAP_HLADR and tile.act = m.const.MAP_EMPTY and m.level.gold = 0
End Function

Function ControlNextLevel(id as integer) as boolean
    vStatus = m.settings.controlMode = m.const.CONTROL_VERTICAL and id = m.code.BUTTON_A_PRESSED
    hStatus = m.settings.controlMode = m.const.CONTROL_HORIZONTAL and id = m.code.BUTTON_FAST_FORWARD_PRESSED
    return vStatus or hStatus
End Function

Function ControlPreviousLevel(id as integer) as boolean
    vStatus = m.settings.controlMode = m.const.CONTROL_VERTICAL and id = m.code.BUTTON_B_PRESSED
    hStatus = m.settings.controlMode = m.const.CONTROL_HORIZONTAL and id = m.code.BUTTON_REWIND_PRESSED
    return vStatus or hStatus
End Function
