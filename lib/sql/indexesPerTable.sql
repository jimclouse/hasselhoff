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
        ,SUM(a.used_pages) AS pages
        ,COALESCE((SELECT STUFF(
            (select ', ' + c.name
            from     sys.index_columns as k
                join     sys.columns c
                    on      k.column_id = c.column_id
                        and     c.object_id = k.object_id
            where   k.object_id = i.object_id
                and     k.index_id = i.index_id
                and     k.is_included_column = 0
            order by k.key_ordinal, k.column_id
            for xml path(''))
            , 1, 2, '')),'') as keyColumns
        ,COALESCE((SELECT STUFF(
            (select ', ' + c.name
            from     sys.index_columns as k
                join     sys.columns c
                    on      k.column_id = c.column_id
                        and     c.object_id = k.object_id
            where   k.object_id = i.object_id
                and     k.index_id = i.index_id
                and     is_included_column = 1
            order by k.column_id
            for xml path(''))
            , 1, 2, '')),'') as includes
FROM   sys.indexes i
    JOIN    sys.objects o
        ON      i.object_id = O.object_id
    LEFT JOIN
         sys.dm_db_index_usage_stats s
        ON      s.[object_id] = i.[object_id]
            AND     s.index_id = i.index_id
            AND     s.database_id = DB_ID()
    LEFT JOIN sys.partitions AS p
        ON      p.OBJECT_ID = i.OBJECT_ID
            AND     p.index_id = i.index_id
    LEFT JOIN sys.allocation_units AS a
        ON      a.container_id = p.partition_id
WHERE  OBJECTPROPERTY(O.[object_id], 'IsMsShipped') = 0
    AND     O.object_id = object_id('{{schemaName}}.{{tableName}}')

GROUP BY i.object_id, I.name, i.index_id, S.user_seeks, S.user_scans ,S.user_lookups ,S.user_updates ,S.last_user_seek ,S.last_user_scan ,S.last_user_lookup ,S.last_user_update ,S.system_seeks ,S.system_scans ,S.system_lookups
ORDER BY    I.name;


