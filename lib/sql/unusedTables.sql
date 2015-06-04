USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH CTE_ACCESS_DATES AS (
    select  o.object_id
            ,o.schema_id
            ,object_name(o.object_id) as tableName
            ,MAX(us.last_user_lookup) as lastUserLookup
            ,MAX(us.last_user_scan) as lastUserScan
            ,MAX(us.last_user_seek) as lastUserSeek
    from    sys.tables o
        left join sys.dm_db_index_usage_stats as us 
            on  o.object_id = us.object_id
                and us.database_id =  DB_ID()

    WHERE   o.type = 'U'
    group by o.schema_id, o.object_id
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
FROM    CTE_ACCESS_DATES CAD
    LEFT JOIN   CTE_MAX_ACCESS CMA
        ON      CAD.object_id = CMA.object_id
ORDER BY CAD.tableName


