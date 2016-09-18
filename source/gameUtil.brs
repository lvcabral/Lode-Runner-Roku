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

Function GetConstants() as object
    const = {}

    const.SPRITES_AP2 = 0 'Apple II
    const.SPRITES_C64 = 1 'Commodore 64
    const.SPRITES_IBM = 2 'IBM PC
    const.SPRITES_A8B = 3 'Atari 8 bits
    const.SPRITES_RND = 4 'Randomize

    const.VERSION_CLASSIC      = 0
    const.VERSION_CHAMPIONSHIP = 1
    const.VERSION_PROFESSIONAL = 2

    const.TILE_WIDTH    = 20
    const.TILE_HEIGHT   = 22
    const.GROUND_HEIGHT = 10

    const.TILES_X = 28
    const.TILES_Y = 16

    const.MOVE_X = 4
    const.MOVE_Y = 4

    const.MAX_GUARDS = 5

    const.START_HEALTH = 5
    const.LIMIT_HEALTH = 100

    const.LEVEL_STARTUP = 0
    const.LEVEL_PAUSED  = 1
    const.LEVEL_PLAYING = 2

    const.ACT_NONE  = 0
    const.ACT_UP    = 1
    const.ACT_DOWN  = 2
    const.ACT_LEFT  = 3
    const.ACT_RIGHT = 4
    const.ACT_DIG   = 5

    const.MAP_EMPTY  = 0
    const.MAP_BLOCK  = 1
    const.MAP_SOLID  = 2
    const.MAP_LADDR  = 3
    const.MAP_BAR    = 4
    const.MAP_TRAP   = 5
    const.MAP_HLADR  = 6
    const.MAP_GOLD   = 7

    const.SCORE_COMPLETE = 1500
    const.SCORE_GOLD = 250
    const.SCORE_FALL = 75
    const.SCORE_DIES = 75

    const.CONTROL_VERTICAL   = 0
    const.CONTROL_HORIZONTAL = 1

    const.REWFF_LEVEL  = 0
    const.REWFF_HEALTH = 1

    const.TILES_Z = 20
    const.CHARS_Z = 30

    return const
End Function

Function GetVersionMap(versionId as integer) as string
    versionMaps = ["classic", "championship", "professional"]
    return versionMaps[versionId]
End Function

Function GetCursors(controlMode as integer) as object
    this = {
            code: bslUniversalControlEventCodes()
            up: false
            down: false
            left: false
            right: false
            dig: false
            digLeft: false
            digRight: false
           }
    if controlMode = m.const.CONTROL_VERTICAL
        this.update = update_cursor_vertical
    else
        this.update = update_cursor_horizontal
    end if
    this.reset = reset_cursors
    return this
End Function

Sub update_cursor_vertical(id as integer, shiftToggle as boolean)
    if id = m.code.BUTTON_UP_PRESSED
        m.up = true
        m.down = false
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.up = false
        m.down = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.left = true
        m.right = false
    else if id = m.code.BUTTON_RIGHT_PRESSED
        m.left = false
        m.right = true
    else if id = m.code.BUTTON_SELECT_PRESSED
        m.dig = true
    else if id = m.code.BUTTON_A_PRESSED
        m.digLeft = true
        m.dig = true
    else if id = m.code.BUTTON_B_PRESSED
        m.digRight = true
        m.dig = true
    else if id = m.code.BUTTON_UP_RELEASED
        m.up = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.down = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.left = false
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.right = false
    else if id = m.code.BUTTON_SELECT_RELEASED
        m.dig = false
    else if id = m.code.BUTTON_A_RELEASED
        m.digLeft = false
        m.dig = false
    else if id = m.code.BUTTON_B_RELEASED
        m.digRight = false
        m.dig = false
    end if
End Sub

Sub update_cursor_horizontal(id as integer, shiftToggle as boolean)
    if id = m.code.BUTTON_RIGHT_PRESSED
        m.up = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.down = true
    else if id = m.code.BUTTON_UP_PRESSED
        m.left = true
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.right = true
    else if id = m.code.BUTTON_SELECT_PRESSED
        m.dig = true
    else if id = m.code.BUTTON_A_PRESSED
        m.digLeft = true
        m.dig = true
    else if id = m.code.BUTTON_B_PRESSED
        m.digRight = true
        m.dig = true
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.up = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.down = false
    else if id = m.code.BUTTON_UP_RELEASED
        m.left = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.right = false
    else if id = m.code.BUTTON_SELECT_RELEASED
        m.dig = false
    else if id = m.code.BUTTON_A_RELEASED
        m.digLeft = false
        m.dig = false
    else if id = m.code.BUTTON_B_RELEASED
        m.digRight = false
        m.dig = false
    end if
End Sub

Sub reset_cursors()
    m.up = false
    m.down = false
    m.left = false
    m.right = false
    m.dig = false
    m.digLeft = false
    m.digRight = false
End Sub

Function key_u() as boolean
    return m.cursors.up
End Function

Function key_d() as boolean
    return m.cursors.down
End Function

Function key_l() as boolean
    return m.cursors.left
End Function

Function key_r() as boolean
    return m.cursors.right
End Function

Function key_dg() as boolean
    return m.cursors.dig
End Function

Function key_dl() as boolean
    return m.cursors.digLeft
End Function

Function key_dr() as boolean
    return m.cursors.digRight
End Function

Function LoadBitmapRegions(path as string, jsonFile as string, pngFile = "" as string) as object
    if pngFile = ""
        pngFile = jsonFile
    end if
    print "loading ";path + jsonFile + ".json"
    json = ParseJson(ReadAsciiFile(path + jsonFile + ".json"))
    regions = {}
    if json <> invalid
        bitmap = CreateObject("roBitmap", path + pngFile + ".png")
        for each name in json.frames
            frame = json.frames.Lookup(name).frame
            regions.AddReplace(name, CreateObject("roRegion", bitmap, frame.x, frame.y, frame.w, frame.h))
        next
    end if
    return regions
End Function

Function GenerateFrameNames(prefix as string, start as integer, finish as integer, suffix = "" as string, shuffle = false as boolean, repeatFrame = 1 as integer) as object
    frameNames = []
    if shuffle
        length = finish-start+1
        frame = rnd(length)-1
        for f = 1 to length
            for r = 1 to repeatFrame
                frameNames.Push(prefix + itostr(frame+start) + suffix)
            next
            frame = (frame + 1) mod length
        next
    else
        for f = start to finish
            for r = 1 to repeatFrame
                frameNames.Push(prefix + itostr(f) + suffix)
            next
        next
    end if
    return frameNames
End Function

Function GetPaintedBitmap(color as integer, width as integer, height as integer, alpha as boolean) as object
    bitmap = CreateObject("roBitmap", {width:width, height:height, alphaenable:alpha})
    bitmap.clear(color)
    return bitmap
End Function

Function GetManifestArray() as Object
    manifest = ReadAsciiFile("pkg:/manifest")
    lines = manifest.Tokenize(chr(10))
    aa = {}
    for each line in lines
        entry = line.Tokenize("=")
        aa.AddReplace(entry[0],entry[1].Trim())
    end for
    print aa
    return aa
End Function

Function IsHD()
    di = CreateObject("roDeviceInfo")
    return (di.GetUIResolution().name <> "sd")
End Function

Function IsfHD()
    di = CreateObject("roDeviceInfo")
    return(di.GetUIResolution() = "fhd")
End Function

'------- Registry Functions -------
Function GetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "LodeRunner")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return default
End Function

Sub SaveRegistryString(key As String, value As String)
    sec = CreateObject("roRegistrySection", "LodeRunner")
    sec.Write(key, value)
    sec.Flush()
End Sub

Sub SaveSettings(settings as object)
    SaveRegistryString("Settings", FormatJSON({settings: settings}, 1))
End Sub

Function LoadSettings() as dynamic
    json = GetRegistryString("Settings")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid
            return obj.settings
        end if
    end if
    return invalid
End Function

Function itostr(i as integer) as string
    str = Stri(i)
    return strTrim(str)
End Function

Function strTrim(str as String) as string
    st = CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function

Function zeroPad(number as integer, length = invalid) as string
    text = itostr(number)
    if length = invalid then length = 2
    if text.Len() < length
        for i = 1 to length-text.Len()
            text = "0" + text
        next
    end if
    return text
End Function
