USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT top 100 SCHEMA_NAME(o.Schema_ID) AS schemaName
    ,OBJECT_NAME(s.[object_id]) AS tableName
    ,i.name AS indexName
    ,s.user_updates as updates
    ,s.system_seeks as seeks
    ,s.system_scans as scans
    ,s.system_lookups as lookups
    ,s.system_seeks + s.system_scans + s.system_lookups as totalUsage
FROM    sys.dm_db_index_usage_stats s
    JOIN    sys.indexes i
        ON      s.[object_id] = i.[object_id]
            AND     s.index_id = i.index_id
    JOIN    sys.objects o
        ON      i.object_id = O.object_id
WHERE   s.database_id = DB_ID()
    AND     OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
    AND s.user_seeks = 0
    AND s.user_scans = 0
    AND s.user_lookups = 0
    AND i.name IS NOT NULL
ORDER BY s.user_updates DESC;