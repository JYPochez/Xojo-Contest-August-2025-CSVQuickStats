#tag Class
Protected Class CSVAnalyzer
	#tag Enum, Name = eDataType, Type = Integer, Flags = &h0, Description = 4461746120747970657320666F722043535620636F6C756D6E730A
		Text = 0
		Integer = 1
		Double = 2
		Boolean = 3
		Date = 4
		Mixed = 5
	#tag EndEnum

	#tag Method, Flags = &h0, Description = 496E697469616C697A65732074686520616E616C797A65722077697468206120435356207265616465720A
		Sub Constructor(reader As CSVReader)
		  mReader = reader
		  mColumnStats = New Dictionary
		  mAnalyzed = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 506572666F726D7320636F6D706C65746520616E616C79736973206F66207468652043535620646174610A
		Function Analyze() As Boolean
		  Try
		    // Check if data is available (file may already be read)
		    If mReader.GetColumnCount() = 0 And mReader.GetRowCount() = 0 Then
		      // File not yet read, try to read it
		      If Not mReader.ReadFile() Then
		        Return False
		      End If
		    End If
		    
		    AnalyzeColumns()
		    mAnalyzed = True
		    Return True
		    
		  Catch e As RuntimeException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 416E616C797A6573206561636820636F6C756D6E2064617461207479706520616E6420737461746973746963730A
		Private Sub AnalyzeColumns()
		  Var headers() As String = mReader.GetHeaders()
		  Var rows() As String = mReader.GetRows()
		  
		  For columnIndex As Integer = 0 To mReader.GetColumnCount() - 1
		    Var columnName As String
		    If headers.Count > columnIndex Then
		      columnName = headers(columnIndex)
		    Else
		      columnName = "Column " + Str(columnIndex + 1)
		    End If
		    
		    Var stats As New Dictionary
		    Var values() As String
		    
		    // Collect all values for this column
		    For Each rowString As String In rows
		      Var rowArray() As String = rowString.Split(Chr(1))
		      If rowArray.Count > columnIndex Then
		        values.Add(rowArray(columnIndex))
		      Else
		        values.Add("") // Empty cell
		      End If
		    Next
		    
		    // Analyze this column's data
		    AnalyzeColumnData(values, stats, columnName)
		    mColumnStats.Value(columnName) = stats
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 416E616C797A6573206120737065636966696320636F6C756D6E20646174610A
		Private Sub AnalyzeColumnData(values() As String, stats As Dictionary, columnName As String)
		  stats.Value("total_count") = values.Count
		  stats.Value("empty_count") = 0
		  stats.Value("non_empty_count") = 0
		  stats.Value("unique_count") = 0
		  stats.Value("data_type") = eDataType.Text
		  
		  Var uniqueValues As New Dictionary
		  Var numericValues() As Double
		  Var integerValues() As Integer
		  Var booleanCount As Integer = 0
		  Var dateCount As Integer = 0
		  
		  // First pass: collect unique values and attempt type detection
		  For Each value As String In values
		    If value.Trim = "" Then
		      stats.Value("empty_count") = CType(stats.Value("empty_count"), Integer) + 1
		    Else
		      stats.Value("non_empty_count") = CType(stats.Value("non_empty_count"), Integer) + 1
		      uniqueValues.Value(value) = True
		      
		      // Try to parse as number
		      If IsNumeric(value) Then
		        Var doubleValue As Double = CDbl(value)
		        numericValues.Add(doubleValue)
		        
		        // Check if it's also an integer
		        If doubleValue = Round(doubleValue) Then
		          integerValues.Add(Round(doubleValue))
		        End If
		      End If
		      
		      // Try to parse as boolean
		      Var lowerValue As String = value.Lowercase.Trim
		      If lowerValue = "true" Or lowerValue = "false" Or lowerValue = "yes" Or lowerValue = "no" Or lowerValue = "1" Or lowerValue = "0" Then
		        booleanCount = booleanCount + 1
		      End If
		      
		      // Try to parse as date (simplified check)
		      If IsValidDate(value) Then
		        dateCount = dateCount + 1
		      End If
		    End If
		  Next
		  
		  stats.Value("unique_count") = uniqueValues.KeyCount
		  
		  // Determine primary data type
		  Var nonEmptyCount As Integer = CType(stats.Value("non_empty_count"), Integer)
		  If nonEmptyCount > 0 Then
		    If integerValues.Count = nonEmptyCount Then
		      stats.Value("data_type") = eDataType.Integer
		      CalculateNumericStats(stats, numericValues)
		    ElseIf numericValues.Count = nonEmptyCount Then
		      stats.Value("data_type") = eDataType.Double
		      CalculateNumericStats(stats, numericValues)
		    ElseIf booleanCount = nonEmptyCount Then
		      stats.Value("data_type") = eDataType.Boolean
		    ElseIf dateCount = nonEmptyCount Then
		      stats.Value("data_type") = eDataType.Date
		    ElseIf numericValues.Count > 0 Or booleanCount > 0 Or dateCount > 0 Then
		      stats.Value("data_type") = eDataType.Mixed
		      // Add warning about mixed data types
		      Var issueReporter As CSVIssueReporter = mReader.GetIssueReporter()
		      issueReporter.AddWarning(0, 0, "Column '" + columnName + "' contains mixed data types (text and numbers)", "Consider separating different data types into different columns or cleaning data to be consistent")
		    Else
		      stats.Value("data_type") = eDataType.Text
		    End If
		  End If
		  
		  // Calculate text statistics
		  CalculateTextStats(stats, values)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 43616C63756C61746573206E756D65726963207374617469737469637320666F72206120636F6C756D6E0A
		Private Sub CalculateNumericStats(stats As Dictionary, values() As Double)
		  If values.Count = 0 Then
		    Return
		  End If
		  
		  // Sort for percentile calculations
		  values.Sort()
		  
		  stats.Value("min") = values(0)
		  stats.Value("max") = values(values.Count - 1)
		  
		  // Calculate mean
		  Var sum As Double = 0
		  For Each value As Double In values
		    sum = sum + value
		  Next
		  stats.Value("mean") = sum / values.Count
		  
		  // Calculate median
		  If values.Count Mod 2 = 1 Then
		    stats.Value("median") = values(values.Count \ 2)
		  Else
		    Var mid1 As Integer = values.Count \ 2 - 1
		    Var mid2 As Integer = values.Count \ 2
		    stats.Value("median") = (values(mid1) + values(mid2)) / 2.0
		  End If
		  
		  // Calculate standard deviation
		  Var mean As Double = CType(stats.Value("mean"), Double)
		  Var variance As Double = 0
		  For Each value As Double In values
		    variance = variance + (value - mean) * (value - mean)
		  Next
		  variance = variance / values.Count
		  stats.Value("std_dev") = Sqrt(variance)
		  
		  // Calculate percentiles
		  stats.Value("q1") = CalculatePercentile(values, 0.25)
		  stats.Value("q3") = CalculatePercentile(values, 0.75)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 43616C63756C617465732074657874207374617469737469637320666F72206120636F6C756D6E0A
		Private Sub CalculateTextStats(stats As Dictionary, values() As String)
		  If values.Count = 0 Then
		    Return
		  End If
		  
		  Var lengths() As Integer
		  For Each value As String In values
		    If value.Trim <> "" Then
		      lengths.Add(value.Length)
		    End If
		  Next
		  
		  If lengths.Count > 0 Then
		    lengths.Sort()
		    stats.Value("min_length") = lengths(0)
		    stats.Value("max_length") = lengths(lengths.Count - 1)
		    
		    Var totalLength As Integer = 0
		    For Each length As Integer In lengths
		      totalLength = totalLength + length
		    Next
		    stats.Value("avg_length") = totalLength / lengths.Count
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 43616C63756C6174657320612070657263656E74696C652066726F6D206120736F727465642061727261790A
		Private Function CalculatePercentile(sortedValues() As Double, percentile As Double) As Double
		  If sortedValues.Count = 0 Then
		    Return 0
		  End If
		  
		  If percentile <= 0 Then
		    Return sortedValues(0)
		  End If
		  
		  If percentile >= 1 Then
		    Return sortedValues(sortedValues.Count - 1)
		  End If
		  
		  Var index As Double = percentile * (sortedValues.Count - 1)
		  Var lowerIndex As Integer = Floor(index)
		  Var upperIndex As Integer = Ceiling(index)
		  
		  If lowerIndex = upperIndex Then
		    Return sortedValues(lowerIndex)
		  Else
		    Var weight As Double = index - lowerIndex
		    Return sortedValues(lowerIndex) * (1 - weight) + sortedValues(upperIndex) * weight
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436865636B73206966206120737472696E6720726570726573656E747320612076616C696420646174650A
		Private Function IsValidDate(value As String) As Boolean
		  // Simplified date validation
		  // This is a basic implementation - could be enhanced
		  Try
		    If value.IndexOf("/") > -1 Or value.IndexOf("-") > -1 Or value.IndexOf(".") > -1 Then
		      // Basic pattern matching for date formats
		      Return True
		    End If
		    Return False
		  Catch
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 47657473207374617469737469637320666F72206120737065636966696320636F6C756D6E0A
		Function GetColumnStats(columnName As String) As Dictionary
		  If mColumnStats.HasKey(columnName) Then
		    Return CType(mColumnStats.Value(columnName), Dictionary)
		  Else
		    Return New Dictionary
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 4765747320616C6C20636F6C756D6E206E616D6573207769746820737461746973746963730A
		Function GetColumnNames() As String()
		  Var names() As String
		  For Each key As Variant In mColumnStats.Keys
		    names.Add(CType(key, String))
		  Next
		  Return names
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73206261736963206461746173657420696E666F726D6174696F6E0A
		Function GetDatasetInfo() As Dictionary
		  Var info As New Dictionary
		  info.Value("file_path") = mReader.GetFilePath()
		  info.Value("total_rows") = mReader.GetRowCount()
		  info.Value("total_columns") = mReader.GetColumnCount()
		  info.Value("has_headers") = mReader.GetHeaders().Count > 0
		  Return info
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 436865636B7320696620616E616C7973697320686173206265656E20706572666F726D65640A
		Function IsAnalyzed() As Boolean
		  Return mAnalyzed
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21, Description = 5265666572656E636520746F2074686520435356207265616465720A
		Private mReader As CSVReader
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 53746F726573207374617469737469637320666F72206561636820636F6C756D6E0A
		Private mColumnStats As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 466C616720696E6469636174696E67207768657468657220616E616C7973697320686173206265656E20706572666F726D65640A
		Private mAnalyzed As Boolean
	#tag EndProperty

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass