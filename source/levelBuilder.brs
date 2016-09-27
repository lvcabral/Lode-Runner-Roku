' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: September 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' **  Level sets ported from: https://github.com/SimonHung/LodeRunner_TotalRecall
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateLevel(levelSet as string, levelId as integer) as object
    this = {number: levelId, gold: 0, status: m.const.LEVEL_STARTUP}
    this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/hole.json"))
    this.redraw = true
    if m.maps = invalid or m.maps.name <> levelSet
        'Load json
        path = "pkg:/assets/maps/"
        m.maps = ParseJson(ReadAsciiFile(path + levelSet + ".json"))
        if m.maps = invalid
           print "invalid json: "; path + levelSet + ".json"
           return invalid
        end if
    end if
    levelMap = m.maps.levels.Lookup("level-" + zeroPad(levelId,3))
    if levelMap = invalid
       print "invalid level: "; levelId
       return invalid
    end if
	'Create empty map[x][y] array
	map = []
	for x = 0 to m.const.TILES_X - 1
		map[x] = []
		for y = 0 to m.const.TILES_Y
			map[x][y] = {hole: false, guard: false, redraw: false}
		next
	next
	'Fill Map
    this.guards = []
	for y = m.const.TILES_Y-1 to 0 step -1
		for x = m.const.TILES_X-1 to 0 step -1
			id = levelMap[y].Mid(x, 1)
			if id = " " 'empty
				map[x][y].base = m.const.MAP_EMPTY
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = invalid
			else if id = "#" 'Normal Brick
				map[x][y].base = m.const.MAP_BLOCK
				map[x][y].act = m.const.MAP_BLOCK
				map[x][y].bitmap = "brick"
			else if id = "@" 'Solid Brick
				map[x][y].base = m.const.MAP_SOLID
				map[x][y].act = m.const.MAP_SOLID
				map[x][y].bitmap = "solid"
			else if id = "H" 'Ladder
				map[x][y].base = m.const.MAP_LADDR
				map[x][y].act = m.const.MAP_LADDR
				map[x][y].bitmap = "ladder"
			else if id = "-" 'Line of rope
				map[x][y].base = m.const.MAP_BAR
				map[x][y].act = m.const.MAP_BAR
				map[x][y].bitmap = "rope"
			else if id = "X" 'False brick
				map[x][y].base = m.const.MAP_TRAP 'behavior same as empty
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = "brick"
			else if id = "S" 'Ladder appears at end of level
				map[x][y].base = m.const.MAP_HLADR 'behavior same as empty before end of level
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = "ladder"
			else if id = "$" 'Gold chest
				map[x][y].base = m.const.MAP_GOLD 'keep gold on base map
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = "gold"
                this.gold++
			else if id = "0" 'Guard
				map[x][y].base = m.const.MAP_EMPTY
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = invalid
				if this.guards.Count() < m.const.MAX_GUARDS
                    map[x][y].guard = true
                    this.guards.Push({x: x, y: y})
				end if
			else if id = "&" 'Player
				map[x][y].base = m.const.MAP_EMPTY
				map[x][y].act = m.const.MAP_EMPTY
				map[x][y].bitmap = invalid
				if this.runner = invalid
                    this.runner = {x: x, y: y}
				end if
			end if
		next
	next
    this.map = map
    return this
End Function

Function IsBarrier(mapTile) as boolean
    return (mapTile = invalid or mapTile.act = m.const.MAP_BLOCK or mapTile.act = m.const.MAP_SOLID or mapTile.act = m.const.MAP_TRAP)
End Function

Function IsLadder(mapTile, hidden as boolean) as boolean
    return mapTile <> invalid and (mapTile.act = m.const.MAP_LADDR or (mapTile.base = m.const.MAP_HLADR and hidden))
End Function

Function IsFloor(mapTile, useBase = false as boolean, useGuard = true as boolean) as boolean
    if useBase
        return (mapTile = invalid or mapTile.base = m.const.MAP_BLOCK or mapTile.base = m.const.MAP_SOLID or mapTile.base = m.const.MAP_LADDR or (useGuard and mapTile.guard))
    else
        return (mapTile = invalid or mapTile.act = m.const.MAP_BLOCK or mapTile.act = m.const.MAP_SOLID or mapTile.act = m.const.MAP_LADDR or (useGuard and mapTile.guard))
    end if
End Function

Function IsBar(mapTile) as boolean
    return mapTile <> invalid and mapTile.base = m.const.MAP_BAR
End Function

Function IsGold(mapTile) as boolean
    return mapTile <> invalid and mapTile.base = m.const.MAP_GOLD
End Function

Function IsEmpty(mapTile) as boolean
    return mapTile <> invalid and mapTile.base = m.const.MAP_EMPTY
End Function

Function HasGuard(mapTile) as boolean
    return mapTile <> invalid and mapTile.guard
End Function
