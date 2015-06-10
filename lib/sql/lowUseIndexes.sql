USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT top 100 SCHEMA_NAME(o.Schema_ID) AS schemaName
    ,OBJECT_NAME(s.[object_id]) AS tableName
    ,i.name AS indexName
    ,S.user_updates as updates
    ,S.user_seeks as userSeeks
    ,S.user_scans as userScans
    ,S.user_lookups as userLookups
    ,S.system_seeks as systemSeeks
    ,S.system_scans as systemScans
    ,S.system_lookups as systemLookups
    ,S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups as totalUsage
FROM    sys.dm_db_index_usage_stats s
    JOIN    sys.indexes i
        ON      s.[object_id] = i.[object_id]
            AND     s.index_id = i.index_id
    JOIN    sys.objects o
        ON      i.object_id = O.object_id
WHERE   s.database_id = DB_ID()
    AND     OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
    AND     S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups > 0
    AND     i.name IS NOT NULL
ORDER BY S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups ASC;