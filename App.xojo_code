#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Constant, Name = kApplicationName, Type = String, Dynamic = False, Default = "CSVQuickStats", Scope = Public, Description = 4170706C69636174696F6E206E616D652075736564207468726F7567686F757420746865206170700A
	#tag EndConstant

	#tag Constant, Name = kApplicationVersion, Type = String, Dynamic = False, Default = "1.0.0", Scope = Public, Description = 4170706C69636174696F6E2076657273696F6E20737472696E670A
	#tag EndConstant

	#tag Constant, Name = kUsageMessage, Type = String, Dynamic = False, Default = "Usage: CSVQuickStats <csv-file> [--json <output-file>] [--markdown <output-file>]", Scope = Public, Description = 436F6D6D616E64206C696E6520757361676520696E737472756374696F6E730A
	#tag EndConstant

	#tag Event, Description = 48616E646C657320636F6E736F6C65206170706C69636174696F6E20737461727475702C2070617273657320617267756D656E74732C20616E642070726F636573736573204353562066696C650A
		Sub Run(args() As String)
		  Try
		    If ParseCommandLineArguments(args) Then
		      ProcessCSVFile()
		    End If
		  Catch e As RuntimeException
		    PrintError("Error: " + e.Message)
		    Quit(1)
		  End Try
		  
		  Quit(0)
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h21, Description = 50617273657320617267756D656E747320616E64207365747320696E7374616E63652070726F706572746965730A
		Private Function ParseCommandLineArguments(args() As String) As Boolean
		  If args.Count < 2 Then
		    PrintUsage()
		    Return False
		  End If
		  
		  mCSVFilePath = args(1)
		  
		  // Check if file exists
		  Var csvFile As FolderItem = New FolderItem(mCSVFilePath, FolderItem.PathModes.Native)
		  If Not csvFile.Exists Then
		    PrintError("Error: File not found: " + mCSVFilePath)
		    Return False
		  End If
		  
		  // Parse optional arguments
		  Var i As Integer = 2
		  While i < args.Count
		    Select Case args(i)
		    Case "--json"
		      If i + 1 < args.Count And args(i + 1).Left(2) <> "--" Then
		        mJSONOutputPath = args(i + 1)
		        i = i + 2 // Skip next argument
		      Else
		        // Generate automatic filename
		        mJSONOutputPath = GenerateOutputFilename(mCSVFilePath, "json")
		        i = i + 1
		      End If
		    Case "--markdown"
		      If i + 1 < args.Count And args(i + 1).Left(2) <> "--" Then
		        mMarkdownOutputPath = args(i + 1)
		        i = i + 2 // Skip next argument
		      Else
		        // Generate automatic filename
		        mMarkdownOutputPath = GenerateOutputFilename(mCSVFilePath, "md")
		        i = i + 1
		      End If
		    Else
		      PrintError("Error: Unknown argument: " + args(i))
		      PrintUsage()
		      Return False
		    End Select
		  Wend
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50726F63657373657320746865204353562066696C6520616E64206F757470757473207374617469737469637320746F20636F6E736F6C6520616E64206F7074696F6E616C2066696C65730A
		Private Sub ProcessCSVFile()
		  Print(GlobalConstants.gAnalyzingMessage)
		  
		  // Create CSV reader and read file to trigger parsing
		  Var reader As New CSVReader(mCSVFilePath)
		  If Not reader.ReadFile() Then
		    // Check for parsing issues and show detailed report
		    Var issueReporter As CSVIssueReporter = reader.GetIssueReporter()
		    Print("")
		    Print(issueReporter.GetFormattedReport())
		    PrintError(GlobalConstants.gErrorAnalysisFailed)
		    Return
		  End If
		  
		  // Store initial warning count before analysis
		  Var issueReporter As CSVIssueReporter = reader.GetIssueReporter()
		  Var initialWarningCount As Integer = issueReporter.GetWarningCount()
		  
		  // Show any parsing warnings
		  If initialWarningCount > 0 Then
		    Print("")
		    Print(issueReporter.GetFormattedReport())
		    Print("")
		  End If
		  
		  Var analyzer As New CSVAnalyzer(reader)
		  
		  // Perform analysis (file already read, so this will just analyze data)
		  If Not analyzer.Analyze() Then
		    PrintError(GlobalConstants.gErrorAnalysisFailed)
		    Return
		  End If
		  
		  // Check for any new warnings generated during analysis
		  If issueReporter.GetWarningCount() > initialWarningCount Then
		    Print("")
		    Print(issueReporter.GetFormattedReport())
		    Print("")
		  End If
		  
		  // Create output formatter with issue reporter
		  Var formatter As New OutputFormatter(analyzer, issueReporter)
		  
		  // Always show console output
		  Print("")
		  Print(formatter.FormatConsoleOutput())
		  
		  // Export to JSON if requested
		  If mJSONOutputPath <> "" Then
		    If ConfirmFileReplacement(mJSONOutputPath) Then
		      Var jsonOutput As String = formatter.FormatJSONOutput()
		      If formatter.WriteToFile(jsonOutput, mJSONOutputPath) Then
		        Print(GlobalConstants.gSuccessOutputCreated + " " + mJSONOutputPath)
		      Else
		        PrintError(GlobalConstants.gErrorOutputFailed + " (JSON)")
		      End If
		    Else
		      Print("JSON export cancelled.")
		    End If
		  End If
		  
		  // Export to Markdown if requested
		  If mMarkdownOutputPath <> "" Then
		    If ConfirmFileReplacement(mMarkdownOutputPath) Then
		      Var markdownOutput As String = formatter.FormatMarkdownOutput()
		      If formatter.WriteToFile(markdownOutput, mMarkdownOutputPath) Then
		        Print(GlobalConstants.gSuccessOutputCreated + " " + mMarkdownOutputPath)
		      Else
		        PrintError(GlobalConstants.gErrorOutputFailed + " (Markdown)")
		      End If
		    Else
		      Print("Markdown export cancelled.")
		    End If
		  End If
		  
		  Print("")
		  Print(GlobalConstants.gProcessingComplete)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5072696E7473206170706C69636174696F6E2075736167652068656C700A
		Private Sub PrintUsage()
		  Print(kApplicationName + " v" + kApplicationVersion)
		  Print("")
		  Print(kUsageMessage)
		  Print("")
		  Print("Arguments:")
		  Print("  <csv-file>              Path to the CSV file to analyze")
		  Print("  --json <output-file>    Export statistics to JSON file")
		  Print("  --markdown <output-file> Export statistics to Markdown file")
		  Print("")
		  Print("Example:")
		  Print("  CSVQuickStats data.csv")
		  Print("  CSVQuickStats data.csv --json stats.json --markdown report.md")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5072696E747320616E206572726F72206D65737361676520746F2073746465727220696620706F737369626C650A
		Private Sub PrintError(message As String)
		  // In Xojo console applications, Print writes to stderr for error messages
		  System.DebugLog(message)
		  Print(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 47656E6572617465732061757465F6D61746963206F757470757420666696C656E616D652066726F6D20435356207061746820616E6420657874656E73696F6E0A
		Private Function GenerateOutputFilename(csvPath As String, extension As String) As String
		  Var csvFile As FolderItem = New FolderItem(csvPath, FolderItem.PathModes.Native)
		  Var baseName As String = csvFile.Name
		  
		  // Remove .csv extension if present
		  If baseName.EndsWith(".csv") Then
		    baseName = baseName.Left(baseName.Length - 4)
		  End If
		  
		  // Create output filename in same directory as CSV file
		  Var outputPath As String = csvFile.Parent.NativePath + "/" + baseName + "." + extension
		  
		  Return outputPath
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 41736B732075736572206966206578697364696E672066696C652073686F756C64E2066520726570266163656420
		Private Function ConfirmFileReplacement(filePath As String) As Boolean
		  Var outputFile As FolderItem = New FolderItem(filePath, FolderItem.PathModes.Native)
		  If outputFile.Exists Then
		    Print("Output file already exists: " + filePath)
		    Print("Replace existing file? (y/N): ")
		    
		    Var input As String = Input
		    Return input.Lowercase.Trim = "y" Or input.Lowercase.Trim = "yes"
		  End If
		  
		  Return True // File doesn't exist, proceed
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = 5061746820746F20746865204353562066696C6520746F2070726F636573730A
		Private mCSVFilePath As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 4F7074696F6E616C207061746820666F72204A534F4E206F75747075740A
		Private mJSONOutputPath As String
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 4F7074696F6E616C207061746820666F72204D61726B646F776E206F75747075740A
		Private mMarkdownOutputPath As String
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass