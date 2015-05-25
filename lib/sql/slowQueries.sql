SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT TOP 50   CAST(qs.total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS totalDuration
                ,CAST(qs.total_worker_time * 100.0 / qs.total_elapsed_time AS DECIMAL(28, 2)) AS pctCpu
                ,CAST((qs.total_elapsed_time - qs.total_worker_time)* 100.0 / qs.total_elapsed_time AS DECIMAL(28, 2)) AS pctWaiting
                ,qs.execution_count as execCount
                ,CAST(qs.total_elapsed_time / 1000000.0 / qs.execution_count AS DECIMAL(28, 2)) AS avgDuration
                ,SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1, ((CASE WHEN qs.statement_end_offset = -1 
                    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                    ELSE qs.statement_end_offset
                    END - qs.statement_start_offset)/2) + 1) AS individualQuery
                ,qt.text AS parentQuery
                ,qp.query_plan as queryPlan
FROM    sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
    CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
WHERE   qs.total_elapsed_time > 0
    AND     qp.dbid = DB_ID(N'{{database}}')
ORDER BY    qs.total_elapsed_time DESC;