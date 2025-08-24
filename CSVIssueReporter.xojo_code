#tag Class
Protected Class CSVIssueReporter
	#tag Method, Flags = &h0, Description = Initializes an empty issue reporter
		Sub Constructor()
		  ReDim mIssues(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Adds a critical error that prevents analysis
		Sub AddCriticalError(lineNumber As Integer, columnIndex As Integer, message As String, suggestion As String = "")
		  Var issue As New CSVIssue(CSVIssue.eSeverity.Critical, lineNumber, columnIndex, message, suggestion)
		  mIssues.Add(issue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Adds a warning that allows analysis to continue
		Sub AddWarning(lineNumber As Integer, columnIndex As Integer, message As String, suggestion As String = "")
		  Var issue As New CSVIssue(CSVIssue.eSeverity.Warning, lineNumber, columnIndex, message, suggestion)
		  mIssues.Add(issue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Adds an informational message
		Sub AddInfo(lineNumber As Integer, columnIndex As Integer, message As String, suggestion As String = "")
		  Var issue As New CSVIssue(CSVIssue.eSeverity.Info, lineNumber, columnIndex, message, suggestion)
		  mIssues.Add(issue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns true if there are any critical errors
		Function HasCriticalErrors() As Boolean
		  For Each issue As CSVIssue In mIssues
		    If issue.GetSeverity() = CSVIssue.eSeverity.Critical Then
		      Return True
		    End If
		  Next
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the count of critical errors
		Function GetCriticalErrorCount() As Integer
		  Var count As Integer = 0
		  For Each issue As CSVIssue In mIssues
		    If issue.GetSeverity() = CSVIssue.eSeverity.Critical Then
		      count = count + 1
		    End If
		  Next
		  Return count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns the count of warnings
		Function GetWarningCount() As Integer
		  Var count As Integer = 0
		  For Each issue As CSVIssue In mIssues
		    If issue.GetSeverity() = CSVIssue.eSeverity.Warning Then
		      count = count + 1
		    End If
		  Next
		  Return count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns formatted report of all issues
		Function GetFormattedReport() As String
		  If mIssues.Count = 0 Then
		    Return "✅ No issues found - CSV file is clean!"
		  End If
		  
		  Var result As String
		  Var criticalCount As Integer = GetCriticalErrorCount()
		  Var warningCount As Integer = GetWarningCount()
		  
		  // Summary
		  result = "=== CSV Analysis Issues ===" + EndOfLine + EndOfLine
		  
		  If criticalCount > 0 Then
		    result = result + "❌ " + Str(criticalCount) + " Critical Error"
		    If criticalCount > 1 Then result = result + "s"
		    result = result + " Found - Analysis stopped" + EndOfLine
		  End If
		  
		  If warningCount > 0 Then
		    result = result + "⚠️  " + Str(warningCount) + " Warning"
		    If warningCount > 1 Then result = result + "s"
		    If criticalCount = 0 Then
		      result = result + " - Analysis completed with notes"
		    End If
		    result = result + EndOfLine
		  End If
		  
		  result = result + EndOfLine
		  
		  // Critical errors first
		  If criticalCount > 0 Then
		    result = result + "CRITICAL ERRORS:" + EndOfLine
		    For Each issue As CSVIssue In mIssues
		      If issue.GetSeverity() = CSVIssue.eSeverity.Critical Then
		        result = result + issue.GetFormattedMessage() + EndOfLine + EndOfLine
		      End If
		    Next
		  End If
		  
		  // Then warnings
		  If warningCount > 0 Then
		    result = result + "WARNINGS:" + EndOfLine
		    For Each issue As CSVIssue In mIssues
		      If issue.GetSeverity() = CSVIssue.eSeverity.Warning Then
		        result = result + issue.GetFormattedMessage() + EndOfLine + EndOfLine
		      End If
		    Next
		  End If
		  
		  Return result.Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Clears all recorded issues
		Sub ClearIssues()
		  ReDim mIssues(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = Returns all issues
		Function GetAllIssues() As CSVIssue()
		  Return mIssues
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = Array of all recorded CSV issues
		Private mIssues() As CSVIssue
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass