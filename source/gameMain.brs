' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: September 2019
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = {black: &hFF, white: &hFFFFFFFF, darkgray: &h0F0F0FFF, blue: &h0000FFFF}
    'Util objects
    m.theme = GetTheme()
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    m.sounds = LoadSounds(true)
    m.files = CreateObject("roFileSystem")
    m.manifest = GetManifestArray()
    m.settings = LoadSettings()
    m.savedGame = LoadSavedGame()
    m.highScores = LoadHighScores()
    m.custom = LoadCustomLevels()
    'Debug switches
    m.stopGuards = false ' flag to enable/disable guards
    m.immortal = false 'flag to enable/disable runner immortality
    m.isOpenGL = isOpenGL()
    selection = m.const.MENU_START
    'Main Menu Loop
    while true
        'Configure screen/game areas based on the configuration
        SetupMenuScreen()
        print "Starting menu..."
        selection = StartMenu(selection)
        SetupGameScreen()
        if selection = m.const.MENU_START
            print "Starting game..."
            if m.savedGame <> invalid and m.savedGame.restore
                m.settings.version = m.savedGame.version
                m.currentLevel = m.savedGame.level
                m.levelSprites = invalid
                ResetGame()
                if m.level.runner <> invalid
                    m.runner.health = m.savedGame.health
                    m.runner.score = m.savedGame.score
                    m.runner.usedCheat = m.savedGame.usedCheat
                end if
            else
                m.currentLevel = m.settings.startLevel
                m.levelSprites = invalid
                ResetGame()
                if m.level.runner <> invalid
                    m.runner.usedCheat = (m.settings.startLevel > 1 or m.settings.version = m.const.VERSION_CUSTOM)
                end if
            end if
            if m.level.runner <> invalid
                'Open Game Screen
                PlayIntro(2000)
                if PlayGame()
                    ShowHighScores(5000)
                end if
            else
                res = MessageDialog("Lode Runner", "Custom level has no runner!", m.port, 1)
            end if
        else if selection = m.const.MENU_VERSION
            EditCustomLevel(m.settings.startLevel)
            m.settings.startLevel = 1
            SaveCustomLevels(m.custom)
        else if selection = m.const.MENU_CREDITS
            ShowCredits()
        else if selection = m.const.MENU_HISCORES
            ShowHighScores()
        end if
    end while
End Sub

Sub PlayIntro(waitTime as integer)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    imgIntro = "pkg:/assets/images/" + GetSpriteFolder(spriteMode) + "/start-screen.png"
    bmp = CreateObject("roBitmap", imgIntro)
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
        if type(key) = "roUniversalControlEvent"
            key = key.getInt()
        end if
		if key = invalid or key < 100 then exit while
	end while
End Sub

Sub NextLevel()
    g = GetGlobalAA()
    if g.currentLevel = g.maps.levels.total then return
    g.currentLevel++
    ResetGame()
End Sub

Sub PreviousLevel()
    g = GetGlobalAA()
    if g.currentLevel = 1 then return
    g.currentLevel--
    ResetGame()
End Sub

Sub ResetGame()
    g = GetGlobalAA()
    print "Reseting Level "; itostr(g.currentLevel)
    if g.level <> invalid
        DestroyStage()
        if g.guards <> invalid and g.guards.Count() > 0
            for each guard in g.guards
                if guard.sprite <> invalid
                    guard.sprite.Remove()
                    guard.sprite = invalid
                end if
            next
            g.guards.Clear()
        end if
        if g.runner <> invalid and g.runner.sprite <> invalid
            g.runner.sprite.Remove()
            g.runner.sprite = invalid
        end if
    end if
    g.level = CreateLevel(GetVersionMap(g.settings.version), g.currentLevel)
    if g.level.runner = invalid
        g.runner.alive = false
        g.gameOver = true
        return
    end if
    if g.settings.spriteMode < g.const.SPRITES_RND
        LoadGameSprites(g.settings.spriteMode)
    else
        if g.levelSprites = invalid
            g.levelSprites = RandomizeLevelSprites(g.maps.levels.total)
        end if
        LoadGameSprites(g.levelSprites[g.currentLevel])
    end if
    if g.runner = invalid
        g.runner = CreateRunner(g.level)
    else
        g.runner.startLevel(g.level)
    end if
    if g.guards = invalid then g.guards = []
    for i = 0 to g.level.guards.Count() - 1
        g.guards.Push(CreateGuard(g.level, g.level.guards[i]))
    next
    g.nextGuard = 0
    g.nextMoves = 0
    g.statusRedraw = true
    StopAudio()
    StopSound()
End Sub

Sub LoadGameSprites(spriteMode as integer)
    g = GetGlobalAA()
    if g.regions = invalid then g.regions = {spriteMode: spriteMode}
    path = "pkg:/assets/sprites/" + GetSpriteFolder(spriteMode) + "/"
    'Load Regions
    if g.regions.tiles = invalid or g.regions.spriteMode <> spriteMode
        g.regions.tiles = LoadBitmapRegions(path, "tiles")
        g.regions.hole = LoadBitmapRegions(path, "hole")
        g.regions.runner = LoadBitmapRegions(path, "runner")
        g.regions.guard = LoadBitmapRegions(path, "guard")
        g.regions.text = LoadBitmapRegions(path, "text")
    end if
    g.regions.spriteMode = spriteMode
End Sub

Function RandomizeLevelSprites(max as integer) as object
    rndArray = [-1]
    spriteMode = -1
    for i = 1 to max
        while spriteMode = rndArray[i - 1]
            spriteMode = Rnd(m.const.SPRITES_RND) - 1
        end while
        rndArray.Push(spriteMode)
    next
    Return rndArray
End Function

Sub SetupMenuScreen()
	if IsWideScreen()
        print "Starting in 16x9 mode"
		m.mainWidth = 1280
		m.mainHeight = 720
	else
        print "Starting in 4x3 mode"
		m.mainWidth = 854
		m.mainHeight = 626
	end if
    m.gameWidth = 560
    m.gameHeight = 384
    ResetScreen(m.mainWidth, m.mainHeight, m.gameWidth, m.gameHeight)
End Sub

Sub SetupGameScreen()
	if IsWideScreen()
        print "Starting in 16x9 mode"
		m.mainWidth = 854
		m.mainHeight = 480
	else
        print "Starting in 4x3 mode"
		m.mainWidth = 640
		m.mainHeight = 480
	end if
    m.gameWidth = 560
    m.gameHeight = 384
    ResetScreen(m.mainWidth, m.mainHeight, m.gameWidth, m.gameHeight)
End Sub

Sub ResetScreen(mainWidth as integer, mainHeight as integer, gameWidth as integer, gameHeight as integer)
    g = GetGlobalAA()
    g.mainScreen = CreateObject("roScreen", true, mainWidth, mainHeight)
    g.mainScreen.SetAlphaEnable(true)
    g.mainScreen.SetMessagePort(g.port)
    xOff = Cint((mainWidth-gameWidth) / 2)
    yOff = Cint((mainHeight-gameHeight) / 2)
    drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, yOff, gameWidth, gameHeight)
    g.gameMap = CreateObject("roBitmap", {width:g.gameWidth, height:g.gameHeight, alphaenable:true})
    g.gameScreen = drwRegions.main
    g.gameTop = drwRegions.upper
    g.gameBottom = drwRegions.lower
    g.gameScreen.SetAlphaEnable(true)
    if g.compositor = invalid then g.compositor = CreateObject("roCompositor")
    g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
End Sub

Sub ClearScreenBuffers()
    m.mainScreen.Clear(m.colors.black)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(m.colors.black)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(m.colors.black)
End Sub

Function GetTheme() as object
    theme = {
            BackgroundColor: "#000000",
            OverhangSliceSD: "pkg:/images/overhang_sd.jpg",
            OverhangSliceHD: "pkg:/images/overhang_hd.jpg",
            GridScreenOverhangSliceSD: "pkg:/images/overhang_sd.jpg",
            GridScreenOverhangSliceHD: "pkg:/images/overhang_hd.jpg",
            GridScreenBackgroundColor: "#000000",
            GridScreenOverhangHeightSD: "90",
            GridScreenOverhangHeightHD: "135",
            ListScreenHeaderText: "#FFFFFFFF",
            ListScreenDescriptionText: "#FFFFFFFF",
            ListItemHighlightText: "#FFD801FF"
            }
    return theme
End Function
