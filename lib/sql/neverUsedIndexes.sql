USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  SCHEMA_NAME(O.Schema_ID) AS schemaName
        ,OBJECT_NAME(I.object_id) AS tableName
        ,I.NAME AS indexName
        ,S.user_updates as updates
        ,S.user_seeks as userSeeks
        ,S.user_scans as userScans
        ,S.user_lookups as userLookups
        ,S.system_seeks as systemSeeks
        ,S.system_scans as systemScans
        ,S.system_lookups as systemLookups
        ,S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups as totalUsage
		,spaceUsage.[indexSizeMb]
FROM    sys.indexes I
    JOIN    sys.objects O
        ON      I.object_id = O.object_id
LEFT JOIN   sys.dm_db_index_usage_stats S
        ON      S.object_id = I.object_id
            AND     I.index_id = S.index_id
OUTER APPLY(
select
    ROUND(8 * SUM(allocation_units.used_pages) / 1024.0, 2) AS [indexSizeMb]
    ,SUM(allocation_units.used_pages) AS [# Pages]
from
    sys.partitions as partitions
    left join sys.allocation_units as allocation_units on allocation_units.container_id = partitions.partition_id
where
    partitions.OBJECT_ID = O.object_id
    and partitions.index_id = S.index_id
) as spaceUsage
WHERE   OBJECTPROPERTY(O.object_id,'IsMsShipped') = 0
    AND     I.name IS NOT NULL
    AND     (S.object_id IS NULL OR (S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups)  = 0 )
ORDER BY [indexSizeMb] DESC, S.user_updates desc, SchemaName, TableName, IndexName;