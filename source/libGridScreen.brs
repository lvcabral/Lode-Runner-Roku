' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: July 2019
' **  Updated: July 2019
' **  Copyright (c) 2016-2019 Marcelo Lv Cabral. All Rights Reserved.
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateGridScreen() as object
    ' Objects
    this = {content:[], canvas: CreateCanvas()}
    this.screen = this.canvas.screen
    this.codes = m.code
    this.sounds = m.sounds
    this.theme = m.theme

    ' Properties
    this.breadCrumb = []
    this.listName = ""
    this.message = ""
    this.focus = 0
    this.visible = false

    ' Methods
    this.SetMessagePort = set_msg_port
    this.SetBreadcrumbText = set_breadcrumb_text
    this.SetListName = set_list_name
    this.SetContentList = set_grid_content
    this.SetContentItem = set_grid_item
    this.GetContentList = get_content_list
    this.SetFocusedListItem = set_focused_item
    this.ShowMessage = show_message
    this.Show = show_grid_screen
    this.Wait = wait_grid_screen
    this.Close = close_screen

    ' Initialize Canvas
    this.canvas.SetLayer(0, GetOverhang())

    return this
End Function

Sub show_grid_screen()
    thumbs = {w:210, h:157}
    txtArray = []
    imgArray = []
    txtArray.Append(m.breadCrumb)
    if m.content.Count() > 0
        menuPos = {x: 44, y: 190}
        txtArray.Push({
                    Text: m.listName
                    TextAttrs: {color: m.theme.ListScreenDescriptionText, font: "Medium", HAlign: "Left"}
                    TargetRect: {x:menuPos.x, y:menuPos.y-42, w:450, h:60}})
        for i = m.first to Min(m.first+14, m.content.Count()-1)
            if m.content[i] <> invalid
                imgArray.Push({
                            url: m.content[i].HDPosterUrl
                            TargetRect: {x: menuPos.x, y: menuPos.y}})
            end if
            if m.focus = i
                imgArray.Push({
                            url: "pkg:/images/grid-focus.png"
                            TargetRect: {x: menuPos.x-11, y: menuPos.y-11}})
            end if
            menuPos.x += thumbs.w + 36
            if i > 0 and (i+1) mod 5 = 0
                menuPos.x = 44
                menuPos.y += thumbs.h + 20
            end if
        next
    else if m.message <> ""
        txtArray.Push({
                    Text: m.message
                    TextAttrs: {color: m.theme.ListScreenDescriptionText, font: "Medium", HAlign: "Center"}
                    TargetRect: {x:44, y:424, w:1184, h:60}})
    end if
    m.canvas.SetLayer(1, imgArray)
    m.canvas.SetLayer(2, txtArray)
    m.canvas.Show()
    m.visible = true
End Sub

Sub set_grid_content(list as object)
    m.content = list
    m.first = 0
    if m.visible then m.Show()
End Sub

Sub set_grid_item(index as integer, item as object)
    m.content[index] = item
    if m.visible and index >= m.first and index < m.first + 15 then m.Show()
End Sub

Function wait_grid_screen(port) as object
    if port = invalid then port = m.canvas.screen.port
    while true
        event = wait(0, port)
        if type(event) = "roUniversalControlEvent"
            index = event.GetInt()
            if index = m.codes.BUTTON_LEFT_PRESSED
                if m.content.Count() > 0
                    if m.focus mod 5 = 0
                        m.focus = Min(m.focus + 4, m.content.Count() - 1)
                        m.sounds.navMulti.Trigger(50)
                    else
                        m.focus--
                        m.sounds.navSingle.Trigger(50)
                    end if
                    m.Show()
                    msg = GetScreenMessage(m.focus, "focused")
                    exit while
                end if
            else if index = m.codes.BUTTON_RIGHT_PRESSED
                if m.content.Count() > 0
                    m.focus++
                    if m.focus mod 5 = 0
                        m.focus -= 5
                        m.sounds.navMulti.Trigger(50)
                    else if m.focus = m.content.Count()
                        m.focus--
                        m.sounds.deadend.Trigger(50)
                    else
                        m.sounds.navSingle.Trigger(50)
                    end if
                    m.Show()
                    msg = GetScreenMessage(m.focus, "focused")
                    exit while
                end if
            else if index = m.codes.BUTTON_UP_PRESSED
                if m.content.Count() > 0
                    m.focus -= 5
                    if m.focus < 0
                        m.focus += 5
                        m.sounds.deadend.Trigger(50)
                    else 
                        if m.focus < m.first then m.first -= 5
                        m.sounds.navSingle.Trigger(50)
                    end if
                    m.Show()
                    msg = GetScreenMessage(m.focus, "focused")
                    exit while
                end if
            else if index = m.codes.BUTTON_DOWN_PRESSED
                if m.content.Count() > 0
                    m.focus += 5
                    if m.focus > m.content.Count() - 1
                        m.focus -= 5
                        m.sounds.deadend.Trigger(50)
                    else 
                        if m.focus > m.first + 14 then m.first += 5
                        m.sounds.navSingle.Trigger(50)
                    end if
                    m.Show()
                    msg = GetScreenMessage(m.focus, "focused")
                    exit while
                end if
            else if index = m.codes.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                msg = GetScreenMessage(m.focus, "closed")
                m.Close()
                exit while
            else if index = m.codes.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                msg = GetScreenMessage(m.focus, "selected")
                exit while
            else if index = m.codes.BUTTON_UP_PRESSED or index = m.codes.BUTTON_DOWN_PRESSED
                m.sounds.dead.Trigger(50)
            end if
        end if
    end while
    return msg
End Function

Sub set_list_name(name as string)
    m.listName = name
    if m.visible then m.Show()
End Sub

Sub show_message(message as string)
    m.message = message
    if m.visible then m.Show()
End Sub