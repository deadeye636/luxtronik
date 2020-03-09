B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
Sub Class_Globals
	Public Metric           As String
	Public LuxID            As Int
	Public WSPage			As String
	Public WSContent			As String
	Public Description      As String
	Public MQTT				As Boolean
	Public Value				As Int
	Public Unit				As String
	Public Text             As String
End Sub

Public Sub Initialize
	MQTT = True ' TODO: Datenbankfeld anlegen
End Sub