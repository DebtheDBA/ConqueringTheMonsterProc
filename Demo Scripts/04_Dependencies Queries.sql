/* EXEC Demo.sp_NightlyProcessingForReporting @StartDate = getdate() */

/* confirm the object information*/
SELECT * FROM sys.objects 
WHERE OBJECT_ID = OBJECT_ID(N'demo.sp_NightlyProcessingForReporting')

/* Look at sys.dependencies for everything but procs */
SELECT d.object_id,
       OBJECT_SCHEMA_NAME(d.object_id) + '.' + OBJECT_NAME(d.object_id) AS SchemaObject,
	   d.column_id,
       d.referenced_major_id,
	   OBJECT_SCHEMA_NAME(d.referenced_major_id) + '.' + OBJECT_NAME(d.referenced_major_id) AS ReferencedSchemaObject,
       referenced_minor_id,
	   c.name AS ReferencedcolumnName,
       d.is_selected,
       d.is_updated,
       d.is_select_all 
FROM sys.sql_dependencies AS d
	LEFT JOIN sys.columns AS c ON c.column_id = d.referenced_minor_id AND c.object_id = d.referenced_major_id
WHERE d.OBJECT_ID = OBJECT_ID(N'demo.sp_NightlyProcessingForReporting')


/* find nested view information 
https://github.com/SQLBek/sp_helpExpandView
*/

/* run sp_helpExpandView for the main proc. Includes information for the related stored procedure */
EXEC sp_helpExpandView @ViewName = '[demo].[sp_NightlyProcessingForReporting]', @OutputFormat = 'horizontal'


/* run sp_helpExpandView for the main proc. Includes information for the related stored procedure */
EXEC sp_helpExpandView @ViewName = '[demo].[sp_NightlyProcessingForReporting]', @OutputFormat = 'vertical'
