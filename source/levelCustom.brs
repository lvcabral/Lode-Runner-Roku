' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: July 2019
' **  Updated: September 2019
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Sub SaveCustomLevels(custom as Object)
    if custom <> invalid
        compressed = CompressMaps(custom)
        SaveRegistryString("CustomLevels", compressed.Join(","))
    end if
End Sub

Function LoadCustomLevels() as object
    custom = invalid
    json = GetRegistryString("CustomLevels")
    if json <> "" and json.left(1) = "{"
        print "Loading 5 custom levels..."
        obj = ParseJSON(json)
        if obj <> invalid and obj.custom <> invalid
            custom = obj.custom
        end if
    else if json <> ""
        compressed = json.Split(",")
        if compressed.Count() = 15
            print "Loading 15 custom levels..."
            custom = {levels: {name: "custom", total: 15}}
            for l = 1 to 15
                map = UncompressMap(compressed[l-1])
                if map <> invalid and map.Count() = 16
                    custom.levels.AddReplace("level-" + zeroPad(l, 3), map)
                else
                    print "Invalid map: "; compressed[l-1]
                end if
            next
        else
            print "Invalid custom data: "; json
        end if
    end if
    if custom = invalid
        custom = {levels: {name: "custom", total: 15}}
        map = [
        "                  S         ",
        "    $             S         ",
        "#@#@#@#H#######   S         ",
        "       H----------S    $    ",
        "       H    ##H   #######H##",
        "       H    ##H          H  ",
        "     0 H    ##H       $0 H  ",
        "##H#####    ########H#######",
        "  H                 H       ",
        "  H           0     H       ",
        "#########H##########H       ",
        "         H          H       ",
        "       $ H----------H   $   ",
        "    H######         #######H",
        "    H         &  $         H",
        "############################"]
        custom.levels.AddReplace("level-001", map)
        for l = 2 to 15
            map = []
            for i = 1 to m.const.TILES_Y
                map.Push(String(m.const.TILES_X, " "))
            next
            custom.levels.AddReplace("level-" + zeroPad(l, 3), map)
        next
    else if custom.levels.total = 5
        print "Upgrading custom levels..."
        custom.levels.total = 15
        for l = 6 to 15
            map = []
            for i = 1 to m.const.TILES_Y
                map.Push(String(m.const.TILES_X, " "))
            next
            custom.levels.AddReplace("level-" + zeroPad(l, 3), map)
        next
    end if
    return custom
End Function

Function CompressMaps(maps as object) as object
    result = []
    sumversion = 0
    if maps = invalid or not maps.DoesExist("levels")
        return invalid
    end if
    for l = 1 to maps.levels.total
        compressed = ""
        levelMap = maps.levels.Lookup("level-" + zeroPad(l,3))
        for y = 0 to m.const.TILES_Y-1
            current = ""
            counter = 0
            for x = 0 to m.const.TILES_X-1
                id = levelMap[y].Mid(x, 1)
                if id <> current
                    if counter > 1
                        compressed += itostr(counter)
                    end if
                    if id <> "0"
                        compressed += id
                    else
                        compressed += "G"
                    end if
                    counter = 1
                    current = id
                else
                    counter++
                end if
            next
            if counter > 1
                compressed += itostr(counter)
            end if
        next
        sumversion += len(compressed)
        result.Push(compressed)
        'print "map ";l; " ["; compressed; "] "; len(compressed)
    next
    return result
End Function

Function UncompressMap(compressed as string) as object
    ' print "Uncompress" + Chr(10)
    ' print compressed
    id = ""
    last = ""
    level = []
    row = ""
    repeat = 0
    for c = 1 to Len(compressed)
        char = Mid(compressed, c, 1)
        if IsDigit(char) and IsDigit(last)
            repeat = Val(last+char)
            rpId = id
            last = ""
        else if not IsDigit(char)
            if IsDigit(last)
                repeat = Val(last)
                rpId = id
            else if last <> ""
                repeat = 1
                rpId = id
            end if
            id = char
            last = char
        else
            last = char
        end if
        if repeat > 0
            row += String(repeat, rpId)
            if Len(row) >= m.const.TILES_X
                level.Push(PadLeft(row.Replace("G","0"), m.const.TILES_X))
                row = ""
            end if
            repeat = 0
        end if
    next
    if Len(row) > 0 and Len(row) <  m.const.TILES_X
        if IsDigit(char)
            row += String(Val(char), id)
        else
            row += char
        end if
        level.Push(PadLeft(row.Replace("G","0"), m.const.TILES_X))
    end if
    return level
End Function

Function IsDigit(char) as boolean
    return char >= "0" and char <= "9"
End Function