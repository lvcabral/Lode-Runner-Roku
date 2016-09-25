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

Function StartMenu() as integer
    this = {
            screen: CreateObject("roListScreen")
            port: CreateObject("roMessagePort")
           }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Game Menu")
    this.spriteModes  = ["Apple II", "Commodore 64", "IBM Personal Computer",
                         "Atari 8 bits", "Sinclair ZX Spectrum", "Randomize!"]
    this.spriteHelp   = ["Original Version", "", "CGA Version",
                         "400/800/XL/XE", "", "New theme every level"]
    this.spriteImage  = ["pkg:/images/apple_ii.png", "pkg:/images/commodore_64.png",
                         "pkg:/images/ibm_pc.png", "pkg:/images/atari_400.png",
                         "pkg:/images/zx_spectrum.png", "pkg:/images/randomize.png"]
    this.versionModes = ["Classic (1983)", "Championship (1984)", "Professional (1985)"]
    this.versionHelp  = ["150 original levels", "50 difficult levels created by fans",
                         "150 new levels by Dodosoft"]
    this.versionImage = ["pkg:/images/version_classic.png", "pkg:/images/version_championship.png",
                         "pkg:/images/version_professional.png"]
    this.controlModes = ["Vertical Mode", "Horizontal Mode"]
    this.controlHelp  = ["", ""]
    this.controlImage = ["pkg:/images/control_vertical.png", "pkg:/images/control_horizontal.png"]
    this.speedModes   = ["Very Slow", "Slow", "Normal", "Fast", "Very Fast"]
    this.speedHelp    = ["VERY SLOW", "SLOW", "NORMAL", "FAST", "VERY FAST"]
    listItems = GetMenuItems(this)
    this.screen.SetContent(listItems)
    this.screen.Show()
    startGame = false
    listIndex = 0
    oldIndex = 0
    selection = -1
    while true
        msg = wait(0,this.port)
        if msg.isScreenClosed() then exit while
        if type(msg) = "roListScreenEvent"
            if msg.isListItemFocused()
                listIndex = msg.GetIndex()
            else if msg.isListItemSelected()
                selection = msg.GetIndex()
                if selection = 0 'Play game
                    SaveSettings(m.settings)
                    exit while
                else if selection >= listItems.Count() - 2
                    exit while
                end if
            else if msg.isRemoteKeyPressed()
                remoteKey = msg.GetIndex()
                if listIndex = m.const.MENU_GRAPHICS
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        m.settings.spriteMode--
                        if m.settings.spriteMode < 0 then m.settings.spriteMode = this.spriteModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        m.settings.spriteMode++
                        if m.settings.spriteMode = this.spriteModes.Count() then m.settings.spriteMode = 0
                    end if
                    listItems[listIndex].Title = "Graphics: " + this.spriteModes[m.settings.spriteMode]
                    listItems[listIndex].ShortDescriptionLine1 = this.spriteHelp[m.settings.spriteMode]
                    listItems[listIndex].HDPosterUrl = this.spriteImage[m.settings.spriteMode]
                    listItems[listIndex].SDPosterUrl = this.spriteImage[m.settings.spriteMode]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = m.const.MENU_VERSION
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        m.settings.version--
                        if m.settings.version < 0 then m.settings.version = this.versionModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        m.settings.version++
                        if m.settings.version = this.versionModes.Count() then m.settings.version = 0
                    end if
                    listItems[listIndex].Title = "Version: " + this.versionModes[m.settings.version]
                    listItems[listIndex].ShortDescriptionLine1 = this.versionHelp[m.settings.version]
                    listItems[listIndex].HDPosterUrl = this.versionImage[m.settings.version]
                    listItems[listIndex].SDPosterUrl = this.versionImage[m.settings.version]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = m.const.MENU_CONTROL
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        m.settings.controlMode--
                        if m.settings.controlMode < 0 then m.settings.controlMode = this.controlModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        m.settings.controlMode++
                        if m.settings.controlMode = this.controlModes.Count() then m.settings.controlMode = 0
                    end if
                    listItems[listIndex].Title = "Control: " + this.controlModes[m.settings.controlMode]
                    listItems[listIndex].ShortDescriptionLine1 = this.controlHelp[m.settings.controlMode]
                    listItems[listIndex].HDPosterUrl = this.controlImage[m.settings.controlMode]
                    listItems[listIndex].SDPosterUrl = this.controlImage[m.settings.controlMode]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = m.const.MENU_SPEED
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        m.settings.speed--
                        if m.settings.speed < 0 then m.settings.speed = this.speedModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        m.settings.speed++
                        if m.settings.speed = this.speedModes.Count() then m.settings.speed = 0
                    end if
                    listItems[listIndex].Title = "Game Speed: " + this.speedModes[m.settings.speed]
                    listItems[listIndex].ShortDescriptionLine1 = this.speedHelp[m.settings.speed]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                end if
            end if
        end if
    end while
    return selection
End Function

Function GetMenuItems(menu as object)
    listItems = []
    listItems.Push({
                Title: "Start the Game"
                HDSmallIconUrl: "pkg:/images/icon_start.png"
                SDSmallIconUrl: "pkg:/images/icon_start.png"
                HDPosterUrl: "pkg:/images/cover.png"
                SDPosterUrl: "pkg:/images/cover.png"
                ShortDescriptionLine1: ""
                ShortDescriptionLine2: "Press OK to start the game"
                })
    listItems.Push({
                Title: "Graphics: " + menu.spriteModes[m.settings.spriteMode]
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.spriteImage[m.settings.spriteMode]
                SDPosterUrl: menu.spriteImage[m.settings.spriteMode]
                ShortDescriptionLine1: menu.spriteHelp[m.settings.spriteMode]
                ShortDescriptionLine2: "Use Left and Right to select the skin"
                })
    listItems.Push({
                Title: "Version: " + menu.versionModes[m.settings.version]
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.versionImage[m.settings.version]
                SDPosterUrl: menu.versionImage[m.settings.version]
                ShortDescriptionLine1: menu.versionHelp[m.settings.version]
                ShortDescriptionLine2: "Use Left and Right to select a level set"
                })
    listItems.Push({
                Title: "Control: " + menu.controlModes[m.settings.controlMode]
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.controlImage[m.settings.controlMode]
                SDPosterUrl: menu.controlImage[m.settings.controlMode]
                ShortDescriptionLine1: menu.controlHelp[m.settings.controlMode]
                ShortDescriptionLine2: "Use Left and Right to set the control mode"
                })
    listItems.Push({
                Title: "Game Speed: " + menu.speedModes[m.settings.speed]
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: "pkg:/images/brick_logo.png"
                SDPosterUrl: "pkg:/images/brick_logo.png"
                ShortDescriptionLine1: menu.speedHelp[m.settings.speed]
                ShortDescriptionLine2: "Use Left and Right to set the game speed"
                })
    listItems.Push({
                Title: "High Scores"
                HDSmallIconUrl: "pkg:/images/icon_hiscores.png"
                SDSmallIconUrl: "pkg:/images/icon_hiscores.png"
                HDPosterUrl: "pkg:/images/brick_logo.png"
                SDPosterUrl: "pkg:/images/brick_logo.png"
                ShortDescriptionLine1: ""
                ShortDescriptionLine2: "Press OK to open High Scores"
                })
    listItems.Push({
                Title: "Game Credits"
                HDSmallIconUrl: "pkg:/images/icon_info.png"
                SDSmallIconUrl: "pkg:/images/icon_info.png"
                HDPosterUrl: "pkg:/images/brick_logo.png"
                SDPosterUrl: "pkg:/images/brick_logo.png"
                ShortDescriptionLine1: ""
                ShortDescriptionLine2: "Press OK to read game credits"
                })
    return listItems
End Function

Sub ShowCredits(waitTime = 0 as integer)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    imgIntro = "pkg:/images/game_credits.png"
    bmp = CreateObject("roBitmap", imgIntro)
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
		if key = invalid or key < 100 then exit while
	end while
End Sub

Function CheckHighScores() as boolean
    if m.runner.usedCheat then return false
    counter = 0
    index = -1
    max = 10
    changed = false
    oldScores = m.highScores[m.settings.version]
    newScores = []
    if oldScores.Count() = 0
        index = 0
        newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
    else
        for each score in oldScores
            if m.runner.score > score.points and index < 0
                index = counter
                newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
                counter++
                if counter = max then exit for
            end if
            newScores.Push(score)
            counter++
            if counter = max then exit for
        next
		if counter < max and index < 0
			index = counter
			newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
		end if
    end if
    if index >= 0
        playerName = KeyboardScreen("", "Please type your name (max 13 letters)")
        if playerName = "" then playerName = "< NO NAME >"
        playerName = padLeft(UCase(playerName), 13)
        newScores[index].name = playerName
        m.highScores[m.settings.version] = newScores
        SaveHighScores(m.highScores)
        changed = true
    end if
    return changed
End Function

Sub ShowHighScores(waitTime = 0 as integer)
    if m.regions = invalid then LoadGameSprites(m.settings.spriteMode)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    'Draw Screen
    bmp = CreateObject("roBitmap", {width:640, height:480, alphaenable:true})
    border = 10
    columns = m.const.TILES_X + 3
    lineSpacing = (m.const.TILE_HEIGHT + 10)
    x = border
    y = m.const.TILE_HEIGHT
    WriteText(bmp, padCenter(GetVersionMap(m.settings.version) + " LODE RUNNER", columns), x, y)
    y += lineSpacing
    WriteText(bmp, padCenter("HIGH SCORES", columns), x, y)
    y += lineSpacing
    WriteText(bmp, "NO      NAME      LEVEL  SCORE", x, y)
    y += lineSpacing
    ground = m.regions.tiles.Lookup("ground")
    for i = 0 to columns - 1
        bmp.DrawObject(x + i * m.const.TILE_WIDTH, y, ground)
    next
    y += (m.const.GROUND_HEIGHT + 7)
    scores = m.highScores[m.settings.version]
    for h = 1 to 10
        x = WriteText(bmp, zeroPad(h) + ". ", x, y)
        if h <= scores.Count()
            x = WriteText(bmp, scores[h - 1].name + " ", x, y)
            x = WriteText(bmp, " " + zeroPad(scores[h - 1].level, 3) + "  ", x, y)
            x = WriteText(bmp, zeroPad(scores[h - 1].points, 7), x, y)
        end if
        x = border
        y += lineSpacing
    next
    'Paint screen
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
    while true
        key = wait(waitTime, m.port)
        if key = invalid or key < 100 then exit while
    end while
End Sub
