﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
Sub Class_Globals
	Public Metric           As String
	Public LuxID            As Int
	Public Description      As String
	Public FormatID         As Int
	Public MapID            As Int
	Public History          As Boolean
	Public History_Interval As Int
	Public History_LastSave As Long
	Public MQTT				As Boolean
	Public Value            As Double
End Sub

Public Sub Initialize
	MQTT = True ' TODO: Datenbankfeld anlegen
End Sub