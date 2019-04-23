
	Set strMyTable = Browser("Columbus").Page("Columbus").WebTable("TblEditParameter_ParameterPlanValue")
	intRwCnt = strMyTable.RowCount          
	'intColCnt = strMyTable.ColumnCount(1)
	
	    For i= intRwCnt To 1 Step -1
	        'Paramnam = strMyTable.GetCellData(i,1)
	        strMyTable.ChildItem(i,1,"WebElement",0).click              
	        Exit For 
	    Next 
