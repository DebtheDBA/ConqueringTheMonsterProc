/* Check for main proc */
EXEC DBA.dbo.sp_QuickieStore
    @database_name = 'AutoDealershipDemo_Summit2023',
	@procedure_schema =  'demo',
	@procedure_name = 'sp_NightlyProcessingForReporting',
	@execution_type_desc = 'Regular';


/* check for proc called inside main proc */
EXEC DBA.dbo.sp_QuickieStore
    @database_name = 'AutoDealershipDemo_Summit2023',
	@procedure_schema =  'demo',
	@procedure_name = 'sp_SearchAllSoldInventory',
	@execution_type_desc = 'Regular';
	
	