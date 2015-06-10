USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  SCHEMA_NAME(O.Schema_ID) AS schemaName
        ,OBJECT_NAME(I.object_id) AS tableName
        ,I.NAME AS indexName
        ,S.user_updates as updates
        ,S.system_seeks as seeks
        ,S.system_scans as scans
        ,S.system_lookups as lookups
        ,S.system_seeks + s.system_scans + s.system_lookups as totalUsage
FROM    sys.indexes I 
    JOIN    sys.objects O
        ON      I.object_id = O.object_id
LEFT JOIN   sys.dm_db_index_usage_stats S 
        ON      S.object_id = I.object_id
            AND     I.index_id = S.index_id
WHERE   OBJECTPROPERTY(O.object_id,'IsMsShipped') = 0
    AND     I.name IS NOT NULL
    AND     (S.object_id IS NULL OR (s.system_seeks + s.system_scans + s.system_lookups)  = 0 )
ORDER BY S.user_updates desc, SchemaName, TableName, IndexName;