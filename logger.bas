B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8
@EndOfDesignText@
#IgnoreWarnings: 9
Sub Process_Globals
	Public LogDir  As String
	Public LogFile As String
	Public LogSizeMax  As Int = 1024*1024*2
	Public LogFilesMax As Int = 5
	
	Public DateFormat  As String = "yyyy/MM/dd"
	Public TimeFormat  As String = "HH:mm:ss"
	
	Public LogConsole  As Boolean = False
	Public LogRotate   As Boolean = False
	
	Public LogLevel As String = "INFO"
	
	Dim INFO  As String = "INFO"
	Dim WARN  As String = "WARN"
	Dim ERROR As String = "ERROR"
	
End Sub

Sub wInfo(Message As String) 'ignore
	Write(INFO, Message)
End Sub

Sub wWarn(Message As String) 'ignore
	Write(WARN, Message)
End Sub

Sub wError(Message As String) 'ignore
	Write(ERROR, Message)
End Sub

Sub Write(lLevel As String, Message As String)
	Dim Prefix As String
	If LogDir = "" Or LogFile = "" Then
		#If B4J
		LogError("Unable to log to file!")
		#Else
		Log("Unable to log to file!")
		#End If
		Return
	End If
	lLevel=lLevel.ToUpperCase.Trim
	If lLevel = "" Then lLevel = "INFO"
	
	If LogLevel="ERROR" And LogLevel="INFO" And LogLevel="WARN" Then Return
	If LogLevel="WARN"  And LogLevel="INFO" Then Return 

	DateTime.DateFormat = DateFormat
	DateTime.TimeFormat = TimeFormat
	Prefix = DateTime.Date(DateTime.Now) & " " & DateTime.Time(DateTime.Now) & " " & LogLevel
	Message = Prefix & " - " & Message & CRLF
	If LogConsole=True Then
		If lLevel = ERROR Then
			#If B4J
			LogError(Message)
			#Else
			Log(Message)
			#End If
		Else
			Log(Message)
		End If
	End If
	If LogSizeMax>0 Then
		If File.Size(LogDir, LogFile)>=LogSizeMax Then
			LogFilesRotate
		End If
	End If

	Try
		Dim os As OutputStream = File.OpenOutput(LogDir, LogFile, True)
		Dim data() As Byte = Message.GetBytes("UTF8")
		os.WriteBytes(data, 0, data.Length)
		os.Close
	Catch
		Log(LastException.Message)
	End Try
End Sub

Sub LogFilesRotate
	Dim Files As List
	Dim LogFiles As Map
	Dim FileName As String
	Dim FileNameNew As String
	Dim LogIndex As Int
	Dim LogFileCount As Int
	LogFiles.Initialize
	Files=File.ListFiles(LogDir)
	For I=0 To Files.Size-1
		FileName = Files.Get(I)
		If FileName.StartsWith(LogFile)=False Then Continue
		If FileName.Length=LogFile.Length Then
			LogIndex=0
		Else
			LogIndex = FileName.SubString(LogFile.Length+1)
		End If
		LogFiles.Put(LogIndex, FileName)
		LogFileCount = LogFileCount + 1
	Next
	For I=LogFiles.Size-1 To 0
		FileName=LogFiles.GetValueAt(I)
		LogIndex=LogFiles.GetKeyAt(I)
		Log(LogIndex & " " & FileName)
		If LogFileCount>LogFilesMax Then
			File.Delete(LogDir, FileName)
			Continue
		End If
		Dim NewIndex As Int
		NewIndex = LogIndex
		NewIndex = NewIndex + 1
		FileNameNew = LogFile & "." & NewIndex
		Log(FileName & " ---> " & FileNameNew)
		File.Copy(LogDir, FileName, LogDir, FileNameNew)
		File.Delete(LogDir, FileName)
	Next
End Sub