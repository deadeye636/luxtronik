B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.1
@EndOfDesignText@
#IgnoreWarnings: 12

Sub Class_Globals
	Private Config, Defaults As Map
	
	Private Directory, Filename As String
End Sub

Public Sub Initialize(tDirectory As String, tFilename As String)
	Config.Initialize
	Defaults.Initialize
	
	If tDirectory = "" Then tDirectory = File.DirApp
	If tFilename  = "" Then tFilename  = "config.properties"
	
	Directory = tDirectory
	Filename  = tFilename
	
	LoadConfig
End Sub

Public Sub LoadConfig As Boolean
	Private Result As Boolean
	Config.Clear
	
#If Debug
	Config = File.ReadMap2(Directory & "/../", "config.properties", Config)
	Result=True
#Else
	If File.Exists(Directory, Filename) Then
		Config = File.ReadMap(Directory, Filename)
		Result = True
	End If
#End If
	LoadDefaults
	Return Result
End Sub

Public Sub LoadConfigMap(m1 As Map)
	If m1.IsInitialized Then Config = m1
End Sub

Public Sub WriteConfig
	Try
		File.WriteMap(Directory, Filename, Config)
	Catch
		Log(LastException)
	End Try
End Sub

Public Sub Delete(Option As String)
	Config.Remove(Option)
End Sub

Public Sub Reset
	Config.Clear
	LoadDefaults
End Sub

Private Sub LoadDefaults
	For Each k As String In Defaults.Keys
		If Config.ContainsKey(k)=False Then Config.Put(k, Defaults.Get(k))
	Next
End Sub

Public Sub GetString(Option As String, Default As String) As String
	Dim Value As String = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
		If Value="" Then Value=Default
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub GetNum(Option As String, Default As Long) As Object
	Dim Value As String = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
	Catch
		Value="0"
		Log(LastException.Message)
	End Try
	If IsNumber(Value)=False Then Value="0"
	Return Value
End Sub

Public Sub GetInt(Option As String, Default As Int) As Int
	Dim Value As Int = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub GetFloat(Option As String, Default As Float) As Float
	Dim Value As Float = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub GetDouble(Option As String, Default As Double) As Double
	Dim Value As Double = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub GetLong(Option As String, Default As Long) As Long
	Dim Value As Long = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub GetBoolean(Option As String, Default As Boolean) As Boolean
	Dim Value As String = Default
	Try
		If Config.ContainsKey(Option) Then Value=Config.Get(Option)
		Select Value.ToLowerCase
			Case "y", "1"
				Value = True
			Case "n", "0"
				Value = False
		End Select
	Catch
		Log(LastException.Message)
	End Try
	Return Value
End Sub

Public Sub SetString(Option As String, Value As String)
	Config.Put(Option, Value)
End Sub

Public Sub SetInt(Option As String, Value As Int)
	Config.Put(Option, Value)
End Sub

Public Sub SetFloat(Option As String, Value As Float)
	Config.Put(Option, Value)
End Sub

Public Sub SetDouble(Option As String, Value As Double)
	Config.Put(Option, Value)
End Sub

Public Sub SetLong(Option As String, Value As Long)
	Config.Put(Option, Value)
End Sub

Public Sub SetBoolean(Option As String, Value As Boolean)
	Config.Put(Option, Value)
End Sub

