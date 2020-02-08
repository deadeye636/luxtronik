B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.1
@EndOfDesignText@
Sub Class_Globals
	Private CallBack    As Object
	Private EventName   As String
	
	Private wsc         As MyWebSocketClient
	Private Connected   As Boolean
	
	Public DoMessageDump As Boolean
	Public DoReconnect   As Boolean
	
	Private LuxHost     As String
	Private LuxPassword As String
	Private LuxPin      As String
		
	Private mNavigation   As Map
	Private mContent      As Map
	Private mContentMapID As Map
	Private CurMenuItem   As cLuxWSItem
	
	Private TimerLuxWSRefresh    As Timer
End Sub

Public Sub Initialize(tCallBack As Object, tEventName As String)
	TimerLuxWSRefresh.Initialize("TimerLuxWSRefresh", 1000 * 5 )
	
	mNavigation.Initialize
	CurMenuItem.Initialize
	mContent.Initialize
	mContentMapID.Initialize
	
	CallBack  = tCallBack
	EventName = tEventName
End Sub

Public Sub Connect(Host As String, Password As String, Pin As String, TimeOut As Int)
	If Connected Then

	End If
	If Host.StartsWith("ws://")=False And Host.StartsWith("wss://")=False Then
		
	End If
	If Password.Length > 6 Or IsNumber(Password)=False Then
		
	End If
	If Pin.Length > 4 Or IsNumber(Pin)=False Then
		
	End If
	If TimeOut=0 Then TimeOut=5000
	LuxHost     = Host
	LuxPassword = Password
	LuxPin      = Pin
	Dim m1 As Map
	m1.Initialize
	wsc.Initialize("wsc", LuxHost, m1, TimeOut)
	wsc.Connect
End Sub

Public Sub Reconnect
	logger.wInfo("Reconnect")
End Sub

Public Sub Disconnect
	If Connected Then
		logger.wInfo("Disconnect")
		wsc.Close
	End If
End Sub

Public Sub getRefreshTimer As Int
	Return TimerLuxWSRefresh.Interval
End Sub
Public Sub setRefreshTimer(tInterval As Int)
	TimerLuxWSRefresh.Interval = tInterval
End Sub

Public Sub getHost As String
	Return LuxHost
End Sub
Public Sub getPassword As String
	Return LuxPassword
End Sub
Public Sub getPin As String
	Return LuxPin
End Sub


Sub wsc_Open (o1 As Object)
	logger.wInfo("WS Open")
	Connected = True
	CallSubDelayed2(CallBack, EventName & "_open", o1)
	wsc.SendText("LOGIN;" & LuxPassword)
End Sub

Sub wsc_Close (code As Int, reason As String, remote As Boolean)
	logger.wInfo($"Connection closed - ${code}-${reason}-${remote}"$)
	wsc_DoDisconnect(remote)
End Sub

Sub wsc_Error
	logger.wInfo("Error " & LastException.Message)
	wsc_DoDisconnect(True)
End Sub

Sub wsc_DoDisconnect(remote As Boolean)
	Connected = False
	
	If DoReconnect And remote Then
		Sleep(5000)
		Reconnect
	End If
End Sub

Sub wsc_Message (Message As String)
	Dim xml As Xml2Map
	Dim m1 As Map
	Dim attr As Map
	Dim id As String

	xml.Initialize
	m1 = xml.Parse(Message)
	
	Dim ItemMap As Map
	ItemMap.Initialize
	If m1.ContainsKey("Navigation") Then
		DumpMessage(Message, "Navigation")
		
		m1 = m1.Get("Navigation")
		attr = m1.Get("Attributes")
		id = attr.Get("id")
		Dim MenuItem As cLuxWSItem
		MenuItem.ID   = id
		MenuItem.Name = "Navigation"
		mNavigation.Put(MenuItem.Name, MenuItem)
		ItemMap = LuxBuildFlatMap("", ItemMap, GetElements(m1, "item"), False)
		mNavigation = ItemMap
		Wait For (LuxInstallateur) Complete(Result As Boolean)
'		CallSubDelayed3(Me, "LuxWSGetContent", mNavigation.Get("Informationen"), True)
		CallSubDelayed2(CallBack, EventName & "_Navigation", mNavigation)
	Else If m1.ContainsKey("Content") Then
		DumpMessage(Message, CurMenuItem.Name)
		m1 = m1.Get("Content")
		attr = m1.Get("Attributes")
		ItemMap = LuxBuildFlatMap("", ItemMap, GetElements(m1, "item"), False)
		mContent = ItemMap
		mContentMapID.Clear
		Dim MenuItem As cLuxWSItem
		For Each k As String In mContent.Keys
			MenuItem = mContent.Get(k)
			mContentMapID.Put(MenuItem.ID, k)
		Next
		CallSubDelayed3(CallBack, EventName & "_Content", CurMenuItem, mContent)
	else If m1.ContainsKey("values") Then
		DumpMessage(Message, CurMenuItem.Name & "_values")
		m1 = m1.Get("values")
		ItemMap = LuxBuildFlatMap("", ItemMap, GetElements(m1, "item"), True)
		
		For Each k As String In ItemMap.Keys
			Dim MenuItemNew As cLuxWSItem
			MenuItemNew = ItemMap.Get(k)
			If mContentMapID.ContainsKey(k) Then
				MenuItem = mContent.Get(mContentMapID.Get(k))
				MenuItem.Value = MenuItemNew.Value
				mContent.Put(mContentMapID.Get(k), MenuItem)
			End If
		Next
		CallSubDelayed3(CallBack, EventName & "_Content", CurMenuItem, mContent)
	Else
		DumpMessage(Message, "unkown")
	End If
	CallSubDelayed2(CallBack, EventName & "_Message", Message)
End Sub

Sub LuxWSGetContent(MenuItem As cLuxWSItem, DoRefresh As Boolean)
	If MenuItem = Null Then Return
	If MenuItem.ID = Null Then Return
	mContent.Clear
	mContentMapID.Clear
	wsc.SendText("GET;" & MenuItem.ID)
	CurMenuItem = MenuItem
	
	TimerLuxWSRefresh.Enabled = False	' Reset Timer
	TimerLuxWSRefresh.Enabled = DoRefresh
End Sub

Sub TimerLuxWSRefresh_Tick
	If mContentMapID.Size = 0 Then Return ' No Page loaded
	Log("TimerLuxWSRefresh_Tick")
	wsc.SendText("REFRESH")
End Sub

Sub LuxInstallateur As ResumableSub
	'GET;0x320f10
	'REFRESH
	'SET;set_0x2eb92c;9445
	'SAVE;1
	
	' Das Menü muss regelmäßig neugeladen werden da es sonst sein kann das man wieder Benutzer ist.
	If mNavigation.ContainsKey("Zugang: Installateur") Then Return False ' Wir sind bereits Installateur
	If mNavigation.ContainsKey("Zugang: Benutzer")=False Then
		' Hier ist was falsch!
		' Wir sind nicht Installateur oder Benutzer
		LogError("Zugangsart konnte nicht bestimmt werden!")
		Return False
	End If
	CallSubDelayed3(Me, "LuxWSGetContent", mNavigation.Get("Zugang: Benutzer"), False)
	Wait For ContentLoaded
	

	If mContent.ContainsKey("Passwort") Then
		Dim ContentItem As cLuxWSItem = mContent.Get("Passwort")
		wsc.SendText("SET;set_" & ContentItem.ID &";" & LuxPin)
		Sleep(500)
		wsc.SendText("SAVE;1")
	End If
	Sleep(500)
	CallSubDelayed3(Me, "LuxWSGetContent", CurMenuItem, True)
	Return True
End Sub


Sub LuxBuildFlatMap(Prefix As String, ItemMap As Map, items As List, IdAsKey As Boolean) As Map
	Dim idx      As Int
	Dim Id       As String
	Dim name     As String
	Dim readonly As Boolean
	Dim m1       As Map
	Dim attr     As Map
	Dim NewPrefix As String
	If items.Size=0 Then Return ItemMap
	
	For idx=0 To items.Size - 1
		m1 = items.Get(idx)
		name = m1.Get("name")
		attr = m1.Get("Attributes")
		Id   = attr.Get("id")
		If m1.ContainsKey("readOnly") And m1.Get("readOnly")="true" Then readonly = True Else readonly = False
		If name.Contains("[") And name.Contains(",") Then
			name = name.SubString(1)
			name = name.SubString2(0, name.IndexOf(",")-1)
			name = name.Trim
		End If
		
		Dim MenuItem As cLuxWSItem
		MenuItem.ID       = Id
		MenuItem.Name     = name
		MenuItem.ReadOnly = readonly
		If m1.ContainsKey("value") Then	MenuItem.Value = m1.Get("value")

		If IdAsKey Then
			ItemMap.Put(Id, MenuItem)
		Else
			ItemMap.Put(Prefix & MenuItem.Name, MenuItem)
		End If
		NewPrefix = Prefix & MenuItem.Name & "/"
		
		If m1.ContainsKey("item") Then ItemMap=LuxBuildFlatMap(NewPrefix, ItemMap, GetElements(m1, "item"), IdAsKey)
	Next
	Return ItemMap
End Sub

Sub GetElements (m As Map, key As String) As List
	Dim res As List
	If m.ContainsKey(key) = False Then
		res.Initialize
		Return res
	Else
		Dim value As Object = m.Get(key)
		If value Is List Then Return value
		res.Initialize
		res.Add(value)
		Return res
	End If
End Sub

Sub DumpMessage(message As String, PageName As String)
	Dim file1 As String
	DateTime.DateFormat = "yyyyMMdd"
	DateTime.TimeFormat = "HHmmss"
	
	If DoMessageDump Then
		file1 = DateTime.Date(DateTime.Now) & "_" &DateTime.Time(DateTime.Now) & "_" & Rnd(0, 9999) & "_" & PageName & ".xml"
		File.WriteString(File.DirApp, file1, message)
	End If
End Sub
