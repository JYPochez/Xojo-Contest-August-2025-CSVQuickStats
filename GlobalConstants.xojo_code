#tag Module
Protected Module GlobalConstants
	#tag Constant, Name = gAnalyzingMessage, Type = String, Dynamic = False, Default = \"Analyzing CSV file...", Scope = Public
	#tag EndConstant

	#tag Constant, Name = gCompanyName, Type = String, Dynamic = False, Default = \"VeryniceSW", Scope = Public, Description = 436F6D70616E79206E616D65207573656420696E20746865206170706C69636174696F6E0A
	#tag EndConstant

	#tag Constant, Name = gCompanyURL, Type = String, Dynamic = False, Default = \"https://www.verynicesw.fr", Scope = Public, Description = 436F6D70616E792055524C207573656420696E20746865206170706C69636174696F6E0A
	#tag EndConstant

	#tag Constant, Name = gCopyrightYear, Type = String, Dynamic = False, Default = \"2025", Scope = Public, Description = 436F70797269676874207965617220666F7220746865206170706C69636174696F6E0A
	#tag EndConstant

	#tag Constant, Name = gErrorAnalysisFailed, Type = String, Dynamic = False, Default = \"Error: Failed to analyze the CSV file.", Scope = Public, Description = 4572726F72206D65737361676520666F7220616E616C79736973206661696C7572650A
	#tag EndConstant

	#tag Constant, Name = gErrorFileNotFound, Type = String, Dynamic = False, Default = \"Error: The specified CSV file was not found.", Scope = Public, Description = 4572726F72206D65737361676520666F722066696C65206E6F7420666F756E640A
	#tag EndConstant

	#tag Constant, Name = gErrorInvalidFile, Type = String, Dynamic = False, Default = \"Error: The specified file is not a valid CSV file.", Scope = Public, Description = 4572726F72206D65737361676520666F7220696E76616C6964204353562066696C650A
	#tag EndConstant

	#tag Constant, Name = gErrorOutputFailed, Type = String, Dynamic = False, Default = \"Error: Failed to write output file.", Scope = Public, Description = 4572726F72206D65737361676520666F72206F7574707574206661696C7572650A
	#tag EndConstant

	#tag Constant, Name = gFileExtensionCSV, Type = String, Dynamic = False, Default = \".csv", Scope = Public, Description = 46696C6520657874656E73696F6E20666F72204353562066696C65730A
	#tag EndConstant

	#tag Constant, Name = gFileExtensionJSON, Type = String, Dynamic = False, Default = \".json", Scope = Public, Description = 46696C6520657874656E73696F6E20666F72204A534F4E2066696C65730A
	#tag EndConstant

	#tag Constant, Name = gFileExtensionMarkdown, Type = String, Dynamic = False, Default = \".md", Scope = Public, Description = 46696C6520657874656E73696F6E20666F72204D61726B646F776E2066696C65730A
	#tag EndConstant

	#tag Constant, Name = gProcessingComplete, Type = String, Dynamic = False, Default = \"Processing complete.", Scope = Public, Description = 4D65737361676520646973706C61796564207768656E2070726F63657373696E6720697320636F6D706C6574650A
	#tag EndConstant

	#tag Constant, Name = gSuccessAnalysisComplete, Type = String, Dynamic = False, Default = \"Analysis completed successfully.", Scope = Public, Description = 53756363657373206D65737361676520666F7220636F6D706C6574656420616E616C797369730A
	#tag EndConstant

	#tag Constant, Name = gSuccessOutputCreated, Type = String, Dynamic = False, Default = \"Output file created successfully:", Scope = Public, Description = 53756363657373206D65737361676520666F72206F75747075742066696C652067656E65726174696F6E0A
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
