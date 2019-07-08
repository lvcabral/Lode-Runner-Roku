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

Sub DrawStatusBar()
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    if m.bmpStatus = invalid or m.statusRedraw
        statusHeight = m.gameScreen.GetHeight() - (m.const.TILES_Y * m.const.TILE_HEIGHT)
        m.bmpStatus = CreateObject("roBitmap", {width:m.gameScreen.GetWidth(), height:statusHeight, alphaenable:false})
        m.bmpStatus.Clear(m.colors.black)
        x = 0
        y = 0
        ground = m.regions.tiles.Lookup("ground")
        for i = 0 to m.const.TILES_X
            m.bmpStatus.DrawObject(x + i * m.const.TILE_WIDTH, y, ground)
        next
        y += m.const.GROUND_HEIGHT
        if spriteMode = m.const.SPRITES_ZXS
            x = WriteText(m.bmpStatus, "SCORE ", x, y)
        else
            x = WriteText(m.bmpStatus, "SCORE", x, y)
        end if
        x = WriteText(m.bmpStatus, zeroPad(m.runner.score, 7), x, y)
        if spriteMode = m.const.SPRITES_ZXS
            x = WriteText(m.bmpStatus, " LIVES ", x, y)
        else
            x = WriteText(m.bmpStatus, " MEN", x, y)
        end if
        x = WriteText(m.bmpStatus, zeroPad(m.runner.health, 3), x, y)
        if spriteMode = m.const.SPRITES_ZXS
            x = WriteText(m.bmpStatus, " LEVL", x, y)
        else
            x = WriteText(m.bmpStatus, " LEVEL", x, y)
        end if
        x = WriteText(m.bmpStatus, zeroPad(m.currentLevel, 3), x, y)
        m.statusRedraw = false
    end if
    m.gameScreen.DrawObject(0, m.const.TILES_Y * m.const.TILE_HEIGHT, m.bmpStatus)
    DrawLogo(spriteMode)
End Sub

Sub DrawLogo(spriteMode as integer)
    bmp = CreateObject("roBitmap", "pkg:/assets/images/" + GetSpriteFolder(spriteMode) + "/logo.png")
    m.gameBottom.Clear(m.colors.black)
    x = Cint((m.gameBottom.GetWidth() - bmp.GetWidth()) / 2)
    y = Cint((m.gameBottom.GetHeight() - bmp.GetHeight()) / 2)
    m.gameBottom.DrawObject(x, y, bmp)
End Sub

Function WriteText(canvas as object, text as string, x as integer, y as integer, redraw = false as boolean) as integer
    text = UCase(text)
    for c = 0 to len(text) - 1
        ci = asc(text.mid(c,1))
        'Convert accented characters not supported by the font
        if (ci > 191 and ci < 199) or (ci > 223 and ci < 231) 'A
            ci = 65
        else if ci = 199 or ci = 231 'C
            ci = 67
        else if (ci > 199 and ci < 204) or (ci > 231 and ci < 236) 'E
            ci = 69
        else if (ci > 203 and ci < 208) or (ci > 235 and ci < 240) 'I
            ci = 73
        else if ci = 208 'D
            ci = 68
        else if ci = 209 or ci = 241 'N
            ci = 78
        else if (ci > 209 and ci < 215) or (ci > 241 and ci < 247)'O
            ci = 79
        else if ci = 215 'X
            ci = 88
        else if ci = 216 '0
            ci = 48
        else if (ci > 216 and ci < 221) or (ci > 248 and ci < 253) 'U
            ci = 85
        else if ci = 221 'Y
            ci = 89
        else if ci > 160
            ci = 32
        end if
        'write the letter
        char = chr(ci)
        if ci = 08 then char = "back"
        if ci = 13 then char = "enter"
        if ci = 32 then char = "space"
        letter = m.regions.text.Lookup(char)
        if letter = invalid then letter = m.regions.text.Lookup("block")
        if not redraw
            canvas.DrawObject(x, y, letter)
        else
            bmp = CreateObject("roBitmap", {width:letter.GetWidth(), height:letter.GetHeight(), alphaenable:true})
            bmp.Clear(m.colors.black)
            bmp.DrawObject(0, 0, letter)
            canvas.DrawObject(x, y, bmp)
        end if
        x += letter.GetWidth()
    next
    return x
End Function
