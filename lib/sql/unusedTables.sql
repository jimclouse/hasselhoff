USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


;WITH extra AS
(   -- Get info for FullText indexes, XML Indexes, etc
    SELECT  sit.[object_id],
            sit.[parent_id],
            ps.[index_id],
            SUM(ps.reserved_page_count) AS [reserved_page_count],
            SUM(ps.used_page_count) AS [used_page_count]
    FROM    sys.dm_db_partition_stats ps
    INNER JOIN  sys.internal_tables sit
            ON  sit.[object_id] = ps.[object_id]
    WHERE   sit.internal_type IN
               (202, 204, 207, 211, 212, 213, 214, 215, 216, 221, 222, 236)
    GROUP BY    sit.[object_id],
                sit.[parent_id],
                ps.[index_id]
),
agg AS
(   -- Get info for Tables, Indexed Views, etc (including "extra")
    SELECT  ps.[object_id] AS [ObjectID],
            ps.index_id AS [IndexID],
            SUM(ps.in_row_data_page_count) AS [InRowDataPageCount],
            SUM(ps.used_page_count) AS [UsedPageCount],
            SUM(ps.reserved_page_count) AS [ReservedPageCount],
            SUM(ps.row_count) AS [RowCount],
            SUM(ps.lob_used_page_count + ps.row_overflow_used_page_count)
                    AS [LobAndRowOverflowUsedPageCount]
    FROM    sys.dm_db_partition_stats ps
    GROUP BY    ps.[object_id],
                ps.[index_id]
    UNION ALL
    SELECT  ex.[parent_id] AS [ObjectID],
            ex.[object_id] AS [IndexID],
            0 AS [InRowDataPageCount],
            SUM(ex.used_page_count) AS [UsedPageCount],
            SUM(ex.reserved_page_count) AS [ReservedPageCount],
            0 AS [RowCount],
            0 AS [LobAndRowOverflowUsedPageCount]
    FROM    extra ex
    GROUP BY    ex.[parent_id],
                ex.[object_id]
),
spaceused AS
(
SELECT  agg.[ObjectID],
        OBJECT_SCHEMA_NAME(agg.[ObjectID]) AS [SchemaName],
        OBJECT_NAME(agg.[ObjectID]) AS [TableName],
        SUM(CASE
                WHEN (agg.IndexID < 2) THEN agg.[RowCount]
                ELSE 0
            END) AS [Rows],
        SUM(agg.ReservedPageCount) * 8 AS [ReservedKB],
        SUM(agg.LobAndRowOverflowUsedPageCount +
            CASE
                WHEN (agg.IndexID < 2) THEN (agg.InRowDataPageCount)
                ELSE 0
            END) * 8 AS [DataKB],
        SUM(agg.UsedPageCount - agg.LobAndRowOverflowUsedPageCount -
            CASE
                WHEN (agg.IndexID < 2) THEN agg.InRowDataPageCount
                ELSE 0
            END) * 8 AS [IndexKB],
        SUM(agg.ReservedPageCount - agg.UsedPageCount) * 8 AS [UnusedKB],
        SUM(agg.UsedPageCount) * 8 AS [UsedKB]
FROM    agg
GROUP BY    agg.[ObjectID],
            OBJECT_SCHEMA_NAME(agg.[ObjectID]),
            OBJECT_NAME(agg.[ObjectID])
),
CTE_ACCESS_DATES AS (
    select  o.object_id
            ,o.schema_id
            ,object_name(o.object_id) as tableName
            ,MAX(us.last_user_lookup) as lastUserLookup
            ,MAX(us.last_user_scan) as lastUserScan
            ,MAX(us.last_user_seek) as lastUserSeek
			,sp.ReservedKB
			,sp.rows
    from    sys.tables o
        left join sys.dm_db_index_usage_stats as us
            on  o.object_id = us.object_id
                and us.database_id =  DB_ID()
		left join spaceused sp on sp.ObjectID = o.object_id
    WHERE   o.type = 'U'
    group by o.schema_id, o.object_id, sp.ReservedKB, sp.rows
), CTE_MAX_ACCESS AS (
    SELECT  object_id
            ,MAX(U.accessDate) as lastAccessedDate
    FROM    CTE_ACCESS_DATES A
    UNPIVOT ( accessDate FOR n IN ( A.lastUserLookup, A.lastUserScan, A.lastUserSeek ) ) as U
    GROUP BY object_id
)

SELECT  SCHEMA_NAME(CAD.schema_id) AS schemaName
        ,CAD.tableName
        ,CMA.lastAccessedDate
        ,CAD.lastUserLookup
        ,CAD.lastUserScan
        ,CAD.lastUserSeek
		,CONVERT(DECIMAL(10,2),CAD.reservedKB / 1024.0) as reservedSizeMB
		,CAD.rows
FROM    CTE_ACCESS_DATES CAD
    LEFT JOIN   CTE_MAX_ACCESS CMA
        ON      CAD.object_id = CMA.object_id
ORDER BY CAD.tableName


