SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE {{database}};

SELECT  TOP 50
        ROUND(s.avg_total_user_cost *
            s.avg_user_impact
                    * (s.user_seeks + s.user_scans),0)
                                    AS cost
        ,d.[statement] as statement
        ,equality_columns equality
        ,inequality_columns inequality
        ,included_columns included
FROM    sys.dm_db_missing_index_groups g
    JOIN    sys.dm_db_missing_index_group_stats s
        ON      s.group_handle = g.index_group_handle
    JOIN    sys.dm_db_missing_index_details d
        ON      d.index_handle = g.index_handle
ORDER BY    cost DESC;