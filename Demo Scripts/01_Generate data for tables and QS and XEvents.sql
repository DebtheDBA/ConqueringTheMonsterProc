/* run script for one night over one week */

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-01',
	@EndDate = '2023-01-02'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-02',
	@EndDate = '2023-01-03'
	
EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-03',
	@EndDate = '2023-01-04'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-04',
	@EndDate = '2023-01-05'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-05',
	@EndDate = '2023-01-06'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-06',
	@EndDate = '2023-01-07'

/* run script for one week over 7 weeks */

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-01',
	@EndDate = '2023-01-08'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-08',
	@EndDate = '2023-01-15'
	
EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-15',
	@EndDate = '2023-01-22'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-22',
	@EndDate = '2023-01-29'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-01-29',
	@EndDate = '2023-02-05'

EXEC demo.sp_NightlyProcessingForReporting 
	@StartDate = '2023-02-05',
	@EndDate = '2023-02-12'

