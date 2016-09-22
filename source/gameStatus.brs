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

Sub DrawStatusBar()
    if m.settings.spriteMode < m.const.SPRITES_RND
        spriteMode = m.settings.spriteMode
    else
        spriteMode = m.levelSprites[m.currentLevel]
    end if
    x = 0
    y = m.const.TILES_Y * m.const.TILE_HEIGHT
    ground = m.regions.tiles.Lookup("ground")
    for i = 0 to m.const.TILES_X
        m.gameScreen.DrawObject(x + i * m.const.TILE_WIDTH, y, ground)
    next
    y += m.const.GROUND_HEIGHT
    if spriteMode = m.const.SPRITES_ZXS
        x = WriteText(m.gameScreen, "SCORE ", x, y)
    else
        x = WriteText(m.gameScreen, "SCORE", x, y)
    end if
    x = WriteText(m.gameScreen, zeroPad(m.runner.score, 7), x, y)
    if spriteMode = m.const.SPRITES_ZXS
        x = WriteText(m.gameScreen, " LIVES ", x, y)
    else
        x = WriteText(m.gameScreen, " MEN", x, y)
    end if
    x = WriteText(m.gameScreen, zeroPad(m.runner.health, 3), x, y)
    if spriteMode = m.const.SPRITES_ZXS
        x = WriteText(m.gameScreen, " LEVL", x, y)
    else
        x = WriteText(m.gameScreen, " LEVEL", x, y)
    end if
    x = WriteText(m.gameScreen, zeroPad(m.currentLevel, 3), x, y)
    DrawLogo(spriteMode)
End Sub

Sub DrawLogo(spriteMode as integer)
    bmp = CreateObject("roBitmap", "pkg:/assets/images/" + GetSpriteFolder(spriteMode) + "/logo.png")
    m.gameBottom.Clear(m.colors.black)
    x = Cint((m.gameBottom.GetWidth() - bmp.GetWidth()) / 2)
    y = Cint((m.gameBottom.GetHeight() - bmp.GetHeight()) / 2)
    m.gameBottom.DrawObject(x, y, bmp)
End Sub

Function WriteText(screen as object, text as string, x as integer, y as integer) as integer
    text = UCase(text)
    for c = 0 to len(text) - 1
        ci = asc(text.mid(c,1))
        'Convert accented characters not supported by the font
        if ci > 191 and ci < 199
            ci = 65
        else if ci = 199
            ci = 67
        else if ci > 199 and ci < 204
            ci = 69
        else if ci > 203 and ci < 208
            ci = 73
        else if ci = 208
            ci = 68
        else if ci = 209
            ci = 78
        else if ci > 209 and ci < 215
            ci = 79
        else if ci = 215
            ci = 120
        else if ci = 216
            ci = 48
        else if ci > 216 and ci < 221
            ci = 85
        else if ci = 221
            ci = 89
        else if ci > 223 and ci < 231
            ci = 97
        else if ci = 231
            ci = 99
        else if ci > 231 and ci < 236
            ci = 101
        else if ci > 235 and ci < 240
            ci = 105
        else if ci = 240
            ci = 100
        else if ci = 241
            ci = 110
        else if ci > 241 and ci < 247
            ci = 111
        else if ci > 248 and ci < 253
            ci = 117
        else if ci > 160
            ci = 32
        end if
        'write the letter
        char = chr(ci)
        if ci = 32 then char = "space"
        letter = m.regions.text.Lookup(char)
        if letter <> invalid
            screen.DrawObject(x, y, letter)
            x += letter.GetWidth()
        end if
    next
    return x
End Function
