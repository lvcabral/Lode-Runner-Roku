' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: April 2017
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function GetConstants() as object
    const = {}

    const.SPRITES_AP2 = 0 'Apple II
    const.SPRITES_C64 = 1 'Commodore 64
    const.SPRITES_IBM = 2 'IBM PC
    const.SPRITES_A8B = 3 'Atari 8 bits
    const.SPRITES_ZXS = 4 'ZX Spectrum
    const.SPRITES_NES = 5 'NES
    const.SPRITES_RND = 6 'Randomize

    const.VERSION_CLASSIC      = 0
    const.VERSION_CHAMPIONSHIP = 1
    const.VERSION_PROFESSIONAL = 2
    const.VERSION_CUSTOM       = 3

    const.SPEED_VERY_SLOW = 0
    const.SPEED_SLOW      = 1
    const.SPEED_NORMAL    = 2
    const.SPEED_FAST      = 3
    const.SPEED_VERY_FAST = 4

    const.MENU_START    = 0
    const.MENU_GRAPHICS = 1
    const.MENU_VERSION  = 2
    const.MENU_CONTROL  = 3
    const.MENU_SPEED    = 4
    const.MENU_HISCORES = 5
    const.MENU_CREDITS  = 6

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

    const.MAP_EMPTY = 0
    const.MAP_BLOCK = 1
    const.MAP_SOLID = 2
    const.MAP_LADDR = 3
    const.MAP_BAR   = 4
    const.MAP_TRAP  = 5
    const.MAP_HLADR = 6
    const.MAP_GOLD  = 7
    const.MAP_RUNNR = 8
    const.MAP_GUARD = 9

    const.SCORE_COMPLETE = 1500
    const.SCORE_GOLD     = 250
    const.SCORE_FALL     = 75
    const.SCORE_DIES     = 75

    const.CONTROL_VERTICAL   = 0
    const.CONTROL_HORIZONTAL = 1

    const.TILES_Z = 20
    const.CHARS_Z = 30

    const.MESSAGEBOX_YES = 1
    const.MESSAGEBOX_NO = 2
    const.MESSAGEBOX_CANCEL = 3

    return const
End Function

Function GetSpriteFolder(spritesId as integer) as string
    folders = ["ap2", "c64", "ibm", "a8b", "zxs", "nes"]
    if spritesId < folders.Count()
        return folders[spritesId]
    else
        return "ap2"
    end if
End Function

Function GetVersionMap(versionId as integer) as string
    versionMaps = ["classic", "championship", "professional", "custom"]
    return versionMaps[versionId]
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

Function ScaleBitmap(bitmap as object, scale as float, simpleMode = false as boolean) as object
    if scale = 1.0
        scaled = bitmap
    else if scale = int(scale) or simpleMode
		scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:bitmap.GetAlphaEnable()})
		scaled.DrawScaledObject(0,0,scale,scale,bitmap)
    else
        region = CreateObject("roRegion", bitmap, 0, 0, bitmap.GetWidth(), bitmap.GetHeight())
        region.SetScaleMode(1)
        scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:bitmap.GetAlphaEnable()})
        scaled.DrawScaledObject(0,0,scale,scale,region)
	end if
    return scaled
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

'------- Device Check Functions -------

Function IsHD()
    di = CreateObject("roDeviceInfo")
    return (di.GetUIResolution().name <> "sd")
End Function

Function IsfHD()
    di = CreateObject("roDeviceInfo")
    return(di.GetUIResolution() = "fhd")
End Function

Function IsOpenGL() as Boolean
    di = CreateObject("roDeviceInfo")
    graph = di.GetGraphicsPlatform()
    return (graph = "opengl")
End Function

'------- Roku Screens Functions ----
Function MessageDialog(title, text, port = invalid, buttons = 3 as integer) as integer
    if port = invalid then port = CreateObject("roMessagePort")
    d = CreateObject("roMessageDialog")
    d.SetTitle(title)
    d.SetText(text)
    d.SetMessagePort(port)
    if buttons = 1
        d.AddButton(1, "OK")
    else
        d.AddButton(1, "Yes")
        d.AddButton(2, "No")
        if buttons = 3 then d.AddButton(3, "Cancel")
    end if
    d.EnableOverlay(true)
    d.Show()
    result = 0
    while true
        msg = wait(0, port)
        if msg.isScreenClosed()
            exit while
        else if msg.isButtonPressed()
            result = msg.GetIndex()
            exit while
        end if
    end while
    return result
End Function

Function KeyboardScreen(title = "", prompt = "", text = "", button1 = "Okay", button2= "Cancel", secure = false, port = invalid) as string
    if port = invalid then port = CreateObject("roMessagePort")
    result = ""
    port = CreateObject("roMessagePort")
    screen = CreateObject("roKeyboardScreen")
    screen.SetMessagePort(port)
    screen.SetTitle(title)
    screen.SetDisplayText(prompt)
    screen.SetText(text)
    screen.AddButton(1, button1)
    screen.AddButton(2, button2)
    screen.SetSecureText(secure)
    screen.Show()
    while true
        msg = wait(0, port)

        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed()
                exit while
            else if msg.isButtonPressed()
                if msg.GetIndex() = 1 and screen.GetText().Trim() <> "" 'Ok
                    result = screen.GetText()
                    exit while
                else if msg.GetIndex() = 2 'Cancel
                    result = ""
                    exit while
                end if
            end if
        end if
    end while
    screen.Close()
    return result
End function

'------- Registry Functions -------
Function GetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "LodeRunner")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return default
End Function

Sub SaveRegistryString(key as string, value as string)
    sec = CreateObject("roRegistrySection", "LodeRunner")
    sec.Write(key, value)
    sec.Flush()
End Sub

Sub SaveSettings(settings as object)
    SaveRegistryString("Settings", FormatJSON({settings: settings}, 1))
End Sub

Function LoadSettings() as dynamic
    settings = invalid
    json = GetRegistryString("Settings")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid
            settings = obj.settings
        end if
    end if
    if settings = invalid then settings = {}
    if settings.controlMode = invalid then settings.controlMode = m.const.CONTROL_VERTICAL
    if settings.spriteMode = invalid then settings.spriteMode = m.const.SPRITES_AP2
    if settings.version = invalid then settings.version = m.const.VERSION_CLASSIC
    if settings.startLevel = invalid then settings.startLevel = 1
    if settings.speed = invalid then settings.speed = m.const.SPEED_NORMAL
    return settings
End Function

Sub SaveGame()
    if m.savedGame = invalid then m.savedGame = {}
    m.savedGame.version = m.settings.version
    m.savedGame.level = m.currentLevel
    m.savedGame.health = m.runner.health
    m.savedGame.score = m.runner.score
    m.savedGame.usedCheat = m.runner.usedCheat
    SaveRegistryString("SavedGame", FormatJSON({savedGame: m.savedGame}, 1))
End Sub

Sub ClearSavedGame()
    m.savedGame = invalid
    SaveRegistryString("SavedGame", FormatJSON({savedGame: invalid}, 1))
End Sub

Function LoadSavedGame() as dynamic
    json = GetRegistryString("SavedGame")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid and obj.savedGame <> invalid
            return obj.savedGame
        end if
    end if
    return invalid
End Function

Sub SaveHighScores(scores as Object)
    if scores <> invalid
        SaveRegistryString("HighScores", FormatJSON({highScores: scores}, 1))
    end if
End Sub

Function LoadHighScores() as Dynamic
    highScores = invalid
    json = GetRegistryString("HighScores")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid and obj.highScores <> invalid
            highScores = obj.highScores
        end if
    end if
    if highScores = invalid then highScores = [[],[],[]]
    return highScores
End Function

Sub SaveCustomLevels(custom as Object)
    if custom <> invalid
        SaveRegistryString("CustomLevels", FormatJSON({custom: custom}, 1))
    end if
End Sub

Function LoadCustomLevels() as object
    custom = invalid
    json = GetRegistryString("CustomLevels")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid and obj.custom <> invalid
            custom = obj.custom
        end if
    end if
    if custom = invalid
        custom = {levels: {name: "custom", total: 5}}
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
        for l = 2 to 5
            map = []
            for i = 1 to m.const.TILES_Y
                map.Push("                            ")
            next
            custom.levels.AddReplace("level-" + zeroPad(l, 3), map)
        next
    end if
    return custom
End Function

'------- String Functions -------

Function itostr(i as integer) as string
    return i.ToStr()
End Function

Function zeroPad(number as integer, length = 2 as integer) as string
    text = number.ToStr()
    if text.Len() < length then text = String(length-text.Len(), "0") + text
    return text
End Function

Function padCenter(text as string, size as integer) as string
    if Len(text) > size then text.Left(text, size)
    if Len(text) < size
        left = ""
        right = ""
        for c = 1 to size - Len(text)
            if c mod 2 = 0
                left += " "
            else
                right += " "
            end if
        next
        text = left + text + right
    end if
    return text
End Function

Function padLeft(text as string, size as integer) as string
    if Len(text) > size
        return text.Left(size)
    else if Len(text) < size
        text += StringI(size - Len(text), 32)
    end if
    return text
End Function

'------- Remote Control Functions -------

Function GetControl(controlMode as integer) as object
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
        this.update = update_control_vertical
    else
        this.update = update_control_horizontal
    end if
    this.reset = reset_control
    return this
End Function

Sub update_control_vertical(id as integer)
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
    else if id = m.code.BUTTON_REWIND_PRESSED
        m.digLeft = true
        m.dig = true
    else if id = m.code.BUTTON_FAST_FORWARD_PRESSED
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
    else if id = m.code.BUTTON_REWIND_RELEASED
        m.digLeft = false
        m.dig = false
    else if id = m.code.BUTTON_FAST_FORWARD_RELEASED
        m.digRight = false
        m.dig = false
    end if
End Sub

Sub update_control_horizontal(id as integer)
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

Sub reset_control()
    m.up = false
    m.down = false
    m.left = false
    m.right = false
    m.dig = false
    m.digLeft = false
    m.digRight = false
End Sub
