#tag Class
Protected Class CSVIssue
	#tag Enum, Name = eSeverity, Type = Integer, Flags = &h0, Description = Severity levels for CSV parsing issues
		Critical = 0
		Warning = 1
		Info = 2
	#tag EndEnum

	#tag Method, Flags = &h0, Description = Initializes a CSV issue with details
		Sub Constructor(severity As eSeverity, lineNumber As Integer, columnIndex As Integer, message As String, suggestion As String = "")
		  mSeverity = severity
		  mLineNumber = lineNumber
		  mColumnIndex = columnIndex
		  mMessage = message
		  mSuggestion = suggestion
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns formatted issue message for console display
		Function GetFormattedMessage() As String
		  Var prefix As String
		  Select Case mSeverity
		  Case eSeverity.Critical
		    prefix = "❌ CRITICAL"
		  Case eSeverity.Warning
		    prefix = "⚠️  WARNING"
		  Case eSeverity.Info
		    prefix = "ℹ️  INFO"
		  End Select
		  
		  Var location As String = "Line " + Str(mLineNumber)
		  If mColumnIndex > 0 Then
		    location = location + ", Column " + Str(mColumnIndex)
		  End If
		  
		  Var result As String = prefix + " (" + location + "): " + mMessage
		  If mSuggestion <> "" Then
		    result = result + EndOfLine + "    → Suggestion: " + mSuggestion
		  End If
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the severity level of this issue
		Function GetSeverity() As eSeverity
		  Return mSeverity
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the line number where this issue occurred
		Function GetLineNumber() As Integer
		  Return mLineNumber
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the column index where this issue occurred
		Function GetColumnIndex() As Integer
		  Return mColumnIndex
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the issue message
		Function GetMessage() As String
		  Return mMessage
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the suggested solution
		Function GetSuggestion() As String
		  Return mSuggestion
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = The severity level of this issue
		Private mSeverity As eSeverity
	#tag EndProperty

	#tag Property, Flags = &h21, Description = The line number where this issue occurred
		Private mLineNumber As Integer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = The column index where this issue occurred (0 for row-level issues)
		Private mColumnIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = The issue message
		Private mMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = Suggested solution for this issue
		Private mSuggestion As String
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass