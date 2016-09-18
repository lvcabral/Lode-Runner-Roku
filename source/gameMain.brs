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
    'Initialize Settings
    m.settings = LoadSettings()
    if m.settings = invalid
        m.settings = {}
        m.settings.controlMode = m.const.CONTROL_VERTICAL
        m.settings.spriteMode = m.const.SPRITES_AP2
        m.settings.version = m.const.VERSION_CLASSIC
        m.settings.rewFF = m.const.REWFF_LEVEL
    end if
    'Debug switches
    m.stopGuards = false ' flag to enable/disable guards AI
    m.immortal = false 'flag to enable/disable runner immortality
    'Main Menu Loop
    while true
        'Configure screen/game areas based on the configuration
        SetupGameScreen()
        print "Starting menu..."
        if StartMenu()
            print "Starting game..."
            m.currentLevel = 1
            m.levelSprites = invalid
            'Open Game Screen
            ResetGame()
            PlayIntro(2000)
            PlayGame()
        end if
    end while
End Sub

Sub PlayIntro(waitTime as integer)
	screen = m.mainScreen
    centerX = Cint((screen.GetWidth() - 640) / 2)
    centerY = Cint((screen.GetHeight() - 400) / 2)
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    if spriteMode = m.const.SPRITES_AP2
        imgIntro = "pkg:/assets/images/ap2/start-screen.png"
    else if spriteMode = m.const.SPRITES_C64
        imgIntro = "pkg:/assets/images/c64/start-screen.png"
    else if spriteMode = m.const.SPRITES_IBM
        imgIntro = "pkg:/assets/images/ibm/start-screen.png"
    else if spriteMode = m.const.SPRITES_A8B
        imgIntro = "pkg:/assets/images/a8b/start-screen.png"
    end if
    screen.Clear(0)
    screen.SwapBuffers()
    screen.DrawObject(centerX, centerY, CreateObject("roBitmap", imgIntro))
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
    if g.level <> invalid then DestroyStage()
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
        if g.runner.sprite <> invalid
            g.runner.sprite.Remove()
            g.runner.sprite = invalid
        end if
    end if
    g.runner.alive = true
    if g.guards = invalid then g.guards = []
    if g.guards.Count() > 0
        for each guard in g.guards
            if guard.sprite <> invalid then guard.sprite.Remove()
        next
        g.guards.Clear()
    end if
    for i = 0 to g.level.guards.Count() - 1
        g.guards.Push(CreateGuard(g.level, g.level.guards[i]))
    next
    g.guardFlag = true
    g.level.redraw = true
    'StopAudio()
End Sub

Sub LoadGameSprites(spriteMode as integer)
    g = GetGlobalAA()
    if g.regions = invalid then g.regions = {spriteMode: spriteMode}
    if spriteMode = g.const.SPRITES_AP2
        path = "pkg:/assets/sprites/ap2/"
    else if spriteMode = g.const.SPRITES_C64
        path = "pkg:/assets/sprites/c64/"
    else if spriteMode = g.const.SPRITES_IBM
        path = "pkg:/assets/sprites/ibm/"
    else if spriteMode = g.const.SPRITES_A8B
        path = "pkg:/assets/sprites/a8b/"
    end if
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
            spriteMode = Rnd(4) - 1
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
