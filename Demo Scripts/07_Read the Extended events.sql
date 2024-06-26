--SELECT *, CAST(event_data AS XML) AS EventDataXML 
--FROM sys.fn_xe_file_target_read_file('C:\GitRepo\ConqueringtheMonsterProc\ExtendedEvents\*.xel', null, null, null)

DECLARE @EventFileTarget NVARCHAR(400) = 'C:\GitRepo\ConqueringtheMonsterProc\ExtendedEvents\*.xel'

/* https://www.sqlshack.com/using-sql-server-extended-events-to-monitor-query-performance/ */


SELECT n.value( '(@name)[1]', 'varchar(50)' ) AS event_name, 
	n.value( '(@package)[1]', 'varchar(50)' ) AS package_name, 
	n.value( '(@timestamp)[1]', 'datetime2' ) AS [utc_timestamp], 
	n.value( '(action[@name="database_id"]/value)[1]', 'bigint' ) AS database_id,
	DB_NAME(n.value( '(action[@name="database_id"]/value)[1]', 'bigint' )) AS database_name,
	n.value( '(data[@name="object_name"]/value)[1]', 'nvarchar(max)' ) AS objectname,
	n.value( '(data[@name="statement"]/value)[1]', 'nvarchar(max)' ) AS sql_text,
	n.value( '(data[@name="physical_reads"]/value)[1]', 'bigint' ) AS physical_reads, 
	n.value( '(data[@name="logical_reads"]/value)[1]', 'bigint' ) AS logical_reads, 
	n.value( '(data[@name="writes"]/value)[1]', 'bigint' ) AS writes, 
	n.value( '(data[@name="row_count"]/value)[1]', 'bigint' ) AS row_count, 
	n.value( '(data[@name="cpu_time"]/value)[1]', 'bigint' ) AS cpu_time, 
	n.value( '(data[@name="duration"]/value)[1]', 'bigint' ) / 1000 AS duration_ms, 
	n.value( '(action[@name="transaction_id"]/value)[1]', 'bigint' ) AS transaction_id, 
	n.value( '(action[@name="request_id"]/value)[1]', 'bigint' ) AS request_id
FROM
        (
            SELECT CAST(event_data AS XML) AS event_data
            FROM sys.fn_xe_file_target_read_file( @EventFileTarget, NULL, NULL, NULL )
        ) AS ed
        CROSS APPLY
        ed.event_data.nodes( 'event' ) AS q(n)
WHERE n.value( '(@timestamp)[1]', 'datetime2' ) > '2024-06-01'
GO




DECLARE @EventFileTarget NVARCHAR(400) = 'C:\GitRepo\ConqueringtheMonsterProc\ExtendedEvents\*.xel'


SELECT TOP 10
	n.value( '(@name)[1]', 'varchar(50)' ) AS event_name, 
	n.value( '(@package)[1]', 'varchar(50)' ) AS package_name, 
	n.value( '(@timestamp)[1]', 'datetime2' ) AS [utc_timestamp], 
	n.value( '(action[@name="database_id"]/value)[1]', 'bigint' ) AS database_id,
	DB_NAME(n.value( '(action[@name="database_id"]/value)[1]', 'bigint' )) AS database_name,
	n.value( '(data[@name="object_name"]/value)[1]', 'nvarchar(max)' ) AS objectname,
	n.value( '(data[@name="statement"]/value)[1]', 'nvarchar(max)' ) AS sql_text,
	n.value( '(data[@name="physical_reads"]/value)[1]', 'bigint' ) AS physical_reads, 
	n.value( '(data[@name="logical_reads"]/value)[1]', 'bigint' ) AS logical_reads, 
	n.value( '(data[@name="writes"]/value)[1]', 'bigint' ) AS writes, 
	n.value( '(data[@name="row_count"]/value)[1]', 'bigint' ) AS row_count, 
	n.value( '(data[@name="cpu_time"]/value)[1]', 'bigint' ) AS cpu_time, 
	n.value( '(data[@name="duration"]/value)[1]', 'bigint' ) / 1000 AS duration_ms, 
	n.value( '(action[@name="transaction_id"]/value)[1]', 'bigint' ) AS transaction_id, 
	n.value( '(action[@name="request_id"]/value)[1]', 'bigint' ) AS request_id
FROM
        (
            SELECT CAST(event_data AS XML) AS event_data
            FROM sys.fn_xe_file_target_read_file( @EventFileTarget, NULL, NULL, NULL )
        ) AS ed
        CROSS APPLY
        ed.event_data.nodes( 'event' ) AS q(n)
WHERE n.value( '(@timestamp)[1]', 'datetime2' ) > '2024-06-01'
AND n.value( '(@name)[1]', 'varchar(50)' ) = 'sp_statement_completed'
ORDER BY n.value( '(data[@name="duration"]/value)[1]', 'bigint' ) / 1000 DESC

GO