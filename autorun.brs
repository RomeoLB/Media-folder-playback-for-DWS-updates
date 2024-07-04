'04/07/24 - RLB - v4.5
'Standalone script to playback files on Media folder on current storage
'As PlayStaticImage() is broken on XC4055 using roImagePlayer instead...
'WORKING SCRIPT for Standalone playback for single screen and multi screen
'Media files are sorted in ABC order before playback
'Playback of video files in Media folder are looped
'content update is done via DWS by deleting and adding new files to Media folder


Sub Main()

	m.msgPort = CreateObject("roMessagePort")
	b = CreateObject("roByteArray")
	b.FromHexString("ffffffff")
	color_spec% = (255*256*256*256) + (b[1]*256*256) + (b[2]*256) + b[3]

	vm = CreateObject("roVideoMode")
	vm.SetBackgroundColor(color_spec%)
	SystemLog = CreateObject("roSystemLog")
	
	di = CreateObject("roDeviceInfo")
	model = di.GetModel()
	outputNumber = Mid(model, 3, 1)


	'outputNumber = "1"

	print " outputNumber: "; outputNumber 

	'video mode screen for single output player config
	SingleOutputVideomodeScreen = "1920x1080x60p"
	'SingleOutputVideomodeScreen = "3840x2160x50p:fullres"
	'SingleOutputVideomodeScreen = "Modeline 1280x720x30p 35.25  1280 1320 1440 1600  720 723 728 736 -hsync +vsync"

	'video mode screen for each screen for Multi output config
	'MultiOutputVideomodeScreen = "1920x1080x60p"
	MultiOutputVideomodeScreen = "3840x2160x60p"

	' SystemLog.sendline("@@@ MultiOutputVideomodeScreen: " + MultiOutputVideomodeScreen)

	if outputNumber = "1" then
		vm.Setmode(SingleOutputVideomodeScreen)
		SystemLog.sendline("@@@ SingleOutputVideomodeScreen: " + SingleOutputVideomodeScreen)
		'vm.SetCustomModeline("Modeline 1280x720x30p 35.25  1280 1320 1440 1600  720 723 728 736 -hsync +vsync")
	else if outputNumber = "2" or outputNumber = "4" then
		print ""
		print " @@@ MultiOutputVideomodeScreen @@@ "
		print ""
		SystemLog.sendline("@@@ MultiOutputVideomodeScreen: " + MultiOutputVideomodeScreen)
		sm = vm.GetScreenModes()
		'videomodeScreen = "3840x2160x25p:fullres" - fullres param not to be used in dual screen config
		'videomodeScreen = "3840x2160x50p:fullres" - fullres param not to be used in dual screen config
		'videomodeScreen = "3840x2160x50p"
	  
		' For using BrightAuthor:Connected, it is recommended that the fullres modifier be added to prevent
		' the zones from scaling across the entire canvas.
		sm[0].name = "HDMI-1"
		'sm[0].video_mode = "Modeline 1080x1920_50.00  144.50  1080 1160 1272 1464  1920 1923 1933 1978 -hsync +vsync"
		'sm[0].video_mode = "Modeline 3840x2160x30p 297.00 3840 4016 4104 4400  2160 2168 2178 2250  +hsync -vsync"
		sm[0].video_mode = MultiOutputVideomodeScreen
		sm[0].transform = "normal"
		sm[0].display_x = 0
		sm[0].display_y = 0
		sm[0].enabled = true
	  
		' Safeguard for models more than 1 HDMI outputs
		if (sm[1] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			sm[1].name = "HDMI-2"
			'sm[1].video_mode ="Modeline 1080x1920_50.00  144.50  1080 1160 1272 1464  1920 1923 1933 1978 -hsync +vsync"
			'sm[1].video_mode = "Modeline 3840x2160x30p 297.00 3840 4016 4104 4400  2160 2168 2178 2250  +hsync -vsync"
			sm[1].video_mode = MultiOutputVideomodeScreen
			sm[1].transform = "normal"
			sm[1].display_x = 1920
			sm[1].display_y = 0
			sm[1].enabled = false
		end if

		if (sm[2] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			sm[2].name = "HDMI-3"
			'sm[1].video_mode ="Modeline 1080x1920_50.00  144.50  1080 1160 1272 1464  1920 1923 1933 1978 -hsync +vsync"
			'sm[1].video_mode = "Modeline 3840x2160x30p 297.00 3840 4016 4104 4400  2160 2168 2178 2250  +hsync -vsync"
			sm[2].video_mode = MultiOutputVideomodeScreen
			sm[2].transform = "normal"
			sm[2].display_x = 0
			sm[2].display_y = 0
			sm[2].enabled = false
		  end if
	
		  if (sm[3] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			sm[3].name = "HDMI-4"
			'sm[1].video_mode ="Modeline 1080x1920_50.00  144.50  1080 1160 1272 1464  1920 1923 1933 1978 -hsync +vsync"
			'sm[1].video_mode = "Modeline 3840x2160x30p 297.00 3840 4016 4104 4400  2160 2168 2178 2250  +hsync -vsync"
			sm[3].video_mode = MultiOutputVideomodeScreen
			sm[3].transform = "normal"
			sm[3].display_x = 0
			sm[3].display_y = 0
			sm[3].enabled = false
		  end if

		vm.SetScreenModes(sm)

		reportedVideoMode = vm.GetScreenModes()[0].video_mode
		print "reportedVideoMode: "; reportedVideoMode
		SystemLog.sendline("@@@ reportedVideoMode: " + reportedVideoMode)
	end if	

	graphicPlaneWidth = vm.GetResX()
	graphicPlaneHeight = vm.GetResY()

	print "graphicPlaneWidth: "; graphicPlaneWidth
	print "graphicPlaneHeight: "; graphicPlaneHeight

	'''''''''''''''''''''''''''''''''''''''
	r1CoordinateX = 0
	r1CoordinateY = 0

	r2CoordinateX = 0
	r2CoordinateY = 0

	m.r1 = createobject("rorectangle",r1CoordinateX,r1CoordinateY,graphicPlaneWidth,graphicPlaneHeight)
	m.r2 = createobject("rorectangle",r2CoordinateX,r2CoordinateY,graphicPlaneWidth,graphicPlaneHeight)

	'''''''''''''''''''''''''''''''''''''''
	SystemLog.sendline("@@@ Rectangle 1 param: " + str(r1CoordinateX) + " , " +  str(r1CoordinateY) + " , " + str(graphicPlaneWidth) + " , " +  str(graphicPlaneHeight))
	SystemLog.sendline("@@@ Rectangle 2 param: " + str(r2CoordinateX) + " , " +  str(r2CoordinateY) + " , " + str(graphicPlaneWidth) + " , " +  str(graphicPlaneHeight))
	SystemLog.sendline("@@@ Graphics Plane width: " + str(vm.GetResX()) + " - Graphics Plane height: " + str(vm.GetResY()))
	SystemLog.sendline("@@@ Video Plane width: " + str(vm.GetVideoResX()) + " - Video Plane height: " + str(vm.GetVideoResY()))
	'stop

	m.sTime = createObject("roSystemTime")
	gpioPort = CreateObject("roControlPort", "BrightSign")
	gpioPort.SetPort(m.msgPort)	
	m.StartDelayTimer = StartDelayTimer
	m.sh = CreateObject("roStorageHotplug")
	m.sh.SetPort(m.msgPort)
	m.mountedPath = ""
	m.ActivePlaylist = []
	FadeOutLengthVal = 1000
	m.ImageTransitionTimeoutVal = 5000

	StoragePath = FindSourcePath()
	print "StoragePath: "; StoragePath

	ListMediaFiles(StoragePath)

	while true
	    
		msg = wait(0, m.msgPort)
		
		'print "type of msgPort is ";type(msg)
	
		if type(msg) = "roControlDown" then
		
			button = msg.GetInt()

			print ""
			print " GPIO roControlDown GPIO "; button 
			print m.sTime.GetLocalDateTime()
			print ""
				
			if button = 12 then 
				print " @@@ GPIO 12 pressed @@@  "
				stop
			end if
		else if type(msg) = "roControlUp" then
			button = msg.GetInt()
		else if type(msg) = "roDatagramEvent" then

		else if type(msg) = "roTimerEvent" then

			timerIdentity = msg.GetSourceIdentity()
			UserData = msg.GetUserData()

			if m.DelayTimer <> invalid then
				if m.DelayTimer.GetIdentity() = timerIdentity then
					InitialisePlayers()
				end if
			end if 	
			if m.Imagetransition <> invalid then
				if m.Imagetransition.GetIdentity() = timerIdentity then
					'print "  *********  Imagetransition Timer Done ******** "
					PlayPlaylist(m.playlist1, 1, 1)
				end if
			end if		
		else if type(msg) = "roVideoEvent" then	

			VideoPlayerEventReceived = msg.GetInt()
		
			if VideoPlayerEventReceived = 8 then 
			
				VideoSourceIdentity = msg.GetSourceIdentity()
				VideoSourceIdentity$ = VideoSourceIdentity.toStr()
	
				if m.PlaybackAA <> invalid then
				
					FindMyID = m.PlaybackAA.lookup(VideoSourceIdentity$)
					PlayPlaylist(m.playlist1, 1, 1)
				end if 
			else if VideoPlayerEventReceived = 3 then
				m.i1.StopDisplay()
			end if
		end if				
	end while
End Sub



Function StartDelayTimer()

	retval = false

	m.DelayTimer = invalid
	
	m.DelayTimer = CreateObject("roTimer")
	m.DelayTimer.SetUserData({name:"DelayTimer"})
	m.DelayTimer.SetPort(m.msgPort)
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddMilliseconds(1000)
	m.DelayTimer.SetDateTime(newTimeout)
	ok = m.DelayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function ListMediaFiles(storagePath)

    PlayableFileOnStorage = CreateObject("roArray", 1, true)
	m.mountedPath = storagePath + "Media/"
    FileOnStorage = ListDir(m.mountedPath)
    m.playlist1 = CreateObject("roArray", 1, true)
    index = 0
    ext = ""

	for each file in FileOnStorage

		ext = ucase(right(file,4))

		if ucase(right(file,4)) = ".MP4" or ucase(right(file,4)) = ".MOV" or ucase(right(file,4)) = ".JPG" or ucase(right(file,4)) = ".PNG" then 
			if ext = ".MP4" or ext = ".MOV" then 
				filetype = "video"
			else if ext = ".JPG" or ext = ".PNG" then
				filetype = "image"
			end if 	

			if left(file,2) <> "._" then
				PlayableFileOnStorage.push(file)
				filepath$ = m.mountedPath + file
				m.playlist1[index] = {filename: file, filepath: m.mountedPath + file, filetype: filetype}					
				index = index + 1
			end if
		end if
	next 

	SortFilesABC()

	if m.playlist1.count() > 0 then

		print " @@@ File(s) in Media folder @@@ "
		playlistIndex = 0
		for each file in m.playlist1
			print m.playlist1[playlistIndex].filename
			playlistIndex = playlistIndex + 1
		next     
		print ""

		ok = m.StartDelayTimer()

		if ok = true then
			return true
		end if 
	end if 
End Function



Function StartImagetransitionTimer(TimeOnScreen as integer)As boolean

	retval = false
	
	m.Imagetransition = CreateObject("roTimer")
	m.Imagetransition.SetUserData({name:"Imagetransition"})
	m.Imagetransition.SetPort(m.msgPort)
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddMilliseconds(TimeOnScreen)
	m.Imagetransition.SetDateTime(newTimeout)
	ok = m.Imagetransition.Start()

	if ok then
		return true
	end if 

	return retval	
End Function



Function PlayPlaylist(Playlist as Object, playlistNum as integer, fileIndex as integer) As Boolean

	m.ActivePlaylist[playlistNum] = playlist
	
	if m.ActivePlaylist[playlistNum].count() >= 0 then
		
		if m.PlayfileIndex[fileIndex] = -1 or m.PlayfileIndex[fileIndex] >= m.ActivePlaylist[playlistNum].count() then
			m.PlayfileIndex[fileIndex] = 0
		end if

		if m.PlayfileIndex[fileIndex] <= m.ActivePlaylist[playlistNum].count() then

			VideoIndex = m.PlayfileIndex[fileIndex]
				
			print " --- Loading File: "	m.ActivePlaylist[playlistNum][VideoIndex].filename

			if m.ActivePlaylist[playlistNum][VideoIndex].filetype = "video" then

				print " --- Loaded File is a Video --- "
			
				m.v1.SetRectangle(m.r1)
				ok = m.v1.PlayFile({Filename: m.ActivePlaylist[playlistNum][VideoIndex].filepath})
				CurrentVideoFileDuration = m.v1.GetDuration()
				print " @@@ CurrentVideoFileDuration @@@ " CurrentVideoFileDuration	
			else if m.ActivePlaylist[playlistNum][VideoIndex].filetype = "image" then

				print " --- Loaded File is an Image --- "
				'Below is broken on Series 5 so using roImagePlayer instead...
				' ok = videoplayer.PlayStaticImage({Filename: m.ActivePlaylist[playlistNum][VideoIndex].filepath})

				m.i1.SetRectangle(m.r2)
				m.i1.DisplayFile({Filename: m.ActivePlaylist[playlistNum][VideoIndex].filepath})
				m.v1.StopClear()
				StartImagetransitionTimer(m.ImageTransitionTimeoutVal)
			end if	
		end if
		
		if m.PlayfileIndex[fileIndex] = m.ActivePlaylist[playlistNum].count() then
			m.PlayfileIndex[fileIndex] = 0
		else if m.ActivePlaylist[playlistNum].count() >  VideoIndex then
			VideoIndex = VideoIndex + 1
			m.PlayfileIndex[fileIndex] = VideoIndex
		end if
	end if
End Function



Function InitialisePlayers()

	m.PlaybackAA = {}
	
	m.v1 = CreateObject("roVideoPlayer")
	m.v1.SetPort(m.msgport)
	m.v1.SetRectangle(m.r1)
	'm.v1.SetViewMode(0)
	m.v1.SetViewMode("ScaleToFit")
	m.v1.SetLoopMode(0)
	m.v1_IDTemp = m.v1.GetIdentity()
	m.v1_ID = m.v1_IDTemp.Tostr()
	m.PlaybackAA.AddReplace(m.v1_ID, "v1")


	m.i1 = CreateObject("roImagePlayer")
	m.i1.SetDefaultMode(0)
	m.i1.SetRectangle(m.r2)

	m.Playfile1Index = 0

	m.PlayfileIndex = CreateObject("roArray", 1, true)
	m.PlayfileIndex[1] = m.Playfile1Index

	m.Playlists = CreateObject("roArray", 1, true)
	m.Playlists[1] = m.playlist1
	
	m.VideoPlayers = CreateObject("roArray", 1, true)
	m.VideoPlayers[1] = m.v1

	'starting playback here
	PlayPlaylist(m.playlist1, 1, 1)
End Function



Function FindDestPath()
    destinationPaths = ["SSD:", "SD:", "USB1:"]
    for each destination in destinationPaths
        if IsMounted(destination) then
            return destination+"/"
        end if
    next
    return "unknown"
End Function



Function FindSourcePath()
    sourcePaths = ["USB1:", "SD:", "SSD:"]
    for each source in sourcePaths
		print "source: "; source
        if IsMounted(source) and IsExists(source+"/autorun.brs") then
            return source+"/"
        end if
    next
    return "unknown"
End Function



Function IsMounted(path as String)
    if CreateObject("roStorageHotplug").GetStorageStatus(path).mounted then
        return true
    end if

    return false
End Function



Function IsExists(path as String)
    file = CreateObject("roReadFile", path)
    if type(file) = "roReadFile" then
        return true
    end if

    return false
End Function



Function SortFilesABC() As Boolean
	
	if m.playlist1.count() > 0 then
        for i% = m.playlist1.count() - 1 to 1 step -1
            for j% = 0 to i% - 1
                if m.playlist1[j%].filename > m.playlist1[j%+1].filename then
                    tmp = m.playlist1[j%].filename
                    m.playlist1[j%].filename = m.playlist1[j%+1].filename
                    m.playlist1[j%+1].filename = tmp
                    
                    ttmp$ = m.playlist1[j%].filetype
                    m.playlist1[j%].filetype = m.playlist1[j%+1].filetype
                    m.playlist1[j%+1].filetype = ttmp$

					ptmp$ = m.playlist1[j%].filepath
                    m.playlist1[j%].filepath = m.playlist1[j%+1].filepath
                    m.playlist1[j%+1].filepath = ptmp$
                end if
            next
        next
    end if

	print" m.playlist1" + Chr(13) + Chr(10) m.playlist1
End Function