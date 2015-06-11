USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  I.name as indexName
        ,S.user_seeks as userSeeks
        ,S.user_scans as userScans
        ,S.user_lookups as userLookups
        ,S.user_updates as userUpdates
        ,S.last_user_seek as lastUserSeek
        ,S.last_user_scan as lastUserScan
        ,S.last_user_lookup as lastUserLookup
        ,S.last_user_update as lastUserUpdate
        ,S.system_seeks as systemSeeks
        ,S.system_scans as systemScans
        ,S.system_lookups as systemLookups
        ,S.system_seeks + s.system_scans + s.system_lookups + S.user_seeks + S.user_scans + S.user_lookups as totalUsage 
        ,8 * SUM(a.used_pages) AS indexSizeKb
FROM    sys.dm_db_index_usage_stats s
    JOIN    sys.indexes i
        ON      s.[object_id] = i.[object_id]
            AND     s.index_id = i.index_id
    JOIN    sys.objects o
        ON      i.object_id = O.object_id
    LEFT JOIN sys.partitions AS p 
        ON      p.OBJECT_ID = i.OBJECT_ID
            AND     p.index_id = i.index_id
    LEFT JOIN sys.allocation_units AS a 
        ON      a.container_id = p.partition_id
WHERE   s.database_id = DB_ID()
    AND     OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
    AND     O.object_id = object_id('{{tableName}}')
GROUP BY I.name, S.user_seeks, S.user_scans ,S.user_lookups ,S.user_updates ,S.last_user_seek ,S.last_user_scan ,S.last_user_lookup ,S.last_user_update ,S.system_seeks ,S.system_scans ,S.system_lookups
ORDER BY    I.name;

