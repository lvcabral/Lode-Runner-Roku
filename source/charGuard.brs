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

Function CreateGuard(level as object, guardPos as object) as object
    this = {}
    'Constants
    this.const = m.const
    'Properties
    this.charType = "guard"
    this.hasGold = false
    this.inHole = false
    'Methods
    this.update = update_guard
    this.startLevel = start_level_guard
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
        if m.offsetY = 0 and not m.inHole
            print "fall into hole"
            if m.hasGold
                print "release gold"
                m.level.map[m.blockX][m.blockY-1].base = m.const.MAP_GOLD
                m.level.map[m.blockX][m.blockY-1].bitmap = "gold"
                m.hasGold = false
                m.level.redraw = true
            end if
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
                    if x > runnerPos.X and not IsBarrier(leftTile)
                        m.charAction = "runLeft"
                        m.frame = 0
                    else
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
    else
        if m.state = m.STATE_FALL or m.inHole or m.level.status = m.const.LEVEL_STARTUP
            m.move(m.const.ACT_NONE)
        else if y > runnerPos.Y and IsLadder(curTile, hladr) and not upTile.guard
            m.move(m.const.ACT_UP)
        else if y < runnerPos.Y and IsLadder(downTile, hladr) and not downTile.guard
            m.move(m.const.ACT_DOWN)
        else if y < runnerPos.Y and curTile.base = m.const.MAP_BAR and not IsFloor(downTile)
            m.move(m.const.ACT_DOWN)
        else if y < runnerPos.Y and IsLadder(curTile, hladr) and not IsFloor(downTile)
            m.move(m.const.ACT_DOWN)
        else if x > runnerPos.X and not leftTile.guard
            m.move(m.const.ACT_LEFT)
        else if x < runnerPos.X and not rightTile.guard
            m.move(m.const.ACT_RIGHT)
        else
            m.move(m.const.ACT_NONE)
        end if
    end if
    if m.blockX <> x or m.blockY <> y
        m.level.map[x][y].guard = false
        m.level.map[m.blockX][m.blockY].guard = true
    end if
    'Update animation frame
    m.frameUpdate()
End Sub
