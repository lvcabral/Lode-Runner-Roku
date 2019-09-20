' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: July 2019
' **  Updated: September 2019
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Sub ShowHighScores(waitTime = 0 as integer)
    if m.settings.version < m.const.VERSION_CUSTOM
        version = m.settings.version
    else
        version = m.const.VERSION_CLASSIC
    end if
    if m.regions = invalid then LoadGameSprites(m.settings.spriteMode)
    screen = m.mainScreen
    ClearScreenBuffers()
    'Draw Screen
    bmp = CreateObject("roBitmap", {width:640, height:480, alphaenable:true})
    border = 10
    columns = m.const.TILES_X + 3
    lineSpacing = (m.const.TILE_HEIGHT + 10)
    x = border
    y = m.const.TILE_HEIGHT
    WriteText(bmp, padCenter(GetVersionMap(version) + " LODE RUNNER", columns), x, y)
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
    scores = m.highScores[version]
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
        if type(key) = "roUniversalControlEvent"
            key = key.getInt()
        end if
        if key = invalid or key < 100 then exit while
    end while
End Sub

Function CheckHighScores() as boolean
    if m.runner.usedCheat then return false
    if m.runner.score = 0 then return false
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
                if counter = max
                    exit for
                end if
            end if
            newScores.Push(score)
            counter++
            if counter = max
                exit for
            end if
        next
		if counter < max and index < 0
			index = counter
			newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
		end if
    end if
    if index >= 0
        playerName = NewHighScore(newScores, index)
        if playerName = ""
            playerName = "< NO NAME >"
        end if
        playerName = padLeft(UCase(playerName), 13)
        newScores[index].name = playerName
        m.highScores[m.settings.version] = newScores
        SaveHighScores(m.highScores)
        changed = true
    end if
    return changed
End Function

Function NewHighScore(newScores as object, index as integer) as string
    version = m.settings.version
    screen = m.mainScreen
    playerName = ""
    key = 0
    maxNameSize = 13
    curButton = 0 'letter A
    curTimer = 30 'in seconds
    counter = 1
    flash = true
    ClearScreenBuffers()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            moveCursor = false
            key = event.GetInt()
            if key = m.code.BUTTON_SELECT_PRESSED and curTimer > 0
                'Select keyboard letter/button
                if curButton < 26 'letter
                    if Len(playerName) < maxNameSize
                        playerName += Chr(65 + curButton)
                    end if
                else if curButton = 26 'dot
                    if Len(playerName) < maxNameSize
                        playerName += "."
                    end if
                else if curButton = 27 'dash
                    if Len(playerName) < maxNameSize
                        playerName += "-"
                    end if
                else if curButton = 28 'delete
                    if Len(playerName) > 0
                        playerName = Left(playerName, Len(playerName) - 1)
                    end if
                else if curButton = 29 'end
                    curTimer = -3
                end if
                m.sounds.select.Trigger(50)
            else if key = m.code.BUTTON_LEFT_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_RIGHT_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_UP_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_DOWN_PRESSED
                moveCursor = true
            end if
            if moveCursor and curTimer > 0
                m.sounds.navSingle.Trigger(50)
                curButton = CursorUpdate(curButton, key)
                DrawNameRegistration(newScores, index, playerName, curTimer, flash, curButton, key)
                key = 0
            end if
        else if event = invalid
            ticks = m.clock.TotalMilliseconds()
            if ticks > 100
                if counter mod 5 = 0
                    flash = not flash
                end if
                if curTimer = 0
                    exit while
                end if
                DrawNameRegistration(newScores, index, playerName, curTimer, flash, curButton, key)
                if counter mod 10 = 0
                    if curTimer > 0 curTimer-- else curTimer++
                end if
                m.clock.Mark()
                counter++
            end if
        end if
	end while
    return playerName
End Function

Sub DrawNameRegistration(newScores as object, index as integer, playerName as string, curTimer as integer, flash as boolean, curButton as integer, key as integer)
    bmp = CreateObject("roBitmap", {width:640, height:480, alphaenable:true})
    width = bmp.GetWidth()
    border = 10
    columns = m.const.TILES_X + 3
    lineSpacing = (m.const.TILE_HEIGHT + 9)
    letterWidth = m.regions.text.Lookup("A").GetWidth()
    x = border
    y = m.const.TILE_HEIGHT
    WriteText(bmp, padCenter(GetVersionMap(m.settings.version) + " LODE RUNNER", columns), x, y)
    y += lineSpacing
    WriteText(bmp, padCenter("NEW HIGH SCORE", columns), x, y)
    y += lineSpacing
    WriteText(bmp, "NO      NAME      LEVEL  SCORE", x, y)
    y += lineSpacing
    ground = m.regions.tiles.Lookup("ground")
    for i = 0 to columns - 1
        bmp.DrawObject(x + i * m.const.TILE_WIDTH, y, ground)
    next
    y += (m.const.GROUND_HEIGHT + 7)   
    x = WriteText(bmp, zeroPad(index+1) + ". ", x, y)
    if flash
        x = WriteText(bmp, padLeft(UCase(playerName)+"_", 14), x, y)
    else 
        x = WriteText(bmp, padLeft(UCase(playerName)+" ", 14), x, y)
    end if
    x = WriteText(bmp, " " + zeroPad(newScores[index].level, 3) + "  ", x, y)
    x = WriteText(bmp, zeroPad(newScores[index].points, 7), x, y)
    y += lineSpacing * 2
    x = CenterText("A B C D E F G H I J", width)
    WriteText(bmp, "A B C D E F G H I J", x, y)
    m.yOff = y
    y += lineSpacing
    WriteText(bmp, "K L M N O P Q R S T", x, y)
    y += lineSpacing
    WriteText(bmp, "U V W X Y Z . - " + Chr(08) + " " + Chr(13), x, y)
    if curTimer > 0
        text = "REMAINING TIME: " + zeroPad(curTimer)
    else
        text = "YOUR NAME WAS REGISTERED"
    end if
    x = CenterText(text, width)
    y += lineSpacing * 2
    WriteText(bmp, text, x, y)

    x = CenterText("A B C D E F G H I J", width) - 6 + (curButton - Int(curButton / 10) * 10) * (letterWidth*2)
    y = m.yOff + Int(curButton / 10) * 30
    cursor = CreateObject("roBitmap", "pkg:/images/keyboard_cursor.png")
    bmp.DrawObject(x, y, cursor)

    ' Paint the Screen
    centerX = Cint((m.mainScreen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - bmp.GetHeight()) / 2)
    m.mainScreen.Clear(m.colors.black)
    m.mainScreen.DrawObject(centerX, centerY, bmp)
    m.mainScreen.SwapBuffers()
End Sub

Function CursorUpdate(curButton, key)
    ' Update Cursor 
    if key = m.code.BUTTON_LEFT_PRESSED
        if curButton = 0
            curButton = 29
        else
            curButton--
        end if
    else if key = m.code.BUTTON_UP_PRESSED
        curButton -= 10
        if curButton < 0
            curButton +=29 
        end if
    else if key = m.code.BUTTON_RIGHT_PRESSED 
        if curButton >= 29
            curButton = 0
        else
            curButton++
        end if
    else if key = m.code.BUTTON_DOWN_PRESSED
         curButton += 10
        if curButton > 29
            curButton-=29
        end if
    end if
    return curButton
End Function

Function CenterText(text as string, width as integer)
    letterWidth = m.regions.text.Lookup("A").GetWidth()
    length = Len(text) * (letterWidth + 3)
    return Cint((width - length) / 2)
End Function
