'#######################################################################################################################
'Script Description		: Databaes Business Components
'Test Tool/Version		: HP Quick Test Professional 11+
'Test Tool Settings		: N.A.
'Application Automated	: Putty
'Author					: Cognizant
'Date Created			: 25/06/2015
'#######################################################################################################################
Option Explicit	'Forcing Variable declarations

'#######################################################################################################################
'Function Description   : Function to Execute the Database Query
'Entry Point			: Required Database Access		
'Exit Point				: Query Execution 
'Input Parameters 		: None
'Return Value    		: None
'Author					: Cognizant
'Date Created			: 25/06/2015
'Status					: Completed
'#######################################################################################################################

Sub ExecuteDatabase()
	
	'============================= INPUT VALUES ==========================================================
	
	'Variable Declaration
	Dim strTNSConnectionName,strUserName,strPassword,strQuery, strReturnedValue, strExpectedValue,intTotalCommands,intCommandNo,strTestCaseName,strIteration,strCommandType, strParsed_Value_LogFile,strSplit_Start,strSplit_End
	
	strTNSConnectionName=gobjDataTable.GetData("DBCommand", "DBIPAddress")
	strUserName= gobjDataTable.GetData("DBCommand", "DBUserName")
	strPassword= gobjDataTable.GetData("DBCommand", "DBPassword")
	intTotalCommands=gobjDataTable.GetData("DBCommand", "intTotalCommand")	
	strTestCaseName=gobjDataTable.GetData("DBCommand", "TC_ID")
	strIteration=gobjDataTable.GetData("DBCommand", "Iteration")
	
	gobjReport.UpdateTestLog "DataBase Details", " DataBase :  " & strTNSConnectionName & " User Name : " &  strUserName & " Password : " & strPassword ,"Done"
	
	'============================= INPUT VALUES - END ====================================================

	'Executing all the DB commands for the test case
	
	For intCommandNo = 1 To intTotalCommands
		
		gobjDataTable.SetCurrentRow strTestCaseName,strIteration,intCommandNo
		strQuery=gobjDataTable.GetData("DBCommand", "strQuery")
		strExpectedValue=gobjDataTable.GetData("DBCommand", "strExpectedResult")
		strCommandType=gobjDataTable.GetData("DBCommand", "strCommandType")
		strSplit_Start=gobjDataTable.GetData("DBCommand", "strStart_Tag")
		strSplit_End=gobjDataTable.GetData("DBCommand", "strEnd_Tag")
		
				
		Select case Ucase(strCommandType)
		
			Case "DELETE"
			
				strReturnedValue=DeleteQueryExecution(strTNSConnectionName,strUserName,strPassword,strQuery)
	
				If Trim(strReturnedValue)="" Then
				
					gobjReport.UpdateTestLog "DataBase", "Error In Executing the Delete Query: " & strQuery ,"Fail"
					
				Else
				
					gobjReport.UpdateTestLog "DataBase", strReturnedValue & " Records deleted for the Query " & strQuery , "Pass"
	
				End if
			
			
			Case "SELECT"
			
				strReturnedValue=SelectQueryExecution(strTNSConnectionName,strUserName,strPassword,strQuery)
		
				If Trim(strReturnedValue)="" Then
				
					gobjReport.UpdateTestLog "DataBase", "Error In Executing the Query" & strQuery, "Fail"
					
				Else
	
					If Trim(ucase(strExpectedValue))=Trim(ucase(strReturnedValue)) Then
					
						gobjReport.UpdateTestLog "DataBase", "Expected Value(" & strExpectedValue & ") is matched with Database Returned Value(" & strReturnedValue & ")", "Pass"
						
					Else
					
						gobjReport.UpdateTestLog "DataBase", "Expected Value(" & strExpectedValue & ") is not matched with Database Returned Value(" & strReturnedValue & ")", "Fail"
						
					End If
					
		
					
				End If
				
			Case "BATCHSTATUS"
			
				strParsed_Value_LogFile = Parse_LogFile(strSplit_Start,strSplit_End)
				
				If Trim(strParsed_Value_LogFile)="" Then
				
					gobjReport.UpdateTestLog "Log File Parsing", "Error In Parsing the Log File with Start and End Tags : " & strSplit_Start & " And " & strSplit_End, "Fail"
					
				Else
				
					'Replace the input variable of the query with dynamic value
					strQuery=Replace(strQuery,"InputVariable",strParsed_Value_LogFile)
					'Waiting for database to upload data
					wait(30)
					strReturnedValue=SelectQueryExecution(strTNSConnectionName,strUserName,strPassword,strQuery)

		
					If Trim(strReturnedValue)="" Then
					
						gobjReport.UpdateTestLog "DataBase", "Error In Executing the Query" & strQuery, "Fail"
						
					Else
					
															
						If Trim(ucase(strExpectedValue))=Trim(ucase(strReturnedValue)) Then
						
							gobjReport.UpdateTestLog "DataBase", "All the Batch Steps are completed. All the Steps are completed for JOB Execution ID  " & strParsed_Value_LogFile, "Pass"
							
						Else
						
							gobjReport.UpdateTestLog "DataBase","All the Batch Steps are not completed. Verify JOB Execution ID  " & strParsed_Value_LogFile, "Fail"
							
						End If
		
						
					End If
					
				
				End if
			
			Case "STOREDPROCEDURE"
			
				StoredProcedureExecution strTNSConnectionName,strUserName,strPassword,strQuery
				
		
		End Select 
		

		
	Next

	
	
End Sub
'###################################################################################################################

'#######################################################################################################################
'Function Description   : Function to execute the Delete Query 
'Entry Point			: Required Database Access		
'Exit Point				: Query Execution
'Input Parameters 		: strTNSConnectionName,strUserName,strPassword,strQuery
'Return Value    		: Number of Rows Deleted
'Author					: Cognizant
'Date Created			: 25/06/2015
'Status					: Completed
'#######################################################################################################################
Function DeleteQueryExecution(strTNSConnectionName,strUserName,strPassword,strQuery)
	
	On Error Resume Next
	
	Dim g_objConn,objCMD,objRS, strReturnValue,lngRecAffected,adCmdText

	strReturnValue=""
	
	Set g_objConn = CreateObject("ADODB.Connection")
	
	g_objConn.Open "Provider=OraOLEDB.Oracle;Data Source=" + strTNSConnectionName + ";User ID=" + strUserName + ";Password=" + strPassword
	
	g_objConn.Execute strQuery,lngRecAffected, adCmdText

	If Err.Description <> "" Then
		DeleteQueryExecution=""	
		gobjReport.UpdateTestLog "Query Execution", strQuery & " Error Occured: " & Err.Description, "Fail"		
	Else
		gobjReport.UpdateTestLog "DataBase", "Query Executed Successfully: " & strQuery, "Pass"
		DeleteQueryExecution=lngRecAffected
	End If
	
	g_objConn.Close
	
	Set g_objConn = nothing
	
	
End Function
'#######################################################################################################################


'#######################################################################################################################
'Function Description   : Function to execute the Select Query 
'Entry Point			: Required Database Access		
'Exit Point				: Query Execution
'Input Parameters 		: strTNSConnectionName,strUserName,strPassword,strQuery
'Return Value    		: Recordset Value
'Author					: Cognizant
'Date Created			: 25/06/2015
'Status					: Completed
'#######################################################################################################################

Function SelectQueryExecution(strTNSConnectionName,strUserName,strPassword,strQuery)
		
	Dim g_objConn,objCMD,objRS, strReturnValue

	strReturnValue=""
	
	Set g_objConn = CreateObject("ADODB.Connection")
	
	g_objConn.Open "Provider=OraOLEDB.Oracle;Data Source=" + strTNSConnectionName + ";User ID=" + strUserName + ";Password=" + strPassword
	
	
	Set objCMD = CreateObject("ADODB.Command")
	Set objRS  = CreateObject("ADODB.Recordset")
	
	objCMD.ActiveConnection = g_objConn
	objCMD.CommandText = strQuery
	objRS.Open objCMD
	
	objRS.movefirst
	
	Do While Not objRS.EOF
		strReturnValue=strReturnValue & objRS.Fields(0).Value & "#"
		objRS.movenext
	Loop
	
	If Err.Description <> "" Then
		SelectQueryExecution=""	
		gobjReport.UpdateTestLog "Query Execution", "Error Occured: " & Err.Description, "Fail"
	Else
		gobjReport.UpdateTestLog "DataBase", "Query Executed Successfully: " & strQuery, "Pass"
		SelectQueryExecution=strReturnValue
	End If
	
	
	'Clean up
	objRS.Close
	
	set objRS = Nothing
	set objCMD= Nothing
	
	Set g_objConn = nothing

End Function
'#######################################################################################################################

'#######################################################################################################################
'Function Description   : Function to parse the log file for getting the result
'Entry Point			: Putty Log file availabity	
'Exit Point				: Parsed Result
'Input Parameters 		: strSplit_Start,strSplit_End
'Return Value    		: Parsed Result
'Author					: Cognizant
'Date Created			: 25/06/2015
'Status					: Completed
'#######################################################################################################################

Function Parse_LogFile(strSplit_Start,strSplit_End)
	
	Dim fso,logfile,strLogPath,strFileContent,strSplitByStartTag, strSplitByEndTag

	strLogPath="C:\Users\" & Environment.Value("UserName") & "\putty.log"
		
	Set fso=createobject("Scripting.FileSystemObject")
	
	If fso.FileExists(strLogPath) Then	
	
		Set logfile=fso.OpenTextFile(strLogPath,1,True)
		
		'Read  the entire contents of  priously written file 
		strFileContent=logfile.ReadAll
		
		If instr(strFileContent,strSplit_Start)  And instr(strFileContent,strSplit_End)  Then
			
			strSplitByStartTag=Split(strFileContent,strSplit_Start)
			strSplitByEndTag=Split(strSplitByStartTag(Ubound(strSplitByStartTag)),strSplit_End)
			Parse_LogFile=strSplitByEndTag(0)
			
		Else
			
			gobjReport.UpdateTestLog "Parsing Log File","Invalid Start and End tags are specified for Parsing:" & strSplit_Start & " And " & strSplit_End, "Fail"
			Parse_LogFile=""
			
		End If
			
		
	Else
			
		gobjReport.UpdateTestLog "Parsing Log File", "Log file is not available at " & strLogPath, "Fail"
		Parse_LogFile=""
			
	End if
		
		
		
	'Close the files
	logfile.Close
	
	'Release the allocated objects
	Set logfile=nothing
	
End Function
	

'#######################################################################################################################


'#######################################################################################################################
'Function Description   : Function to Execute the stored Procedure
'Entry Point			: Required Database Access	
'Exit Point				: Shored Procedure Execution
'Input Parameters 		: strTNSConnectionName,strUserName,strPassword,strQuery
'Return Value    		: Nil
'Author					: Cognizant
'Date Created			: 25/06/2015
'Status					: Completed
'#######################################################################################################################

Sub StoredProcedureExecution(strTNSConnectionName,strUserName,strPassword,strStoredProcedureName)
	
	Dim g_objConn,objCMD
	
	Set g_objConn = CreateObject("ADODB.Connection")

	g_objConn.Open "Provider=OraOLEDB.Oracle;Data Source=" + strTNSConnectionName + ";User ID=" + strUserName + ";Password=" + strPassword
	
	Set objCMD = CreateObject("ADODB.Command")

	
	objCMD.CommandText = strStoredProcedureName
	objCMD.CommandType = 4
	objCMD.ActiveConnection = g_objConn
	objCMD.Execute
	
	If Err.Description <> "" Then
		
		gobjReport.UpdateTestLog "Stored Procedure" ,"Error occured while executing the Stored Procedure: " & strStoredProcedureName & " . Error Description: " & Err.Description, "Fail"
	
	Else
	
		gobjReport.UpdateTestLog "Stored Procedure" , "Stored Procedure : " & strStoredProcedureName & " Executed Successfully", "Pass"
		
	End If

	set objCMD= Nothing
	
	Set g_objConn = nothing


End sub
'#######################################################################################################################