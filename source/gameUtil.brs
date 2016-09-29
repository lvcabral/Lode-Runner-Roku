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

Function GetConstants() as object
    const = {}

    const.SPRITES_AP2 = 0 'Apple II
    const.SPRITES_C64 = 1 'Commodore 64
    const.SPRITES_IBM = 2 'IBM PC
    const.SPRITES_A8B = 3 'Atari 8 bits
    const.SPRITES_ZXS = 4 'ZX Spectrum
    const.SPRITES_RND = 5 'Randomize

    const.VERSION_CLASSIC      = 0
    const.VERSION_CHAMPIONSHIP = 1
    const.VERSION_PROFESSIONAL = 2

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
    folders = ["ap2", "c64", "ibm", "a8b", "zxs"]
    if spritesId < folders.Count()
        return folders[spritesId]
    else
        return "ap2"
    end if
End Function

Function GetVersionMap(versionId as integer) as string
    versionMaps = ["classic", "championship", "professional"]
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
    model = Val(Left(di.GetModel(),1))
    return (model = 3 or model = 4 or model = 6)
End Function

'------- Roku Screens Functions ----
Function MessageDialog(title, text, port = invalid) as integer
    if port = invalid then port = CreateObject("roMessagePort")
    d = CreateObject("roMessageDialog")
    d.SetTitle(title)
    d.SetText(text)
    d.SetMessagePort(port)
    d.AddButton(1, "Yes")
    d.AddButton(2, "No")
    d.AddButton(3, "Cancel")
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

'------- String Functions -------

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
    if Len(text) > size then text.Left(text, size)
    if Len(text) < size
        for c = 1 to size - Len(text)
            text += " "
        next
    end if
    return text
End Function
