#tag Class
Protected Class CSVReader
	#tag Constant, Name = kDefaultDelimiter, Type = String, Dynamic = False, Default = ",", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kQuoteCharacter, Type = String, Dynamic = False, Default = """", Scope = Public, Description = 4353562071756F7465206368617261637465720A
	#tag EndConstant

	#tag Method, Flags = &h0, Description = 496E697469616C697A657320612043535620726561646572207769746820746865207370656369666965642066696C650A
		Sub Constructor(filePath As String)
		  mFilePath = filePath
		  mDelimiter = ","
		  // Initialize empty array
		  ReDim mHeaders(-1)
		  ReDim mRows(-1)
		  mHasHeaders = True
		  // Initialize issue reporter
		  mIssueReporter = New CSVIssueReporter()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 526561647320746865204353562066696C6520616E64207061727365732069747320636F6E74656E74730A
		Function ReadFile() As Boolean
		  Try
		    Var csvFile As FolderItem = New FolderItem(mFilePath, FolderItem.PathModes.Native)
		    If Not csvFile.Exists Then
		      mIssueReporter.AddCriticalError(0, 0, "File not found: " + mFilePath, "Check file path and permissions")
		      Return False
		    End If
		    
		    // Check file size (50MB limit)
		    If csvFile.Length > 52428800 Then // 50MB in bytes
		      mIssueReporter.AddCriticalError(0, 0, "File exceeds maximum size limit (50MB)", "Use a smaller file or split into multiple files")
		      Return False
		    End If
		    
		    Var input As TextInputStream = TextInputStream.Open(csvFile)
		    input.Encoding = Encodings.UTF8
		    
		    Var content As String = input.ReadAll
		    input.Close
		    
		    // Check for completely empty file
		    If content.Trim = "" Then
		      mIssueReporter.AddCriticalError(0, 0, "File is completely empty", "Ensure the file contains CSV data")
		      Return False
		    End If
		    
		    Return ParseCSVContent(content)
		    
		  Catch e As RuntimeException
		    mIssueReporter.AddCriticalError(0, 0, "Failed to read file: " + e.Message, "Check file permissions and format")
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365732043535620636F6E74656E7420696E746F206865616465727320616E6420726F77730A
		Private Function ParseCSVContent(content As String) As Boolean
		  Try
		    // Split content into lines
		    Var lines() As String = content.Split(EndOfLine)
		    
		    // Remove empty lines at the end
		    While lines.Count > 0 And lines(lines.Count - 1).Trim = ""
		      lines.RemoveAt(lines.Count - 1)
		    Wend
		    
		    If lines.Count = 0 Then
		      mIssueReporter.AddCriticalError(0, 0, "No valid data found in file", "Ensure file contains CSV data with proper line endings")
		      Return False
		    End If
		    
		    // Parse headers if present
		    Var startRow As Integer = 0
		    Var expectedColumnCount As Integer = 0
		    
		    If mHasHeaders And lines.Count > 0 Then
		      mHeaders = ParseCSVLine(lines(0), 1) // Line 1 for headers
		      If mHeaders.Count = 0 Then
		        mIssueReporter.AddCriticalError(1, 0, "Header row is empty or malformed", "Ensure first row contains valid column headers")
		        Return False
		      End If
		      expectedColumnCount = mHeaders.Count
		      startRow = 1
		    Else
		      mIssueReporter.AddWarning(0, 0, "No header row detected", "Consider adding column headers for clarity")
		    End If
		    
		    // Parse data rows with detailed error checking
		    ReDim mRows(-1)
		    Var validRowCount As Integer = 0
		    
		    For i As Integer = startRow To lines.Count - 1
		      Var lineNumber As Integer = i + 1 // 1-based line numbers for user
		      
		      If lines(i).Trim = "" Then
		        // Skip empty lines but warn about them
		        mIssueReporter.AddWarning(lineNumber, 0, "Empty line encountered", "Remove empty lines for cleaner data")
		        Continue
		      End If
		      
		      Var rowData() As String = ParseCSVLine(lines(i), lineNumber)
		      If rowData.Count = 0 Then
		        // ParseCSVLine already reported the specific error
		        Continue
		      End If
		      
		      // Check column count consistency
		      If expectedColumnCount = 0 Then
		        expectedColumnCount = rowData.Count
		      ElseIf rowData.Count <> expectedColumnCount Then
		        If rowData.Count < expectedColumnCount Then
		          mIssueReporter.AddWarning(lineNumber, 0, "Missing columns - Expected " + Str(expectedColumnCount) + ", found " + Str(rowData.Count), "Add missing commas or values")
		        Else
		          mIssueReporter.AddWarning(lineNumber, 0, "Extra columns - Expected " + Str(expectedColumnCount) + ", found " + Str(rowData.Count), "Remove extra columns or check for unescaped commas")
		        End If
		      End If
		      
		      // Store the row data
		      mRows.Add(String.FromArray(rowData, Chr(1)))
		      validRowCount = validRowCount + 1
		    Next
		    
		    // Check if we have any valid data rows
		    If validRowCount = 0 Then
		      mIssueReporter.AddCriticalError(0, 0, "No valid data rows found", "Ensure file contains parseable CSV data after headers")
		      Return False
		    End If
		    
		    // Success with possible warnings
		    If mIssueReporter.GetWarningCount() > 0 And Not mIssueReporter.HasCriticalErrors() Then
		      mIssueReporter.AddInfo(0, 0, "CSV parsed successfully with " + Str(validRowCount) + " data rows", "")
		    End If
		    
		    Return True
		    
		  Catch e As RuntimeException
		    mIssueReporter.AddCriticalError(0, 0, "Unexpected error during parsing: " + e.Message, "Check file format and encoding")
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320612073696E676C6520435356206C696E6520696E746F20636F6C756D6E20646174610A
		Private Function ParseCSVLine(line As String, lineNumber As Integer = 0) As String()
		  Var columns() As String
		  Var currentColumn As String = ""
		  Var inQuotes As Boolean = False
		  Var i As Integer = 0
		  Var currentColumnIndex As Integer = 1 // 1-based for user display
		  
		  While i < line.Length
		    Var char As String = line.Mid(i + 1, 1)
		    
		    Select Case char
		    Case kQuoteCharacter
		      If inQuotes Then
		        // Check for escaped quote (double quote)
		        If i + 1 < line.Length And line.Mid(i + 2, 1) = kQuoteCharacter Then
		          currentColumn = currentColumn + kQuoteCharacter
		          i = i + 1 // Skip next quote
		        Else
		          inQuotes = False
		        End If
		      Else
		        inQuotes = True
		      End If
		      
		    Case mDelimiter
		      If inQuotes Then
		        currentColumn = currentColumn + char
		      Else
		        columns.Add(currentColumn.Trim)
		        currentColumn = ""
		        currentColumnIndex = currentColumnIndex + 1
		      End If
		      
		    Else
		      currentColumn = currentColumn + char
		    End Select
		    
		    i = i + 1
		  Wend
		  
		  // Check for unclosed quotes - this is a critical error
		  If inQuotes Then
		    mIssueReporter.AddCriticalError(lineNumber, currentColumnIndex, "Unclosed quote in field", "Add closing quote or escape internal quotes with double quotes")
		    ReDim columns(-1) // Return empty array to indicate parsing failure
		    Return columns
		  End If
		  
		  // Add the last column
		  columns.Add(currentColumn.Trim)
		  
		  Return columns
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652068656164657273206F6620746865204353562066696C650A
		Function GetHeaders() As String()
		  Return mHeaders
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206461746120726F7773206F6620746865204353562066696C650A
		Function GetRows() As String()
		  Return mRows
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206E756D626572206F6620636F6C756D6E7320696E20746865204353562066696C650A
		Function GetColumnCount() As Integer
		  If mHeaders.Count > 0 Then
		    Return mHeaders.Count
		  ElseIf mRows.Count > 0 Then
		    Var firstRow() As String = mRows(0).Split(Chr(1))
		    Return firstRow.Count
		  Else
		    Return 0
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206E756D626572206F66206461746120726F777320696E20746865204353562066696C650A
		Function GetRowCount() As Integer
		  Return mRows.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652069737375652072657064F7274657220666F72206572726F7220616E64207761726E696E672064657461696C730A
		Function GetIssueReporter() As CSVIssueReporter
		  Return mIssueReporter
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5365747320776865746865722074686520666972737420726F7720636F6E7461696E732068656164657273202864656661756C743A2074727565290A
		Sub SetHasHeaders(hasHeaders As Boolean)
		  mHasHeaders = hasHeaders
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53657473207468652064656C696D697465722063686172616374657220666F7220746865204353562066696C65202864656661756C743A20636F6D6D61290A
		Sub SetDelimiter(delimiter As String)
		  mDelimiter = delimiter
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652066696C6520706174680A
		Function GetFilePath() As String
		  Return mFilePath
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = 5061746820746F20746865204353562066696C6520746F20726561640A
		Private mFilePath As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 44656C696D6974657220636861726163746572207573656420696E20746865204353562066696C650A
		Private mDelimiter As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 48656164657273206F6620746865204353562066696C650A
		Private mHeaders() As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 4461746120726F7773206F6620746865204353562066696C650A
		Private mRows() As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 576865746865722074686520666972737420726F7720636F6E7461696E7320686561646572730A
		Private mHasHeaders As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 4973737565207265706F7274657220666F7220747261636B696E67207061727365206572726F727320616E64207761726E696E67730A
		Private mIssueReporter As CSVIssueReporter
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass