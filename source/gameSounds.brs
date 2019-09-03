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

Function LoadSounds(enable as boolean) as object
    sounds = {  enabled:enable,
                folder: "pkg:/assets/sounds/c64/",
                mp3: {clip:"", priority:0, cycles:0},
                wav: {clip:"", priority:0, cycles:0},
                navSingle : CreateObject("roAudioResource", "navsingle"),
                navMulti : CreateObject("roAudioResource", "navmulti"),
                deadend : CreateObject("roAudioResource", "deadend"),
                select : CreateObject("roAudioResource", "select")
             }
    sounds.metadata = ParseJson(ReadAsciiFile(sounds.folder + "sounds.json"))
    for each name in sounds.metadata.clips
        clip = sounds.metadata.clips.Lookup(name)
        if clip <> invalid and clip.type = "wav"
            sounds.AddReplace(name,CreateObject("roAudioResource", sounds.folder + name + ".wav"))
        end if
    next
    return sounds
End Function

Function IsSilent() as boolean
    return (m.sounds.mp3.cycles = 0 and m.sounds.wav.cycles = 0)
End Function

Sub SoundUpdate()
    if not m.sounds.enabled then return
    m.audioPort.GetMessage()
    if m.sounds.mp3.cycles > 0
        m.sounds.mp3.cycles -= 1
    end if
    if m.sounds.wav.cycles > 0
        m.sounds.wav.cycles -= 1
    end if
End Sub

Sub PlaySound(clip as string, overlap = false as boolean, volume = 75 as integer)
    g = GetGlobalAA()
    meta = g.sounds.metadata.clips.Lookup(clip)
    if meta.type = "mp3"
        PlaySoundMp3(clip, overlap)
    else
        PlaySoundWav(clip, overlap, volume)
    end if
End Sub

Sub PlaySoundMp3(clip as string, overlap as boolean)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    ctrl = g.sounds.mp3
    meta = g.sounds.metadata.clips.Lookup(clip)
    if meta = invalid then return
    if ctrl.cycles = 0 or meta.priority > ctrl.priority or (ctrl.clip = clip and overlap)
        'print "play sound mp3: "; clip
        ctrl.clip = clip
        ctrl.priority = meta.priority
        ctrl.cycles = cint(meta.duration / g.speed)
        g.audioPlayer.SetContentList([{url: g.sounds.folder + clip + ".mp3"}])
        g.audioPlayer.setLoop(false)
        g.audioPlayer.play()
    end if
End Sub

Sub PlaySoundWav(clip as string, overlap = false as boolean, volume = 75 as integer)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    ctrl = g.sounds.wav
    meta = g.sounds.metadata.clips.Lookup(clip)
    if meta <> invalid and (meta.priority >= ctrl.priority or ctrl.cycles = 0)
        sound = g.sounds.Lookup(clip)
        'print "play sound wav: "; clip
        StopSound()
        sound.Trigger(volume)
        ctrl.clip = clip
        ctrl.priority = meta.priority
        ctrl.cycles = cint(meta.duration / g.speed)
        g.sounds.wav = ctrl
    end if
End Sub

Sub StopAudio()
    g = GetGlobalAA()
    if g.sounds.enabled
        g.audioPlayer.stop()
        g.sounds.mp3 = {clip:"", priority:0, cycles:0}
    end if
End Sub

Sub StopSound()
    g = GetGlobalAA()
    if g.sounds.enabled
        wav = g.sounds.Lookup(g.sounds.wav.clip)
        if wav <> invalid and wav.IsPlaying()
            wav.Stop()
        end if
        g.sounds.wav = {clip:"", priority:0, cycles:0}
    end if
End Sub
