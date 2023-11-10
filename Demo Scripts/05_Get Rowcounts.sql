DROP TABLE IF EXISTS #helpExpandViewResults
CREATE TABLE #helpExpandViewResults
	(HierarchyLvl TINYINT,
	BaseObject_FullName NVARCHAR(256),
	Child_DBName NVARCHAR(128),
	Child_FullName NVARCHAR(256),
	ChildType CHAR(2),
	ObjectHierarchyID TINYINT,
	ParentObjectHierarchyID TINYINT
	)

/* run sp_helpExpandView for the main proc and store the results. Includes information for the related stored procedure */
INSERT INTO #helpExpandViewResults
(
    HierarchyLvl,
    BaseObject_FullName,
    Child_DBName,
    Child_FullName,
    ChildType,
    ObjectHierarchyID,
    ParentObjectHierarchyID
)
EXEC sp_helpExpandView @ViewName = '[demo].[sp_NightlyProcessingForReporting]', @OutputFormat = 'vertical'

/* get the partitions for the tables */
SELECT distinct
	OBJECT_SCHEMA_NAME(p.object_id) AS SchemaName,
	OBJECT_NAME(p.object_id) AS TableName,
	p.index_id,
	p.rows
FROM sys.partitions AS p
	JOIN #helpExpandViewResults AS results ON OBJECT_SCHEMA_NAME(p.object_id) + '.' + OBJECT_NAME(p.object_id) = results.Child_FullName
WHERE p.index_id <=1