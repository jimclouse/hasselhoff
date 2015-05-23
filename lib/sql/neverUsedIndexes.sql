USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  SCHEMA_NAME(O.Schema_ID) AS schemaName
        ,OBJECT_NAME(I.object_id) AS tableName
        ,I.NAME AS indexName
FROM    sys.indexes I 
    JOIN    sys.objects O
        ON      I.object_id = O.object_id
LEFT JOIN   sys.dm_db_index_usage_stats S 
        ON      S.object_id = I.object_id
            AND     I.index_id = S.index_id
WHERE   OBJECTPROPERTY(O.object_id,'IsMsShipped') = 0
    AND     I.name IS NOT NULL
    AND     S.object_id IS NULL

ORDER BY SchemaName, TableName, IndexName;
