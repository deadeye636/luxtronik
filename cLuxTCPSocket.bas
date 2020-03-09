B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.1
@EndOfDesignText@
Sub Class_Globals
	Private CallBack    As Object
	Private EventName   As String
		
	Public DoMessageDump As Boolean
	Public DoReconnect   As Boolean
	
	Private LuxHost     As String
	Private LuxPort     As Int
	Private LuxTimeout  As Int
	
	Private Working As Boolean
	Private StreamBuffer As B4XBytesBuilder
	
	Private Timer1 As Timer
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(tCallBack As Object, tEventName As String, Host As String, Port As Int, TimeOut As Int)
	CallBack  = tCallBack
	EventName = tEventName
	
	LuxHost    = Host
	LuxPort    = Port
	LuxTimeout = TimeOut
	If LuxPort   =0 Then LuxPort    = 8888
	If LuxTimeout=0 Then LuxTimeout = 3
	
	StreamBuffer.Initialize
	Timer1.Initialize("Timer1", 1000)
End Sub

Public Sub SetInterval(Interval As Int)
	If Interval=0 Then
		Timer1.Enabled = False
	Else
		If Timer1.Enabled = False Then Timer1_Tick
		Timer1.Interval = Interval
		Timer1.Enabled  = True
	End If
End Sub

Sub Timer1_Tick
	GetData
End Sub

Public Sub GetData
	Dim start As Long = DateTime.Now
	logger.wInfo($"Connect to Luxtronik ${LuxHost}:${LuxPort}"$)
	If Working Then
		logger.wInfo($"busy..."$)
		Return
	End If
	Dim Socket  As Socket
	Dim aStream As AsyncStreams
	
	Working = True
	Socket.Initialize("Socket")
	Socket.Connect(LuxHost, LuxPort, LuxTimeout*1000)
	
	Wait For Socket_Connected (Successful As Boolean)
	If Successful Then
		StreamBuffer.Clear
		aStream.Initialize(Socket.InputStream, Socket.OutputStream, "Stream")
		logger.wInfo("Luxtronik GetCalcs (3004)")
		LuxReqVals(aStream, 3004)
		Sleep(1000)
		Dim vals() As Int = 	LuxReadVals(StreamBuffer.ToArray, 3004)
		StreamBuffer.Clear
		CallSubDelayed3(CallBack, EventName & "_NewData", 3004, vals)
		
		logger.wInfo("Luxtronik GetParams (3003)")
		LuxReqVals(aStream, 3003)
		Sleep(1000)
		Dim vals() As Int = 	LuxReadVals(StreamBuffer.ToArray, 3003)
		StreamBuffer.Clear
		CallSubDelayed3(CallBack, EventName & "_NewData", 3003, vals)
		
		aStream.Close
		Socket.Close
	Else
		logger.wError("Unable to connect! timeout!")
		logger.wError(LastException.Message)
	End If
	Working = False
	logger.wInfo($"LuxGetData duration $1.0{DateTime.Now - start} $"$)
End Sub

Sub LuxReqVals(aStream As AsyncStreams, opcode As Int)
	Dim b() As Byte
	Dim bc As ByteConverter

	bc.LittleEndian = False
	b = bc.IntsToBytes(Array As Int(opcode, 0))
	aStream.Write(b)
End Sub

Sub LuxReadVals(Buffer() As Byte, OpCode As Int) As Int()
	Dim Raf    As RandomAccessFile
	Dim vals() As Int
	
	logger.wInfo("Luxtronik read values")
	Raf.Initialize3(Buffer,False)
	Dim OperationResult As Int=Raf.ReadInt(Raf.CurrentPosition)' Reads the first 4 bytes
	If OperationResult<>OpCode Then
		logger.wWARN("Wrong data package received " & OperationResult)
		Return vals
	End If
	If OpCode=3004 Then	Raf.ReadInt(Raf.CurrentPosition)
	Try
		Dim TextLen As Int=Raf.ReadInt(Raf.CurrentPosition) 'read the second 4 bytes
	Catch
		logger.wError("Can't decode buffer!")
		logger.wError(LastException.Message)
		Return vals
	End Try
	
	If TextLen=0 Or TextLen>2000 Then
		logger.wError("Array size to big or zero?")
		Return vals
	End If
	
	Dim i(TextLen) As Int
	For idx = 0 To TextLen-1
		i(idx) = Raf.ReadInt(Raf.CurrentPosition)
	Next
	vals = i
	Return vals
End Sub

Sub Stream_NewData (Buffer() As Byte)
'	logger.wInfo("Luxtronik NewData")
	StreamBuffer.Append(Buffer)
End Sub

Sub Stream_Error
	logger.wError("Stream Error!")
	logger.wError(LastException.Message)
End Sub

Sub Stream_Terminated
End Sub

#Region ParamSet
Sub SendData(OpCode As Int, Params As Map) As ResumableSub
	Dim s1   As Socket
	Dim b() As Byte
	Dim bc As ByteConverter
	Dim astream As AsyncStreams
	
	Dim ParamID  As Int
	Dim ParamVal As Int
	
	s1.Initialize("SocketParamSet")
	s1.Connect(LuxHost, LuxPort, LuxTimeout)
	Wait For SocketParamSet_Connected (Successful As Boolean)
	If Successful Then
		astream.Initialize(s1.InputStream, s1.OutputStream, "StreamParamSet")
		bc.LittleEndian = False
		For idx=0 To Params.Size-1
			ParamID  = Params.GetKeyAt(idx)
			ParamVal = Params.GetValueAt(idx)
			b = bc.IntsToBytes(Array As Int(OpCode, ParamID, ParamVal))
			astream.Write(b)
		Next 
	End If
	astream.Close
	s1.Close
	Return Successful
End Sub

Sub StreamParamSet_NewData (Buffer() As Byte)
End Sub

Sub StreamParamSet_Error
End Sub

Sub StreamParamSet_Terminated
End Sub
#End Region