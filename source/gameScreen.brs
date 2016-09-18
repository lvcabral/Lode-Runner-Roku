' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: September 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' **  https://github.com/SimonHung/LodeRunner - HTML5 version by Simon Hung
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function PlayGame() as boolean
    'Clear screen (needed for non-OpenGL devices)
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Set offsets
    m.canvasX = Cint((m.mainWidth - m.gameWidth) / 2)
    m.canvasY = Cint((m.mainHeight - m.gameHeight) / 2)
    'Initialize flags and aux variables
    m.speed = 30
    m.debugMode = false
    m.gameOver = false
    m.level.redraw = true
    'Game Loop
    m.clock.Mark()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            id = event.GetInt()
            if id = m.code.BUTTON_BACK_PRESSED
                m.audioPlayer.Stop()
                DestroyChars()
                return false
            else if m.gameOver
                m.audioPlayer.Stop()
                DestroyChars()
                return true
            else if id = m.code.BUTTON_INSTANT_REPLAY_PRESSED
                ResetGame()
            else if id = m.code.BUTTON_PLAY_PRESSED
                PauseGame()
            else if id = m.code.BUTTON_FAST_FORWARD_PRESSED
                if m.settings.rewFF = m.const.REWFF_LEVEL
                    NextLevel()
                else if m.runner.health < m.const.LIMIT_HEALTH
                    m.runner.health++
                end if
            else if id = m.code.BUTTON_REWIND_PRESSED
                if m.settings.rewFF = m.const.REWFF_LEVEL
                    PreviousLevel()
                else if m.runner.health > 0
                    m.runner.health--
                end if
            else
                m.runner.cursors.update(id, false)
            end if
        else if event = invalid
            'Game screen process
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                'Update sprites
                RunnerUpdate()
                if m.level.redraw then DrawLevel()
                HolesUpdate()
                if m.guardFlag then GuardsUpdate()
                m.guardFlag = not m.guardFlag
                'SoundUpdate()
                'Paint Screen
                if m.level.status = m.const.LEVEL_STARTUP then LevelStartup()
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                DrawStatusBar()
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                CheckLevelSuccess()
                'Check runner death
                if not m.runner.alive
                    m.runner.health--
                    if m.runner.health > 0
                        ResetGame()
                    else
                        GameOver()
                        DestroyChars()
                        exit while
                    end if
                end if
            end if
        end if
    end while
End Function

Sub LevelStartup()
    for i = 0 to 255 step 2
        hexcolor = &hFF - i
        bmpFront = GetPaintedBitmap(hexcolor, m.gameScreen.GetWidth(), m.gameScreen.GetHeight()-32, true)
        rgnFront = CreateObject("roRegion", bmpFront, 0, 0, m.gameScreen.GetWidth(), m.gameScreen.GetHeight()-32)
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
End Sub

Sub CheckLevelSuccess()
    if m.runner.success
        for s = 50 to m.const.SCORE_COMPLETE step 50
            m.runner.score += 50
            m.compositor.DrawAll()
            DrawStatusBar()
            m.mainScreen.SwapBuffers()
        next
        if m.runner.health < m.const.LIMIT_HEALTH then m.runner.health++
        NextLevel()
    end if
End Sub

Sub PauseGame()
    text = "PAUSED"
    x = Cint((m.gameWidth - (m.const.TILE_WIDTH * Len(text))) / 2)
    y = Cint((m.gameHeight - m.const.TILE_HEIGHT) / 2)
    m.gameScreen.DrawRect(x - 6, y, (m.const.TILE_WIDTH * Len(text)) + 6, m.const.TILE_HEIGHT + 3, &HFF)
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
    if spriteMode = m.const.SPRITES_AP2
        bmp = CreateObject("roBitmap", "pkg:/assets/images/ap2/game-over.png")
    else if spriteMode = m.const.SPRITES_C64
        bmp = CreateObject("roBitmap", "pkg:/assets/images/c64/game-over.png")
    else if spriteMode = m.const.SPRITES_IBM
        bmp = CreateObject("roBitmap", "pkg:/assets/images/ibm/game-over.png")
    else if spriteMode = m.const.SPRITES_A8B
        bmp = CreateObject("roBitmap", "pkg:/assets/images/a8b/game-over.png")
    end if
    x = Cint((m.gameWidth - bmp.GetWidth()) / 2)
    y = Cint((m.gameHeight - bmp.GetHeight()) / 2)
    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
    sprite = m.compositor.NewSprite(x, y, rgn, 100)
    m.compositor.DrawAll()
    DrawStatusBar()
    m.mainScreen.SwapBuffers()
    while true
        key = wait(7000, m.port)
		if key = invalid or key < 100 then exit while
	end while
    sprite.Remove()
End Sub

Sub RunnerUpdate()
    m.runner.update()
    rnRegion = m.regions.runner.Lookup(m.runner.frameName)
    if rnRegion <> invalid
        x = (m.runner.blockX * m.const.TILE_WIDTH) + m.runner.offsetX
        y = (m.runner.blockY * m.const.TILE_HEIGHT) + m.runner.offsetY
        if m.runner.sprite = invalid
            m.runner.sprite = m.compositor.NewSprite(x, y, rnRegion, m.const.CHARS_Z)
        else
            m.runner.sprite.SetRegion(rnRegion)
            m.runner.sprite.MoveTo(x, y)
        end if
        'Check collision with guards
        if not m.immortal
            objList = m.runner.sprite.CheckMultipleCollisions()
            if objList <> invalid then m.runner.alive = false
        end if
    end if
End Sub

Sub GuardsUpdate()
    for each guard in m.guards
        if not guard.alive
            for ty = 0 to m.const.TILES_Y-1
                guard.blockX = Rnd(m.const.TILES_X) - 1
                guard.blockY = ty
                if m.level.map[guard.blockX][ty].base = m.const.MAP_EMPTY
                    guard.alive = true
                    guard.inHole = false
                    exit for
                end if
            next
        end if
        if not m.stopGuards then guard.update({x: m.runner.blockX, y: m.runner.blockY})
        gdRegion = m.regions.guard.Lookup(guard.frameName)
        if gdRegion <> invalid
            x = (guard.blockX * m.const.TILE_WIDTH) + guard.offsetX
            y = (guard.blockY * m.const.TILE_HEIGHT) + guard.offsetY
            if guard.sprite = invalid
                guard.sprite = m.compositor.NewSprite(x, y, gdRegion, m.const.CHARS_Z)
            else
                guard.sprite.SetRegion(gdRegion)
                guard.sprite.MoveTo(x, y)
            end if
        end if
    next
End Sub

Sub DrawLevel()
    print "draw level"
    'Clear old stage sprites
    DestroyStage()
    'Draw level rooms
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
                    if tile.base = m.const.MAP_HLADR
                        tile.sprite.SetDrawableFlag(m.level.gold = 0)
                    end if
                end if
            end if
        next
    next
    m.level.redraw = false
End Sub

Sub HolesUpdate()
    for ty = m.const.TILES_Y-1 to 0 step -1
		for tx = m.const.TILES_X-1 to 0 step -1
            tile = m.level.map[tx][ty]
            if tile.bitmap <> invalid
                if tile.hole
                    actionArray = m.level.animations.sequence.Lookup(tile.bitmap)
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
                                        exit for
                                    end if
                                next
                            end if
                        else
                            print "start fill"
                            tile.bitmap = "fillHole"
                        end if
                        tile.frame = 0
                    end if
                    tileRegion = m.regions.hole.Lookup(frameName)
                    if tileRegion <> invalid
                        if tile.sprite <> invalid then tile.sprite.Remove()
                        x = tx * m.const.TILE_WIDTH
                        y = ty * m.const.TILE_HEIGHT
                        yOff = tileRegion.GetHeight() - 22
                        tile.sprite = m.compositor.NewSprite(x, y - yOff, tileRegion, m.const.CHARS_Z + 1)
                        tile.sprite.SetMemberFlags(0)
                    end if
                end if
            end if
        next
    next
End Sub

Sub DestroyChars()
    if m.runner <> invalid
        if m.runner.sprite <> invalid then m.runner.sprite.Remove()
        m.runner = invalid
    end if
    if m.guards <> invalid and m.guards.Count() > 0
        for each guard in m.guards
            if guard.sprite <> invalid then guard.sprite.Remove()
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
