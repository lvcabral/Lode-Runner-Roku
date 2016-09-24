' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: September 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function ImplementActor(this as object) as object
    'Constants
    this.STATE_STOP = 0
    this.STATE_MOVE = 1
    this.STATE_FALL = 2
    'Animations
    this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/" + this.charType + ".json"))
    'Properties
    this.alive = true
    this.state = this.STATE_STOP
    'Methods
    this.move = move_actor
    this.frameUpdate = frame_update_actor
    return this
End Function

Sub move_actor(action)
    curTile = m.level.map[m.blockX][m.blockY]
    hladr = (m.level.gold = 0)
    'Collect gold
    if curTile.base = m.const.MAP_GOLD
        takeGold = false
        if m.charType = "runner"
            PlaySound("getGold")
            m.level.gold--
            AddScore(m.const.SCORE_GOLD)
            takeGold = true
            if m.level.gold = 0
                PlaySound("goldFinish" + itostr((m.level.number - 1) MOD 6 + 1))
            end if
        else if m.hasGold = 0
            m.hasGold = Rnd(26) + 12
            takeGold = true
        end if
        if takeGold
            m.level.map[m.blockX][m.blockY].base = m.const.MAP_EMPTY
            m.level.map[m.blockX][m.blockY].bitmap = invalid
            m.level.map[m.blockX][m.blockY].redraw = true
        end if
    end if
    'Update char position
    upTile = invalid
    downTile = invalid
    leftTile = invalid
    rightTile = invalid
    if m.blockY > 0 then upTile = m.level.map[m.blockX][m.blockY-1]
    if m.blockY < m.const.TILES_Y-1 then downTile = m.level.map[m.blockX][m.blockY+1]
    if m.blockX > 0 then leftTile = m.level.map[m.blockX-1][m.blockY]
    if m.blockX < m.const.TILES_X-1 then rightTile = m.level.map[m.blockX+1][m.blockY]
    if m.state <> m.STATE_FALL or IsFloor(downTile) then m.state = m.STATE_STOP
    if m.state = m.STATE_FALL
        if curTile.base = m.const.MAP_BAR and m.offsetY = 0
            m.state = m.STATE_MOVE
            m.charAction = m.charAction.Replace("fall", "bar")
            m.frame = 0
        end if
    else if action = m.const.ACT_DIG and m.charType = "runner"
        if m.canDig()
            PlaySound("dig")
            if m.keyDL() or (m.charAction = "runLeft" and not m.keyDR())
                m.charAction = "digLeft"
                tile = m.level.map[m.blockX-1][m.blockY+1]
                tile.bitmap = "digHoleLeft"
            else
                m.charAction = "digRight"
                tile = m.level.map[m.blockX+1][m.blockY+1]
                tile.bitmap = "digHoleRight"
            end if
            tile.frame = 0
            tile.act = m.const.MAP_EMPTY
            tile.hole = true
            m.state = m.STATE_MOVE
            m.offsetX = 0
            m.frame = 0
        end if
    else if action = m.const.ACT_UP and not (IsBarrier(upTile) and m.offsetY = 0)
        if IsLadder(curTile, hladr) or (IsLadder(downTile, hladr) and m.offsetY > 0)
            if m.charAction <> "runUpDown"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = 0
            m.offsetY -= m.const.MOVE_Y
            if m.offsetY < 0
                if IsLadder(curTile, hladr) and not IsBarrier(upTile)
                    m.blockY--
                    m.offsetY += m.const.TILE_HEIGHT
                    if m.charType = "guard" then m.tryDropGold()
                else
                    m.offsetY = 0
                end if
            end if
        end if
    else if action = m.const.ACT_DOWN and not IsBarrier(downTile)
        downTile2 = invalid
        if m.blockY < m.const.TILES_Y-2 then downTile2 = m.level.map[m.blockX][m.blockY + 2]
        if IsLadder(curTile, hladr) or IsLadder(downTile, hladr)
            if m.charAction <> "runUpDown"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = 0
            m.offsetY += m.const.MOVE_Y
            if m.offsetY >= m.const.TILE_HEIGHT
                m.blockY++
                m.offsetY -= m.const.TILE_HEIGHT
                if m.offsetY < m.const.MOVE_Y then m.offsetY = 0
                if not IsFloor(downTile) and not IsFloor(downTile2)
                    m.state = m.STATE_FALL
                    m.charAction = "fallLeft"
                    m.frame = 0
                end if
                if m.charType = "guard" then m.tryDropGold()
            end if
        else if (curTile.base = m.const.MAP_BAR or curTile.base = m.const.MAP_EMPTY) and not IsFloor(downTile)
            m.state = m.STATE_FALL
            m.charAction = "fallLeft"
            m.frame = 0
        end if
    else if action = m.const.ACT_LEFT
        if curTile.base = m.const.MAP_BAR and m.charAction <> "barLeft"
            m.charAction = "barLeft"
            m.frame = 0
        else if curTile.base <> m.const.MAP_BAR
            if not IsFloor(downTile) and not IsLadder(curTile, hladr)
                m.charAction = "fallLeft"
                m.frame = 0
            else if m.charAction <> "runLeft"
                m.charAction = "runLeft"
                m.frame = 0
            end if
        end if
        if m.charAction = "fallLeft"
            m.state = m.STATE_FALL
        else if not ((m.blockX = 0 or IsBarrier(leftTile)) and m.offsetX = 0)
            m.state = m.STATE_MOVE
            m.offsetX -= m.const.MOVE_X
            if m.offsetX < 0
                m.blockX--
                m.offsetX += m.const.TILE_WIDTH
                if m.charType = "guard" then m.tryDropGold()
            end if
            m.offsetY = 0
        end if
    else if action = m.const.ACT_RIGHT
        if curTile.base = m.const.MAP_BAR and m.charAction <> "barRight"
            m.charAction = "barRight"
            m.frame = 0
        else if curTile.base <> m.const.MAP_BAR
            if not IsFloor(downTile) and not IsLadder(curTile, hladr)
                m.charAction = "fallRight"
                m.frame = 0
            else if m.charAction <> "runRight"
                m.charAction = "runRight"
                m.frame = 0
            end if
        end if
        if m.charAction = "fallRight"
            m.state = m.STATE_FALL
        else if not ((m.blockX = m.const.TILES_X-1 and m.offsetX = 0) or IsBarrier(rightTile))
            m.state = m.STATE_MOVE
            m.offsetX += m.const.MOVE_X
            if m.offsetX >= m.const.TILE_WIDTH / 2
                m.blockX++
                m.offsetX -= m.const.TILE_WIDTH
                if m.charType = "guard" then m.tryDropGold()
            end if
            m.offsetY = 0
        else if m.offsetX < 0
            m.state = m.STATE_MOVE
            m.offsetX += m.const.MOVE_X
            m.offsetY = 0
        end if
    end if
    'Update fall
    if m.state = m.STATE_FALL
        m.offsetX = 0
        m.offsetY += m.const.MOVE_Y
        if m.offsetY >= m.const.TILE_HEIGHT
            m.blockY++
            m.offsetY -= m.const.TILE_HEIGHT
            if m.offsetY < m.const.MOVE_Y then m.offsetY = 0
            if m.charType = "guard" then m.tryDropGold()
        end if
    end if
End Sub

Sub frame_update_actor()
    'Update animation frame
    if m.state <> m.STATE_STOP
        actionArray = m.animations.sequence.Lookup(m.charAction)
        m.frameName = m.charType + "_" + zeroPad(actionArray[m.frame])
        m.frame++
        if m.frame >= actionArray.Count() then m.frame = 0
    end if
End Sub
