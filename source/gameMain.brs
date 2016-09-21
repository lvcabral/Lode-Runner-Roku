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
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = { red: &hAA0000FF, green:&h00AA00FF, yellow: &hFFFF55FF, black: &hFF, white: &hFFFFFFFF, gray: &h404040FF, navy: &h080030FF, darkred: &h810000FF }
    'Util objects
    app = CreateObject("roAppManager")
    app.SetTheme(GetTheme())
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    'm.sounds = LoadSounds(true)
    m.files = CreateObject("roFileSystem")
    m.manifest = GetManifestArray()
    m.settings = LoadSettings()
    'Debug switches
    m.stopGuards = false ' flag to enable/disable guards
    m.immortal = false 'flag to enable/disable runner immortality
    'Main Menu Loop
    while true
        'Configure screen/game areas based on the configuration
        SetupGameScreen()
        print "Starting menu..."
        selection = StartMenu()
        if selection = m.const.MENU_START
            print "Starting game..."
            m.currentLevel = 1
            m.levelSprites = invalid
            'Open Game Screen
            ResetGame()
            PlayIntro(2000)
            PlayGame()
        else if selection = m.const.MENU_CREDITS
            ShowCredits()
        end if
    end while
End Sub

Sub PlayIntro(waitTime as integer)
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    imgIntro = "pkg:/assets/images/" + GetSpriteFolder(spriteMode) + "/start-screen.png"
    screen = m.mainScreen
    bmp = CreateObject("roBitmap", imgIntro)
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(0)
    screen.SwapBuffers()
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
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
        if g.guards.Count() > 0
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
    g.level.redraw = true
    'StopAudio()
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
            spriteMode = Rnd(5) - 1
        end while
        rndArray.Push(spriteMode)
    next
    Return rndArray
End Function

Sub SetupGameScreen()
	if IsHD()
		m.mainWidth = 854
		m.mainHeight = 480
	else
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
    g.mainScreen.SetMessagePort(g.port)
    xOff = Cint((mainWidth-gameWidth) / 2)
    yOff = Cint((mainHeight-gameHeight) / 2)
    drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, yOff, gameWidth, gameHeight)
    g.gameScreen = drwRegions.main
    g.gameBottom = drwRegions.lower
    g.gameScreen.SetAlphaEnable(true)
    g.compositor = CreateObject("roCompositor")
    g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
End Sub

Function GetTheme() as object
    theme = {
                BackgroundColor: "#000000",
                OverhangSliceSD: "pkg:/images/overhang_sd.jpg",
                OverhangSliceHD: "pkg:/images/overhang_hd.jpg",
                ListScreenHeaderText: "#FFFFFF",
                ListScreenDescriptionText: "#FFFFFF",
                ListItemHighlightText: "#FFD801"
            }
    return theme
End Function
