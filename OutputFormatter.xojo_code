#tag Class
Protected Class OutputFormatter
	#tag Method, Flags = &h0, Description = 496E697469616C697A657320746865206F757470757420666F726D6174746572207769746820616E20616E616C797A65720A
		Sub Constructor(analyzer As CSVAnalyzer, issueReporter As CSVIssueReporter = Nil)
		  mAnalyzer = analyzer
		  mIssueReporter = issueReporter
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 466F726D617473206F757470757420666F7220636F6E736F6C6520646973706C61790A
		Function FormatConsoleOutput() As String
		  Var output As String = ""
		  
		  If Not mAnalyzer.IsAnalyzed() Then
		    Return "Error: Data has not been analyzed yet."
		  End If
		  
		  Var info As Dictionary = mAnalyzer.GetDatasetInfo()
		  
		  // Dataset overview
		  output = output + "=== CSV Quick Statistics ===" + EndOfLine + EndOfLine
		  output = output + "File: " + CType(info.Value("file_path"), String) + EndOfLine
		  output = output + "Rows: " + CType(info.Value("total_rows"), Integer).ToString + EndOfLine
		  output = output + "Columns: " + CType(info.Value("total_columns"), Integer).ToString + EndOfLine
		  output = output + "Has Headers: " + If(CType(info.Value("has_headers"), Boolean), "Yes", "No") + EndOfLine
		  output = output + EndOfLine
		  
		  // Column statistics
		  output = output + "=== Column Statistics ===" + EndOfLine + EndOfLine
		  
		  Var columnNames() As String = mAnalyzer.GetColumnNames()
		  For Each columnName As String In columnNames
		    output = output + FormatColumnStats(columnName, mAnalyzer.GetColumnStats(columnName))
		    output = output + EndOfLine
		  Next
		  
		  Return output
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D617473207374617469737469637320666F7220612073696E676C6520636F6C756D6E0A
		Private Function FormatColumnStats(columnName As String, stats As Dictionary) As String
		  Var output As String = ""
		  
		  output = output + "Column: " + columnName + EndOfLine
		  output = output + "  Type: " + GetDataTypeName(CType(stats.Value("data_type"), CSVAnalyzer.eDataType)) + EndOfLine
		  output = output + "  Total Count: " + CType(stats.Value("total_count"), Integer).ToString + EndOfLine
		  output = output + "  Non-Empty: " + CType(stats.Value("non_empty_count"), Integer).ToString + EndOfLine
		  output = output + "  Empty: " + CType(stats.Value("empty_count"), Integer).ToString + EndOfLine
		  output = output + "  Unique Values: " + CType(stats.Value("unique_count"), Integer).ToString + EndOfLine
		  
		  // Add numeric statistics if available
		  If stats.HasKey("min") Then
		    output = output + "  Min: " + CType(stats.Value("min"), Double).ToString + EndOfLine
		    output = output + "  Max: " + CType(stats.Value("max"), Double).ToString + EndOfLine
		    output = output + "  Mean: " + Format(CType(stats.Value("mean"), Double), "0.00") + EndOfLine
		    output = output + "  Median: " + Format(CType(stats.Value("median"), Double), "0.00") + EndOfLine
		    output = output + "  Std Dev: " + Format(CType(stats.Value("std_dev"), Double), "0.00") + EndOfLine
		    output = output + "  Q1: " + Format(CType(stats.Value("q1"), Double), "0.00") + EndOfLine
		    output = output + "  Q3: " + Format(CType(stats.Value("q3"), Double), "0.00") + EndOfLine
		  End If
		  
		  // Add text statistics if available
		  If stats.HasKey("min_length") Then
		    output = output + "  Min Length: " + CType(stats.Value("min_length"), Integer).ToString + EndOfLine
		    output = output + "  Max Length: " + CType(stats.Value("max_length"), Integer).ToString + EndOfLine
		    output = output + "  Avg Length: " + CType(stats.Value("avg_length"), Integer).ToString + EndOfLine
		  End If
		  
		  Return output
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436F6E76657274732064617461207479706520656E756D20746F2068756D616E207265616461626C6520737472696E670A
		Private Function GetDataTypeName(dataType As CSVAnalyzer.eDataType) As String
		  Select Case dataType
		  Case CSVAnalyzer.eDataType.Text
		    Return "Text"
		  Case CSVAnalyzer.eDataType.Integer
		    Return "Integer"
		  Case CSVAnalyzer.eDataType.Double
		    Return "Number"
		  Case CSVAnalyzer.eDataType.Boolean
		    Return "Boolean"
		  Case CSVAnalyzer.eDataType.Date
		    Return "Date"
		  Case CSVAnalyzer.eDataType.Mixed
		    Return "Mixed"
		  Else
		    Return "Unknown"
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 466F726D617473206F7574707574206173204A534F4E20737472696E670A
		Function FormatJSONOutput() As String
		  If Not mAnalyzer.IsAnalyzed() Then
		    Return "{""error"": ""Data has not been analyzed yet.""}"
		  End If
		  
		  Var json As String = "{"
		  
		  // Dataset info
		  Var info As Dictionary = mAnalyzer.GetDatasetInfo()
		  json = json + """dataset"": {"
		  json = json + """file_path"": """ + EscapeJSONString(CType(info.Value("file_path"), String)) + ""","
		  json = json + """total_rows"": " + CType(info.Value("total_rows"), Integer).ToString + ","
		  json = json + """total_columns"": " + CType(info.Value("total_columns"), Integer).ToString + ","
		  json = json + """has_headers"": " + If(CType(info.Value("has_headers"), Boolean), "true", "false")
		  json = json + "},"
		  
		  // Add issue information if available
		  If mIssueReporter <> Nil Then
		    json = json + """issues"": " + FormatIssuesJSON() + ","
		  End If
		  
		  // Columns
		  json = json + """columns"": {"
		  
		  Var columnNames() As String = mAnalyzer.GetColumnNames()
		  For i As Integer = 0 To columnNames.Count - 1
		    If i > 0 Then json = json + ","
		    json = json + """" + EscapeJSONString(columnNames(i)) + """: "
		    json = json + FormatColumnStatsJSON(mAnalyzer.GetColumnStats(columnNames(i)))
		  Next
		  
		  json = json + "}}"
		  
		  Return json
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D617473206120636F6C756D6E2073746174697374696373206173204A534F4E206F626A6563740A
		Private Function FormatColumnStatsJSON(stats As Dictionary) As String
		  Var json As String = "{"
		  
		  json = json + """type"": """ + GetDataTypeName(CType(stats.Value("data_type"), CSVAnalyzer.eDataType)) + ""","
		  json = json + """total_count"": " + CType(stats.Value("total_count"), Integer).ToString + ","
		  json = json + """non_empty_count"": " + CType(stats.Value("non_empty_count"), Integer).ToString + ","
		  json = json + """empty_count"": " + CType(stats.Value("empty_count"), Integer).ToString + ","
		  json = json + """unique_count"": " + CType(stats.Value("unique_count"), Integer).ToString
		  
		  // Add numeric statistics if available
		  If stats.HasKey("min") Then
		    json = json + ","
		    json = json + """min"": " + CType(stats.Value("min"), Double).ToString + ","
		    json = json + """max"": " + CType(stats.Value("max"), Double).ToString + ","
		    json = json + """mean"": " + CType(stats.Value("mean"), Double).ToString + ","
		    json = json + """median"": " + CType(stats.Value("median"), Double).ToString + ","
		    json = json + """std_dev"": " + CType(stats.Value("std_dev"), Double).ToString + ","
		    json = json + """q1"": " + CType(stats.Value("q1"), Double).ToString + ","
		    json = json + """q3"": " + CType(stats.Value("q3"), Double).ToString
		  End If
		  
		  // Add text statistics if available
		  If stats.HasKey("min_length") Then
		    json = json + ","
		    json = json + """min_length"": " + CType(stats.Value("min_length"), Integer).ToString + ","
		    json = json + """max_length"": " + CType(stats.Value("max_length"), Integer).ToString + ","
		    json = json + """avg_length"": " + CType(stats.Value("avg_length"), Integer).ToString
		  End If
		  
		  json = json + "}"
		  
		  Return json
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D6174732069737375652072657078F7274206173204A534F4E206F626A6563740A
		Private Function FormatIssuesJSON() As String
		  If mIssueReporter = Nil Then
		    Return "{}"
		  End If
		  
		  Var json As String = "{"
		  Var issues() As CSVIssue = mIssueReporter.GetAllIssues()
		  
		  json = json + """has_issues"": " + If(issues.Count > 0, "true", "false") + ","
		  json = json + """critical_error_count"": " + Str(mIssueReporter.GetCriticalErrorCount()) + ","
		  json = json + """warning_count"": " + Str(mIssueReporter.GetWarningCount()) + ","
		  json = json + """details"": ["
		  
		  For i As Integer = 0 To issues.Count - 1
		    If i > 0 Then json = json + ","
		    Var issue As CSVIssue = issues(i)
		    json = json + "{"
		    json = json + """severity"": """ + GetSeverityName(issue.GetSeverity()) + ""","
		    json = json + """line_number"": " + Str(issue.GetLineNumber()) + ","
		    json = json + """column_index"": " + Str(issue.GetColumnIndex()) + ","
		    json = json + """message"": """ + EscapeJSONString(issue.GetMessage()) + ""","
		    json = json + """suggestion"": """ + EscapeJSONString(issue.GetSuggestion()) + """"
		    json = json + "}"
		  Next
		  
		  json = json + "]}"
		  Return json
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D61747320697373756520726570B;67274206173204D61726B646F776E2073656374696F6E0A
		Private Function FormatIssuesMarkdown() As String
		  If mIssueReporter = Nil Then
		    Return ""
		  End If
		  
		  Var issues() As CSVIssue = mIssueReporter.GetAllIssues()
		  If issues.Count = 0 Then
		    Return "## Data Quality" + EndOfLine + EndOfLine + "✅ **No issues found** - CSV file is clean!" + EndOfLine
		  End If
		  
		  Var md As String = "## Data Quality Issues" + EndOfLine + EndOfLine
		  
		  Var criticalCount As Integer = mIssueReporter.GetCriticalErrorCount()
		  Var warningCount As Integer = mIssueReporter.GetWarningCount()
		  
		  // Summary
		  If criticalCount > 0 Then
		    md = md + "❌ **" + Str(criticalCount) + " Critical Error"
		    If criticalCount > 1 Then md = md + "s"
		    md = md + "** - Analysis stopped" + EndOfLine + EndOfLine
		  End If
		  
		  If warningCount > 0 Then
		    md = md + "⚠️ **" + Str(warningCount) + " Warning"
		    If warningCount > 1 Then md = md + "s"
		    If criticalCount = 0 Then
		      md = md + "** - Analysis completed with notes"
		    Else
		      md = md + "**"
		    End If
		    md = md + EndOfLine + EndOfLine
		  End If
		  
		  // Critical errors first
		  If criticalCount > 0 Then
		    md = md + "### Critical Errors" + EndOfLine + EndOfLine
		    For Each issue As CSVIssue In issues
		      If issue.GetSeverity() = CSVIssue.eSeverity.Critical Then
		        md = md + FormatIssueMarkdown(issue) + EndOfLine
		      End If
		    Next
		    md = md + EndOfLine
		  End If
		  
		  // Then warnings
		  If warningCount > 0 Then
		    md = md + "### Warnings" + EndOfLine + EndOfLine
		    For Each issue As CSVIssue In issues
		      If issue.GetSeverity() = CSVIssue.eSeverity.Warning Then
		        md = md + FormatIssueMarkdown(issue) + EndOfLine
		      End If
		    Next
		  End If
		  
		  Return md
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D617473206120736968676C652069737375652061732048617A6B646F776E0A
		Private Function FormatIssueMarkdown(issue As CSVIssue) As String
		  Var md As String = ""
		  
		  Select Case issue.GetSeverity()
		  Case CSVIssue.eSeverity.Critical
		    md = "- ❌ **CRITICAL"
		  Case CSVIssue.eSeverity.Warning
		    md = "- ⚠️ **WARNING"
		  Case CSVIssue.eSeverity.Info
		    md = "- ℹ️ **INFO"
		  End Select
		  
		  md = md + " (Line " + Str(issue.GetLineNumber())
		  If issue.GetColumnIndex() > 0 Then
		    md = md + ", Column " + Str(issue.GetColumnIndex())
		  End If
		  md = md + ")**: " + issue.GetMessage()
		  
		  If issue.GetSuggestion() <> "" Then
		    md = md + EndOfLine + "  - *Suggestion*: " + issue.GetSuggestion()
		  End If
		  
		  Return md + EndOfLine
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 466F726D617473206F7574707574206173204D61726B646F776E20737472696E670A
		Function FormatMarkdownOutput() As String
		  If Not mAnalyzer.IsAnalyzed() Then
		    Return "# CSV Quick Statistics" + EndOfLine + EndOfLine + "**Error**: Data has not been analyzed yet."
		  End If
		  
		  Var md As String = ""
		  
		  // Header
		  md = md + "# CSV Quick Statistics" + EndOfLine + EndOfLine
		  
		  // Dataset overview
		  Var info As Dictionary = mAnalyzer.GetDatasetInfo()
		  md = md + "## Dataset Overview" + EndOfLine + EndOfLine
		  md = md + "- **File**: `" + CType(info.Value("file_path"), String) + "`" + EndOfLine
		  md = md + "- **Rows**: " + CType(info.Value("total_rows"), Integer).ToString + EndOfLine
		  md = md + "- **Columns**: " + CType(info.Value("total_columns"), Integer).ToString + EndOfLine
		  md = md + "- **Has Headers**: " + If(CType(info.Value("has_headers"), Boolean), "Yes", "No") + EndOfLine
		  md = md + EndOfLine
		  
		  // Add issue information if available
		  If mIssueReporter <> Nil Then
		    md = md + FormatIssuesMarkdown()
		    md = md + EndOfLine
		  End If
		  
		  // Column statistics
		  md = md + "## Column Statistics" + EndOfLine + EndOfLine
		  
		  Var columnNames() As String = mAnalyzer.GetColumnNames()
		  For Each columnName As String In columnNames
		    md = md + FormatColumnStatsMarkdown(columnName, mAnalyzer.GetColumnStats(columnName))
		    md = md + EndOfLine
		  Next
		  
		  Return md
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 466F726D617473206120636F6C756D6E2073746174697374696373206173204D61726B646F776E2073656374696F6E0A
		Private Function FormatColumnStatsMarkdown(columnName As String, stats As Dictionary) As String
		  Var md As String = ""
		  
		  md = md + "### " + columnName + EndOfLine + EndOfLine
		  md = md + "| Statistic | Value |" + EndOfLine
		  md = md + "|-----------|-------|" + EndOfLine
		  md = md + "| Type | " + GetDataTypeName(CType(stats.Value("data_type"), CSVAnalyzer.eDataType)) + " |" + EndOfLine
		  md = md + "| Total Count | " + CType(stats.Value("total_count"), Integer).ToString + " |" + EndOfLine
		  md = md + "| Non-Empty | " + CType(stats.Value("non_empty_count"), Integer).ToString + " |" + EndOfLine
		  md = md + "| Empty | " + CType(stats.Value("empty_count"), Integer).ToString + " |" + EndOfLine
		  md = md + "| Unique Values | " + CType(stats.Value("unique_count"), Integer).ToString + " |" + EndOfLine
		  
		  // Add numeric statistics if available
		  If stats.HasKey("min") Then
		    md = md + "| Min | " + CType(stats.Value("min"), Double).ToString + " |" + EndOfLine
		    md = md + "| Max | " + CType(stats.Value("max"), Double).ToString + " |" + EndOfLine
		    md = md + "| Mean | " + Format(CType(stats.Value("mean"), Double), "0.00") + " |" + EndOfLine
		    md = md + "| Median | " + Format(CType(stats.Value("median"), Double), "0.00") + " |" + EndOfLine
		    md = md + "| Std Dev | " + Format(CType(stats.Value("std_dev"), Double), "0.00") + " |" + EndOfLine
		    md = md + "| Q1 | " + Format(CType(stats.Value("q1"), Double), "0.00") + " |" + EndOfLine
		    md = md + "| Q3 | " + Format(CType(stats.Value("q3"), Double), "0.00") + " |" + EndOfLine
		  End If
		  
		  // Add text statistics if available
		  If stats.HasKey("min_length") Then
		    md = md + "| Min Length | " + CType(stats.Value("min_length"), Integer).ToString + " |" + EndOfLine
		    md = md + "| Max Length | " + CType(stats.Value("max_length"), Integer).ToString + " |" + EndOfLine
		    md = md + "| Avg Length | " + CType(stats.Value("avg_length"), Integer).ToString + " |" + EndOfLine
		  End If
		  
		  Return md
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 45736361706573207370656369616C206368617261637465727320696E204A534F4E20737472696E670A
		Private Function EscapeJSONString(value As String) As String
		  // Basic JSON string escaping
		  value = value.ReplaceAll(Chr(92), Chr(92) + Chr(92)) // Backslash
		  value = value.ReplaceAll(Chr(34), Chr(92) + Chr(34)) // Quote
		  value = value.ReplaceAll(Chr(13), Chr(92) + "r")     // Carriage return
		  value = value.ReplaceAll(Chr(10), Chr(92) + "n")     // Line feed
		  value = value.ReplaceAll(Chr(9), Chr(92) + "t")      // Tab
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 57726974657320666F726D6174746564206F757470757420746F20612066696C650A
		Function WriteToFile(content As String, filePath As String) As Boolean
		  Try
		    Var outputFile As FolderItem = New FolderItem(filePath, FolderItem.PathModes.Native)
		    Var output As TextOutputStream = TextOutputStream.Create(outputFile)
		    output.Encoding = Encodings.UTF8
		    output.Write(content)
		    output.Close
		    Return True
		  Catch e As RuntimeException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436F6E76657274732073657665726974792065756D20746F20737472696E670A
		Private Function GetSeverityName(severity As CSVIssue.eSeverity) As String
		  Select Case severity
		  Case CSVIssue.eSeverity.Critical
		    Return "critical"
		  Case CSVIssue.eSeverity.Warning
		    Return "warning"
		  Case CSVIssue.eSeverity.Info
		    Return "info"
		  Else
		    Return "unknown"
		  End Select
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = 5265666572656E636520746F207468652043535620616E616C797A65720A
		Private mAnalyzer As CSVAnalyzer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 5265666572656E636520746F20746865206973737565207265706F727465720A
		Private mIssueReporter As CSVIssueReporter
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass