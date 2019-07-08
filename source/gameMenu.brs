' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: July 2019
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function StartMenu(focus as integer) as integer
    this = {
            screen: CreateListScreen(true)
            port: m.port
           }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Game Menu")
    this.spriteModes  = ["Apple II", "Commodore 64", "IBM Personal Computer",
                         "Atari 8 bits", "Sinclair ZX Spectrum", "NES", "Randomize!"]
    this.spriteHelp   = ["Original Version", "", "CGA Version",
                         "400/800/XL/XE", "", "", "New theme every level"]
    this.spriteImage  = ["pkg:/images/apple_ii.png", "pkg:/images/commodore_64.png",
                         "pkg:/images/ibm_pc.png", "pkg:/images/atari_400.png",
                         "pkg:/images/zx_spectrum.png", "pkg:/images/nes.png","pkg:/images/randomize.png"]
    this.versionModes = ["Classic (1983)", "Championship (1984)", "Professional (1985)", "Custom Levels"]
    this.startLevels  = [1, 1, 1, 1]
    this.startLevels[m.settings.version] = m.settings.startLevel
    this.versionHelp  = ["150 original levels", "50 difficult levels created by fans",
                         "150 new levels by Dodosoft", "Edit your own custom levels"]
    this.controlModes = ["Vertical Mode", "Horizontal Mode"]
    this.controlHelp  = ["", ""]
    this.controlImage = ["pkg:/images/control_vertical.png", "pkg:/images/control_horizontal.png"]
    this.speedModes   = ["Very Slow", "Slow", "Normal", "Fast", "Very Fast"]
    this.speedHelp    = ["VERY SLOW", "SLOW", "NORMAL", "FAST", "VERY FAST"]
    listItems = GetMenuItems(this)
    this.screen.SetContent(listItems)
    this.screen.SetFocusedListItem(focus)
    this.screen.Show()
    startGame = false
    listIndex = 0
    oldIndex = 0
    selection = -1
    while true
        msg = this.screen.Wait(this.port)
        if msg.isScreenClosed()
            exit while
        else if msg.isListItemFocused()
            listIndex = msg.GetIndex()
        else if msg.isListItemSelected()
            selection = msg.GetIndex()
            if selection = m.const.MENU_START
                SaveSettings(m.settings)
                res = m.const.MESSAGEBOX_YES
                if m.savedGame <> invalid
                    res = MessageDialog("Lode Runner", "Do you want to continue unfinished game?", this.port)
                    m.savedGame.restore = (res = m.const.MESSAGEBOX_YES)
                end if
                if res < m.const.MESSAGEBOX_CANCEL then exit while
            else if selection = m.const.MENU_VERSION
                selected = SelectStartLevel(m.settings.spriteMode, m.settings.version, m.settings.startLevel, this.port)
                this.screen.Show()
                if selected > 0 and m.settings.version = m.const.VERSION_CUSTOM
                    m.settings.startLevel = selected
                    exit while
                else if selected > 0 and selected <> m.settings.startLevel
                    this.startLevels[m.settings.version] = selected
                    m.settings.startLevel = selected
                    listItems[selection].Title = "Version: " + this.versionModes[m.settings.version]
                    listItems[selection].ShortDescriptionLine1 = this.versionHelp[m.settings.version] + Chr(10) + "Start Level: " + zeroPad(m.settings.startLevel, 3)
                    imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, m.settings.startLevel)
                    listItems[selection].HDPosterUrl = imgPath
                    listItems[selection].SDPosterUrl = imgPath
                    this.screen.SetItem(selection, listItems[selection])
                end if
            else if selection >= m.const.MENU_HISCORES
                exit while
            end if
        else if msg.isRemoteKeyPressed()
            remoteKey = msg.GetIndex()
            update = (remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED)
            if remoteKey = m.code.BUTTON_REWIND_PRESSED
                this.screen.SetFocusedListItem(m.const.MENU_START)
            else if remoteKey = m.code.BUTTON_FAST_FORWARD_PRESSED
                this.screen.SetFocusedListItem(m.const.MENU_CREDITS)
            else if listIndex = m.const.MENU_GRAPHICS
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    m.settings.spriteMode--
                    if m.settings.spriteMode < 0 then m.settings.spriteMode = this.spriteModes.Count() - 1
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    m.settings.spriteMode++
                    if m.settings.spriteMode = this.spriteModes.Count() then m.settings.spriteMode = 0
                end if
                if update
                    listItems[listIndex].Title = "Graphics: " + this.spriteModes[m.settings.spriteMode]
                    listItems[listIndex].ShortDescriptionLine1 = this.spriteHelp[m.settings.spriteMode]
                    listItems[listIndex].HDPosterUrl = this.spriteImage[m.settings.spriteMode]
                    listItems[listIndex].SDPosterUrl = this.spriteImage[m.settings.spriteMode]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                    imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, m.settings.startLevel)
                    listItems[listIndex + 1].HDPosterUrl = imgPath
                    listItems[listIndex + 1].SDPosterUrl = imgPath
                    this.screen.SetItem(listIndex + 1, listItems[listIndex + 1])
                end if
            else if listIndex = m.const.MENU_VERSION
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    m.settings.version--
                    if m.settings.version < 0 then m.settings.version = this.versionModes.Count() - 1
                    m.settings.startLevel = this.startLevels[m.settings.version]
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    m.settings.version++
                    if m.settings.version = this.versionModes.Count() then m.settings.version = 0
                    m.settings.startLevel = this.startLevels[m.settings.version]
                end if
                if update
                    listItems[listIndex].Title = "Version: " + this.versionModes[m.settings.version]
                    listItems[listIndex].ShortDescriptionLine1 = this.versionHelp[m.settings.version] + Chr(10) + "Start Level: " + zeroPad(m.settings.startLevel, 3)
                    imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, m.settings.startLevel)
                    listItems[listIndex].HDPosterUrl = imgPath
                    listItems[listIndex].SDPosterUrl = imgPath
                    this.screen.SetItem(listIndex, listItems[listIndex])
                end if
            else if listIndex = m.const.MENU_CONTROL
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    m.settings.controlMode--
                    if m.settings.controlMode < 0 then m.settings.controlMode = this.controlModes.Count() - 1
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    m.settings.controlMode++
                    if m.settings.controlMode = this.controlModes.Count() then m.settings.controlMode = 0
                end if
                if update
                    listItems[listIndex].Title = "Control: " + this.controlModes[m.settings.controlMode]
                    listItems[listIndex].ShortDescriptionLine1 = this.controlHelp[m.settings.controlMode]
                    listItems[listIndex].HDPosterUrl = this.controlImage[m.settings.controlMode]
                    listItems[listIndex].SDPosterUrl = this.controlImage[m.settings.controlMode]
                    this.screen.SetItem(listIndex, listItems[listIndex])
                end if
            else if listIndex = m.const.MENU_SPEED
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    m.settings.speed--
                    if m.settings.speed < 0 then m.settings.speed = this.speedModes.Count() - 1
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    m.settings.speed++
                    if m.settings.speed = this.speedModes.Count() then m.settings.speed = 0
                end if
                if update
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
    img = GetLevelMapImage(m.settings.spriteMode, m.settings.version, m.settings.startLevel)
    listItems.Push({
                Title: "Version: " + menu.versionModes[m.settings.version]
                HDSmallIconUrl: "pkg:/images/icon_arrows_ok.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_ok.png"
                HDPosterUrl: img
                SDPosterUrl: img
                ShortDescriptionLine1: menu.versionHelp[m.settings.version] + Chr(10) + "Start Level: " + zeroPad(m.settings.startLevel, 3)
                ShortDescriptionLine2: "Left & Right set version, OK to select level"
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
                ShortDescriptionLine1: "Use of cheat keys or custom start level" + Chr(10) + "disables record for high score."
                ShortDescriptionLine2: "Press OK to open High Scores"
                })
    listItems.Push({
                Title: "Game Credits"
                HDSmallIconUrl: "pkg:/images/icon_info.png"
                SDSmallIconUrl: "pkg:/images/icon_info.png"
                HDPosterUrl: "pkg:/images/brick_logo.png"
                SDPosterUrl: "pkg:/images/brick_logo.png"
                ShortDescriptionLine1: "Beta v" + m.manifest.major_version + "." + m.manifest.minor_version + "." + m.manifest.build_version
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

Function SelectStartLevel(spriteMode as integer, versionId as integer, levelId as integer, port = invalid) as integer
    mapName = GetVersionMap(versionId)
    screen = CreateObject("roGridScreen")
    if port = invalid then port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetBreadcrumbEnabled(false)
    screen.SetGridStyle("flat-landscape")
    screen.SetDisplayMode("scale-to-fit")
    screen.ShowMessage("Loading " + mapName + " maps...")
    'Load the content
    m.level = CreateLevel(mapName, levelId)
    if m.maps.levels.total > 100
        screen.SetupLists(3)
        screen.SetListNames(["Levels: 1 to 50", "Levels: 51 to 100", "Levels: 101 to " + itostr(m.maps.levels.total)])
        content = [[],[],[]]
    else if m.maps.levels.total > 50
        screen.SetupLists(2)
        screen.SetListNames(["Levels: 1 to 50", "Levels: 51 to " + itostr(m.maps.levels.total)])
        content = [[],[]]
    else
        screen.SetupLists(1)
        screen.SetListNames(["Levels: 1 to " + itostr(m.maps.levels.total)])
        content = [[]]
    end if
    screen.Show()
    screen.SetDescriptionVisible(false)
    if m.settings.version < m.const.VERSION_CUSTOM
        for r = 0 to content.Count() - 1
            for l = 1 to 50
                id = 50 * r + l
                if l < 7 or l > 48
                    imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, id)
                    content[r].Push({id: id, SDPosterUrl: imgPath, HDPosterUrl: imgPath})
                else
                    content[r].Push(invalid)
                end if
            next
        next
    else
        for l = 1 to 5
            imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, l)
            content[0].Push({id: l, SDPosterUrl: imgPath, HDPosterUrl: imgPath})
        next
    end if
    for t = 0 to content.count()-1
        screen.SetContentList(t, content[t])
    end for
    screen.SetFocusedListItem(0, 0)
    selected = -1
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roGridScreenEvent"
            if msg.isScreenClosed()
                exit while
            else if msg.isListItemFocused() and m.settings.version < m.const.VERSION_CUSTOM
                row = msg.GetIndex()
                rowList = content[msg.GetIndex()]
                col = msg.GetData()
                for x = -3 to 3
                    idx = col + x
                    if idx < 0 then idx += 49
                    if idx > 49 then idx -= 49
                    levelId = 50 * row + idx + 1
                    if rowList[idx] = invalid
                        imgPath = GetLevelMapImage(m.settings.spriteMode, m.settings.version, levelId)
                        rowList[idx] = {id: levelId, SDPosterUrl: imgPath, HDPosterUrl: imgPath}
                        screen.SetContentList(row, rowList)
                    end if
                next
            else if msg.isListItemSelected()
                row = msg.GetIndex()
                rowList = content[msg.GetIndex()]
                idx = msg.GetData()
                selected = rowList[idx].id
                exit while
            end if
        end if
    end while
    m.level = invalid
    return selected
End Function

Function GetLevelMapImage(spriteMode as integer, versionId as integer, levelId as integer) as string
    LoadGameSprites(spriteMode)
    mapName = GetVersionMap(versionId)
    tmpFile = "tmp:/" + mapName + itostr(spriteMode) + zeroPad(levelId, 3) + ".png"
    if not m.files.Exists(tmpFile) or versionId = m.const.VERSION_CUSTOM
        'Load level map
        level = CreateLevel(mapName, levelId)
        'Canvas Bitmaps
        bmp = CreateObject("roBitmap", {width:m.gameWidth, height:m.gameHeight, alphaenable:true})
        'Draw level
        for ty = m.const.TILES_Y-1 to 0 step -1
            for tx = m.const.TILES_X-1 to 0 step -1
                tile = level.map[tx][ty]
                if tile.bitmap <> invalid and tile.base <> m.const.MAP_HLADR
                    tileRegion = m.regions.tiles.Lookup(tile.bitmap)
                    if tileRegion <> invalid
                        x = tx * m.const.TILE_WIDTH
                        y = ty * m.const.TILE_HEIGHT
                        bmp.DrawObject(x, y, tileRegion)
                    end if
                end if
            next
        next
        reg = CreateObject("roFontRegistry")
        font = reg.GetDefaultFont(30, true, false)
        bmp.DrawText(zeroPad(levelId, 3), (m.gameWidth - 60) / 2, m.gameHeight - 32, m.colors.white, font)
        bmp.Finish()
        png = bmp.GetPng(0, 0, m.gameWidth, m.gameHeight)
        png.WriteFile(tmpFile)
    end if
    return tmpFile
End Function
